---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://www.npmjs.com/package/@tailwindcss/language-server",
    description = "Language Server Protocol implementation for Tailwind CSS, used by Tailwind CSS IntelliSense for VS Code.",
  },
  command = "tailwindcss-language-server",
  args = { "--stdio", "node-ipc", "--socket=<port>" },
}
