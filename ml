#! /bin/sh -e
#
# Fzf email viewer
# Usage: ml [MLIST OPTION] [MAILBOX: Inbox|Sent|...etc]
#
# Options:
# If the name of a valid maildir subfolder is passed (e.g. Inbox,
# Sent, etc.), that mailbox will be displayed. All other options are
# passed to mlist (see $ man mlist).

[ -z $MAILDIR ] && printf "MAILDIR not set. \
        Try 'export MAILDIR=/path/to/maildir'." && exit

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

if [[ -z "$context" ]]
then
    for d in $MAILDIR/*/
    do
        if [ -d "$d" ]
        then
            if [[ $(basename $d) == @(Inbox|INBOX|inbox) ]]
            then
                context=$d
            fi
            if [[ -n "$context" ]]; then
                break
            fi
        fi
    done
fi

if [[ -z "$context" ]]
then
    printf "No inbox found in $MAILDIR.\n"
    return
fi

[[ -z $(mlist $option $context ) ]] && exit

selection=$(mlist $option $context | msort -d -r | mseq -S | mscan | fzf \
          --preview="_fzf-mshow {}" \
          --bind "ctrl-u:execute-silent*_fzf-mflag -s {}*
                  +reload[_ml-reload $option $context]" \
          --bind "ctrl-r:execute-silent*_fzf-mflag -S {}*
                  +reload[_ml-reload $option $context]" \
          --bind "ctrl-v:execute*mless {} < /dev/tty > /dev/tty 2>&1*" \
          --bind "ctrl-d:execute*md {}*") || return

printf "$selection\nReply? [Y/n]: "

read confirm

if [[ "${confirm}" != @(Y|y|yes) ]]
then
    printf ""
    return
fi

mrep
