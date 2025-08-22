---@type conform.FileFormatterConfig
return {
  meta = {
    url = "https://doc.qt.io/qt-6//qtqml-tooling-qmlformat.html",
    description = "A tool that automatically formats QML files.",
  },
  command = "qmlformat",
  args = { "-i", "$FILENAME" },
  stdin = false,
}
