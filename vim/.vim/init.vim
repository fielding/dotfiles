" init.vim — neovim primary config
" author: fielding johnston

" common {{{1
runtime common.vim

" plug {{{1
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" colors
Plug 'fielding/vice'
Plug 'fielding/lightline-vice.vim'
Plug '~/src/hack/human-plus-plus/packages/neovim-plugin'

" features
Plug 'bronson/vim-trailing-whitespace'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/goyo.vim'
Plug 'moll/vim-bbye'
Plug 'tomtom/tcomment_vim'
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-gitgutter'
Plug 'godlygeek/tabular'
Plug 'itchyny/lightline.vim'
Plug 'mgee/lightline-bufferline'
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'ap/vim-css-color'
Plug 'editorconfig/editorconfig-vim'
Plug '/opt/homebrew/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'bkad/CamelCaseMotion'
Plug 'w0rp/ale'
Plug 'wakatime/vim-wakatime'

" language support
Plug 'heavenshell/vim-jsdoc'
Plug 'chr4/nginx.vim'
Plug 'xu-cheng/brew.vim'
Plug 'davidoc/taskpaper.vim'
Plug 'https://git.imbue.studio/fielding/vim-scheme.git'

call plug#end()

" plugin config {{{1

" indent guides
let g:indent_guides_auto_colors = 0
let g:indent_guides_color_change_percent = 10
let g:indent_guides_guide_size = 1

" editorconfig
let g:EditorConfig_core_mode = 'vim_core'

" ale
let g:ale_linters = {
      \  'bash': ['shellcheck'],
      \  'c': ['clangtidy'],
      \  'javascript': ['eslint'],
      \  'python': ['ruff'],
      \  'sh': ['shellcheck'],
      \  'typescript': ['eslint'],
      \  'zig': ['zls'],
      \  }

let g:ale_fixers = {
      \  'bash': ['shfmt'],
      \  'c': ['clang-format'],
      \  'css': ['prettier'],
      \  'graphql': ['prettier'],
      \  'javascript': ['prettier', 'eslint'],
      \  'json': ['prettier'],
      \  'jsx': ['prettier', 'eslint'],
      \  'less': ['prettier'],
      \  'markdown': ['prettier'],
      \  'python': ['ruff', 'ruff_format'],
      \  'scss': ['prettier'],
      \  'sh': ['shfmt'],
      \  'typescript': ['prettier', 'eslint'],
      \  'typescriptreact': ['prettier', 'eslint'],
      \  'zig': ['zigfmt'],
      \}

let g:ale_sh_shfmt_options = '-i 2 -ci -p'
let g:ale_bash_shfmt_options = '-i 2 -ci'

" vimwiki
let g:vimwiki_list = [{'path': '~/notes/', 'path_html': '~/Documents/wiki', 'syntax': 'markdown', 'ext': '.md', 'folding': 'expr'}]
let g:vimwiki_global_ext = 0

" fzf
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

" startify
function! s:filter_header(lines) abort
  let longest_line   = max(map(copy(a:lines), 'strwidth(v:val)'))
  let centered_lines = map(copy(a:lines),
        \ 'repeat(" ", (&columns / 2) - (longest_line / 2)) . v:val')
  return centered_lines
endfunction

let g:fielding_f = [
      \ '████████████████████████████████▓▒░',
      \ '████████████████████████████████▓▒░',
      \ '████████████████████████████████▓▒░',
      \ '████████████████████████████████▓▒░',
      \ '█████████▓▒░',
      \ '█████████',
      \ '█████████',
      \ '█████████',
      \ '█████████████████████████▓▒░',
      \ '█████████████████████████▓▒░',
      \ '█████████████████████████▓▒░',
      \ '█████████████████████████▓▒░',
      \ '█████████▓▒░',
      \ '█████████',
      \ '█████████',
      \ '█████████',
      \ '█████████',
      \ '█████████',
      \ '█████████',
      \ '█████████',
      \ ]

let g:startify_custom_header = s:filter_header(g:fielding_f) + [''] + s:filter_header(startify#fortune#boxed())
let g:startify_bookmarks = ["~/.vimrc"]

" CamelCaseMotion
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
map <silent> ge <Plug>CamelCaseMotion_ge
sunmap w
sunmap b
sunmap e
sunmap ge

" yankstack
nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste

" lightline
let g:lightline = {
      \ 'colorscheme': 'vice',
      \ 'tabline': {'left': [['buffers']], 'right': [[]]},
      \ 'component_expand': {'buffers': 'lightline#bufferline#buffers'},
      \ 'component_type': {'buffers': 'tabsel'}
      \ }
let g:lightline#bufferline#filename_modifier = ':t'
let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#number_map = {
      \ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
      \ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹'}

nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)
nmap <Leader>0 <Plug>lightline#bufferline#go(10)
nmap <Leader><Tab> :bn<CR>
nmap <Leader><S-Tab> :bp<CR>

" fzf mappings
nnoremap <silent> <Leader><Leader> :Files<cr>
nnoremap <silent> <Leader><Enter> :Buffers<CR>

" colors {{{1
if !exists('g:syntax_on')
  syntax enable
endif

set t_Co=256
set background=dark

" true color
if has('termguicolors')
  set termguicolors
endif

let g:tinted_background_transparent = 0
colorscheme humanplusplus
lua require('human-plus-plus').setup({})

" vim:foldmethod=marker
