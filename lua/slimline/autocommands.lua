local augroup = vim.api.nvim_create_augroup('slimline', { clear = true })

vim.api.nvim_create_autocmd('User', {
  group = augroup,
  pattern = 'GitSignsUpdate',
  callback = function()
    require('slimline').refresh()
  end,
})

vim.api.nvim_create_autocmd('Colorscheme', {
  group = augroup,
  callback = function()
    require('slimline.highlights').create_hls()
  end,
})
