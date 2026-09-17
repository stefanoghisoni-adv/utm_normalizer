# UTM Source Normalizer for Google Tag Manager

A custom variable template for **Google Tag Manager Web containers** that returns the complete Page Location while normalizing Meta source codes and renaming custom tracking parameters to standard UTM names.

It is designed for campaigns that use Meta's `{{site_source_name}}` macro, which may generate values such as `fb`, `ig`, `msg`, `ws`, `th`, or `an`. These values can be translated into naming conventions suitable for **Google Analytics 4** or **HubSpot**.

## Features

- Returns the **entire Page Location**, including path, query string, and URL fragment.
- Normalizes Meta source codes according to the selected destination platform.
- Supports a custom source parameter such as `data_src` and renames it to `utm_source`.
- Supports additional custom parameter mappings, for example `utm_traffic` to `utm_medium`.
- Preserves parameter values when renaming additional custom UTMs.
- Prevents duplicate output parameters when the destination parameter already exists.
- Leaves unrelated query parameters unchanged.
- Requires no network, DOM, cookie, storage, or data layer permissions.

## Source normalization

| Input value | Google Analytics 4 | HubSpot |
|---|---|---|
| `fb` | `facebook` | `Meta` |
| `ig` | `instagram` | `Meta` |
| `msg` | `messenger` | `Meta` |
| `ws` | `whatsapp` | `Meta` |
| `th` | `facebook` | `Meta` |
| `an` | `facebook` | `Meta` |

Unknown source values are preserved. If an unknown value is found in a configured custom source parameter, only the parameter name is changed to `utm_source`.

## Installation

1. Download `template.tpl` from this repository.
2. Open a **Google Tag Manager Web container**.
3. Go to **Templates**.
4. In **Variable Templates**, click **Search Gallery** if the template is published in the Community Template Gallery, or click **New** and then **Import** to install it manually.
5. Select `template.tpl`, review the requested permissions, and save the template.
6. Create a new user-defined variable and choose **UTM Source Normalizer** as its type.

## Configuration

### Page Location originale

Select the built-in `{{Page URL}}` variable, or another variable that returns the complete URL to transform.

### Utilizzo una nomenclatura custom per gli UTM

Enable this option when the source is stored in a parameter other than `utm_source`.

In **Nome custom del parametro sorgente**, enter the parameter name only, without `?`, `&`, or `=`.

Example:

```text
data_src
```

Given this URL:

```text
https://example.com/landing?data_src=fb&utm_medium=cpc
```

the custom source parameter is renamed to `utm_source` and its value is normalized.

### Piattaforma di destinazione

Choose one of the available naming conventions:

- **Google Analytics 4** — returns source names such as `facebook` and `instagram`.
- **HubSpot** — returns `Meta` for recognized Meta source codes.

### Altri UTM personalizzati

Use the nested table to rename additional tracking parameters. Each row contains:

| Field | Description | Example |
|---|---|---|
| Nome da identificare | Parameter name to find in the input URL | `utm_traffic` |
| Nome di output | Standard parameter name to return | `utm_medium` |

You can add multiple mappings, for example:

| Input parameter | Output parameter |
|---|---|
| `utm_traffic` | `utm_medium` |
| `data_campaign` | `utm_campaign` |
| `data_content` | `utm_content` |

The parameter value is preserved. Only its name changes.

## Examples

### Custom source for Google Analytics 4

Configuration:

- Custom source parameter: `data_src`
- Destination: Google Analytics 4

Input:

```text
https://example.com/landing?data_src=fb&utm_medium=cpc
```

Output:

```text
https://example.com/landing?utm_source=facebook&utm_medium=cpc
```

### Custom source for HubSpot

Configuration:

- Custom source parameter: `data_src`
- Destination: HubSpot

Input:

```text
https://example.com/landing?data_src=ig&utm_medium=paid_social
```

Output:

```text
https://example.com/landing?utm_source=Meta&utm_medium=paid_social
```

### Multiple custom UTM parameters

Configuration:

- Custom source parameter: `data_src`
- Destination: Google Analytics 4
- Additional mapping: `utm_traffic` → `utm_medium`
- Additional mapping: `data_campaign` → `utm_campaign`

Input:

```text
https://example.com/landing?data_src=fb&utm_traffic=cpc&data_campaign=summer_sale
```

Output:

```text
https://example.com/landing?utm_source=facebook&utm_medium=cpc&utm_campaign=summer_sale
```

## Conflict handling

When both a custom parameter and its standard destination parameter are present, the configured custom parameter takes precedence.

Example:

```text
https://example.com/?utm_source=old-value&data_src=fb
```

With `data_src` configured as the custom source, the output for Google Analytics 4 is:

```text
https://example.com/?utm_source=facebook
```

The same rule applies to rows in **Altri UTM personalizzati**: the mapped custom parameter replaces an existing destination parameter, and the output contains only one instance of that parameter.

## Using the returned value

This template returns a transformed URL string. It does **not** modify the URL displayed in the browser.

Use the variable as the value of:

- `page_location` in a Google tag or GA4 event tag;
- the corresponding page URL property in a HubSpot integration;
- another tag field that accepts the complete normalized URL.

## Privacy and permissions

The template processes only the URL supplied through its input field. It does not:

- send network requests;
- read or write cookies;
- access browser storage;
- access the DOM;
- read or write the data layer.

## Compatibility

- Google Tag Manager **Web** containers
- Google Analytics 4
- HubSpot

## Testing

The template includes tests covering:

- every supported Meta source code;
- GA4 and HubSpot output conventions;
- standard and custom source parameters;
- additional custom UTM mappings;
- duplicate destination parameters;
- unknown values;
- URL fragments and unrelated parameters.

Before publishing changes, run all tests from the template editor's **Tests** tab.

## Repository structure

For submission to the Google Tag Manager Community Template Gallery, the repository should contain at least:

```text
.
├── template.tpl
├── metadata.yaml
├── LICENSE
└── README.md
```

Rename the exported GTM template file to `template.tpl`. The Community Template Gallery requires an Apache 2.0 license and uses `metadata.yaml` to identify released versions.

## Contributing

Issues and pull requests are welcome. When proposing a new mapping or behavior change, please include:

- a sample input URL;
- the selected destination platform;
- the expected complete output URL;
- any relevant analytics-platform documentation.

Please keep backward compatibility in mind and add or update template tests for every behavioral change.

## License

Licensed under the Apache License 2.0. See `LICENSE` for details.

## Author

Created and maintained by **Stefano Ghisoni**.
