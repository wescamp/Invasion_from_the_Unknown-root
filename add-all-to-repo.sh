#! /bin/bash
#    Do a recursive svn add of every new file found, after
#    updating specific directories.
#
#    Version 0.9.1
#
#    Copyright (C) 2007 by Ignacio Riquelme M. <shadowm2006@gmail.com>
#    Part of the WesCamp-i18n Project
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 2
#    or at your option any later version.
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY.
#
#   See the COPYING file for more details.
#
# Changelog
# ---------
# * 2007-12-04 (10:04 PM):
#               Added more sanity checks, better output, etc.
#               Also can decide how to resolve missing files in the UMC or Wescamp checkout dirs
#               Optimized a bit (less disk I/O requests for the tagfiles), possibly making
#               the script more human-readable in the process. :-P
# * 2007-12-04 (01:00 AM):
#               Fixed the campaign's inner root dir not being
#               processed and updated
# * 2007-12-03: Initial release 0.9.0
# * 2007-11-??: Initial attempt
#

echo "Checking WesCamp checkout integrity (fast method)..."

if ! [ -d ./po ]; then
	echo "> po source directory does not exist, or ./po is not a directory!"
	exit
fi

if ! [ -f ./list_BASEDIRS ]; then
	echo "> essential tag file 'list_BASEDIRS' cannot be found in current directory!"
	exit
fi

BASE_DIR="`cat ./list_BASEDIRS`"

if ! [ -d ./${BASE_DIR} ]; then
	echo "> base directory of check out, '${BASE_DIR}', does not exist, or is not a directory!"
	exit
fi

# Some platforms or environments seem not to provide the HOME env. variable
if [ $HOME ]; then
	IMPORT_DIR="$HOME/.wesnoth"
else
	IMPORT_DIR="~/.wesnoth"
fi

if ! [ -f ./list_IMPORTDIRS ]; then
	echo "> essential tag file 'list_IMPORTDIRS' cannot be found in current directory; assuming default Wesnoth preferences directory as '$IMPORT_DIR'!"
else
	IMPORT_DIR="`cat ./list_IMPORTDIRS`"
fi

echo "Scanning UMC dir integrity..."

# Initialize directory matches for WML import
CAMPAIGN_DIR="${IMPORT_DIR}/data/campaigns/`cat ./list_BASEDIRS`"

# Probe campaign directory
if ! [ -d $CAMPAIGN_DIR ]; then
	echo "> UMC dir '${CAMPAIGN_DIR}' does not exist or is not a directory!"
	exit
fi

# Probe manifest file (try with both old-style and new-style flavors)
if [ -f "${CAMPAIGN_DIR}.cfg" ]; then
	CAMPAIGN_MANIFEST="${CAMPAIGN_DIR}.cfg"
else
	if [ -f "${CAMPAIGN_DIR}/_main.cfg" ]; then
		CAMPAIGN_MANIFEST="${CAMPAIGN_DIR}/_main.cfg"
	else
		echo "> could not find a suitable UMC manifest file; UMC might be broken!"
	fi
fi

# As everything seems to be fine so far, try to update tagfiles if they
# are present in the UMC dir, importing them to WesCamp. If they are missing,
# copy them to the UMC dir

echo "Verifying tagfiles integrity..."

# Tag file name suffix used in the UMC dir to make sure the files have proper Windows Shell-compatible file type extensions
TAG_FILENAME_SUFFIX=".tag"

UPDATE_BASEDIRS="1"
UPDATE_IMPORTDIRS="1"
UPDATE_WMLDIRS="1"

if ! [ -f ${CAMPAIGN_DIR}/list_BASEDIRS${TAG_FILENAME_SUFFIX} ]; then
	if ! [ -f ./list_BASEDIRS ]; then
		echo "> BASEDIRS tag file missing both in UMC dir and WesCamp checkout, or is not a regular file!"
		exit
	fi
	cp ./list_BASEDIRS ${CAMPAIGN_DIR}/list_BASEDIRS${TAG_FILENAME_SUFFIX}
	touch -c ./list_BASEDIRS
	UPDATE_BASEDIRS="0"
	echo "> restored missing BASEDIRS tag in UMC dir"
fi

if ! [ -f ${CAMPAIGN_DIR}/list_IMPORTDIRS${TAG_FILENAME_SUFFIX} ]; then
	if ! [ -f ./list_IMPORTDIRS ]; then
		echo "> IMPORTDIRS tag file missing both in UMC dir and WesCamp checkout, or is not a regular file!"
		exit
	fi
	cp ./list_IMPORTDIRS ${CAMPAIGN_DIR}/list_IMPORTDIRS${TAG_FILENAME_SUFFIX}
	touch -c ./list_IMPORTDIRS
	UPDATE_IMPORTDIRS="0"
	echo "> restored missing IMPORTDIRS tag in UMC dir"
