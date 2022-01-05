# mblaze scripts

This repository contains a few helpful scripts for using email with [mblaze](https://github.com/leahneukirchen/mblaze). 

`m` - quickly show what's in the inbox 

`ml` - view, mark, and reply to messages using [fzf](https://github.com/junegunn/fzf)

`mf` - flag messages 

`md` - download attatchments 

### Note
The scripts use the maildir directory specified by the MAILDIR environmental variable to locate the mail. For example:

`$ echo "export MAILDIR=~/.mail" >> ~/.bashrc`

