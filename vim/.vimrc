" -----------------------------------------------------------------------------
" file:         ~/.vimrc
" author:       fielding johnston - http://justfielding.com
" -----------------------------------------------------------------------------


" compatability {{{
" -----------------------------------------------------------------------------
"
set nocompatible                                                                " allows me to keep my sanity
set encoding=utf-8                                                              " sets encoding to utf-8

"}}}


if filereadable(expand("~/.vim/bundles.vim"))                                   " if bundles.vim exists then...
	source ~/.vim/bundles.vim                                                     " include vundle's bundle config!
endif

" SeRRRRRR {{{
" ----------------------------------------------------------------------------

"}}}

filetype plugin indent on
syntax on

set backspace=2                                                                 " full backspacing compat
set history=50                                                                  " keep 50 lines of command line history
set ruler                                                                       " show the cursor position all the time
set showcmd                                                                     " display incomplete commands
set incsearch                                                                   " do incremental searching
set hlsearch                                                                    " highlight last used search pattern
set nowrap                                                                      " don't wrap line
set textwidth=0                                                                 " stops linewrapping at invisible margins
set colorcolumn=80                                                              " column indicator
set lbr                                                                         " wrap text
set number                                                                      " show line numbers
" set backup                                                                      " turn on auto backups
" set backupdir=~/.vim/.backup//                                                  " where to put backup files
set directory=~/.vim/.tmp//                                                     " where to put tmp files
set pastetoggle=<f5>                                                            " toggle paste mode
set clipboard=unnamed                                                           " Use the OS clipboard by default
set wildmenu                                                                    " enhanced tab-completion
set suffixesadd=.rb                                                             " comma seperated list of file suffixes
set includeexpr+=substitute(v:fname,'s$','','g')                                " expression substitution
set showtabline=2
set modeline                                                                    " respect modeline
set modelines=4
set undofile
set undodir=~/.vim/undo
set noswapfile

                                                                                " TODO: Come up with what I want to use for listchars
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list

" folding
set foldignore=                                                                 " don't ignore anything when folding
set foldlevelstart=0                                                            " no folds closed on open
set foldmethod=marker                                                           " collapse code using indent levels
set foldnestmax=20                                                              " limit max folds for indent and syntax methods

" status bar info and appearance
" set statusline=\ \%f%m%r%h%w\ ::\ %y\ [%{&ff}]\%=\ [%p%%:\ %l/%L]\            " content for statusline
set laststatus=2                                                                " lastwindow always has status line
set cmdheight=1                                                                 " set 1 line limit for 'messages'
set noshowmode                                                                  " Hide the default mode text

" indenting
set autoindent                                                                  " turns autoidenting on for new lines
set smartindent                                                                 " does the right thing (mostly)
set cindent                                                                     " stricter rules for C programs
set shiftwidth=2                                                                " 2 cols for autoindenting

" don't add newlines at the end of files
set binary
set noeol

" tabs
set expandtab                                                                   " use spaces instead of true tabs
set tabstop=2                                                                   " 2 column tabs


let mapleader=','
" "let g:html_indent_tags = 'li\|p'

                                                                                " TODO: actually implement indent_guides worth a flip
let g:indent_guides_auto_colors=0
let g:indent_guides_color_change_percent=10
let g:indent_guides_guide_size=1

" maps!
" Q does formatting qith gq. Vim 5.0 style
map Q gq

" Shift or not to shift! that is the question
map ; :

" Force writing to a file with sudo
cmap w!! w !sudo tee % >/dev/null

" enables CTRL-U after inserting a line break
inoremap <C-U> <C-G>u<C-U>
" spacebar unhighlights search text
:noremap <silent> <Space> :silent noh<Bar>echo<CR>
" Marked.app preview for markdown files
:nnoremap <leader>m :silent !open -a Marked.app '%:p'<cr>
:noremap <F6> :NERDTreeToggle<CR>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
  set ttymouse=xterm
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  set ofu=syntaxcomplete#Complete
  set path+=/path/to/your/rails-application/app/**
  set path+=/path/to/your/rails-application/lib/**
  set suffixesadd=.rb
  set includeexpr+=substitute(v:fname,'s$','','g')

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 79 characters.:
  autocmd FileType text setlocal textwidth=79

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

  autocmd FileType python setlocal sw=4 sts=4 et

  " Enabled auto sourcing when saving my vimrc
  autocmd BufWritePost .vimrc source $MYVIMRC
endif " has("autocmd")



" Colors/Appearance

set t_Co=256
set t_Sf=[3%dm
set t_Sb=[4%dm

let g:hybrid_use_Xresources=1
set background=dark
colorscheme hybrid
highlight Normal ctermbg=NONE
highlight CursorLine ctermbg=0
highlight Comment cterm=italic

if has('gui_running')
  set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h8
  set guioptions-=T                                                             " remove toolbar
  set guioptions-=r                                                             " remove right scroll bars
  set guioptions-=l                                                             " remove left scroll bars
  set guioptions-=m                                                             " remove menu bar
  set guioptions-=b                                                             " remove bottom scroll bar
  set guicursor+=a:block-blinkon0                                               " use solid block cursor
endif

                                                                                " TODO: finish seting up powerline for vim
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup


let g:Powerline_symbols='fancy'
let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=1


" functions {{{
" -----------------------------------------------------------------------------

"}}}


" extra {{{
" -----------------------------------------------------------------------------
"source ~/.vim/.simplenoterc

" }}}