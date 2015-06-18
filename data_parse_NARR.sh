#!/bin/sh
# This is a script for parsing NARR weather data, picking out a selection of variables, and storing them in NetCDF data files.
# This script assumes you have the ncl_convert2nc utility, freely available on the internet.
# Script author: Kenneth Kuhn
# Last modified: 2/28/2015

# Cylce through years and months of interest
for i in {2014..2014}
do
	for j in {1..2}
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
			if [ -f "narr-a_221_${day_str}_0000_000.grb" ]; then
				ncl_convert2nc narr-a_221_${day_str}_0000_000.grb -v VIS_221_SFC,P_WAT_221_EATM,A_PCP_221_SFC_acc3h,ACPCP_221_SFC_acc3h,T_CDC_221_EATM,CRAIN_221_SFC,CSNOW_221_SFC,CAPE_221_SFC,CAPE_221_SPDY,TKE_221_ISBL,TKE_221_HYBL,HLCY_221_HTGY
			fi
			if [ -f "narr-a_221_${day_str}_0300_000.grb" ]; then
				ncl_convert2nc narr-a_221_${day_str}_0300_000.grb -v VIS_221_SFC,P_WAT_221_EATM,A_PCP_221_SFC_acc3h,ACPCP_221_SFC_acc3h,T_CDC_221_EATM,CRAIN_221_SFC,CSNOW_221_SFC,CAPE_221_SFC,CAPE_221_SPDY,TKE_221_ISBL,TKE_221_HYBL,HLCY_221_HTGY
			fi
			if [ -f "narr-a_221_${day_str}_0600_000.grb" ]; then
				ncl_convert2nc narr-a_221_${day_str}_0600_000.grb -v VIS_221_SFC,P_WAT_221_EATM,A_PCP_221_SFC_acc3h,ACPCP_221_SFC_acc3h,T_CDC_221_EATM,CRAIN_221_SFC,CSNOW_221_SFC,CAPE_221_SFC,CAPE_221_SPDY,TKE_221_ISBL,TKE_221_HYBL,HLCY_221_HTGY
			fi
			if [ -f "narr-a_221_${day_str}_0900_000.grb" ]; then
				ncl_convert2nc narr-a_221_${day_str}_0900_000.grb -v VIS_221_SFC,P_WAT_221_EATM,A_PCP_221_SFC_acc3h,ACPCP_221_SFC_acc3h,T_CDC_221_EATM,CRAIN_221_SFC,CSNOW_221_SFC,CAPE_221_SFC,CAPE_221_SPDY,TKE_221_ISBL,TKE_221_HYBL,HLCY_221_HTGY
			fi
			if [ -f "narr-a_221_${day_str}_1200_000.grb" ]; then
				ncl_convert2nc narr-a_221_${day_str}_1200_000.grb -v VIS_221_SFC,P_WAT_221_EATM,A_PCP_221_SFC_acc3h,ACPCP_221_SFC_acc3h,T_CDC_221_EATM,CRAIN_221_SFC,CSNOW_221_SFC,CAPE_221_SFC,CAPE_221_SPDY,TKE_221_ISBL,TKE_221_HYBL,HLCY_221_HTGY
			fi
			if [ -f "narr-a_221_${day_str}_1500_000.grb" ]; then
				ncl_convert2nc narr-a_221_${day_str}_1500_000.grb -v VIS_221_SFC,P_WAT_221_EATM,A_PCP_221_SFC_acc3h,ACPCP_221_SFC_acc3h,T_CDC_221_EATM,CRAIN_221_SFC,CSNOW_221_SFC,CAPE_221_SFC,CAPE_221_SPDY,TKE_221_ISBL,TKE_221_HYBL,HLCY_221_HTGY
			fi
			if [ -f "narr-a_221_${day_str}_1800_000.grb" ]; then
				ncl_convert2nc narr-a_221_${day_str}_1800_000.grb -v VIS_221_SFC,P_WAT_221_EATM,A_PCP_221_SFC_acc3h,ACPCP_221_SFC_acc3h,T_CDC_221_EATM,CRAIN_221_SFC,CSNOW_221_SFC,CAPE_221_SFC,CAPE_221_SPDY,TKE_221_ISBL,TKE_221_HYBL,HLCY_221_HTGY
			fi
			if [ -f "narr-a_221_${day_str}_2100_000.grb" ]; then
				ncl_convert2nc narr-a_221_${day_str}_2100_000.grb -v VIS_221_SFC,P_WAT_221_EATM,A_PCP_221_SFC_acc3h,ACPCP_221_SFC_acc3h,T_CDC_221_EATM,CRAIN_221_SFC,CSNOW_221_SFC,CAPE_221_SFC,CAPE_221_SPDY,TKE_221_ISBL,TKE_221_HYBL,HLCY_221_HTGY
			fi
		done
		cd ..
	done
done
