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


" Syntax/Indent for specific languages

Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-markdown'



filetype plugin indent on                                               " required!
