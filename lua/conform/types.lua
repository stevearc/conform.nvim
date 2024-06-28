---@class (exact) conform.FormatterInfo
---@field name string
---@field command string
---@field cwd? string
---@field available boolean
---@field available_msg? string

---@class (exact) conform.JobFormatterConfig
---@field command string|fun(self: conform.JobFormatterConfig, ctx: conform.Context): string
---@field args? string|string[]|fun(self: conform.JobFormatterConfig, ctx: conform.Context): string|string[]
---@field range_args? fun(self: conform.JobFormatterConfig, ctx: conform.RangeContext): string|string[]
---@field cwd? fun(self: conform.JobFormatterConfig, ctx: conform.Context): nil|string
---@field require_cwd? boolean When cwd is not found, don't run the formatter (default false)
---@field stdin? boolean Send buffer contents to stdin (default true)
---@field tmpfile_format? string When stdin=false, use this format for temporary files (default ".conform.$RANDOM.$FILENAME")
---@field condition? fun(self: conform.JobFormatterConfig, ctx: conform.Context): boolean
---@field exit_codes? integer[] Exit codes that indicate success (default {0})
---@field env? table<string, any>|fun(self: conform.JobFormatterConfig, ctx: conform.Context): table<string, any>
---@field options? table

---@class (exact) conform.LuaFormatterConfig
---@field format fun(self: conform.LuaFormatterConfig, ctx: conform.Context, lines: string[], callback: fun(err: nil|string, new_lines: nil|string[]))
---@field condition? fun(self: conform.LuaFormatterConfig, ctx: conform.Context): boolean
---@field options? table

---@class (exact) conform.FileLuaFormatterConfig : conform.LuaFormatterConfig
---@field meta conform.FormatterMeta

---@class (exact) conform.FileFormatterConfig : conform.JobFormatterConfig
---@field meta conform.FormatterMeta

---@alias conform.FormatterConfig conform.JobFormatterConfig|conform.LuaFormatterConfig

---@class (exact) conform.FormatterConfigOverride : conform.JobFormatterConfig
---@field inherit? boolean
---@field command? string|fun(self: conform.FormatterConfig, ctx: conform.Context): string
---@field prepend_args? string|string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[]
---@field append_args? string|string[]|fun(self: conform.FormatterConfig, ctx: conform.Context): string|string[]
---@field format? fun(self: conform.LuaFormatterConfig, ctx: conform.Context, lines: string[], callback: fun(err: nil|string, new_lines: nil|string[])) Mutually exclusive with command
---@field options? table

---@class (exact) conform.FormatterMeta
---@field url string
---@field description string
---@field deprecated? boolean

---@class (exact) conform.Context
---@field buf integer
---@field filename string
---@field dirname string
---@field range? conform.Range
---@field shiftwidth integer

---@class (exact) conform.RangeContext : conform.Context
---@field range conform.Range

---@class (exact) conform.Range
---@field start integer[]
---@field end integer[]

---@alias conform.FormatterUnit string|string[]
---@alias conform.FiletypeFormatter conform.FormatterUnit[]|fun(bufnr: integer): string[]

---@class (exact) conform.setupOpts
---@field formatters_by_ft? table<string, conform.FiletypeFormatter> Map of filetype to formatters
---@field format_on_save? conform.FormatOpts|fun(bufnr: integer): nil|conform.FormatOpts If this is set, Conform will run the formatter on save. It will pass the table to conform.format(). This can also be a function that returns the table.
---@field format_after_save? conform.FormatOpts|fun(bufnr: integer): nil|conform.FormatOpts If this is set, Conform will run the formatter asynchronously after save. It will pass the table to conform.format(). This can also be a function that returns the table.
---@field log_level? integer Set the log level (e.g. `vim.log.levels.DEBUG`). Use `:ConformInfo` to see the location of the log file.
---@field notify_on_error? boolean Conform will notify you when a formatter errors (default true).
---@field formatters? table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride> Custom formatters and overrides for built-in formatters.
