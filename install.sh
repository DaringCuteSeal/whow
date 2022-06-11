#!/usr/bin/env sh

if [[ -n "$1" ]]
then
	root="$1"
else
	root="/"
fi
	
install -Dm 755 whow "$root/usr/bin/whow"
