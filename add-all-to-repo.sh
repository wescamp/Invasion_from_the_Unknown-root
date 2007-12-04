#! /bin/bash
#    Do a recursive svn add of every new file found, after
#    updating specific directories.
#
#    Version 0.9.0
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
# * 2007-12-04: Fixed the campaign's inner root dir not being
#               processed and updated
# * 2007-12-03: Initial release 0.9.0
# * 2007-11-??: Initial attempt
#

# Initialize directory matches for WML import
CAMPAIGN_DIR="`cat ./list_IMPORTDIRS`/data/campaigns/`cat ./list_BASEDIRS`"

echo "Importing from UMC dir..."
UMC_DIR_ROOT_CONTENTS="`ls -U -1 --color=none --hide=.*`"

echo "> getting dirlist..."
UMC_DIRS="`cat ./list_WMLDIRS`"
echo "> updating..."
for d in ${UMC_DIRS}; do
	echo ">>: /`cat ./list_BASEDIRS`/${d}"
	cp -uR ${CAMPAIGN_DIR}/$d/* ./`cat ./list_BASEDIRS`/$d 2> ./__cp_output.temp
	if [ $? -ne 0 ] && [ "$1" = "--strict" ]; then
		echo "> an error ocurred during update process:"
		cat ./__cp_output.temp
		rm ./__cp_output.temp
		echo "> aborting..."
		exit
	fi
	if test -d ./`cat ./list_BASEDIRS`/$d; then
		svn add --force ./`cat ./list_BASEDIRS`/$d
	fi
done

# Do the same manually with the inner root
echo ">>: /`cat ./list_BASEDIRS`/"
for f in ${CAMPAIGN_DIR}/*.cfg; do
	cp -uR $f ./`cat ./list_BASEDIRS`/`basename $f`
	svn add --force ./`cat ./list_BASEDIRS`/`basename $f`
done

echo "Completed."
