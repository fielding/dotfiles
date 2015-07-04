if [ -f ~/.bashrc ]; then
	source .bashrc
fi

if [[ `uname -s` == "Darwin" ]]; then
  if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
    . $(brew --prefix)/share/bash-completion/bash_completion
  fi
fi
