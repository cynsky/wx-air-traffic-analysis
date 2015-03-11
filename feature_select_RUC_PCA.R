# This is a script for using Principal Components Analysis to reduce the dimensionality of collected RUC
# and RAP forecast aviation weather data, creating a smaller set of independent variables that account for as much of the 
# variability in the RUC and RAP data as possible.
#
# The time frame here is days so that we are trying to explain variability between days.
#
# Script author: Kenneth Kuhn
# Last modified: 3/2/2015

# Load the library needed for reading in NetCDF files
library(ncdf)

# Point out the base directories for reading in and saving data
input_dir = "/Volumes/NASA_data_copy/data_raw/airspace_weather/RUC/"
output_dir = "/Volumes/NASA_data_copy/features_data/"

# Identify the years, months, and timestamps for which we have data
# Days depends on the month, so we don't do that here
# Also note that there is a gap in the availability of RUC and RAP data around when
# the switch from RUC to RAP was made.
years = c("2010","2011","2012","2013","2014","2015")
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
	# Note these are different than the locations we looked at in NARR, close by in lat/lon but different rows and cols in matrices
	#
	if (case==1) {
		ind_rows = c(224,240,257,271)
		ind_cols = c(150,134,119,103)	
	} else if (case==2) {
		ind_rows = c(190,205,220,235)
		ind_cols = c(102,87,71,56)
	} else {
		ind_rows = c(41,67,93,119,145,171,196,221,246,270,293)
		ind_cols = c(27,43,59,76,93,110,128,146,165,184,204)
	}

	# Cycle through the months of interest, using an index
	for (year_ind in 1:length(years)) {
		# Cycle through the years of interest, using an index
		for (month_ind in 1:length(months)) {
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
			rain = matrix(,nrow=n_days,ncol=n_data)
			snow = matrix(,nrow=n_days,ncol=n_data)
			CAPE = matrix(,nrow=n_days,ncol=n_data)
			REFC = matrix(,nrow=n_days,ncol=n_data)
			# Cycle through the days of interest, using an index
			for (day_index in 1:n_days) {
				# Set up a vector for each weather variable to capture data for this day
				vect_vis = c()
				vect_precip_wat = c()
				vect_t_precip = c()
				vect_rain = c()
				vect_snow = c()
				vect_CAPE = c()
				vect_REFC = c()
				# Cycle through the timestamps of interest, using an index
				for (time_index in 1:length(timestamps)) {
					# Open the relevant NetCDF file
					fname = paste(input_dir,years[year_ind],months[month_ind],"/ruc2_252_",years[year_ind],months[month_ind],days[day_index],"_",timestamps[time_index],"_002.nc",sep="")
					fname_alt = paste(input_dir,years[year_ind],months[month_ind],"/rap_252_",years[year_ind],months[month_ind],days[day_index],"_",timestamps[time_index],"_002.nc",sep="")
					if (file.exists(fname)) {
						temp.nc = open.ncdf(fname)
						# Get the relevant variables from the NetCDF file
						visibility = get.var.ncdf(temp.nc,"VIS_252_SFC")
						precipitable_water = get.var.ncdf(temp.nc,"P_WAT_252_EATM")
						total_precip = get.var.ncdf(temp.nc,"ACPCP_252_SFC_acc2h")
						raining = get.var.ncdf(temp.nc,"CRAIN_252_SFC")
						snowing = get.var.ncdf(temp.nc,"CSNOW_252_SFC")
						CAPE_v = get.var.ncdf(temp.nc,"CAPE_252_SFC")
						REFC_v = get.var.ncdf(temp.nc,"REFC_252_EATM")
						close.ncdf(temp.nc)
					} else if (file.exists(fname_alt)) {
						temp.nc = open.ncdf(fname_alt)
						# Get the relevant variables from the NetCDF file
						visibility = get.var.ncdf(temp.nc,"VIS_P0_L1_GLC0")
						precipitable_water = get.var.ncdf(temp.nc,"PWAT_P0_L200_GLC0")
						total_precip = get.var.ncdf(temp.nc,"ACPCP_P8_L1_GLC0_acc2h")
						raining = get.var.ncdf(temp.nc,"CRAIN_P0_L1_GLC0")
						snowing = get.var.ncdf(temp.nc,"CSNOW_P0_L1_GLC0")
						CAPE_v = get.var.ncdf(temp.nc,"CAPE_P0_L1_GLC0")
						REFC_v = get.var.ncdf(temp.nc,"REFC_P0_L200_GLC0")
						close.ncdf(temp.nc)							
					}
					if ((file.exists(fname))|(file.exists(fname_alt))) {
						# Attach the cells of interest to each vector
						vect_vis = c(vect_vis,c(visibility[ind_rows,ind_cols]))
						vect_precip_wat = c(vect_precip_wat,c(precipitable_water[ind_rows,ind_cols]))
						vect_t_precip = c(vect_t_precip,c(total_precip[ind_rows,ind_cols]))
						vect_rain = c(vect_rain,c(raining[ind_rows,ind_cols]))
						vect_snow = c(vect_snow,c(snowing[ind_rows,ind_cols]))
						vect_CAPE = c(vect_CAPE,c(CAPE_v[ind_rows,ind_cols]))
						vect_REFC = c(vect_REFC,c(REFC_v[ind_rows,ind_cols]))
						# Throw out the data from this NetCDF file we no longer need
						rm(temp.nc,visibility,precipitable_water,total_precip,raining,snowing,CAPE_v,REFC_v)
					} else {
						vect_vis = c(vect_vis,rep(NA,length(ind_rows)*length(ind_cols)))
						vect_precip_wat = c(vect_precip_wat,rep(NA,length(ind_rows)*length(ind_cols)))
						vect_t_precip = c(vect_t_precip,rep(NA,length(ind_rows)*length(ind_cols)))
						vect_rain = c(vect_rain,rep(NA,length(ind_rows)*length(ind_cols)))
						vect_snow = c(vect_snow,rep(NA,length(ind_rows)*length(ind_cols)))
						vect_CAPE = c(vect_CAPE,rep(NA,length(ind_rows)*length(ind_cols)))
						vect_REFC = c(vect_REFC,rep(NA,length(ind_rows)*length(ind_cols)))
					}
				}
				# Load the vectors into the matrices
				if (length(vect_vis)>=1) {
					vis[day_index,] = vect_vis
					precip_wat[day_index,] = vect_precip_wat
					t_precip[day_index,] = vect_t_precip
					rain[day_index,] = vect_rain
					snow[day_index,] = vect_snow
					CAPE[day_index,] = vect_CAPE
					REFC[day_index,] = vect_REFC
					# Throw out the vectors
					rm(vect_vis,vect_precip_wat,vect_t_precip,vect_rain,vect_snow,vect_CAPE,vect_REFC)
				}
			}
			# Save the resulting matrices
			if (case==1) {
				fname = paste(output_dir,"RUC_table_NY_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			} else if (case==2) {
				fname = paste(output_dir,"RUC_table_ATL_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			} else {
				fname = paste(output_dir,"RUC_table_USA_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			}
			if (sum(! is.na(vis))>10) {
				save(vis,precip_wat,t_precip,rain,snow,CAPE,REFC,file=fname)
			}
			# Throw out the matrices
			rm(vis,precip_wat,t_precip,rain,snow,CAPE,REFC)
		}
	}
}

# Next step: apply PCA, using two distinct methodologies.
for (case in 1:3) {
	date_list = c()
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
	one_rain = matrix(0,nrow=0,ncol=n_data)
	one_snow = matrix(0,nrow=0,ncol=n_data)
	one_CAPE = matrix(0,nrow=0,ncol=n_data)
	one_REFC = matrix(0,nrow=0,ncol=n_data)
	# Cycle through the years and months of interest
	for (year_ind in 1:length(years)) {
		for (month_ind in 1:12) {
			# Load the data from this month
			if (case==1) {
				fname = paste(output_dir,"RUC_table_NY_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			} else if (case==2) {
				fname = paste(output_dir,"RUC_table_ATL_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			} else {
				fname = paste(output_dir,"RUC_table_USA_",years[year_ind],"_",months[month_ind],".Rdata",sep="")
			}
			if (file.exists(fname)) {
				load(fname)
				# Bind the new data to the new matrices
				one_vis = rbind(one_vis,vis)
				one_precip_wat = rbind(one_precip_wat,precip_wat)
				one_t_precip = rbind(one_t_precip,t_precip)
				one_rain = rbind(one_rain,rain)
				one_snow = rbind(one_snow,snow)
				one_CAPE = rbind(one_CAPE,CAPE)
				one_REFC = rbind(one_REFC,REFC)
				if (month_ind==12) { days_month=31
				} else { days_month= as.numeric(difftime(as.Date(paste(years[year_ind],as.numeric(months[month_ind])+1,"1",sep="/")),as.Date(paste(years[year_ind],months[month_ind],"1",sep="/")))) }
				date_list = c(date_list,seq(from=as.Date(paste(years[year_ind],months[month_ind],"1",sep="/")),to=as.Date(paste(years[year_ind],months[month_ind],days_month,sep="/")),by="day"))
			}
		}
	}
	# Throw out dates where we are missing data
	class(date_list) = "Date"
	complete = which(complete.cases(one_vis))
	one_vis = one_vis[complete,]
	one_precip_wat = one_precip_wat[complete,]
	one_t_precip = one_t_precip[complete,]
	one_rain = one_rain[complete,]
	one_snow = one_snow[complete,]
	one_CAPE = one_CAPE[complete,]
	one_REFC = one_REFC[complete,]
	date_list = date_list[complete]
	# Approach 1: Apply PCA to each weather variable matrix in turn
	PCA_vis = prcomp(one_vis)
	PCA_precip_wat = prcomp(one_precip_wat)
	PCA_t_precip = prcomp(one_t_precip)
	PCA_rain = prcomp(one_rain)
	PCA_snow = prcomp(one_snow)
	PCA_CAPE = prcomp(one_CAPE)
	PCA_REFC = prcomp(one_REFC)
	# Select the first two principal components for each variable, combine into a data frame.
	# NB: Two principal components doesn't sound like much but this yields 18 data points to describe each day.
	# We're going to cluster off the principal components.  18 variables is enough for cluster analysis. Any more is a bit
	# pointless since we're going to further reduce the data to a single dimension: cluster assignment.
	PCA_feat = data.frame(date=date_list,vis1=PCA_vis$x[,1],vis2=PCA_vis$x[,2])
	PCA_feat = data.frame(PCA_feat,precip_wat1=PCA_precip_wat$x[,1],precip_wat2=PCA_precip_wat$x[,2])
	PCA_feat = data.frame(PCA_feat,t_precip1=PCA_t_precip$x[,1],t_precip2=PCA_t_precip$x[,2])
	PCA_feat = data.frame(PCA_feat,rain1=PCA_rain$x[,1],rain2=PCA_rain$x[,2])
	PCA_feat = data.frame(PCA_feat,snow1=PCA_snow$x[,1],snow2=PCA_snow$x[,2])
	PCA_feat = data.frame(PCA_feat,CAPE1=PCA_CAPE$x[,1],CAPE2=PCA_CAPE$x[,2])
	PCA_feat = data.frame(PCA_feat,REFC1=PCA_REFC$x[,1],REFC2=PCA_REFC$x[,2])
	# Save the result
	if (case==1) {
		fname = paste(output_dir,"NY_RUC_PCA.csv",sep="")
	} else if (case==2) {
		fname = paste(output_dir,"ATL_RUC_PCA.csv",sep="")
	} else {
		fname = paste(output_dir,"USA_RUC_PCA.csv",sep="")
	}
	write.csv(PCA_feat,file=fname,row.names=FALSE)

	# Approach 2: Combine all the weather variables and then apply PCA
	big_data = cbind(one_vis,one_precip_wat,one_t_precip,one_rain,one_snow,one_CAPE,one_REFC)
	PCA_big = prcomp(big_data)
	# Make a data frame based on the first 10 principal components
	# See above for why 10 seems like a reasonable number.
	PCA_2_feat = data.frame(date=date_list,pc1=PCA_big$x[,1],pc2=PCA_big$x[,2],pc3=PCA_big$x[,3],pc4=PCA_big$x[,4])
	PCA_2_feat = data.frame(PCA_2_feat,pc5=PCA_big$x[,5],pc6=PCA_big$x[,6],pc7=PCA_big$x[,7])
	PCA_2_feat = data.frame(PCA_2_feat,pc8=PCA_big$x[,8],pc9=PCA_big$x[,9],pc10=PCA_big$x[,10])
	# Save the result
	if (case==1) {
		fname = paste(output_dir,"NY_RUC_PCA_2.csv",sep="")
	} else if (case==2) {
		fname = paste(output_dir,"ATL_RUC_PCA_2.csv",sep="")
	} else {
		fname = paste(output_dir,"USA_RUC_PCA_2.csv",sep="")
	}
	write.csv(PCA_2_feat,file=fname,row.names=FALSE)
}
