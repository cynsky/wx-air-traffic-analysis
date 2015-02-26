#! /bin/sh
# This is a script for downloading RAP weather data from NOMADS, a repository run by NOAA.
# Script author: Kenneth Kuhn
# Last modified: 2/26/2015

# Cylce through years and months of interest
for i in {2013..2014}
do
	for j in {1..12}
	do
		# ftp in to the proper month directory on NOMADS
		if [ ${j} -lt 10 ]; then
			ftp ftp://nomads.ncdc.noaa.gov/RUC/20km/${i}0${j}/<<**
		else
			ftp ftp://nomads.ncdc.noaa.gov/RUC/20km/${i}${j}/<<**
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
			# download the RAP data then go back to the month directory
			# here we focus on 2 hour forecast data and collect it once every 3 hours
			mget rap_252*0000_002.grb2
			mget rap_252*0300_002.grb2
			mget rap_252*0600_002.grb2
			mget rap_252*0900_002.grb2
			mget rap_252*1200_002.grb2
			mget rap_252*1500_002.grb2
			mget rap_252*1800_002.grb2
			mget rap_252*2100_002.grb2
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
			mv rap_252* ./${i}${j}/
		fi
		echo Got RAP data from year ${i} and month ${j} 
	done
done
