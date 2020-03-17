#!/bin/bash


# This script can either move files, copy files or link
# files of your collection to another directory called 
# the index.
#
# The default behavior is a hard link (because that takes
# the least amount of space).
#
# Check the below Notes and Local Configuration sections 
# for futher details.


# Please read through this LICENSE and the rest of the script.


# LICENSE:
#
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2020 Flowerbug <flowerbug@anthive.com>
#
#
# Copyright 2020 Flowerbug <flowerbug@anthive.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Notes:
#
# this script uses exiftool to move, copy or link picture files from
# your collection to an index.
#
# the link is the easiest to do as that involves no moving of the
# files it just sets up a unique name based upon the time and date
# when the picture was taken along with the ShutterCount which is
# a feature of the camera i am using.  if this is not a feature your
# camera has it might have some other similar feature so you may
# need to check out what exiftool reports for a picture taken with
# your camera and adjust this script to use that name instead.
#
# if you don't specify any options when you run this script then a
# link is made as the default operation.
#
# if you want the script to copy the picture to the index (and rename
# it at the same time) use the -c or --copy option.
#
# for moving pictures use the -m or --move option.  NOTE this does
# remove the original file from your collection.
#


# Local Configuration


# base picture directory
PIC_BASE="${HOME}/pics"

# picture collections directories
PIC_COLL="${PIC_BASE}/collection"

# links to collection directories
PIC_INDEX="${PIC_BASE}/index"


# End Local Configuration

#
# accepted options for the script
function usage_message () {
  echo -e "\n\nUsage: $0\n\n\
  [-c] | [--copy]          copy files (leaves originals alone)\n\n\
  [-h] | [--help]          this help\n\n\
  [-l] | [--link]          link files (leaves originals alone and is\n\
                               the default if no other option is used)\n\n\
  [-m] | [--move]          move files (removes originals)\n\n\
  [-v] | [--verbose]       print out more as things happen\n\n\
  [-V] | [--Version]       give the version number\n\n\
" >&2
exit
}


# check options
copy_files="0"
help="0"
link_files="1"
move_files="0"
verbose="0"
version="0"
while test "$1" != "" ; do
  case "$1" in
    "-c")
        copy_files="1" # copy instead of move or link
        link_files="0"
        move_files="0"
        ;;
    "--copy")
        copy_files="1" # copy instead of move or link
        link_files="0"
        move_files="0"
        ;;
    "-h")
        help="1"       # print some help text
        ;;
    "--help")
        help="1"       # print some help text
        ;;
    "-l")
        link_files="1" # link (default)
        copy_files="0"
        move_files="0"
        ;;
    "--link")
        link_files="1" # link (default)
        copy_files="0"
        move_files="0"
        ;;
    "-m")
        move_files="1" # move instead of link or copy
        copy_files="0"
        link_files="0"
        ;;
    "--move")
        move_files="1" # move instead of link or copy
        copy_files="0"
        link_files="0"
        ;;
    "-v")
        verbose="1"    # print what is happening
        ;;
    "--verbose")
        verbose="1"    # print what is happening
        ;;
    "-V")
        version="1"    # give the version
        ;;
    "--Version")
        version="1"    # give the version
        ;;
    *)
      leading_char=`echo $1 | cut -c 1`
      if test "${leading_char}" == "-" ; then
        echo -e "\nUnrecognized option $1 to $0\n\n"
        usage_message $0
      else
        echo -e "\nUnrecognized parameters $1 to $0\n\n"
        usage_message $0
      fi
        ;;
  esac
shift
done


# print the version if asked and then exit
if test "${version}" == "1" ; then
  echo "$0 Version 1.0.3"
  exit
fi


# print help if asked then exit
if test "${help}" == "1" ; then
  usage_message $0
fi


# if they ask for it print out more of what is happening
if test "${verbose}" == "1" ; then
  verb="-v2"
else
  verb=" "