fi

if ! [ -f ${CAMPAIGN_DIR}/list_WMLDIRS${TAG_FILENAME_SUFFIX} ]; then
	if ! [ -f ./list_WMLDIRS ]; then
		echo "> WMLDIRS tag file missing both in UMC dir and WesCamp checkout, or is not a regular file!"
		exit
	fi
	cp ./list_WMLDIRS ${CAMPAIGN_DIR}/list_WMLDIRS${TAG_FILENAME_SUFFIX}
	touch -c ./list_WMLDIRS
	UPDATE_WMLDIRS="0"
	echo "> restored missing WMLDIRS tag in UMC dir"
fi

# Try updating...
# If we did export some missing tagfiles to the UMC dir in the above step, as they
# were touch-ed, their WesCamp copies should be newer than the UMC copies, thus preventing
# system resources wasting on doing a file copy operation between identical files

if [ ${CAMPAIGN_DIR}/list_BASEDIRS${TAG_FILENAME_SUFFIX} -nt ./list_BASEDIRS ]; then
	cp -u ${CAMPAIGN_DIR}/list_BASEDIRS${TAG_FILENAME_SUFFIX} ./list_BASEDIRS
	echo "> BASEDIRS tag out-dated in WesCamp check-out; fixed by updating from UMC dir"
else
	if [ ${CAMPAIGN_DIR}/list_BASEDIRS${TAG_FILENAME_SUFFIX} -ot ./list_BASEDIRS ]; then
		cp -u ./list_BASEDIRS ${CAMPAIGN_DIR}/list_BASEDIRS${TAG_FILENAME_SUFFIX}
		echo "> BASEDIRS tag out-dated in UMC dir; fixed by updating from WesCamp check-out"
	fi
fi

if [ ${CAMPAIGN_DIR}/list_IMPORTDIRS${TAG_FILENAME_SUFFIX} -nt ./list_IMPORTDIRS ]; then
	cp -u ${CAMPAIGN_DIR}/list_IMPORTDIRS${TAG_FILENAME_SUFFIX} ./list_IMPORTDIRS
	echo "> IMPORTDIRS tag out-dated in WesCamp check-out; fixed by updating from UMC dir"
else
	if [ ${CAMPAIGN_DIR}/list_IMPORTDIRS${TAG_FILENAME_SUFFIX} -ot ./list_IMPORTDIRS ]; then
		cp -u ./list_IMPORTDIRS ${CAMPAIGN_DIR}/list_IMPORTDIRS${TAG_FILENAME_SUFFIX}
		echo "> IMPORTDIRS tag out-dated in UMC dir; fixed by updating from WesCamp check-out"
	fi
fi

if [ ${CAMPAIGN_DIR}/list_WMLDIRS${TAG_FILENAME_SUFFIX} -nt ./list_WMLDIRS ]; then
	cp -u ${CAMPAIGN_DIR}/list_WMLDIRS${TAG_FILENAME_SUFFIX} ./list_WMLDIRS
	echo "> WMLDIRS tag out-dated in WesCamp check-out; fixed by updating from UMC dir"
else
	if [ ${CAMPAIGN_DIR}/list_WMLDIRS${TAG_FILENAME_SUFFIX} -ot ./list_WMLDIRS ]; then
		cp -u ./list_WMLDIRS ${CAMPAIGN_DIR}/list_WMLDIRS${TAG_FILENAME_SUFFIX}
		echo "> WMLDIRS tag out-dated in UMC dir; fixed by updating from WesCamp check-out"
	fi
fi

echo "Importing from UMC dir..."
echo "> getting dirlist..."
UMC_DIRS="`cat ./list_WMLDIRS`"
echo "> updating..."
for d in ${UMC_DIRS}; do
	echo ">>: /${BASE_DIR}/${d}"
	# Don't output anything except in case of errors, unless --strict was passed as parameter
	cp -uR ${CAMPAIGN_DIR}/$d/* ./${BASE_DIR}/$d 2> ./__cp_output.temp
	if [ $? -ne 0 ] && [ "$1" = "--strict" ]; then
		echo "> an error ocurred during update process:"
		cat ./__cp_output.temp
		rm ./__cp_output.temp
		echo "> aborting..."
		exit
	fi
	if test -d ./${BASE_DIR}/$d; then
		svn add --force ./${BASE_DIR}/$d
	fi
done

# Do the same manually with the inner root
echo ">>: /${BASE_DIR}/"
for f in ${CAMPAIGN_DIR}/*.cfg; do
	cp -uR $f ./${BASE_DIR}/`basename $f`
	svn add --force ./${BASE_DIR}/`basename $f`
done

echo "Completed. Now you are ready to do your commit!"
