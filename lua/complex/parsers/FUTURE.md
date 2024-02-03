Consumers should create a parser depending on buffer filetype via:
```lua
---@param language Language enumerated list of supported languages/filetypes
---@return Parser a class exposing methods for consumers to parse and grab common TSNode types
function createParser(language) {}
```
and inject the parser into the scorer.
