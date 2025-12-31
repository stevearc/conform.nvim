local config_files = {
  "vsg_config.yaml",
  "vsg_config.yml",
  "vsg_config.json",
  "vsg.yaml",
  "vsg.yml",
  "vsg.json",
  ".vsg_config.yaml",
  ".vsg_config.yml",
  ".vsg_config.json",
  ".vsg.yaml",
  ".vsg.yml",
  ".vsg.json",
}

local function find_config(dirname)
  local config_dir =
    vim.fs.normalize(os.getenv("XDG_CONFIG_HOME") or (vim.uv.os_homedir() .. "/.config"))

  local paths = {
    dirname,
    (config_dir .. "/vsg"),
  }

  for _, path in ipairs(paths) do
    local config = vim.fs.find(config_files, {
      path = path,
      upward = path == dirname,
    })[1]
    if config then
      return config
    end
  end
end

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jeremiah-c-leary/vhdl-style-guide",
    description = "Style guide enforcement for VHDL.",
  },
  command = "vsg",
  stdin = false,
  args = function(_, ctx)
    local args = { "-of", "syntastic", "--fix", "-f", "$FILENAME" }
    local config_file = find_config(ctx.dirname)

    if config_file then
      table.insert(args, "-c")
      table.insert(args, config_file)
    end

    return args
  end,
}
