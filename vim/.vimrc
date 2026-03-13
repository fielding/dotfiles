" .vimrc — minimal vanilla vim fallback (no plugins)
" full config lives in ~/.vim/init.vim for neovim

runtime common.vim

if !exists('g:syntax_on')
  syntax enable
endif

set t_Co=256
set background=dark

" true color support
if has('termguicolors')
  set termguicolors
endif

" use humanplusplus if available, fall back to desert
try
  colorscheme humanplusplus
catch
  silent! colorscheme desert
endtry

" vim:foldmethod=marker
