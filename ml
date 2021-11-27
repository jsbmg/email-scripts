#! /bin/sh -e
#
# Fzf email viewer
# Usage: ml [mlist option] [Inbox|Sent|...] 

[ -z $MAILDIR ] && printf "MAILDIR not set. Try 'export MAILDIR=/path/to/maildir'." && exit 

context="$MAILDIR/Inbox"
option="-s"

for var in "$@"
do
    if [[ -d "$MAILDIR/$var" ]]
    then
        context="$MAILDIR/$var"
    else
        option="$var"
    fi
done

[[ -z $(mlist $option $context ) ]] && exit 

selection=$(mlist $option $context | msort -d -r | mseq -S | mscan | fzf --preview="_fzf-mshow {}" \
          --bind "ctrl-v:execute*mless {}*" \
          --bind "ctrl-u:execute-silent*_fzf-mflag -s {} *+reload(mlist $option $context | msort -d -r | mseq -S | mscan)" \
          --bind "ctrl-r:execute-silent*_fzf-mflag -S {} *+reload(mlist $option $context | msort -d -r | mseq -S | mscan)" \
          --bind "ctrl-d:execute*fzf-mdownload {}*") || return 

printf "$selection\nReply? [Y/n]: "

read confirm

if [[ "${confirm}" != @(Y|y|yes) ]]
then 
    printf ""
    return
fi

mrep
