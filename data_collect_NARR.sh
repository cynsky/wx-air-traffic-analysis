#! /bin/sh
# This is a script for writing a longer script to download NARR weather data from NOMADS, a repository run by NOAA.
# Script author: Kenneth Kuhn
# Last modified: 3/11/2015

# Cylce through years and months of interest
for i in {2014..2014}
do
	for j in {1..12}
	do
		# ftp in to the proper month directory on NOMADS
		if [ ${j} -lt 10 ]; then
			echo "ftp ftp://nomads.ncdc.noaa.gov/NARR/${i}0${j}/<<EOT" >> NARR_script.sh
		else
			echo "ftp ftp://nomads.ncdc.noaa.gov/NARR/${i}${j}/<<EOT" >> NARR_script.sh
		fi
		echo prompt off >> NARR_script.sh
		# Cycle through the days
		for k in {1..31}
		do
			# Go to the proper day directory, if it exists
			if [ ${j} -lt 10 ]; then
				if [ ${k} -lt 10 ]; then
					echo cd ${i}0${j}0${k} >> NARR_script.sh
				else
					if [ -d ${i}0${j}${k} ]; then
						echo cd ${i}0${j}${k} >> NARR_script.sh
					fi
				fi
			else
				if [ ${k} -lt 10 ]; then
					echo cd ${i}${j}0${k} >> NARR_script.sh
				else
					if [ -d ${i}${j}${k} ]; then
						echo cd ${i}${j}${k} >> NARR_script.sh
					fi
				fi
			fi
			# download the narr data then go back to the month directory
			echo mget narr-a* >> NARR_script.sh
			echo cd .. >> NARR_script.sh
		done
		# end the ftp session
		echo bye >> NARR_script.sh
		echo "EOT" >> NARR_script.sh
		# move everything to a directory for the month on your computer
		if [ ${j} -lt 10 ]; then
			if [ ! -d ${i}0${j} ]; then
				echo mkdir ${i}0${j} >> NARR_script.sh
			fi
			echo mv narr-a* ./${i}0${j}/ >> NARR_script.sh
		else
			if [ ! -d ${i}${j} ]; then
				echo mkdir ${i}${j} >> NARR_script.sh
			fi
			echo mv narr-a* ./${i}${j}/ >> NARR_script.sh
		fi
		echo echo Got NARR data from year ${i} and month ${j} >> NARR_script.sh
	done
done
