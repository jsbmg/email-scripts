#! /bin/sh
#
# List most recent n number of emails 
# Usage: $ m [mlist filter options (see man mlist)] [mailbox name, e.g. "Inbox"] [num emails to show] 
# No args = shows the latest 10 unseen emails in $MAILDIR/Inbox 

[ -z $MAILDIR ] && printf "MAILDIR not set. Try 'export MAILDIR=/path/to/maildir'." && exit 

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

[[ -z $(mlist $option $context ) ]] && exit 

mlist $option $context | msort -d -r | mseq -S | mscan | head -n $max | sed '1!G;h;$!d'
