# Render webform

Render webform documents for your script.

## Usage

```bash
# Generate all documents to the ./docs directory
$ bashly render templates/webform docs

# Generate on change, and show one of the files
$ bashly render templates/webform docs --watch --show index.md
```

## Supported custom definitions

Add these definitions to your `bashly.yml` to render them in your
webform:

### Footer: `x_webform_footer`

Add additional sections to your man pages. This field is expected
to be in webform format.

#### Example

```yaml
x_webform_footer: |-
  # ISSUE TRACKER

  Report issues at <https://github.com/lanalang/smallville>
```
