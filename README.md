Sun 26 Apr 2020 10:12:30 AM EDT


# General Information

  BEFORE running this script for the first time you will likely want to edit it to change the parameters for the locations of the collection you want to index and the results.  Look for the section starting with "Local Configuration".

  mcol_pictures.sh is a bash script which will use exiftool to scan your collection to create names that are unique according to the date the picture was taken and the shutter count.  If your camera does not have the shutter count field kept in the data for your pictures you may want to use exiftool to examine a picture and find some other field to use instead (or you can edit the script to remove it entirely).

  There are three options to use:

    - the default is to make a hard link in the the index to your collection so that the original file is left where it was first placed, you can also specify this by using the -l or --link options.
    - the -c or --copy options will make a copy while creating the new name in the index.
    - the -m or --move options moves the file from the collection to the index which means the original file in the collection is removed as the new file is created.  the contents of the moved file should not be changed in any significant manner by exiftool.

  Both copy and link may report errors because files already exist, these are not really errors - look at the totals to see how many were actually copied or linked.

  The only options the script takes are [-h]|[--help], [-v]|[--verbose], [-V]|[--Version], [-c]|[--copy], [-l]|[--link] or [-m]|[--move]

  Read through the script it is largely meant to be self evident and self documented.  The LICENSE file is provided to make sure you have the full text of that.


# To Install for a Linux/Posix Type System

  mcol_pictures.sh has various linux/posix/unix type tools used within it so if you are trying to use it on any other type system then those you will either have to figure out what is different and fix it or work around it.

  Some of the dependencies are: exiftool and find, there are perhaps others.

  To run the script it needs to be in the $PATH as an executable.  It should run from anywhere.  The directories this script operates on are specified using ${HOME} and specificly the pics/collection and pics/index subdirectories.


# Bug Reporting

  Please use the issue tracker on github for this project.


