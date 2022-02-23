#! /bin/bash
#
# Fzf email viewer

source lib;

read -r -d '' USAGE << EndOfMessage
Usage: ml [MLIST OPTION] [MAILBOX]

Required variables:
    MAILDIR: The email directory (in maildir format) e.g. $HOME/.mail

Mailbox options:
    Any option that is the name of a folder within the MAILDIR directory
    will be interpreted as the mailbox to open. If no mailbox option is
    provided, the default mailbox will be Inbox, INBOX, or inbox, if any
    of those folders exist.

mlist options:
    Any options with a '-' prefix are passed to mlist. For example, '-s'
    will shown unread emails. See the mlist manpage for all options. The
    default option is '-s'. To see all emails of any flag, use '-a'.

Keybindings:
    Enter     = select message for further action
    ctrl+k    = up
    ctrl+j    = down
    ctrl+l    = scroll preview up
    ctrl+h    = scroll preview down
    ctrl+r    = mark read
    ctrl+u    = mark unread
    backspace = trash message
    ctrl_m    = change context
    ctrl+v    = view a message
    ctrl+f    = forward a message
    ctrl+r    = reply to a message
    ctrl+n    = compose a new message
    ctrl+d    = download attatchments (to ~/Downloads)
    ctrl+b    = browse links in selected email
    ctrl+c    = quit

Examples:
    Show unread emails in inbox:
        ml
    Show unread emails in sent folder:
        ml Sent
    Show read emails in Trash folder:
        ml -S Trash
    Show all emails in inbox:
        ml -a
EndOfMessage

usage() {
    echo "$USAGE"
}

[ -z "$MAILDIR" ] && printf "MAILDIR not set. \
        Try 'export MAILDIR=/path/to/maildir'." && exit

# the default option to pass to mlist (show unread emails)
option="-s"

for arg in "$@"
do
    if [[ "$arg" == @(-h|--help) ]]; then
        usage && exit 0
    elif [[ -d "$MAILDIR/$arg" ]]; then
        mailbox="$MAILDIR/$arg"
    else
        if [[ "$arg" == -a ]]; then
            option=""
        else
            option=$arg
        fi
    fi
done

# find inbox dir
if [[ -z "$mailbox" ]]
then
    for dir in $(mdirs "$MAILDIR"); do
        basename=$(basename "$dir" | tr '[:upper:]' '[:lower:]')
        if [[ "$basename" == inbox ]]; then
                mailbox="$dir"
                break
        fi
    done
fi

if [[ -z "$mailbox" ]]; then
    printf "No inbox found in $MAILDIR.\n"
    exit
fi

[[ -z "$(mlist $option $mailbox)" ]] && exit

# position the preview on bottom if column with < 140
if [[ "$(tput cols)" -lt 140 ]]; then
    preview_pos="down"
else
    preview_pos="right"
fi

while true; do
    selection=$(_load $option $mailbox | mscan | fzf \
        --height 100% \
        --border \
        --no-sort \
        --preview="source lib; _mshow {}" \
        --preview-window="$preview_pos" \
        --bind "ctrl-l:preview-half-page-down" \
        --bind "ctrl-h:preview-half-page-up" \
        --bind "enter:execute*source lib; _mless {} < /dev/tty > /dev/tty 2>&1*" \
        --bind "ctrl-u:execute-silent*source lib; _mflag -s {}*+reload[source lib; _load $option $mailbox | mscan]" \
        --bind "ctrl-r:execute-silent*source lib; _mflag -S {}*+reload[source lib; _load $option $mailbox | mscan]" \
        --bind "ctrl-t:execute-silent*source lib; _mflag -T {}*+reload[source lib; _load $option $mailbox | mscan]" \
        --bind "ctrl-f:execute*mfwd {} < /dev/tty > /dev/tty 2>&1*" \
        --bind "ctrl-i:execute*source lib; _change_context*+reload[cat $HOME/.mblaze/seq | mscan]" \
        --bind "ctrl-n:execute*mcom < /dev/tty > /dev/tty 2>&1*" \
        --bind "ctrl-o:execute*source lib; _mrep {} < /dev/tty > /dev/tty 2>&1*" \
        --bind "ctrl-b:execute*source lib; _mlinks {} < /dev/tty > /dev/tty 2>&1*" \
        --bind "ctrl-g:execute[source lib; _mgrep $option $mailbox < /dev/tty > /dev/tty 2>&1]+reload[cat $HOME/.mblaze/seq | mscan]" \
        --bind "ctrl-d:execute*source lib; _mdown {} < /dev/tty > /dev/tty 2>&1*")

    [[ -z "$selection" ]] && exit
done
