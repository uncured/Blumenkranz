#!/bin/bash
IFS=$'\n'
DIR=''
for file in $(find . -name '*.h'); do
	CURRENT_DIR=`dirname $file`
	CURRENT_FILE=`basename $file`
	if [ "$CURRENT_FILE" != "Blumenkranz.h" ]; then
		if [ "$DIR" != "$CURRENT_DIR" ]; then
			DIR=$CURRENT_DIR
			echo "/${DIR#'.'}"
		fi
	    echo "#import \"$CURRENT_FILE\""
	fi
done