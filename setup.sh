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

yn(){
	echo $1 [Y/n]
	for i in {1..3}; do
		read ans
		if [[ $ans == Y ]]; then
			return 1
		elif [[ $ans == n ]]; then
			return 0
		else
			echo "Please answer with either 'Y' (yes) or 'n' (no)."
			echo $1 [Y/n]
		fi
	done
	return 0
}

echo "Preparing RPi4B SD card setup"
echo "-----------------------------"
echo "available images:"
for i in setup/images/*.iso; do
	echo "- $i"
done
yn "Would you like to check whether new images for ubuntu server (ARM64) are available online?"
if [[ 1 -eq $? ]]; then
	
	cd setup
	./get_image.sh
	cd ..
fi
if [[ -n $( ls -l setup/images | grep .iso ) ]]; then
	yn "Would you like to burn an image onto an SD card?"
	if [[ 1 -eq $? ]]; then
		cd setup
		./burn_image.sh
		cd ..
	fi
fi
