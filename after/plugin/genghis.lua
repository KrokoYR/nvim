local keymap = vim.keymap.set
local genghis = require("genghis")
keymap("n", "<leader>yp", genghis.copyFilepath)
keymap("n", "<leader>yn", genghis.copyFilename)
keymap("n", "<leader>rf", genghis.renameFile)
keymap("n", "<leader>mf", genghis.moveAndRenameFile)
keymap("n", "<leader>yf", genghis.duplicateFile)
keymap("n", "<leader>df", function() genghis.trashFile { trashCmd = 'trash' } end) -- default: "trash".
keymap("x", "<leader>x", genghis.moveSelectionToNewFile)
