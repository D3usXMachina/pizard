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


notmnt(){
	MNT=(`lsblk -p | grep $1 | sed -n 's/├─//g; s/└─//g; s/ \+/ /g; s/\(.*\) part \/\(.*\)/\1 \2/p' | sed 's/ \(.*\) / /g'`)
	if [[ -n $MNT ]]; then
		echo "Please unmount all partitions of $1."
		echo "The following partitions are still mounted:"
		I=0
		while [[ -n ${MNT[$(($I + 1))]} ]]; do
			echo "-"$'\t'${MNT[$I]} "@" ${MNT[$(($I + 1))]}
			I=$((I + 2))
		done
		echo "Would you like for these partitions to be automatically unmounted (requires root privileges)? [Y/n]"
		for i in {1..3}; do
			read UNMOUNT
			if [[ $UNMOUNT == Y ]]; then
				I=0
				while [[ -n ${MNT[$(($I + 1))]} ]]; do
					umount -v ${MNT[$I]}
				       	I=$(($I + 2))
				done
				return 1	
			elif [[ $UNMOUNT == n ]]; then
				return 0
			else
				echo "Please answer with either 'Y' (yes) or 'n' (no)"
				echo "Would you like to automatically unmount these partitions? [Y/n]"
				read UMOUNT
			fi
		done
		return 0
	fi
	return 2
}

echo "Please make sure the installation media (SD card) is not inserted."
echo "If it is, please unmount and remove it and press Enter when ready."
read IGNORE
mkdir -p tmp
lsblk -p > tmp/blk_wo_sd.txt

echo "Please insert the installation media (SD card) and press Enter when ready."
read IGNORE
lsblk -p > tmp/blk_w_sd.txt

diff tmp/blk_wo_sd.txt tmp/blk_w_sd.txt > tmp/diff.txt
DEVICE=$(cat tmp/diff.txt | sed -n 2p | sed 's/> // ; s/ \+/ /g; s/ .*//')

if [[ -n $DEVICE ]]; then
	echo "The following device has been identified:"
	echo "-"$'\t'$DEVICE
else
	echo "No device could be identified. Aborting."
	exit
fi

echo "The following images are available:"

ISOS=(`ls images/*.iso`)

for i in ${!ISOS[@]}; do
	echo $i$'\t'${ISOS[$i]}
done

echo "Please select the image you would like to burn to" $DEVICE "by entering the corresponding number:"
for i in {1:3}; do
	read ISONUM
	if [[ $ISONUM -lt ${#ISOS[@]} && $ISONUM -ge 0 ]]; then
		echo "You have selected: " ${ISOS[$ISONUM]}
		break
	else
		echo "Invalid choice. Please select a number between 0 and " ${#ISOS[@]}
	fi
done

if [[ $ISONUM -ge ${#ISOS[@]} || $ISONUM -lt 0 ]]; then
	echo "No valid image chosen. Aborting."
	exit
fi

notmnt $DEVICE
if [[ $? == 0 ]]; then
	echo "Please unmount the partitions yourself and then press Enter to continue."
	read IGNORE
fi
notmnt $DEVICE
if [[ $? != 2 ]]; then
	echo "Cannot proceed with partitions still mounted. Aborting."
	exit
fi

echo "Ready."
echo "Are you sure that you wish to burn " ${ISOS[$ISONUM]} " unto " $DEVICE " ? [Y/n]"
read SURE
if [[ SURE == 'Y' ]]; then
	unzip -p <os.zip> | sudo dd of=/dev/<diskname> bs=4M conv=fsync status=progress
else
	echo "Aborting."
	exit
fi
