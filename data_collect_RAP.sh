#! /bin/sh
# This is a script for writing a longer script to download RAP weather data from NOMADS, a repository run by NOAA.
# Script author: Kenneth Kuhn
# Last modified: 3/12/2015

# Cylce through years and months of interest
for i in {2013..2014}
do
	for j in 1 3
	do
		# ftp in to the proper month directory on NOMADS
		if [ ${j} -lt 10 ]; then
			echo "ftp ftp://nomads.ncdc.noaa.gov/RUC/20km/${i}0${j}/<<EOT" >> RAP_script.sh
		else
			echo "ftp ftp://nomads.ncdc.noaa.gov/RUC/20km/${i}${j}/<<EOT" >> RAP_script.sh
		fi
		echo prompt off >> RAP_script.sh
		# Cycle through the days
		for k in {1..31}
		do
			# Go to the proper day directory, if it exists
			if [ ${j} -lt 10 ]; then
				if [ ${k} -lt 10 ]; then
					echo cd ${i}0${j}0${k} >> RAP_script.sh
				else
					echo cd ${i}0${j}${k} >> RAP_script.sh
				fi
			else
				if [ ${k} -lt 10 ]; then
					echo cd ${i}${j}0${k} >> RAP_script.sh
				else
					echo cd ${i}${j}${k} >> RAP_script.sh
				fi
			fi
			# download the RAP data then go back to the month directory
			# here we focus on 2 hour forecast data and collect it once every 3 hours
			echo mget rap_252*0000_002.grb2 >> RAP_script.sh
			echo mget rap_252*0300_002.grb2 >> RAP_script.sh
			echo mget rap_252*0600_002.grb2 >> RAP_script.sh
			echo mget rap_252*0900_002.grb2 >> RAP_script.sh
			echo mget rap_252*1200_002.grb2 >> RAP_script.sh
			echo mget rap_252*1500_002.grb2 >> RAP_script.sh
			echo mget rap_252*1800_002.grb2 >> RAP_script.sh
			echo mget rap_252*2100_002.grb2 >> RAP_script.sh
			echo cd .. >> RAP_script.sh
		done
		# end the ftp session
		echo bye >> RAP_script.sh
		echo "EOT" >> RAP_script.sh
		# move everything to a directory for the month on your computer
		if [ ${j} -lt 10 ]; then
			if [ ! -d ${i}0${j} ]; then
				echo mkdir ${i}0${j} >> RAP_script.sh
			fi
			echo mv narr-a* ./${i}0${j}/ >> RAP_script.sh
		else
			if [ ! -d ${i}${j} ]; then
				echo mkdir ${i}${j} >> RAP_script.sh
			fi
			echo mv rap_252* ./${i}${j}/ >> RAP_script.sh
		fi
		echo "echo Got RAP data from year ${i} and month ${j}" >> RAP_script.sh
	done
done
