PATH=~/.local/bin:~/.local/sbin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/vc/bin:$PATH
NPM_PACKAGES="$HOME/.npm-packages"

source ~/.local/share/antigen/antigen.zsh

antigen use oh-my-zsh
antigen bundle git
antigen bundle pip
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle npm
antigen bundle go
antigen bundle gem
antigen bundle node
antigen bundle python
antigen bundle rust
antigen bundle cargo
antigen bundle github
antigen bundle colorize
antigen bundle pylint
antigen bundle docker-compose
antigen bundle z
antigen bundle zsh-users/zsh-history-substring-search
antigen theme agnoster
antigen bundle ael-code/zsh-gpg-agent

antigen apply
