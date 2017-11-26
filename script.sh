#!/bin/bash

set -e

PPT_PATH="$1"
DST_PATH="$2"
INFERT_COLOR="$3"
FILE_NAME=$(echo $PPT_PATH | cut -f 1 -d '.')

VERSION=0.0.1

info() {
     local green="\033[1;32m"
     local normal="\033[0m"
     echo -e "[${green}INFO${normal}] $1"
}

error() {
     local red="\033[1;31m"
     local normal="\033[0m"
     echo -e "[${red}ERROR${normal}] $1"
}

usage() {
cat << EOF
VERSION: $VERSION
USAGE:
    $1 srcfile
    $2 distpath
    $3 infert the color (TRUE of FALSE)

DESCRIPTION:
    This script aim to get images from a ppt file.

    srcfile  - The source ppt file.
    distpath - The location where the file should be saved.

    This script is depend on the mac app LibreOffice. So you must install LibreOffice first

AUTHOR:
    Matthias<github@dolstra.mem>

LICENSE:
    This script follow MIT license.

EXAMPLE:
    $0 test.ppt dist FALSE
EOF
}


# Check LibreOffice
command -v /Applications/LibreOffice.app/Contents/MacOS/soffice --headless --convert-to odp >/dev/null 2>&1 || { error >&2 "The LibreOffice is not installed. Please install it first."; exit -1; }

# Check param
if [[ -z $PPT_PATH ]];then
    usage
    exit -1
fi

# Check dst path whether exist.
if [ ! -d "$DST_PATH" ];then
    mkdir -p "$DST_PATH"
fi


echo "Exporting the images from the .ppt"
/Applications/LibreOffice.app/Contents/MacOS/soffice  --headless --convert-to odp "$PPT_PATH"
# echo "$FILE_NAME".odp
unzip  -j "$FILE_NAME".odp "Pictures/*" -d "$DST_PATH/" -o
rm "$FILE_NAME".odp

FILES=./"${DST_PATH}"/*

if [INFERT_COLOR == 'YES'];then

  # Check if ImageMagick is installed
  command -v convert >/dev/null 2>&1 || { error >&2 "The ImageMagick is not installed. Please use brew on OSX to install it first."; exit -1; }

  # loop trough the files and infert the color.
  for f in $FILES
  do
  if [[ "$f" == *\.* ]]
  then
    #infert the color with convert
    convert -negate "$f" "$f"
  fi
  done
fi

mv "$PPT_PATH" "./$DST_PATH/$PPT_PATH"
mv "$DST_PATH" "$FILE_NAME"
