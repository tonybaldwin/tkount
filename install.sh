#!/bin/bash

##########################################################3
# This script will install tkount on a gnu/linux system.
# If you're using BSD or Mac OS, I believe it should also work fine.
# If you are using Windows, I can't help you.
##########################################################3

if [ != "$HOME/bin/" ]; then
	mkdir $HOME/bin/
	$PATH=$PATH:/$HOME/bin/
	export PATH
fi

cp tkount.tcl $HOME/bin/tkount
chmod +x $HOME/bin/tkount

echo -e "Installation complete!\n
To run tkount, execute \"tkount\" from terminal, or make a shortcut or menu item that points to $HOME/bin/tkount."

