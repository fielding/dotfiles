if [ -f ~/.bashrc ]; then
	source .bashrc
fi

if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
  . $(brew --prefix)/share/bash-completion/bash_completion
fi

