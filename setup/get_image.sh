#!/bin/bash

#    PIZARD - a quick raspberryPI setup wiZARD
#    Copyright (C) 2022 Joel Fischer
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

echo "Fetching information from ubuntu.com..."
mkdir -p tmp
wget -q https://ubuntu.com/download/server/arm -P tmp
LATEST=$(cat tmp/arm | grep -oE 'https.*.iso')
rm tmp/arm

if [[ -n $(ls images | grep current.txt) ]]; then
	AVAIL=$(cat images/current.txt)
else
	AVAIL="none"
fi

echo ""
echo "Latest version of ubuntu server:"
echo $LATEST
echo "Current available image:"
echo $AVAIL
echo ""

if [[ $LATEST == $AVAIL ]]; then
	echo "Latest version already present. Nothing to be done."
else
	echo "There is a newer image available. Would you like to download it? [Y/n]"
	for i in {1..3}; do
		read ans
		if [[ ans == Y ]]; then
			mkdir -p images
			wget $LATEST -P images
			echo $LATEST > images/current.txt
		elif [[ ans == n ]]; then
			break
		else
			echo "Please answer with either 'Y' or 'n'"
			echo "Would you like to download the latest image? [Y/n]"
		fi
	done
fi
