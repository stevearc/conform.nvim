local function find_local_config()
  local current_file = vim.api.nvim_buf_get_name(0)
  local local_configs = { ".vsg.yaml", ".vsg.yml", ".vsg.json" }
  return vim.fs.find(local_configs, {
    path = vim.fs.dirname(current_file),
    upward = true,
  })[1]
end

local function find_global_config()
  local xdg_config_home = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
  local global_configs = { "vsg.yaml", "vsg.yml", "vsg.json" }
  return vim.fs.find(global_configs, {
    path = xdg_config_home .. "/vsg",
    upward = false,
  })[1]
end

---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://github.com/jeremiah-c-leary/vhdl-style-guide",
    description = "Style guide enforcement for VHDL.",
  },
  command = "vsg",
  stdin = false,
  args = function()
    local args = { "-of", "syntastic", "--fix", "-f", "$FILENAME" }
    local config_file = find_local_config() or find_global_config()

    if config_file then
      table.insert(args, "-c")
      table.insert(args, config_file)
    end

    return args
  end,
}
