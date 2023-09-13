local api = vim.api
local M = {}

---Opens signature help if it is available
---Just calls signature_help function from lsp.buf
---Exists to mirror close function
function M.open()
  vim.lsp.buf.signature_help()
end

---Manually closes lsp floating window and cleanups everything
---
---@param winid integer
---@param bufid integer
function M.close(winid, bufid)
  vim.schedule(function()
    local augroup = 'preview_window_' .. winid
    pcall(api.nvim_del_augroup_by_name, augroup)
    pcall(api.nvim_win_close, winid, true)
    pcall(api.nvim_buf_del_var, bufid, 'lsp_floating_preview')
  end)
end

---Toggles builtin lsp signature help window
function M.toggle()
  local bufid = api.nvim_get_current_buf()
  local status, winid = pcall(api.nvim_buf_get_var, bufid, 'lsp_floating_preview')
  -- Check for valid window is necessary because variable will not be removed when window is closed by event
  if not status or not api.nvim_win_is_valid(winid) then
    M.open()
    return
  end
  M.close(winid, bufid)
end

local default_config = {
  close_events = {
    'BufHidden',
    'BufLeave',
    'ModeChanged',
  }
}
---Setup function
---@param config table with optional fields (additional keys are passed on to |nvim_open_win()|)
---             - height: (integer) height of floating window
---             - width: (integer) width of floating window
---             - wrap: (boolean, default true) wrap long lines
---             - wrap_at: (integer) character to wrap at for computing height when wrap is enabled
---             - max_width: (integer) maximal width of floating window
---             - max_height: (integer) maximal height of floating window
---             - pad_top: (integer) number of lines to pad contents at top
---             - pad_bottom: (integer) number of lines to pad contents at bottom
---             - close_events: (table) list of events that closes the floating window
---             - focusable: (boolean, default true) Make float focusable
---             - focus: (boolean, default true) If `true`, and if {focusable}
---                      is also `true`, focus an existing floating window with the same
---                      {focus_id}
---             - silent (boolean, default false) If 'true', won't print message if no signature exists 
function M.setup(config)
  local local_config = vim.tbl_deep_extend('keep', config or {}, default_config)
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    local_config
  )
end

return M
