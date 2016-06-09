#!/usr/bin/env bash
##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

########################################
# set environemnt variables

# set magento developer mode env vars
export MAGE_IS_DEVELOPER_MODE=0
export MAGE_MODE=production

# configure PATH to use local and user scripts
export PATH=~/bin:/usr/local/bin:$PATH:/usr/local/sbin

# Fancy PS1 with flashing username / red path for root login
if [[ $EUID -ne 0 ]]; then
    export PS1='\[\033[0;36m\]\u@\h\[\033[0m\]:\@:\[\033[0;37m\]\w\[\033[0m\]$ '
else
    export PS1='\[\033[0;5m\]\u@\h\[\033[0m\]:\@:\[\033[0;31m\]\w\[\033[0m\]# '
fi

# Color output
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# Allow for easy searching of history
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
