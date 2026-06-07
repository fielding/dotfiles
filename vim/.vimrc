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

" use humanplusplus from the human-plus-plus repo if checked out,
" fall back to desert otherwise.
let s:hpp = expand('~/src/hack/human-plus-plus/packages/vim-plugin')
if isdirectory(s:hpp)
  let &runtimepath = s:hpp . ',' . &runtimepath
endif
try
  colorscheme humanplusplus
catch
  silent! colorscheme desert
endtry

" vim:foldmethod=marker
