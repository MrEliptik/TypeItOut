#!/bin/bash

# Check if file already exists
if ! test -f "TypeItOut.x86_64"; then
	# curl get the JSON response from the latest URL
	# grep find the line containing the URL
	# cut and tr extract the URL
	# wget downloads the URL
	curl -s https://api.github.com/repos/MrEliptik/TypeItOut/releases/latest \
	| grep "browser_download_url.*x86_64" \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -i -
fi
# Make sure its executable
chmod +x TypeItOut.x86_64

# Launch the game
./TypeItOut.x86_64
