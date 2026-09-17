___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "UTM Normalizer",
  "description": "Returns the complete page_location, normalizes utm_source for Google Analytics 4 or HubSpot, and renames additional custom UTM parameters.",
  "categories": [
    "ANALYTICS",
    "ATTRIBUTION",
    "UTILITY"
  ],
  "metadata": {
    "author": {
      "name": "stefano-ghisoni",
      "url": "https://stefanoghisoni.it",
      "email": "info@stefanoghisoni.it"
    }
  },
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "pageLocation",
    "displayName": "Original Page Location",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Select the variable containing the complete URL, such as {{Page URL}} or your page_location variable.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "useCustomSourceParameter",
    "checkboxText": "Use custom UTM naming",
    "simpleValueType": true,
    "defaultValue": false,
    "alwaysInSummary": true,
    "help": "Enable this option when the source parameter in the URL is not named utm_source. The template will read it and return it as the standard utm_source parameter.",
    "subParams": [
      {
        "type": "TEXT",
        "name": "customSourceParameter",
        "displayName": "Custom source parameter name",
        "simpleValueType": true,
        "valueHint": "Example: data_src",
        "help": "Enter only the parameter name to read from the Page URL, without ?, & or =. In the returned URL, this parameter will be renamed to utm_source.",
        "enablingConditions": [
          {
            "paramName": "useCustomSourceParameter",
            "paramValue": true,
            "type": "EQUALS"
          }
        ],
        "valueValidators": [
          {
            "type": "NON_EMPTY",
            "errorMessage": "Enter the custom source parameter name."
          },
          {
            "type": "REGEX",
            "args": [
              "^[A-Za-z0-9_.~-]+$"
            ],
            "errorMessage": "Use only letters, numbers, hyphens, underscores, periods or tildes; do not enter ?, & or =."
          }
        ]
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "additionalUtmGroup",
    "displayName": "Additional custom UTMs",
    "groupStyle": "ZIPPY_CLOSED",
    "help": "Add mappings between parameters found in the URL and the standard names to return. Example: rename utm_traffic to utm_medium while preserving its value.",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "additionalUtmMappings",
        "displayName": "",
        "newRowButtonText": "Add parameter",
        "simpleTableColumns": [
          {
            "type": "TEXT",
            "name": "inputName",
            "displayName": "Input parameter name",
            "defaultValue": "",
            "isUnique": true,
            "valueValidators": [
              {
                "type": "NON_EMPTY",
                "errorMessage": "Enter the parameter name to identify."
              },
              {
                "type": "REGEX",
                "args": [
                  "^[A-Za-z0-9_.~-]+$"
                ],
                "errorMessage": "Use only letters, numbers, hyphens, underscores, periods or tildes."
              }
            ]
          },
          {
            "type": "TEXT",
            "name": "outputName",
            "displayName": "Output parameter name",
            "defaultValue": "",
            "isUnique": true,
            "valueValidators": [
              {
                "type": "NON_EMPTY",
                "errorMessage": "Enter the standard parameter name to return."
              },
              {
                "type": "REGEX",
                "args": [
                  "^[A-Za-z0-9_.~-]+$"
                ],
                "errorMessage": "Use only letters, numbers, hyphens, underscores, periods or tildes."
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "destination",
    "displayName": "Destination platform",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "ga4",
        "displayValue": "Google Analytics 4"
      },
      {
        "value": "hubspot",
        "displayValue": "HubSpot"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "ga4",
    "alwaysInSummary": true,
    "help": "GA4 preserves the recognized social source. HubSpot groups all supported Meta sources under utm_source=Meta."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

/*
 * Normalizes utm_source and renames any configured custom UTM parameters.
 * When a custom source name is configured, the template reads that parameter
 * and returns it under the standard utm_source name, removing duplicates.
 * The rest of the URL is returned in the same order without reconstruction:
 * protocol, host, path, unrelated parameters and fragment remain unchanged.
 */

const input = data.pageLocation;

if (input === undefined || input === null || input === '') {
  return input;
}

const url = '' + input;
const useCustomSourceParameter =
  data.useCustomSourceParameter === true && data.customSourceParameter;
const sourceParameter =
  useCustomSourceParameter
    ? ('' + data.customSourceParameter).toLowerCase()
    : 'utm_source';
const questionMark = url.indexOf('?');

if (questionMark < 0) {
  return url;
}

const hashPosition = url.indexOf('#', questionMark);
const beforeQuery = url.substring(0, questionMark + 1);
const query = hashPosition < 0
  ? url.substring(questionMark + 1)
  : url.substring(questionMark + 1, hashPosition);
const fragment = hashPosition < 0 ? '' : url.substring(hashPosition);

if (!query) {
  return url;
}

function ga4Source(source) {
  if (source === 'fb') return 'facebook';
  if (source === 'ig') return 'instagram';
  if (source === 'msg') return 'messenger';
  if (source === 'ws') return 'whatsapp';

  /*
   * Threads and Audience Network are not listed as standalone sources in GA4's
   * social source categories. Mapping them to Facebook keeps them within the
   * default social classification.
   */
  if (source === 'th' || source === 'an') return 'facebook';

  return '';
}

function normalizedSource(source) {
  const lowerSource = source.toLowerCase();

  if (data.destination === 'hubspot') {
    if (
      lowerSource === 'fb' ||
      lowerSource === 'ig' ||
      lowerSource === 'th' ||
      lowerSource === 'msg' ||
      lowerSource === 'ws' ||
      lowerSource === 'an'
    ) {
      return 'Meta';
    }
    return '';
  }

  return ga4Source(lowerSource);
}

const parameters = query.split('&');
const additionalMappings = data.additionalUtmMappings || [];
const transformed = [];
const deduplicatedTargets = {};
let changed = false;

/*
 * Each parameter becomes a structured item. Configured renames take priority
 * over standard parameters already present in the URL: data_src overrides an
 * existing utm_source and, similarly, utm_traffic overrides an existing
 * utm_medium.
 */
for (let i = 0; i < parameters.length; i++) {
  const parameter = parameters[i];
  const equalsPosition = parameter.indexOf('=');
  const hasEquals = equalsPosition >= 0;
  const rawName = hasEquals
    ? parameter.substring(0, equalsPosition)
    : parameter;
  const rawValue = hasEquals
    ? parameter.substring(equalsPosition + 1)
    : '';
  const lowerName = rawName.toLowerCase();

  let outputName = rawName;
  let outputValue = rawValue;
  let priority = 0;
  let mapped = false;

  if (lowerName === sourceParameter) {
    const normalized = normalizedSource(rawValue);

    if (useCustomSourceParameter || normalized) {
      outputName = 'utm_source';
      outputValue = normalized || rawValue;
      priority = 2;
      mapped = true;
    }
  } else {
    for (let j = 0; j < additionalMappings.length; j++) {
      const mapping = additionalMappings[j];
      const inputName = mapping && mapping.inputName
        ? ('' + mapping.inputName).toLowerCase()
        : '';
      const configuredOutput = mapping && mapping.outputName
        ? '' + mapping.outputName
        : '';

      if (inputName && configuredOutput && lowerName === inputName) {
        outputName = configuredOutput;
        priority = 1;
        mapped = true;
        break;
      }
    }
  }

  if (mapped) {
    deduplicatedTargets[outputName.toLowerCase()] = true;
  }

  if (outputName !== rawName || outputValue !== rawValue) {
    changed = true;
  }

  transformed.push({
    name: outputName,
    value: outputValue,
    hasEquals: hasEquals || mapped,
    priority: priority
  });
}

/*
 * Only names involved in a rename are deduplicated. Other duplicated URL
 * parameters remain untouched. The item with the highest priority wins; when
 * priorities are equal, the first item in the URL is preserved.
 */
const outputParameters = [];
const winnerIndexes = {};

for (let i = 0; i < transformed.length; i++) {
  const item = transformed[i];
  const target = item.name.toLowerCase();

  if (deduplicatedTargets[target]) {
    const currentWinner = winnerIndexes[target];

    if (
      currentWinner === undefined ||
      item.priority > transformed[currentWinner].priority
    ) {
      winnerIndexes[target] = i;
    }
  }
}

for (let i = 0; i < transformed.length; i++) {
  const item = transformed[i];
  const target = item.name.toLowerCase();

  if (
    deduplicatedTargets[target] &&
    winnerIndexes[target] !== i
  ) {
    changed = true;
    continue;
  }

  outputParameters.push(
    item.name + (item.hasEquals ? '=' + item.value : '')
  );
}

if (!changed) {
  return url;
}

return beforeQuery + outputParameters.join('&') + fragment;


___WEB_PERMISSIONS___

[]


___TESTS___

scenarios:
- name: GA4 normalizes all supported Meta sources
  code: |-
    const cases = [
      ['fb', 'facebook'],
      ['ig', 'instagram'],
      ['th', 'facebook'],
      ['msg', 'messenger'],
      ['ws', 'whatsapp'],
      ['an', 'facebook']
    ];

    cases.forEach(function(testCase) {
      mockData.pageLocation = 'https://example.com/prodotto?utm_source=' + testCase[0] + '&utm_medium=paid_social';
      const result = runCode(mockData);
      assertThat(result).isEqualTo(
        'https://example.com/prodotto?utm_source=' + testCase[1] + '&utm_medium=paid_social'
      );
    });
- name: HubSpot groups all supported sources under Meta
  code: |-
    const cases = ['fb', 'ig', 'th', 'msg', 'ws', 'an'];

    cases.forEach(function(source) {
      mockData.pageLocation = 'https://example.com/?utm_source=' + source + '&utm_campaign=test';
      const result = runCode(mockData);
      assertThat(result).isEqualTo(
        'https://example.com/?utm_source=Meta&utm_campaign=test'
      );
    });
- name: Preserves parameters order and fragment
  code: |-
    mockData.pageLocation = 'https://example.com/path?a=1&utm_source=ig&b=due#section';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(
      'https://example.com/path?a=1&utm_source=instagram&b=due#section'
    );
- name: URL without utm_source remains unchanged
  code: |-
    mockData.pageLocation = 'https://example.com/path?utm_medium=paid_social#section';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(mockData.pageLocation);
- name: Custom naming transforms the configured source parameter
  code: |-
    mockData.useCustomSourceParameter = true;
    mockData.customSourceParameter = 'data_src';
    mockData.pageLocation = 'https://example.com/path?data_src=ig&utm_medium=paid_social';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(
      'https://example.com/path?utm_source=instagram&utm_medium=paid_social'
    );
- name: Custom naming removes a duplicated utm_source
  code: |-
    mockData.useCustomSourceParameter = true;
    mockData.customSourceParameter = 'data_src';
    mockData.pageLocation = 'https://example.com/path?utm_source=ig&data_src=fb';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(
      'https://example.com/path?utm_source=facebook'
    );
- name: Custom naming also works with HubSpot
  code: |-
    mockData.destination = 'hubspot';
    mockData.useCustomSourceParameter = true;
    mockData.customSourceParameter = 'data_src';
    mockData.pageLocation = 'https://example.com/path?data_src=msg&utm_campaign=test';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(
      'https://example.com/path?utm_source=Meta&utm_campaign=test'
    );
- name: Custom naming renames unmapped sources
  code: |-
    mockData.useCustomSourceParameter = true;
    mockData.customSourceParameter = 'data_src';
    mockData.pageLocation = 'https://example.com/path?data_src=linkedin&utm_medium=paid_social';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(
      'https://example.com/path?utm_source=linkedin&utm_medium=paid_social'
    );
- name: Additional custom UTMs rename a parameter while preserving its value
  code: |-
    mockData.additionalUtmMappings = [
      {inputName: 'utm_traffic', outputName: 'utm_medium'}
    ];
    mockData.pageLocation = 'https://example.com/path?utm_source=fb&utm_traffic=cpc&utm_campaign=test';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(
      'https://example.com/path?utm_source=facebook&utm_medium=cpc&utm_campaign=test'
    );
- name: Additional UTM mappings work with a custom source
  code: |-
    mockData.useCustomSourceParameter = true;
    mockData.customSourceParameter = 'data_src';
    mockData.additionalUtmMappings = [
      {inputName: 'utm_traffic', outputName: 'utm_medium'},
      {inputName: 'data_campaign', outputName: 'utm_campaign'}
    ];
    mockData.pageLocation = 'https://example.com/path?data_src=ig&utm_traffic=cpc&data_campaign=estate';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(
      'https://example.com/path?utm_source=instagram&utm_medium=cpc&utm_campaign=estate'
    );
- name: A custom parameter overrides a duplicated standard parameter
  code: |-
    mockData.additionalUtmMappings = [
      {inputName: 'utm_traffic', outputName: 'utm_medium'}
    ];
    mockData.pageLocation = 'https://example.com/path?utm_medium=organic&utm_traffic=cpc';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(
      'https://example.com/path?utm_medium=cpc'
    );
- name: An unknown source remains unchanged
  code: |-
    mockData.pageLocation = 'https://example.com/path?utm_source=linkedin&utm_medium=paid_social';
    const result = runCode(mockData);
    assertThat(result).isEqualTo(mockData.pageLocation);
setup: |-
  const mockData = {
    destination: 'ga4',
    useCustomSourceParameter: false,
    additionalUtmMappings: [],
    pageLocation: 'https://example.com/'
  };


___NOTES___

Version 1.3.0
- Normalizes the utm_source parameter.
- Includes a checkbox for using a custom source parameter name, with a nested
  TEXT field visible only when the option is enabled.
- Uses the custom parameter only as input and returns it under the standard
  utm_source name; any pre-existing utm_source is removed to avoid duplicates.
- Includes an "Additional custom UTMs" group with an Input parameter name /
  Output parameter name table for renaming additional parameters while
  preserving their values.
- When a conflict occurs, the configured custom parameter overrides the
  standard parameter already present and the output is deduplicated.
- Includes a destination dropdown with Google Analytics 4 and HubSpot.
- GA4 mapping: fb=facebook, ig=instagram, msg=messenger, ws=whatsapp,
  th=facebook and an=facebook.
- HubSpot mapping: all supported Meta sources become Meta.
- Requires no template permissions.
