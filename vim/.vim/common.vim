" common.vim — shared options, mappings, and autocmds for vim and neovim
" sourced by both .vimrc (vanilla vim) and init.vim (neovim)

" leader {{{1
let mapleader="\<Space>"

" options {{{1
set fileformats=unix,dos
set fileencoding=utf-8
set autoread
set autowrite
set backspace=2
set history=50
set ruler
set showcmd
set incsearch
set hlsearch
set nowrap
set textwidth=80
set colorcolumn=80
set linebreak
set relativenumber number
set clipboard=unnamed
set wildmenu
set suffixesadd=.rb
set includeexpr+=substitute(v:fname,'s$','','g')
set showtabline=2
set modeline
set modelines=4
set lazyredraw
set splitbelow
set splitright
set wildignore+=*/.git/*,*/tmp/*,*.swp

" working file settings and location
set directory=~/.vim/files/swap//
set updatecount=100
set undofile
set undodir=~/.vim/files/undo/
set backup
set backupdir=~/.vim/files/backup/
set backupext=-vimbackup
set backupskip=
set viminfo='100,n~/.vim/files/viminfo

set listchars=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

" disable audio/visual bells
set noerrorbells
set novisualbell
set t_vb=

" folding
set foldignore=
set foldmethod=marker
set foldnestmax=20
set nofoldenable

" status bar
set laststatus=2
set cmdheight=1
set noshowmode
set shortmess+=mwt

" indenting
set autoindent
set smartindent
set cindent
set shiftwidth=2

" tabs
set expandtab
set tabstop=2

set completeopt=longest,menuone,preview

" mouse
if has('mouse')
  set mouse=a
  if !has('nvim')
    set ttymouse=xterm
  endif
endif
if has('mouse_sgr')
  set ttymouse=sgr
endif

" shell type
let g:is_bash = 1

" python host
let g:python3_host_prog = '/opt/homebrew/bin/python3'

" mappings {{{1
" disable arrow keys
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>

command! Sudo :execute ':silent w !sudo tee % > /dev/null' | :edit!

" enables CTRL-U after inserting a line break
inoremap <C-U> <C-G>u<C-U>

" spacebar unhighlights search text
noremap <silent> <leader>/ :silent noh<Bar>echo<CR>

" tmux navigator backspace fix
nnoremap <silent> <BS> :TmuxNavigateLeft<cr>

" align blocks and keep them selected
vmap < <gv
vmap > >gv

" leader d to dump to black hole register
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" neovim terminal commands
command Term split term://$SHELL
command VTerm vsplit term://$SHELL

" neovim terminal navigation
tnoremap <Esc> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l

" autocmds {{{1
if has('autocmd')
  filetype plugin indent on
  set omnifunc=syntaxcomplete#Complete

  augroup vimrcEx
    au!
    " trim trailing whitespace on save
    autocmd BufWritePre * :FixWhitespace
    " restore cursor position
    autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
  augroup END

  " enter insert mode when switching to terminal buffer
  autocmd BufEnter * if &buftype == "terminal" | startinsert | endif

  autocmd StdinReadPre * let s:std_in=1

  autocmd BufRead,BufNewFile,BufFilePre *.md set filetype=markdown

  autocmd FileType c,cpp setlocal shiftwidth=4 tabstop=4 expandtab
  autocmd FileType javascript,typescript setlocal foldmethod=syntax foldlevelstart=2
  autocmd FileType markdown setlocal wrap
  autocmd FileType python setlocal shiftwidth=4 sts=4 et

  " .NFO file encoding
  function! SetFileEncodings(encodings)
    let b:myfileencodingsbak=&fileencodings
    let &fileencodings=a:encodings
  endfunction

  function! RestoreFileEncodings()
    let &fileencodings=b:myfileencodingsbak
    unlet b:myfileencodingsbak
  endfunction

  au BufReadPre *.nfo call SetFileEncodings('cp437')
  au BufReadPost *.nfo call RestoreFileEncodings()
endif

" auto-save on focus lost
au FocusLost * :silent! wall

" vim:foldmethod=marker
