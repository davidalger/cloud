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
# generic aliases

alias trail="tail -f"
alias mreports='grep -rE ^a: var/report/ | cut -d '\''#'\'' -f 1 | cut -d '\'';'\'' -f 2 | sort | uniq -c | sort -n'
alias mexceptions='ack "^Exception" "$1" | sort | uniq -c | sort -nr | vi -c "set nowrap" -'

########################################
# setup git aliases if they do not exist

if [ -x "$(which git 2> /dev/null)" ]; then
    if [ "$(git config --global --get alias.permission-reset)" = "" ]; then
        git config --global --add alias.permission-reset \
            '!git diff -p -R | grep -E "^(diff|(old|new) mode)" | git apply'
    fi

    # TODO convert these to git aliases
    alias git-log-pretty='git log --pretty=format:"%h %ad %an %s" --date=short'
    alias git-log-graph='git log --all --decorate --graph --color=always'
    alias git-prune-remote-branches='git branch -r --merged | grep -v develop | grep -v master | grep origin | grep -v "$(git branch | grep \* | cut -d " " -f2)" | grep -v ">" | xargs -L1 | cut -d "/" -f2-5 | xargs git push origin --delete'
    alias git-prune-local-branches='git branch --merged | grep -v develop | grep -v master | grep -v "$(git branch | grep \* | cut -d " " -f2)" | grep -v ">" | xargs -L1 | xargs -n1 git branch -d'
fi

# timestamp for use in file names
alias ts="date +%F_%H-%M-%S"
