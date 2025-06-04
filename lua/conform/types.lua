---@class (exact) conform.FormatterInfo
---@field name string
---@field command string
---@field cwd? string
---@field available boolean
---@field available_msg? string
---@field error? boolean

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

---@alias conform.FiletypeFormatter conform.FiletypeFormatterInternal|fun(bufnr: integer): conform.FiletypeFormatterInternal

---This list of formatters to run for a filetype, an any associated format options.
---@class conform.FiletypeFormatterInternal : conform.DefaultFiletypeFormatOpts
---@field [integer] string

---@alias conform.LspFormatOpts
---| '"never"' # never use the LSP for formatting (default)
---| '"fallback"' # LSP formatting is used when no other formatters are available
---| '"prefer"' # use only LSP formatting when available
---| '"first"' # LSP formatting is used when available and then other formatters
---| '"last"' # other formatters are used then LSP formatting when available

---@class (exact) conform.FormatOpts
---@field timeout_ms? integer Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.
---@field bufnr? integer Format this buffer (default 0)
---@field async? boolean If true the method won't block. Defaults to false. If the buffer is modified before the formatter completes, the formatting will be discarded.
---@field dry_run? boolean If true don't apply formatting changes to the buffer
---@field undojoin? boolean Use undojoin to merge formatting changes with previous edit (default false)
---@field formatters? string[] List of formatters to run. Defaults to all formatters for the buffer filetype.
---@field lsp_format? conform.LspFormatOpts Configure if and when LSP should be used for formatting. Defaults to "never".
---@field stop_after_first? boolean Only run the first available formatter in the list. Defaults to false.
---@field quiet? boolean Don't show any notifications for warnings or failures. Defaults to false.
---@field range? conform.Range Range to format. Table must contain `start` and `end` keys with {row, col} tuples using (1,0) indexing. Defaults to current selection in visual mode
---@field id? integer Passed to |vim.lsp.buf.format| when using LSP formatting
---@field name? string Passed to |vim.lsp.buf.format| when using LSP formatting
---@field filter? fun(client: table): boolean Passed to |vim.lsp.buf.format| when using LSP formatting
---@field formatting_options? table Passed to |vim.lsp.buf.format| when using LSP formatting

---@class (exact) conform.DefaultFormatOpts
---@field timeout_ms? integer Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.
---@field lsp_format? conform.LspFormatOpts Configure if and when LSP should be used for formatting. Defaults to "never".
---@field quiet? boolean Don't show any notifications for warnings or failures. Defaults to false.
---@field stop_after_first? boolean Only run the first available formatter in the list. Defaults to false.

---@class (exact) conform.DefaultFiletypeFormatOpts : conform.DefaultFormatOpts
---@field id? integer Passed to |vim.lsp.buf.format| when using LSP formatting
---@field name? string Passed to |vim.lsp.buf.format| when using LSP formatting
---@field filter? fun(client: table): boolean Passed to |vim.lsp.buf.format| when using LSP formatting
---@field formatting_options? table Passed to |vim.lsp.buf.format| when using LSP formatting

---@class conform.FormatLinesOpts
---@field timeout_ms? integer Time in milliseconds to block for formatting. Defaults to 1000. No effect if async = true.
---@field bufnr? integer use this as the working buffer (default 0)
---@field async? boolean If true the method won't block. Defaults to false. If the buffer is modified before the formatter completes, the formatting will be discarded.
---@field quiet? boolean Don't show any notifications for warnings or failures. Defaults to false.
---@field stop_after_first? boolean Only run the first available formatter in the list. Defaults to false.

---@class (exact) conform.setupOpts
---@field formatters_by_ft? table<string, conform.FiletypeFormatter> Map of filetype to formatters
---@field format_on_save? conform.FormatOpts|fun(bufnr: integer): nil|conform.FormatOpts If this is set, Conform will run the formatter on save. It will pass the table to conform.format(). This can also be a function that returns the table.
---@field default_format_opts? conform.DefaultFormatOpts The default options to use when calling conform.format()
---@field format_after_save? conform.FormatOpts|fun(bufnr: integer): nil|conform.FormatOpts, nil|fun(err: nil|string, did_edit: nil|boolean) If this is set, Conform will run the formatter asynchronously after save. It will pass the table to conform.format(). This can also be a function that returns the table (and an optional callback that is run after formatting).
---@field log_level? integer Set the log level (e.g. `vim.log.levels.DEBUG`). Use `:ConformInfo` to see the location of the log file.
---@field notify_on_error? boolean Conform will notify you when a formatter errors (default true).
---@field notify_no_formatters? boolean Conform will notify you when no formatters are available for the buffer (default true).
---@field formatters? table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride> Custom formatters and overrides for built-in formatters.
