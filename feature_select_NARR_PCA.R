# This is a script for using Principal Components Analysis to reduce the dimensionality of collected NARR
# aviation weather data, creating a smaller set of independent variables that account for as much of the 
# variability in the NARR data as possible.
#
# The time frame here is days so that we are trying to explain variability between days.
#
# Script author: Kenneth Kuhn
# Last modified: 2/28/2015

# Load the library needed for reading in NetCDF files
library(ncdf)

# Point out the base directories for reading in and saving data
input_dir = "/Volumes/NASA_data_copy/data_raw/airspace_weather/NARR/"
output_dir = "/Volumes/NASA_data_copy/features_data/"

# Identify the years, months, and timestamps for which we have data
# Days depends on the month, so we don't do that here
years = c("2010","2011","2012","2013")
months = c("01","02","03","04","05","06","07","08","09","10","11","12")
timestamps = c("0000","0300","0600","0900","1200","1500","1800","2100")

# The first step is to reformat the data, putting in data frames where each row represents a day.
#
# Warning: this can take awhile, like 4 hours on my laptop.  There's probably a faster way to do this.

# We'll look at 3 cases, focusing on the New York area (1), Atlanta (2), and the entire US (3).
for (case in 1:3) {

	# We start by selecting locations of interest depending on the case we are interested in.
	# Selecting a huge number of locations would yield an even huger set of data points describing each
	# day (8 obs per day and 8 wx variables for each location) which would be unworkable.
	# Selecting a small number of locations would do the work we want PCA to do: dimension reduction.
	#
	if (case==1) {
		ind_rows = c(239,249,259,269)
		ind_cols = c(145,135,125,115)	
	} else if (case==2) {
		ind_rows = c(225,235,245,255)
		ind_cols = c(111,101,91,81)
	} else {
		ind_rows = c(130,146,162,178,194,210,226,242,258,274,290)
		ind_cols = c(55,66,77,88,99,110,121,132,143,154,165)
	}

	# Cycle through the months of interest, using an index
	for (year_ind in 1:4) {
		# Cycle through the years of interest, using an index
		for (month_ind in 1:12) {
			# Identify the days - in the relevant month - for which we have data
			days = c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
			if (month_ind %in% c(1,3,5,7,8,10,12)) { days=c(days,"29","30","31") }
			if (month_ind %in% c(4,6,9,11)) { days=c(days,"29","30") }
			if (month_ind==2 & year_ind==3) { days=c(days,"29") }
			# Calculate the number of days and data points per day in the relevant month for each variable
			n_days = length(days)
			n_data = length(timestamps)*length(ind_rows)*length(ind_cols)
			# Set up matrices for each weather variable to capture data for this month
			vis = matrix(,nrow=n_days,ncol=n_data)
			precip_wat = matrix(,nrow=n_days,ncol=n_data)
			t_precip = matrix(,nrow=n_days,ncol=n_data)
			c_precip = matrix(,nrow=n_days,ncol=n_data)
			clouds = matrix(,nrow=n_days,ncol=n_data)
			rain = matrix(,nrow=n_days,ncol=n_data)
			snow = matrix(,nrow=n_days,ncol=n_data)
			potential = matrix(,nrow=n_days,ncol=n_data)
			TKE = matrix(,nrow=n_days,ncol=n_data)
			# Cycle through the days of interest, using an index
			for (day_index in 1:n_days) {
				# Set up a vector for each weather variable to capture data for this day
				vect_vis = c()
				vect_precip_wat = c()
				vect_t_precip = c()
				vect_c_precip = c()
				vect_clouds = c()
				vect_rain = c()
				vect_snow = c()
				vect_potential = c()
				vect_TKE = c()
				# Cycle through the timestamps of interest, using an index
				for (time_index in 1:length(timestamps)) {
					# Open the relevant NetCDF file
					fname = paste(input_dir,years[year_ind],months[month_ind],"/narr-a_221_",years[year_ind],months[month_ind],days[day_index],"_",timestamps[time_index],"_000.nc",sep="")
					temp.nc = open.ncdf(fname)
					# Get the relevant variables from the NetCDF file
					visibility = get.var.ncdf(temp.nc,"VIS_221_SFC")
					precipitable_water = get.var.ncdf(temp.nc,"P_WAT_221_EATM")
					total_precip = get.var.ncdf(temp.nc,"A_PCP_221_SFC_acc3h")
					convect_precip = get.var.ncdf(temp.nc,"ACPCP_221_SFC_acc3h")
					cloud_cover = get.var.ncdf(temp.nc,"T_CDC_221_EATM")
					raining = get.var.ncdf(temp.nc,"CRAIN_221_SFC")
					snowing = get.var.ncdf(temp.nc,"CSNOW_221_SFC")
					CAPE = get.var.ncdf(temp.nc,"CAPE_221_SFC")
					turbulent_kinetic_energy = get.var.ncdf(temp.nc,"TKE_221_ISBL")
					turbulent_kinetic_energy = turbulent_kinetic_energy[,,15]
					# Close the relevant NetCDF file
					close.ncdf(temp.nc)
					# Attach the cells of interest to each vector
					vect_vis = c(vect_vis,c(visibility[ind_rows,ind_cols]))
					vect_precip_wat = c(vect_precip_wat,c(precipitable_water[ind_rows,ind_cols]))
					vect_t_precip = c(vect_t_precip,c(total_precip[ind_rows,ind_cols]))
					vect_c_precip = c(vect_c_precip,c(convect_precip[ind_rows,ind_cols]))
					vect_clouds = c(vect_clouds,c(cloud_cover[ind_rows,ind_cols]))
					vect_rain = c(vect_rain,c(raining[ind_rows,ind_cols]))
					vect_snow = c(vect_snow,c(snowing[ind_rows,ind_cols]))
					vect_potential = c(vect_potential,c(CAPE[ind_rows,ind_cols]))
					vect_TKE = c(vect_TKE,c(turbulent_kinetic_energy[ind_rows,ind_cols]))
					# Throw out the data from this NetCDF file we no longer need
					rm(temp.nc,visibility,precipitable_water,total_precip,convect_precip,cloud_cover,raining,snowing,CAPE,turbulent_kinetic_energy)
				}
				# Load the vectors into the matrices
				vis[day_index,] = vect_vis
				precip_wat[day_index,] = vect_precip_wat
				t_precip[day_index,] = vect_t_precip
				c_precip[day_index,] = vect_c_precip
				clouds[day_index,] = vect_clouds
				rain[day_index,] = vect_rain
				snow[day_index,] = vect_snow
				potential[day_index,] = vect_potential
				TKE[day_index,] = vect_TKE
				# Throw out the vectors
				rm(vect_vis,vect_precip_wat,vect_t_precip,vect_c_precip,vect_clouds,vect_rain,vect_snow,vect_potential,vect_TKE)
			}
			# Save the resulting matrices
			if (case==1) {
				fname = paste(output_dir,"NARR_table_NY_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			} else if (case==2) {
				fname = paste(output_dir,"NARR_table_ATL_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			} else {
				fname = paste(output_dir,"NARR_table_USA_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			}
			save(vis,precip_wat,t_precip,c_precip,clouds,rain,snow,potential,TKE,file=fname)
			# Throw out the matrices
			rm(vis,precip_wat,t_precip,c_precip,clouds,rain,snow,potential,TKE)
		}
	}
}

# Next step: apply PCA, using two distinct methodologies.
for (case in 1:3) {
	# Set up blank matrices for each weather variable
	if (case==1) {
		n_data = 128
	} else if (case==2) {
		n_data = 128
	} else {
		n_data = 968
	}
	one_vis = matrix(0,nrow=0,ncol=n_data)
	one_precip_wat = matrix(0,nrow=0,ncol=n_data)
	one_t_precip = matrix(0,nrow=0,ncol=n_data)
	one_c_precip = matrix(0,nrow=0,ncol=n_data)
	one_clouds = matrix(0,nrow=0,ncol=n_data)
	one_rain = matrix(0,nrow=0,ncol=n_data)
	one_snow = matrix(0,nrow=0,ncol=n_data)
	one_potential = matrix(0,nrow=0,ncol=n_data)
	one_TKE = matrix(0,nrow=0,ncol=n_data)
	# Cycle through the years and months of interest
	for (year_ind in 1:4) {
		for (month_ind in 1:12) {
			# Load the data from this month
			if (case==1) {
				fname = paste(output_dir,"NARR_table_NY_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			} else if (case==2) {
				fname = paste(output_dir,"NARR_table_ATL_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			} else {
				fname = paste(output_dir,"NARR_table_USA_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			}
			load(fname)
			# Bind the new data to the new matrices
			one_vis = rbind(one_vis,vis)
			one_precip_wat = rbind(one_precip_wat,precip_wat)
			one_t_precip = rbind(one_t_precip,t_precip)
			one_c_precip = rbind(one_c_precip,c_precip)
			one_clouds = rbind(one_clouds,clouds)
			one_rain = rbind(one_rain,rain)
			one_snow = rbind(one_snow,snow)
			one_potential = rbind(one_potential,potential)
			one_TKE = rbind(one_TKE,TKE)
		}
	}

	# Approach 1: Apply PCA to each weather variable matrix in turn
	PCA_vis = prcomp(one_vis)
	PCA_precip_wat = prcomp(one_precip_wat)
	PCA_t_precip = prcomp(one_t_precip)
	PCA_c_precip = prcomp(one_c_precip)
	PCA_clouds = prcomp(one_clouds)
	PCA_rain = prcomp(one_rain)
	PCA_snow = prcomp(one_snow)
	PCA_potential = prcomp(one_potential)
	PCA_TKE = prcomp(one_TKE)
	# Select the first two principal components for each variable, combine into a data frame.
	# NB: Two principal components doesn't sound like much but this yields 18 data points to describe each day.
	# We're going to cluster off the principal components.  18 variables is enough for cluster analysis. Any more is a bit
	# pointless since we're going to further reduce the data to a single dimension: cluster assignment.
	PCA_feat = data.frame(vis1=PCA_vis$x[,1],vis2=PCA_vis$x[,2])
	PCA_feat = data.frame(PCA_feat,precip_wat1=PCA_precip_wat$x[,1],precip_wat2=PCA_precip_wat$x[,2])
	PCA_feat = data.frame(PCA_feat,t_precip1=PCA_t_precip$x[,1],t_precip2=PCA_t_precip$x[,2])
	PCA_feat = data.frame(PCA_feat,c_precip1=PCA_c_precip$x[,1],c_precip2=PCA_c_precip$x[,2])
	PCA_feat = data.frame(PCA_feat,clouds1=PCA_clouds$x[,1],clouds2=PCA_clouds$x[,2])
	PCA_feat = data.frame(PCA_feat,rain1=PCA_rain$x[,1],rain2=PCA_rain$x[,2])
	PCA_feat = data.frame(PCA_feat,snow1=PCA_snow$x[,1],snow2=PCA_snow$x[,2])
	PCA_feat = data.frame(PCA_feat,potential1=PCA_potential$x[,1],potential2=PCA_potential$x[,2])
	PCA_feat = data.frame(PCA_feat,TKE1=PCA_TKE$x[,1],TKE2=PCA_TKE$x[,2])
	# Save the result
	if (case==1) {
		fname = paste(output_dir,"NY_NARR_PCA.csv",sep="")
	} else if (case==2) {
		fname = paste(output_dir,"ATL_NARR_PCA.csv",sep="")
	} else {
		fname = paste(output_dir,"USA_NARR_PCA.csv",sep="")
	}
	write.csv(PCA_feat,file=fname,row.names=FALSE)

	# Approach 2: Combine all the weather variables and then apply PCA
	big_data = cbind(one_vis,one_precip_wat,one_t_precip,one_c_precip,one_clouds,one_rain,one_snow,one_potential,one_TKE)
	PCA_big = prcomp(big_data)
	# Make a data frame based on the first 10 principal components
	# See above for why 10 seems like a reasonable number.
	PCA_2_feat = data.frame(pc1=PCA_big$x[,1],pc2=PCA_big$x[,2],pc3=PCA_big$x[,3],pc4=PCA_big$x[,4])
	PCA_2_feat = data.frame(PCA_2_feat,pc5=PCA_big$x[,5],pc6=PCA_big$x[,6],pc7=PCA_big$x[,7])
	PCA_2_feat = data.frame(PCA_2_feat,pc8=PCA_big$x[,8],pc9=PCA_big$x[,9],pc10=PCA_big$x[,10])
	# Save the result
	if (case==1) {
		fname = paste(output_dir,"NY_NARR_PCA_2.csv",sep="")
	} else if (case==2) {
		fname = paste(output_dir,"ATL_NARR_PCA_2.csv",sep="")
	} else {
		fname = paste(output_dir,"USA_NARR_PCA_2.csv",sep="")
	}
	write.csv(PCA_2_feat,file=fname,row.names=FALSE)
}
