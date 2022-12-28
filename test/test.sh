#!/bin/bash

info(){
	echo -e "\e[0;32m-->\e[0;1m $1\e[0m"
}

write(){
	cat < /dev/stdin > "$1"
}

_date(){
	[[ -z "$1" ]] && date "+%m/%d/%Y" || date -d "$1" "+%m/%d/%Y"
}


gen(){

# Generate configuration file

write "rc" << EOF
icons yes
cachedir "`pwd`"
timeformat 12
dateformat "%a, %b %d %Y"
dateformat_cfg "mm/dd/yyyy"

category "test:blue" "test2"

custom 1 '
echo "A custom section test"
echo "---------------------"
echo "Kernel : `uname -s` `uname -r`"
echo "OS     : `uname -o`"
echo "Arch   : `uname -m`"
echo "Uptime : `uptime --pretty`"
'

format "separator:0" "separator:1" "separator:2" "separator:3" "date" "calendar" "important" "todos" "events" "custom:1"
EOF

# Generate to-do's and events suitable
# for testing Whow.

write "todos" << EOF
todo "A to-do"
todo "A to-do I have to finish today" "`_date`"
todo "A to-do I have to finish tomorrow" "`_date tomorrow`"
todo "A to-do I have to finish in 3 days" "`_date "3 days"`"
todo "A to-do I forgot to do since yesterday" "`_date "yesterday"`"
todo "A to-do I've done" v
todo "A to-do I've done early" "`_date "3 days"`" v

todo "An important to-do" @important
todo "An important to-do I have to finish today" "`_date`" @important
todo "An important to-do I have to finish tomorrow" "`_date tomorrow`" @important
todo "An important to-do I have to finish in 2 days" "`_date "2 days"`" @important
todo "An important to-do I forgot to do since yesterday" "`_date "yesterday"`"
todo "An important to-do I've done" @important v
todo "An important to-do I've done early" "`_date "2 days"`" @important v

todo "A to-do with a category" @test
todo "A to-do with a category without a color" @test2
todo "A to-do with a category that I have to finish today" "`_date`" @test
todo "A to-do with a category that I have to finish tomorrow" "`_date tomorrow`" @test
todo "A to-do with a category that I have to finish in 2 days" "`_date "2 days"`" @test
todo "A to-do with a category that I forgot to do since yesterday" "`_date "yesterday"`" @test
todo "A to-do with a category I've done" @test v
todo "A to-do with a category I've done early" "`_date "3 days"`" @test v
EOF

write "events" << EOF
event "`_date`" "An event today"
event "`_date "tomorrow"`" "An event tomorrow"
event "`_date "2 days"`" "An event in 2 days"

event "`_date`" "An event today with a category" @test
event "`_date`" "An event today with a category without a color" @test2
event "`_date "tomorrow"`" "An event tomorrow" @test
event "`_date "2 days"`" "An event in 2 days" @test

event "`_date`" "An important event today" @important
event "`_date "tomorrow"`" "An important event tomorrow" @important
event "`_date "2 days"`" "An important event in 2 days" @important
event "`_date "1 year ago"`" "An event a year ago"
EOF

}

write "schedule" << EOF
sched ev "06:00 AM" "06:30 AM" "Schedule every day from 06:00 AM to 06:30 AM"
sched wd "06:00 AM" "06:30 AM" "Schedule on weekdays from 06:00 AM to 06:30 AM"
sched we "06:00 AM" "06:30 AM" "Schedule on weekends from 06:00 AM to 06:30 AM"
sched ev "08:00 AM" % "Schedule without end time every day"
sched mon "09:00 AM" "10:00 AM" "Schedule every Monday"
sched tue "09:00 AM" "10:00 AM" "Schedule every Tuesday, with category" @test
EOF

if ! [[ "$1" == "nogen" ]]
then
	gen
fi

set -e
# Call Whow (assuming it's on ..)
[[ -z "$WHOW_PATH" ]] && WHOW_PATH="`pwd`/../whow"

_whow(){
	"$WHOW_PATH" -c "`pwd`/rc" "$@"
}

info 'Check 1: options'

info 'Testing help'
_whow --help

#####

info 'Check 2: show commands'

info 'Testing `whow show`'
_whow show

info 'Testing `whow show important`'
_whow show important

info 'Testing `whow show todos`'
_whow show todos

info 'Testing `whow show events`'
_whow show events

#####

info 'Check 3: to-do commands'

info "Showing to-do's"
_whow show todos

info "Deleting to-do's (\`whow todo del all\`)"
_whow todo del all

info "Showing to-do's"
_whow show todos

info 'Testing `whow todo add "An added to-do"`'
_whow todo add "An added to-do"

info 'Testing `whow todo add "An added to-do" @test`'
_whow todo add "An added to-do" @test

info 'Testing `whow todo add "An added to-do" @important`'
_whow todo add "An added to-do" @important

info 'Testing `whow todo add "An added to-do" "tomorrow"`'
_whow todo add "An added to-do" "tomorrow"

info "Showing to-do's"
_whow show todos

info 'Testing `whow todo mark 1`'
_whow todo mark 1

info 'Testing `whow todo mark 4`'
_whow todo mark 4

info 'Testing `whow todo del 1`'
_whow todo del 1

info 'Testing `whow todo del 3`'
_whow todo del 3

info "Showing to-do's"
_whow show todos


#####

info 'Check 4: events commands'

info "Showing events"
_whow show events

info "Deleting to-do's (\`whow event del all\`)"
_whow event del all

info "Showing to-do's"
_whow show events

info 'Testing `whow event add "today" "An event today"`'
_whow event add "today" "An event today"

info 'Testing `whow event add "tomorrow" "An event tomorrow"` @test'
_whow event add "tomorrow" "An event tomorrow" @test

info 'Testing `whow event add "2 days" "An event in 2 days" @important`'
_whow event add "2 days" "An event in 2 days" @important

info "Showing events"
_whow show events

info 'Testing `whow event del 1`'
_whow event del 1

info 'Testing `whow event del 2`'
_whow event del 2

info "Showing to-do's"
_whow show events


#####

info 'Check 5: schedule commands'

info "Showing schedule"
_whow show schedule
