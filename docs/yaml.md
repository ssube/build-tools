# YAML

## Indentation

Since blocks have to be indented, lists should be consistent:

```yaml
foo: |
  1
  2

bar:
  - 1
  - 2
```

## Quotes

Strings should always be quoted if they:

- start with `{{`
  - this is a YAML requirement to differentiate variables from nested maps
- have no letters
  - number/special-only strings, like versions or IP addresses, might be interpreted as numbers. Disambiguate.
