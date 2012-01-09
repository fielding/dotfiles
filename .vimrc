"--------------------------------------------------------------
" file:         ~/.vimrc
" author:       fielding johnston - http://www.justfielding.com
"--------------------------------------------------------------i

syntax on
colorscheme fielding
filetype plugin on

set nocompatible                                                        " allows me to keep my sanity
set backspace=2                                                         " full backspacing compat
set history=50                                                          " keep 50 lines of command line history
set ruler                                                               " show the cursor position all the time
set showcmd                                                             " display incomplete commands
set incsearch                                                           " do incremental searching
set hlsearch                                                            " highlight last used search pattern
set t_Co=256                                                            " use 256 colors
set encoding=utf-8                                                      " sets encoding to utf-8 for new files
set nowrap                                                              " don't wrap line
set textwidth=0                                                         " stops linewrapping at invisible margins
set lbr                                                                 " wrap text
set number                                                              " show line numbers
set paste                                                               " set paste mode
set backup                                                              " turn on auto backups
set backupdir=~/.vim/.backup//                                          " where to put backup files
set directory=~/.vim/.tmp//                                             " where to put tmp files
set pastetoggle=<f5>                                                    " toggle paste mode
set clipboard+=unnamed                                                  " yank and copy to xclipboard
set wildmenu                                                            " enhanced tab-completion
set suffixesadd=.rb                                                     " comma seperated list of file suffixes 
set includeexpr+=substitute(v:fname,'s$','','g')                        " expression substitution

" status bar info and appearance
set statusline=\ \%f%m%r%h%w\ ::\ %y\ [%{&ff}]\%=\ [%p%%:\ %l/%L]\      " content for statusline
set laststatus=2                                                        " lastwindow always has status line
set cmdheight=1                                                         " set 1 line limit for 'messages'

" indenting
set autoindent                                                          " turns autoidenting on for new lines
set smartindent                                                         " does the right thing (mostly)
set cindent                                                             " stricter rules for C programs
set shiftwidth=2                                                        " 2 cols for autoindenting

" tabs
set expandtab                                                           " use spaces instead of true tabs
set tabstop=2                                                           " 2 column tabs

let g:html_indent_tags = 'li\|p'                                        "

" maps!
map Q gq                                                                " Q does formatting qith gq. Vim 5.0 style
map ; : " 


inoremap <C-U> <C-G>u<C-U>                                              " enables CTRL-U after inserting a line break.
:noremap <silent> <Space> :silent noh<Bar>echo<CR>                      " spacebar unhighlights search text
cmap w!! w !sudo tee % >/dev/null                                       " force writing of files that need root privs


" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
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

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

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

endif " has("autocmd")

" highlighting tabs, trailing white space and non breaking spaces
if &term !=# "linux"
    set list listchars=tab:\»\ ,trail:·,nbsp:-
endif
