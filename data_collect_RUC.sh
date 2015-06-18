#! /bin/sh
# This is a script for writing a longer script to download RUC weather data from NOMADS, a repository run by NOAA.
# Script author: Kenneth Kuhn
# Last modified: 3/12/2015

# Cylce through years and months of interest
for i in {2015..2015}
do
	for j in 4
	do
		# ftp in to the proper month directory on NOMADS
		if [ ${j} -lt 10 ]; then
			echo "ftp ftp://nomads.ncdc.noaa.gov/RUC/20km/${i}0${j}/<<EOT" >> RUC_script.sh
		else
			echo "ftp ftp://nomads.ncdc.noaa.gov/RUC/20km/${i}${j}/<<EOT" >> RUC_script.sh
		fi
		echo prompt off >> RUC_script.sh
		# Cycle through the days
		for k in {21..30}
		do
			# Go to the proper day directory, if it exists
			if [ ${j} -lt 10 ]; then
				if [ ${k} -lt 10 ]; then
					echo cd ${i}0${j}0${k} >> RUC_script.sh
				else
					echo cd ${i}0${j}${k} >> RUC_script.sh
				fi
			else
				if [ ${k} -lt 10 ]; then
					echo cd ${i}${j}0${k} >> RUC_script.sh
				else
					echo cd ${i}${j}${k} >> RUC_script.sh
				fi
			fi
			# download the RUC data then go back to the month directory
			# here we focus on 2 hour forecast data and collect it once every 3 hours
			echo mget ruc2*0000_002.grb >> RUC_script.sh
			echo mget ruc2*0300_002.grb >> RUC_script.sh
			echo mget ruc2*0600_002.grb >> RUC_script.sh
			echo mget ruc2*0900_002.grb >> RUC_script.sh
			echo mget ruc2*1200_002.grb >> RUC_script.sh
			echo mget ruc2*1500_002.grb >> RUC_script.sh
			echo mget ruc2*1800_002.grb >> RUC_script.sh
			echo mget ruc2*2100_002.grb >> RUC_script.sh
			echo cd .. >> RUC_script.sh
		done
		# end the ftp session
		echo bye >> RUC_script.sh
		echo "EOT" >> RUC_script.sh
		# move everything to a directory for the month on your computer
		if [ ${j} -lt 10 ]; then
			if [ ! -d ${i}0${j} ]; then
				echo mkdir ${i}0${j} >> RUC_script.sh
			fi
			echo mv narr-a* ./${i}0${j}/ >> RUC_script.sh
		else
			if [ ! -d ${i}${j} ]; then
				echo mkdir ${i}${j} >> RUC_script.sh
			fi
			echo mv RUC_252* ./${i}${j}/ >> RUC_script.sh
		fi
		echo "echo Got RUC data from year ${i} and month ${j}" >> RUC_script.sh
	done
done
