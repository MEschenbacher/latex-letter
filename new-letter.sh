#!/bin/bash -eu

# https://github.com/MEschenbacher/latex-letter

config=${LETTERCONFIG:-$HOME/.letter.conf}
lettersource=${LETTERSOURCE:-$HOME/.letter.tex}
histfile=${LETTERHISTFILE:-$HOME/.address_history}

source "$config"

open=true
targetdir=''
skip=false

while getopts "nd:so:t:h" opt; do
	case $opt in
		n)  open=false;;
		d)
			targetdir="$OPTARG"
			if [ ! -d "$targetdir" ]; then
				echo "$targetdir" does not exist
				exit 1
			fi
			;;
		s)  skip=true;;
		o)
			if [ -e "$OPTARG" ]; then
				echo "$OPTARG" does exist
				exit 1
			fi
			targetfile="$OPTARG"
			;;
		t)
			lettersource="$OPTARG"
			if [ ! -e "$lettersource" ]; then
				echo "$lettersource" does not exist
				exit 1
			fi
			;;
		h|*)
			echo Usage "$0" [-n] [-d DIR] [-s] [-o FILE] [-t FILE]
			echo -e ' -n\t\t' does not open \$EDITOR on the created file
			echo -e ' -d DIR\t\t' saves the created file in DIR
			echo -e ' -s\t\t' skips variables which are unlikely to change
			echo -e ' -o FILE\t' saves the file as FILE
			echo -e ' -t FILE\t' use FILE as template source file
			exit 1
			;;
	esac
done

if [ "$skip" = false ]; then
	printf "fromname [%s] " "$fromname"
	read -r fromname_new
	if [ "$fromname_new" != "" ]; then
		fromname="$fromname_new"
	fi

	printf "fromaddress [%s] " "$fromaddress"
	read -r fromaddress_new
	if [ "$fromaddress_new" != "" ]; then
		fromaddress="$fromaddress_new"
	fi

	printf "fromphone [%s] " "$fromphone"
	read -r fromphone_new
	if [ "$fromphone_new" != "" ]; then
		fromphone="$fromphone_new"
	fi

	printf "fromemail [%s] " "$fromemail"
	read -r fromemail_new
	if [ "$fromemail_new" != "" ]; then
		fromemail="$fromemail_new"
	fi

	printf "signature [%s] " "$signature"
	read -r signature_new
	if [ "$signature_new" != "" ]; then
		signature="$signature_new"
	fi

	printf "place [%s] " "$place"
	read -r place_new
	if [ "$place_new" != "" ]; then
		place="$place_new"
	fi

	printf "date [%s] " "$date"
	read -r date_new
	if [ "$date_new" != "" ]; then
		date="$date_new"
	fi

	printf "opening [%s] " "$opening"
	read -r opening_new
	if [ "$opening_new" != "" ]; then
		opening="$opening_new"
	fi

	printf "closing [%s] " "$closing"
	read -r closing_new
	if [ "$closing_new" != "" ]; then
		closing="$closing_new"
	fi

fi # if skip

printf "firstfoot (bank information?) [%s] " "$firstfoot"
read -r firstfoot_new
if [ "$firstfoot_new" != "" ]; then
	firstfoot="$firstfoot_new"
fi

while : ; do
	printf "receiver [%s] " "$receiver"
	if [ -e "$histfile" ]; then
		if [ "$receiver" != "" ]; then
			receiver_new=$(echo "$receiver" | cat - "$histfile" | uniq | dmenu)
		else
			receiver_new=$(uniq "$histfile" | dmenu)
		fi
	else
		read -r receiver_new
	fi
	if [ "$receiver_new" != "" ]; then
		echo "$receiver_new" >> "$histfile"
		receiver="$receiver_new"
		break
	fi
done

printf "subject [%s] " "$subject"
read -r subject_new
if [ "$subject_new" != "" ]; then
	subject="$subject_new"
fi

printf "their reference [%s] " "$yourref"
read -r yourref_new
if [ "$yourref_new" != "" ]; then
	yourref="$yourref_new"
fi

printf "their date [%s] " "$yourmail"
read -r yourmail_new
if [ "$yourmail_new" != "" ]; then
	yourmail="$yourmail_new"
fi

printf "member identification [%s] " "$memberident"
read -r memberident_new
if [ "$memberident_new" != "" ]; then
	memberident="$memberident_new"
fi

# if subject is given, infer different file name which includes the subject
if [ -n "$subject" ]; then
	targetfile="letter_$(date +%Y-%m-%d)-$(slugify "$subject").tex"
fi

# use targetdir if not empty
if [ -n "$targetdir" ]; then
	targetfile="$targetdir/$targetfile"
fi

while : ; do
	printf "targetfile [%s] (enter creates file) " "$targetfile"
	read -r targetfile_new
	if [ "$targetfile_new" != "" ]; then
		targetfile="$targetfile_new"
	fi
	if [ -e "$targetfile" ]; then
		echo "$targetfile" already exists. Please retry.
	else
		break
	fi
done

m4 \
	-D __FROMNAME__="$fromname" \
	-D __FROMADDRESS__="$fromaddress" \
	-D __FROMPHONE__="$fromphone" \
	-D __FROMEMAIL__="$fromemail" \
	-D __SIGNATURE__="$signature" \
	-D __PLACE__="$place" \
	-D __DATE__="$date" \
	-D __FIRSTFOOT__="$firstfoot" \
	-D __RECEIVER__="$receiver" \
	-D __SUBJECT__="$subject" \
	-D __OPENING__="$opening" \
	-D __CLOSING__="$closing" \
	-D __YOURREF__="$yourref" \
	-D __YOURMAIL__="$yourmail" \
	-D __MEMBERIDENT__="$memberident" \
	"$lettersource" >> "$targetfile"

if [ "$open" = true ]; then
	if [[ $EDITOR == *vim ]] || [[ $EDITOR == *vi ]]; then
		exec "$EDITOR" "$targetfile" '+/^\\opening'
	else
		exec "$EDITOR" "$targetfile"
	fi
fi
