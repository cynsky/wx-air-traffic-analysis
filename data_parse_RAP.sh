#!/bin/sh
# This is a script for parsing RAP weather data, picking out a selection of variables, and storing them in NetCDF data files.
# This script assumes you have the ncl_convert2nc utility, freely available on the internet.
# Script author: Kenneth Kuhn
# Last modified: 2/28/2015

# Cylce through years and months of interest
for i in {2014..2015}
do
	for j in {1..12}
	do
		# Go to the correct directory, based on the file structure from the data_collect_RUC.sh file
		if [ ${j} -lt 10 ]; then
			cd ${i}0${j}
		else
			cd ${i}${j}
		fi
		# Cycle through the days
		for k in {1..31}
		do
			# Set up the day string
			if [ ${j} -lt 10 ]; then
				if [ ${k} -lt 10 ]; then
					day_str=${i}0${j}0${k}
				else
					day_str=${i}0${j}${k}
				fi
			else
				if [ ${k} -lt 10 ]; then
					day_str=${i}${j}0${k}
				else
					day_str=${i}${j}${k}
				fi
			fi
			if [ -f "rap_252_${day_str}_0000_002.grb2" ]; then
				ncl_convert2nc rap_252_${day_str}_0000_002.grb2 -v VIS_P0_L1_GLC0,PWAT_P0_L200_GLC0,ACPCP_P8_L1_GLC0_acc2h,CRAIN_P0_L1_GLC0,CSNOW_P0_L1_GLC0,CAPE_P0_L1_GLC0,REFC_P0_L200_GLC0
			fi
			if [ -f "rap_252_${day_str}_0300_002.grb2" ]; then
				ncl_convert2nc rap_252_${day_str}_0300_002.grb2 -v VIS_P0_L1_GLC0,PWAT_P0_L200_GLC0,ACPCP_P8_L1_GLC0_acc2h,CRAIN_P0_L1_GLC0,CSNOW_P0_L1_GLC0,CAPE_P0_L1_GLC0,REFC_P0_L200_GLC0
			fi
			if [ -f "rap_252_${day_str}_0600_002.grb2" ]; then
				ncl_convert2nc rap_252_${day_str}_0600_002.grb2 -v VIS_P0_L1_GLC0,PWAT_P0_L200_GLC0,ACPCP_P8_L1_GLC0_acc2h,CRAIN_P0_L1_GLC0,CSNOW_P0_L1_GLC0,CAPE_P0_L1_GLC0,REFC_P0_L200_GLC0
			fi
			if [ -f "rap_252_${day_str}_0900_002.grb2" ]; then
				ncl_convert2nc rap_252_${day_str}_0900_002.grb2 -v VIS_P0_L1_GLC0,PWAT_P0_L200_GLC0,ACPCP_P8_L1_GLC0_acc2h,CRAIN_P0_L1_GLC0,CSNOW_P0_L1_GLC0,CAPE_P0_L1_GLC0,REFC_P0_L200_GLC0
			fi
			if [ -f "rap_252_${day_str}_1200_002.grb2" ]; then
				ncl_convert2nc rap_252_${day_str}_1200_002.grb2 -v VIS_P0_L1_GLC0,PWAT_P0_L200_GLC0,ACPCP_P8_L1_GLC0_acc2h,CRAIN_P0_L1_GLC0,CSNOW_P0_L1_GLC0,CAPE_P0_L1_GLC0,REFC_P0_L200_GLC0
			fi
			if [ -f "rap_252_${day_str}_1500_002.grb2" ]; then
				ncl_convert2nc rap_252_${day_str}_1500_002.grb2 -v VIS_P0_L1_GLC0,PWAT_P0_L200_GLC0,ACPCP_P8_L1_GLC0_acc2h,CRAIN_P0_L1_GLC0,CSNOW_P0_L1_GLC0,CAPE_P0_L1_GLC0,REFC_P0_L200_GLC0
			fi
			if [ -f "rap_252_${day_str}_1800_002.grb2" ]; then
				ncl_convert2nc rap_252_${day_str}_1800_002.grb2 -v VIS_P0_L1_GLC0,PWAT_P0_L200_GLC0,ACPCP_P8_L1_GLC0_acc2h,CRAIN_P0_L1_GLC0,CSNOW_P0_L1_GLC0,CAPE_P0_L1_GLC0,REFC_P0_L200_GLC0
			fi
			if [ -f "rap_252_${day_str}_2100_002.grb2" ]; then
				ncl_convert2nc rap_252_${day_str}_2100_002.grb2 -v VIS_P0_L1_GLC0,PWAT_P0_L200_GLC0,ACPCP_P8_L1_GLC0_acc2h,CRAIN_P0_L1_GLC0,CSNOW_P0_L1_GLC0,CAPE_P0_L1_GLC0,REFC_P0_L200_GLC0
			fi
		done
		cd ..
	done
done

