#!/bin/sh
# This is a script for parsing RUC weather data, picking out a selection of variables, and storing them in NetCDF data files.
# This script assumes you have the ncl_convert2nc utility, freely available on the internet.
# Script author: Kenneth Kuhn
# Last modified: 2/28/2015

# Cylce through years and months of interest
for i in {2010..2012}
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
			if [ -f "ruc2_252_${day_str}_0000_002.grb" ]; then
				ncl_convert2nc ruc2_252_${day_str}_0000_002.grb -v VIS_252_SFC,P_WAT_252_EATM,ACPCP_252_SFC_acc2h,CRAIN_252_SFC,CSNOW_252_SFC,CAPE_252_SFC,REFC_252_EATM
			fi
			if [ -f "ruc2_252_${day_str}_0300_002.grb" ]; then
				ncl_convert2nc ruc2_252_${day_str}_0300_002.grb -v VIS_252_SFC,P_WAT_252_EATM,ACPCP_252_SFC_acc2h,CRAIN_252_SFC,CSNOW_252_SFC,CAPE_252_SFC,REFC_252_EATM
			fi
			if [ -f "ruc2_252_${day_str}_0600_002.grb" ]; then
				ncl_convert2nc ruc2_252_${day_str}_0600_002.grb -v VIS_252_SFC,P_WAT_252_EATM,ACPCP_252_SFC_acc2h,CRAIN_252_SFC,CSNOW_252_SFC,CAPE_252_SFC,REFC_252_EATM
			fi
			if [ -f "ruc2_252_${day_str}_0900_002.grb" ]; then
				ncl_convert2nc ruc2_252_${day_str}_0900_002.grb -v VIS_252_SFC,P_WAT_252_EATM,ACPCP_252_SFC_acc2h,CRAIN_252_SFC,CSNOW_252_SFC,CAPE_252_SFC,REFC_252_EATM
			fi
			if [ -f "ruc2_252_${day_str}_1200_002.grb" ]; then
				ncl_convert2nc ruc2_252_${day_str}_1200_002.grb -v VIS_252_SFC,P_WAT_252_EATM,ACPCP_252_SFC_acc2h,CRAIN_252_SFC,CSNOW_252_SFC,CAPE_252_SFC,REFC_252_EATM
			fi
			if [ -f "ruc2_252_${day_str}_1500_002.grb" ]; then
				ncl_convert2nc ruc2_252_${day_str}_1500_002.grb -v VIS_252_SFC,P_WAT_252_EATM,ACPCP_252_SFC_acc2h,CRAIN_252_SFC,CSNOW_252_SFC,CAPE_252_SFC,REFC_252_EATM
			fi
			if [ -f "ruc2_252_${day_str}_1800_002.grb" ]; then
				ncl_convert2nc ruc2_252_${day_str}_1800_002.grb -v VIS_252_SFC,P_WAT_252_EATM,ACPCP_252_SFC_acc2h,CRAIN_252_SFC,CSNOW_252_SFC,CAPE_252_SFC,REFC_252_EATM
			fi
			if [ -f "ruc2_252_${day_str}_2100_002.grb" ]; then
				ncl_convert2nc ruc2_252_${day_str}_2100_002.grb -v VIS_252_SFC,P_WAT_252_EATM,ACPCP_252_SFC_acc2h,CRAIN_252_SFC,CSNOW_252_SFC,CAPE_252_SFC,REFC_252_EATM
			fi
		done
		cd ..
	done
done