fi


# save me a lot of typing
function printout ( ) {

  if test "${verbose}" == "1" ; then
    echo -e "$1"
  fi
  }


date

echo -e "\n"


# check to make sure all the needed directories exist and if they
# don't create them.


# the most basic one first
if test ! -d ${PIC_COLL} ; then
  echo -e "${PIC_COLL} doesn't exist.  Create it...\n"
  mkdir -p ${PIC_COLL}
fi


# where the files end up
if test ! -d ${PIC_INDEX} ; then
  echo -e "${PIC_INDEX} doesn't exist.  Create it...\n"
  mkdir ${PIC_INDEX}
fi

# what action are we taking
if test ${link_files} == "1" ; then
  action="link"
elif test ${copy_files} == "1" ; then
  action="copy"
elif test ${move_files} == "1" ; then
  action="move"
else
  # this shouldn't be possible from what i've set above but i'll
  # leave this in anyways
  echo -e "No action selected...  Nothing to do...  Exiting...\n\n"
  date
  exit
fi

# how many collections do we have
count_coll=`find ${PIC_COLL}/ -maxdepth 1 -type d -exec printf %.0s. {} + 2>/dev/null | wc -m`

# but we have one too many as find includes the top directory
count_coll=$(($count_coll-1))
echo -e "\nThere are ${count_coll} collection(s) to ${action}."

list_coll=`find ${PIC_COLL}/ -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | tail -n +2 | sort`

# ok we have the list of collections to work with
for coll_dir_name in ${list_coll} ; do

  # make sure we have pictures to act upon
  count_them=`find ${PIC_COLL}/${coll_dir_name} -type f -exec printf %.0s. {} + 2>/dev/null | wc -m`
  printout "\n ${count_them} files in collection ${coll_dir_name}\n"
  if test "${count_them}" == "0" ; then
    echo -e "\n  No files to act upon in collection ${coll_dir_name}...  Nothing done...\n\n"
  else
    if test ${link_files} == "1" ; then 
      echo -e "\n  Linking collection ${coll_dir_name}...\n\n"
      exiftool ${verb} -P ${PIC_INDEX} -fileOrder CreateDate -d ${PIC_INDEX}/%Y/%m/%d/${coll_dir_name}_%Y%m%d_%H%M%S%z '-HardLink<${CreateDate}_${ShutterCount}.%e' ${PIC_COLL}/${coll_dir_name}/*
    elif test ${copy_files} == "1" ; then
      echo -e "\n  Copying collection ${coll_dir_name}...\n\n"
      exiftool ${verb} -P -o ${PIC_INDEX} -fileOrder CreateDate -d ${PIC_INDEX}/%Y/%m/%d/${coll_dir_name}_%Y%m%d_%H%M%S%z '-FileName<${CreateDate}_${ShutterCount}.%e' ${PIC_COLL}/${coll_dir_name}/*
    elif test ${move_files} == "1" ; then
      echo -e "\n  Moving collection ${coll_dir_name}...\n\n"
      exiftool ${verb} -P ${PIC_INDEX} -fileOrder CreateDate -d ${PIC_INDEX}/%Y/%m/%d/${coll_dir_name}_%Y%m%d_%H%M%S%z '-FileName<${CreateDate}_${ShutterCount}.%e' ${PIC_COLL}/${coll_dir_name}/*
    else
      echo -e "What?  Should be an action selected somehow...  Exiting...\n\n"
      date
      exit
    fi
    exif_status="$?"
    printout "Exif Exit Status : ${exif_status}"
    if test "${exif_status}" == "0" ; then
      echo -e "\n\n  Exiftool Exit Status Ok.  Collection ${coll_dir_name} completed...\n\n"
    else
      echo -e "Exiftool Exit Status ${exif_status} is non-zero which means exiftool found some kind of error(s) during moving, copying or linking files."
      exit ${exif_status}
    fi
  fi

done
date
