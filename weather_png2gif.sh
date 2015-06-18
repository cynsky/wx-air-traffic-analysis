#! /bin/sh
#
# This is a script for turning png image files showing precipitation around New York,
# local airports, fixes, and airways into gif files.
# Script author: Kenneth Kuhn
# Last modified: 4/24/2015

echo Turning weather maps into gifs

for i in {2013..2015}
do
	for j in {1..12}
	do
		for k in {1..31}
		do
			if [ ${j} -lt 10 ]; then
				if [ ${k} -lt 10 ]; then
					# gm convert -delay 40 /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_0${j}_0${k}*.png /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_0${j}_0${k}.gif
					if [ -e /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_0${j}_0${k}_00.png ]; then
						gm convert -delay 40 /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_0${j}_0${k}*.png /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_0${j}_0${k}.gif
					fi
				else
					# if [ -e /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_0${j}_${k}_00.png ]; then
					# 	gm convert -delay 40 /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_0${j}_${k}*.png /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_0${j}_${k}.gif
					# fi
					if [ -e /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_0${j}_${k}_00.png ]; then
						gm convert -delay 40 /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_0${j}_${k}*.png /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_0${j}_${k}.gif
					fi
				fi
			else
				if [ ${k} -lt 10 ]; then
					# gm convert -delay 40 /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_${j}_0${k}*.png /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_${j}_0${k}.gif
					if [ -e /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_${j}_0${k}_00.png ]; then
						gm convert -delay 40 /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_${j}_0${k}*.png /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_${j}_0${k}.gif
					fi
				else
					# if [ -e /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_${j}_${k}_00.png ]; then
					# 	gm convert -delay 40 /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_${j}_${k}*.png /Volumes/NASA_data_copy/output_other/nyc_wx_gifs/Wx_${i}_${j}_${k}.gif
					# fi
					if [ -e /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_${j}_${k}_00.png ]; then
						gm convert -delay 40 /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_${j}_${k}*.png /Volumes/NASA_data/output_other/nyc_wx_gifs/Wx_${i}_${j}_${k}.gif
					fi
				fi
			fi
		done
	done
done
