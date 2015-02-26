#! /bin/sh
# This is a script for downloading NARR weather data from NOMADS, a repository run by NOAA.
# Script author: Kenneth Kuhn
# Last modified: 2/26/2015

# Cylce through years and months of interest
for i in {2010..2013}
do
	for j in {1..12}
	do
		# ftp in to the proper month directory on NOMADS
		if [ ${j} -lt 10 ]; then
			ftp ftp://nomads.ncdc.noaa.gov/NARR/${i}0${j}/<<**
		else
			ftp ftp://nomads.ncdc.noaa.gov/NARR/${i}${j}/<<**
		fi
		prompt off
		# Cycle through the days
		for k in {1..31}
		do
			# Go to the proper day directory, if it exists
			if [ ${j} -lt 10 ]; then
				if [ ${k} -lt 10 ]; then
					cd ${i}0${j}0${k}
				else
					if [ -d ${i}0${j}${k} ]; then
						cd ${i}0${j}${k}
					fi
				fi
			else
				if [ ${k} -lt 10 ]; then
					cd ${i}${j}0${k}
				else
					if [ -d ${i}${j}${k} ]; then
						cd ${i}${j}${k}
					fi
				fi
			fi
			# download the narr data then go back to the month directory
			mget narr-a*
			cd ..
		done
		# end the ftp session
		bye
		**
		# move everything to a directory for the month on your computer
		if [ ${j} -lt 10 ]; then
			if [ ! -d ${i}0${j} ]; then
				mkdir ${i}0${j}
			fi
			mv narr-a* ./${i}0${j}/
		else
			if [ ! -d ${i}${j} ]; then
				mkdir ${i}${j}
			fi
			mv narr-a* ./${i}${j}/
		fi
		echo Got NARR data from year ${i} and month ${j} 
	done
done
