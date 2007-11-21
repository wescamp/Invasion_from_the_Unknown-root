#! /bin/bash
# Do a recursive svn add of every new *.cfg file found, after
# updating specific directories.
# 2007-11-19 by Ignacio R. Morelle (shadowmaster)

# Initialize directory matches for WML import
CAMPAIGN_DIR="`cat ./list_IMPORTDIRS`/data/campaigns/`cat ./list_BASEDIRS`"
WHITELIST=".cfg"

#echo "Importing from UMC dir..."

# FIXME: incomplete
#for matching_dir in `cat ./list_WMLDIRS`; do
	# Make required directories
#	mkdir -p ./`cat ./list_BASEDIRS`/${matching_dir}
#	for cf in "${matching_dir}/*${WHITELIST}" do
#		cp $cf 
#	done
#done

# Add all inner files

echo "Add missing files to repository..."

for f in "./Invasion_from_the_unknown/*${WHITELIST}"; do
	svn add $f
done

echo "Update from repository..."
svn up

echo "Commit to repository..."
svn ci
