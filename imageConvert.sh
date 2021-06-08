#!/bin/bash

# Created by Thom on 6/8/2021
# takes in src dir and dest dir parameters but there is zero error checking use at your own risk!

# cd $1
shopt -s nullglob
# STARTTIME=$(date +%T)
STARTTIME=$(date +%s)
green=`tput setaf 2`
reset=`tput sgr0`
src=$1
dest=$2
largeCount=0

### Check if a directory does not exist ###
if [ ! -d "./$src" ]
then
    echo "Directory '$src' DOES NOT exists. Exiting..."
    exit 9999 # die with error code 9999
fi

### Check if a directory does not exist ###
if [ ! -d "./$dest" ]
then
    echo "Directory '$dest' DOES NOT exists. Creating..."
    mkdir $dest
    # exit 9999 # die with error code 9999
fi

cd ./$src
for ext in jpg jpeg png gif; do
  counter=0
  files=( *."$ext" )
  printf '%s %s\n' "$src" "$dest"
  printf 'Converting %s files: %d\n' "$ext" "${#files[@]}"
  # now we can loop over all the files having the current extension

  for f in "${files[@]}"; do
    # anything else you like with these files
    counter=$((counter+1))

    size=$(stat -c%s "$f")

    if [ $size -ge 1048576 ]
    then
        size=$(awk 'BEGIN {printf "%.2f",'$size'/1048576}')M
    elif [ $size -ge 1024 ]
    then
        size=$(awk 'BEGIN {printf "%.2f",'$size'/1024}')K
    fi

    ENDTIME=$((($(date +%s) - $STARTTIME)))
    ELAPSED=$(date -u -d @$ENDTIME +"%T")
    printf '%s %d of %d (%s)(%s)\n' "${green}${f}${reset}" "${counter}" "${#files[@]}" "${size}" "${ELAPSED}"

    cd -
    echo "./$src/$f -> ./$dest/$f"
    # convert ./$src/$f -sampling-factor 4:2:0 -strip -quality 85 -colorspace RGB ./$dest/$f &
    convert -define $ext:extent=300kb -strip -interlace Plane -gaussian-blur 0.05 -quality 75% ./$src/$f ./$dest/$f &

    # convert ./$src/$f -resize '2000x1000>' ./$dest/$f & # <--- HERE <---- !!!
    cd ./$src

    :
  done
done
cd ..

wait
# cd ..
