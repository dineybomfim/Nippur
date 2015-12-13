#/bin/bash

# Definitions
BASEDIR="$( dirname "$0" )"
DESTDIR="/Library/Developer/Xcode/Templates/"

# Start working
echo "---"
echo "Copying files from $BASEDIR to $DESTDIR"

cd "$BASEDIR"
sudo mkdir -p /Library/Developer/Xcode/Templates/
sudo cp -R "File Templates" /Library/Developer/Xcode/Templates/
sudo cp -R "Project Templates" /Library/Developer/Xcode/Templates/

echo "New Xcode Templates were installed at $DESTDIR"
echo "---"
