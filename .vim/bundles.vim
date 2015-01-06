filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

" This is the Vundle package, which can be found on GitHub.
" For GitHub repos, you specify plugins using the
" 'user/repository' format
Plugin 'gmarik/vundle'


" Features

Bundle 'bronson/vim-trailing-whitespace'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'tpope/vim-afterimage'
Bundle 'scrooloose/syntastic'
"Bundle 'spf13/vim-autoclose'
Bundle 'terryma/vim-multiple-cursors'

" Syntax/Indent for specific languages

Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-markdown'
Bundle 'lambdatoast/elm.vim'
Bundle 'leshill/vim-json'
Bundle 'kchmck/vim-coffee-script'

" Color correction

Bundle 'godlygeek/csapprox'

" Color Schemes

Bundle 'morhetz/gruvbox'
Bundle 'tomasr/molokai'
Bundle 'adlawson/vim-sorcerer'
Bundle 'sickill/vim-monokai'
Bundle 'chriskempson/vim-tomorrow-theme'
Bundle 'w0ng/vim-hybrid'
Bundle 'Junza/Spink'


filetype plugin indent on                                               				" required!
