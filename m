#! /bin/bash
#
# List most recent emails
# Usage: $ m [MLIST OPTION] [MAILBOX] [NUM]
#
# Options:
# MLIST OPTION
#    Any option that can be passed to mlist (e.g. "-S")
# MAILBOX
#    The maildir subfolder (e.g. Inbox, Sent, etc.)
# NUM
#    The number of most recent emails to show
#
# No options = shows the latest 10 unseen emails in $MAILDIR/Inbox
source lib;

if [ -z $MAILDIR ]; then
    printf "MAILDIR not set. Try 'export MAILDIR=/path/to/maildir'."
    exit
fi

context="$MAILDIR/Inbox"
option="-s"
max="10"

for var in "$@"
do
    if [[ -d "$MAILDIR/$var" ]]
    then
        context="$MAILDIR/$var"
    else
        case $var in
            ''|*[0-9]*) max=$var ;;
            *) option=$var ;;
        esac
    fi
done

[ -z "$(mlist $option $context)" ] && exit

mlist $option $context | \
        ml_sort | \
        mseq -S | \
        mscan | \
        head -n $max | \
        sed '1!G;h;$!d'
