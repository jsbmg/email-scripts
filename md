#! /bin/sh -e
#
# Download email attachments
# Usage:
#    md [NUM]
# Options:
#    NUM - the email (as enumerated by the `m` command)

case $1 in
    ''|*[!0-9]*) printf "No message number specified. \
            Use the \"m\" command to view a list of messages.\n" && exit ;;
    *)
esac

printf "\33[0;31m$(mscan $1)\033[0m\n\n"
mshow -t $1
printf "\nDownload attachments? [Y/n]: "

read confirm

if [[ $confirm = @(Y|y|yes) ]]
then
    mshow -x $1
else
    printf ""
    return
fi

