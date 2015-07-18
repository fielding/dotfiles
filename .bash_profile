if [ -f ~/.bashrc ]; then
	source .bashrc
fi

if [[ `uname -s` == "Darwin" ]]; then
  if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
    . $(brew --prefix)/share/bash-completion/bash_completion
  fi
fi
<<<<<<< HEAD


source /Users/fielding/.iterm2_shell_integration.bash
=======
>>>>>>> fc3eaa927e3014848ee5056e95ecb59247846e36
