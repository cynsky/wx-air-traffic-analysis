# This is a script for using Expert Judgment to reduce the dimensionality of collected RUC and RAP
# aviation weather forecast data, creating three smaller sets of variables that reflect forecast weather
# conditions. The three sets are based on the application of three distrinct methodologies. The
# first generalizes an idea found in the lit on the FAA's Severe Weather Avoidance Program (SWAP)
# in New York, looking at the distance from busy airports to intense precipitation. The second is
# based on MIT Lincoln Labs work on the Route Availability Planning Tool (RAPT), focusing on the
# degree to which locations on key airways are blocked by bad weather. The final approach focuses 
# on conditions at key waypoints identified by subject matter experts.
#
# Script author: Kenneth Kuhn
# Last modified: 3/27/2015

# Load the libraries needed for reading in NetCDF files, manipulating geo data
library(ncdf)
library(geosphere)

# Point out the base directories for reading in and saving data
input_dir = "/Volumes/NASA_data_copy/data_raw/airspace_weather/RUC/"
output_dir = "/Volumes/NASA_data_copy/features_data/"

# Load in the routes and waypoints
routes <- read.csv("/Volumes/NASA_data_copy/data_raw/TFMI_data/airways.csv")
waypoints <- read.csv("/Volumes/NASA_data_copy/data_raw/TFMI_data/waypoints.csv")

# Load in the locations of RUC and RAP grid cells, NYC, and ATL
fname <- paste(input_dir,"ruc2_252_latlon.txt",sep="")
temp <- read.table(fname,header=FALSE)
grid_lat <- matrix(t(as.matrix(temp[1:4515,1:15])),nrow=301)
grid_lon <- matrix(t(as.matrix(temp[4516:9030,1:15])),nrow=301)
nyc = c(40.7127,-74.0059)
atl = c(33.7550,-84.3900)

# Include a function for calculating the distance between any two coordinates
dist_coord <- function(lon1,lat1,lon2,lat2) {
    a1 = lat1*pi/180
    a2 = lon1*pi/180
    b1 = lat2*pi/180
    b2 = lon2*pi/180
    dlon = b2-a2
    dlat = b1-a1
    a = (sin(dlat/2))^2+cos(a1)*cos(b1)*(sin(dlon/2))^2
    c = 2*atan2(sqrt(a),sqrt(1-a))
    d = 3963.194*c
    return(d)
}
# Include a function for calculating the NARR grid cell closest to any coordinate
# Originally this called dist_coord() but it gives the same results and works much
# faster when just adding up differences in lat and lon.
cell_coord <- function(lon1,lat1) {
	dist_mat = abs(grid_lat-lat1)+abs(grid_lon-lon1)
	closest = which(dist_mat==min(dist_mat),arr.ind=TRUE)
	return(closest)
}

# Pick out the closest grid cells for each waypoint
way_cells = cell_coord(waypoints$lon[1],waypoints$lat[1])
for (i1 in 2:length(waypoints$lat)) {
	next_cells = cell_coord(waypoints$lon[i1],waypoints$lat[i1])
	way_cells = rbind(way_cells,next_cells)
}
waypoints = data.frame(waypoints,way_row=way_cells[,1],way_col=way_cells[,2])
NYways = waypoints[which(waypoints$region=="NY"),]
ATLways = waypoints[which(waypoints$region=="ATL"),]
NYroutes = routes[which(routes$region=="NY"),]
ATLroutes = routes[which(routes$region=="ATL"),]

# Pick out the grid cells that are on a key airway
#
# Start with blank matrices
grid_dim = dim(grid_lat)
NY_grid = matrix(0,nrow=grid_dim[1],ncol=grid_dim[2])
ATL_grid = matrix(0,nrow=grid_dim[1],ncol=grid_dim[2])
USA_grid = matrix(0,nrow=grid_dim[1],ncol=grid_dim[2])
# Cycle through each grid point and find the distance to the nearest airway
# This part takes several hours so run once and save the result
# library(tcltk)
# progress = tkProgressBar(title="Going through grid points",min=0,max=grid_dim[1],width=200)
# for (i1 in 1:grid_dim[1]) {
# 	for (i2 in 1:grid_dim[2]) {
# 		# Compare the location of the current grid point to first New York airway
# 		cur_loc = c(grid_lon[i1,i2],grid_lat[i1,i2])
# 		this_route = rbind(c(NYroutes$pt1_lon[1],NYroutes$pt1_lat[1]),c(NYroutes$pt2_lon[1],NYroutes$pt2_lat[1]))
# 		how_close = dist2Line(cur_loc,this_route)
# 		NY_dist = how_close[1]
# 		# If we're close to New York, find the distance to the closest airway. Otherwise don't bother.
# 		#
# 		# Note the default distance function returns distances in meters
# 		#
# 		if (NY_dist<400000) {
# 			for (i3 in 2:length(NYroutes$region)) {
# 				this_route = rbind(c(NYroutes$pt1_lon[i3],NYroutes$pt1_lat[i3]),c(NYroutes$pt2_lon[i3],NYroutes$pt2_lat[i3]))
# 				how_close = dist2Line(cur_loc,this_route)
# 				if (how_close[1]<NY_dist) { NY_dist=how_close[1] }
# 			}
# 		}
# 		# Save the distance to the closest airway in the NY_grid matrix
# 		NY_grid[i1,i2] = NY_dist
# 		# Compare the location of the current grid point to first Atlanta airway
# 		this_route = rbind(c(ATLroutes$pt1_lon[1],ATLroutes$pt1_lat[1]),c(ATLroutes$pt2_lon[1],ATLroutes$pt2_lat[1]))
# 		how_close = dist2Line(cur_loc,this_route)
# 		ATL_dist = how_close[1]
# 		# If we're close to Atlanta, find the distance to the closest airway. Otherwise don't bother.
# 		if (ATL_dist<400000) {
# 			for (i3 in 2:length(ATLroutes$region)) {
# 				this_route = rbind(c(ATLroutes$pt1_lon[i3],ATLroutes$pt1_lat[i3]),c(ATLroutes$pt2_lon[i3],ATLroutes$pt2_lat[i3]))
# 				how_close = dist2Line(cur_loc,this_route)
# 				if (how_close[1]<ATL_dist) { ATL_dist=how_close[1] }
# 			}
# 		}
# 		# Save the distance to the closest airway in the ATL_grid matrix
# 		ATL_grid[i1,i2] = ATL_dist
# 	}
# 	setTkProgressBar(progress,i1,label=paste(round(i1/grid_dim[1]*100,1),"% done"))
# }
# save(NY_grid,ATL_grid,file=paste(output_dir,"airways_RUC_dist.Rdata",sep=""))
load(file=paste(output_dir,"airways_NARR_dist.Rdata",sep=""))
# Pick out the grid points on an airway
# How large are the grid cells, in meters
grid_radius = 10*1609.34
# Turn the grids into binary matrices, 1 if on an airway and 0 otherwise
NY_grid_temp = matrix(0,nrow=grid_dim[1],ncol=grid_dim[2])
ATL_grid_temp = matrix(0,nrow=grid_dim[1],ncol=grid_dim[2])
NY_grid_temp[which(NY_grid<=grid_radius)] = 1
NY_grid_temp[which(NY_grid>grid_radius)] = 0
ATL_grid_temp[which(ATL_grid>grid_radius)] = 0
ATL_grid_temp[which(ATL_grid<=grid_radius)] = 1
NY_grid = NY_grid_temp
ATL_grid = ATL_grid_temp
USA_grid = NY_grid+ATL_grid
rm(NY_grid_temp,ATL_grid_temp)
NY_grid_route = which(NY_grid==1)
ATL_grid_route = which(ATL_grid==1)
USA_grid_route = c(NY_grid_route,ATL_grid_route)

# Identify the years, months, and timestamps for which we have data
# Days depends on the month, so we don't do that here
years = c("2010","2011","2012","2013","2014")
months = c("01","02","03","04","05","06","07","08","09","10","11","12")
timestamps = c("0000","0300","0600","0900","1200","1500","1800","2100")

# Set up the blank matrices that will store our new, reduced data sets
nyc_1 = matrix(0.0,nrow=1826,ncol=24)
nyc_2 = matrix(0.0,nrow=1826,ncol=5)
nyc_3 = matrix(0.0,nrow=1826,ncol=5)
atl_1 = matrix(0.0,nrow=1826,ncol=24)
atl_2 = matrix(0.0,nrow=1826,ncol=5)
atl_3 = matrix(0.0,nrow=1826,ncol=5)
usa_1 = matrix(0.0,nrow=1826,ncol=48)
usa_2 = matrix(0.0,nrow=1826,ncol=5)
usa_3 = matrix(0.0,nrow=1826,ncol=5)
day_counter = 1

# Cycle through the months of interest, using an index
for (year_ind in 1:5) {
	# Cycle through the years of interest, using an index
	for (month_ind in 1:12) {
		# Identify the days - in the relevant month - for which we have data
		days = c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
		if (month_ind %in% c(1,3,5,7,8,10,12)) { days=c(days,"29","30","31") }
		if (month_ind %in% c(4,6,9,11)) { days=c(days,"29","30") }
		if (month_ind==2 & year_ind==3) { days=c(days,"29") }
		# Cycle through the days of interest, using an index
		for (day_index in 1:length(days)) {
			# Set up blank vectors to store summary data on the data
			nyc_vec_1 = c()
			nyc_vec_2 = c()
			nyc_vec_3 = c()
			atl_vec_1 = c()
			atl_vec_2 = c()
			atl_vec_3 = c()
			usa_vec_1 = c()
			usa_vec_2 = c()
			usa_vec_3 = c()
			# Set up blank vectores to store data on airways or at navaids of interest
			nyc_route_precip = c()
			nyc_route_cape = c()
			atl_route_precip = c()
			atl_route_cape = c()
			usa_route_precip = c()
			usa_route_cape = c()
			nyc_precip_vec = c()
			nyc_cape_vec = c()
			atl_precip_vec = c()
			atl_cape_vec = c()
			usa_precip_vec = c()
			usa_cape_vec = c()
			# Cycle through the timestamps of interest, using an index
			for (time_index in 1:length(timestamps)) {
				# Get the relevant RUC or RAP data
				if (year_ind<=3) {
					fname = paste(input_dir,years[year_ind],months[month_ind],"/ruc2_252_",years[year_ind],months[month_ind],days[day_index],"_",timestamps[time_index],"_002.nc",sep="")
				} else {
					fname = paste(input_dir,years[year_ind],months[month_ind],"/rap_252_",years[year_ind],months[month_ind],days[day_index],"_",timestamps[time_index],"_002.nc",sep="")
				}
				if (file.exists(fname)) {
					temp.nc = open.ncdf(fname)
					if (year_ind<=3) {
						total_precip = get.var.ncdf(temp.nc,"ACPCP_252_SFC_acc2h")
						CAPE = get.var.ncdf(temp.nc,"CAPE_252_SFC")
					} else {
						total_precip = get.var.ncdf(temp.nc,"ACPCP_P8_L1_GLC0_acc2h")
						CAPE = get.var.ncdf(temp.nc,"CAPE_P0_L1_GLC0")
					}
					close.ncdf(temp.nc)
					# Approach 1: SWAP-like
					# Find the distance from N90 to moderate and intense and super precipitation
					moderate = which(total_precip>1.5)
					if (length(moderate)>=1) {
						dist_mat_nyc = abs(grid_lat[moderate]-nyc[1])+abs(grid_lon[moderate]-nyc[2])
						dist_mat_atl = abs(grid_lat[moderate]-atl[1])+abs(grid_lon[moderate]-atl[2])
						closest_nyc = which(dist_mat_nyc==min(dist_mat_nyc))[1]
						closest_atl = which(dist_mat_atl==min(dist_mat_atl))[1]
						prox_mod_nyc = dist_coord(nyc[2],nyc[1],grid_lon[closest_nyc],grid_lat[closest_nyc])
						prox_mod_atl = dist_coord(atl[2],atl[1],grid_lon[closest_atl],grid_lat[closest_atl])
					} else {
						prox_mod_nyc = 9999
						prox_mod_atl = 9999
					}
					intense = which(total_precip>3.0)
					if (length(intense)>=1) {
						dist_mat_nyc = abs(grid_lat[intense]-nyc[1])+abs(grid_lon[intense]-nyc[2])
						dist_mat_atl = abs(grid_lat[intense]-atl[1])+abs(grid_lon[intense]-atl[2])
						closest_nyc = which(dist_mat_nyc==min(dist_mat_nyc))[1]
						closest_atl = which(dist_mat_atl==min(dist_mat_atl))[1]
						prox_int_nyc = dist_coord(nyc[2],nyc[1],grid_lon[closest_nyc],grid_lat[closest_nyc])
						prox_int_atl = dist_coord(atl[2],atl[1],grid_lon[closest_atl],grid_lat[closest_atl])
					} else {
						prox_int_nyc = 9999
						prox_int_atl = 9999
					}
					super = which(total_precip>5.0)
					if (length(super)>=1) {
						dist_mat_nyc = abs(grid_lat[super]-nyc[1])+abs(grid_lon[super]-nyc[2])
						dist_mat_atl = abs(grid_lat[super]-atl[1])+abs(grid_lon[super]-atl[2])
						closest_nyc = which(dist_mat_nyc==min(dist_mat_nyc))[1]
						closest_atl = which(dist_mat_atl==min(dist_mat_atl))[1]
						prox_sup_nyc = dist_coord(nyc[2],nyc[1],grid_lon[closest_nyc],grid_lat[closest_nyc])
						prox_sup_atl = dist_coord(atl[2],atl[1],grid_lon[closest_atl],grid_lat[closest_atl])
					} else {
						prox_sup_nyc = 9999
						prox_sup_atl = 9999
					}
					nyc_vec_1 = c(nyc_vec_1,prox_mod_nyc,prox_int_nyc,prox_sup_nyc)
					atl_vec_1 = c(atl_vec_1,prox_mod_atl,prox_int_atl,prox_sup_atl)
					usa_vec_1 = c(usa_vec_1,prox_mod_nyc,prox_int_nyc,prox_sup_nyc,prox_mod_atl,prox_int_atl,prox_sup_atl)
					# Approach 2: Focus on key airways
					# For now collect all data on relevant grid cells.  Will condense later.
					nyc_route_precip = c(nyc_route_precip,total_precip[NY_grid_route])
					nyc_route_cape = c(nyc_route_cape,CAPE[NY_grid_route])
					atl_route_precip = c(atl_route_precip,total_precip[ATL_grid_route])
					atl_route_cape = c(atl_route_cape,CAPE[ATL_grid_route])
					usa_route_precip = c(usa_route_precip,total_precip[USA_grid_route])
					usa_route_cape = c(usa_route_cape,CAPE[USA_grid_route])
					# Approach 3: Focus on key waypoints
					# For now collect all data on waypoints.  Will condense later.
					for (way_index in 1:length(NYways$lat)) {
						current_row = NYways$way_row[way_index]
						current_col = NYways$way_col[way_index]
						nyc_precip_vec = c(nyc_precip_vec,total_precip[current_row,current_col])
						nyc_cape_vec = c(nyc_cape_vec,CAPE[current_row,current_col])
					}
					for (way_index in 1:length(ATLways$lat)) {
						current_row = ATLways$way_row[way_index]
						current_col = ATLways$way_col[way_index]
						atl_precip_vec = c(atl_precip_vec,total_precip[current_row,current_col])
						atl_cape_vec = c(atl_cape_vec,CAPE[current_row,current_col])
					}
					for (way_index in 1:length(waypoints$lat)) {
						current_row = waypoints$way_row[way_index]
						current_col = waypoints$way_col[way_index]
						usa_precip_vec = c(usa_precip_vec,total_precip[current_row,current_col])
						usa_cape_vec = c(usa_cape_vec,CAPE[current_row,current_col])
					}
				} else {
					nyc_vec_1 = c(nyc_vec_1,rep(NA,3))
					atl_vec_1 = c(atl_vec_1,rep(NA,3))
					usa_vec_1 = c(usa_vec_1,rep(NA,6))
					nyc_route_precip = c(nyc_route_precip,rep(NA,length(NY_grid_route)))
					atl_route_precip = c(atl_route_precip,rep(NA,length(ATL_grid_route)))
					usa_route_precip = c(usa_route_precip,rep(NA,length(USA_grid_route)))
					nyc_route_cape = c(nyc_route_cape,rep(NA,length(NY_grid_route)))
					atl_route_cape = c(atl_route_cape,rep(NA,length(ATL_grid_route)))
					usa_route_cape = c(usa_route_cape,rep(NA,length(USA_grid_route)))
					nyc_precip_vec = c(nyc_precip_vec,rep(NA,length(NYways$lat)))
					atl_precip_vec = c(atl_precip_vec,rep(NA,length(ATLways$lat)))
					usa_precip_vec = c(usa_precip_vec,rep(NA,length(waypoints$lat)))
					nyc_cape_vec = c(nyc_cape_vec,rep(NA,length(NYways$lat)))
					atl_cape_vec = c(atl_cape_vec,rep(NA,length(ATLways$lat)))
					usa_cape_vec = c(usa_cape_vec,rep(NA,length(waypoints$lat)))
				}
			}
			# For approaches 2 and 3, condense the data collected for the day
			# We condense the result down to 5 data points per day, which allows us to visualize and explore the results of our cluster analysis
			nyc_vec_2 = c(sum(nyc_route_precip>3.0,na.rm=TRUE),median(nyc_route_precip,na.rm=TRUE),median(nyc_route_cape,na.rm=TRUE),max(nyc_route_precip,na.rm=TRUE),sum(nyc_route_precip>1.5,na.rm=TRUE))
			atl_vec_2 = c(sum(atl_route_precip>3.0,na.rm=TRUE),median(atl_route_precip,na.rm=TRUE),median(atl_route_cape,na.rm=TRUE),max(atl_route_precip,na.rm=TRUE),sum(atl_route_precip>1.5,na.rm=TRUE))
			usa_vec_2 = c(sum(usa_route_precip>3.0,na.rm=TRUE),median(usa_route_precip,na.rm=TRUE),median(usa_route_cape,na.rm=TRUE),max(usa_route_precip,na.rm=TRUE),sum(usa_route_precip>1.5,na.rm=TRUE))
			rm(nyc_route_precip,nyc_route_cape,atl_route_precip,atl_route_cape,usa_route_precip,usa_route_cape)
			nyc_vec_3 = c(sum(nyc_precip_vec>3.0,na.rm=TRUE),median(nyc_precip_vec,na.rm=TRUE),median(nyc_cape_vec,na.rm=TRUE),max(nyc_precip_vec,na.rm=TRUE),sum(nyc_precip_vec>1.5,na.rm=TRUE))
			atl_vec_3 = c(sum(atl_precip_vec>3.0,na.rm=TRUE),median(atl_precip_vec,na.rm=TRUE),median(atl_cape_vec,na.rm=TRUE),max(atl_precip_vec,na.rm=TRUE),sum(atl_precip_vec>1.5,na.rm=TRUE))
			usa_vec_3 = c(sum(usa_precip_vec>3.0,na.rm=TRUE),median(usa_precip_vec,na.rm=TRUE),median(usa_cape_vec,na.rm=TRUE),max(usa_precip_vec,na.rm=TRUE),sum(usa_precip_vec>1.5,na.rm=TRUE))
			rm(nyc_precip_vec,nyc_cape_vec,atl_precip_vec,atl_cape_vec,usa_precip_vec,usa_cape_vec)
			# Update the overall matrices and clear the daily vectors
			nyc_1[day_counter,] = nyc_vec_1
			nyc_2[day_counter,] = nyc_vec_2
			nyc_3[day_counter,] = nyc_vec_3
			atl_1[day_counter,] = atl_vec_1
			atl_2[day_counter,] = atl_vec_2
			atl_3[day_counter,] = atl_vec_3
			usa_1[day_counter,] = usa_vec_1
			usa_2[day_counter,] = usa_vec_2
			usa_3[day_counter,] = usa_vec_3
			rm(nyc_vec_1,nyc_vec_2,nyc_vec_3,atl_vec_1,atl_vec_2,atl_vec_3,usa_vec_1,usa_vec_2,usa_vec_3)
			day_counter = day_counter+1
		}
	}
}

# Add column names for at least the first 5 variables to the data matrices
colnames(nyc_1) = c("dist_mod_precip_1","dist_int_precip_1","dist_sup_precip_1",
	"dist_mod_precip_2","dist_int_precip_2","dist_sup_precip_2",
	"dist_mod_precip_3","dist_int_precip_3","dist_sup_precip_3",
	"dist_mod_precip_4","dist_int_precip_4","dist_sup_precip_4",
	"dist_mod_precip_5","dist_int_precip_5","dist_sup_precip_5",
	"dist_mod_precip_6","dist_int_precip_6","dist_sup_precip_6",
	"dist_mod_precip_7","dist_int_precip_7","dist_sup_precip_7",
	"dist_mod_precip_8","dist_int_precip_8","dist_sup_precip_8")
colnames(nyc_2) = c("est_airways_blocked","median_airway_precip","median_airway_CAPE","max_airway_precip","est_airways_impacted")
colnames(nyc_3) = c("est_fixes_blocked","median_fix_precip","median_fix_CAPE","max_fix_precip","est_fixes_impacted")
colnames(atl_1) = c("dist_mod_precip_1","dist_int_precip_1","dist_sup_precip_1",
	"dist_mod_precip_2","dist_int_precip_2","dist_sup_precip_2",
	"dist_mod_precip_3","dist_int_precip_3","dist_sup_precip_3",
	"dist_mod_precip_4","dist_int_precip_4","dist_sup_precip_4",
	"dist_mod_precip_5","dist_int_precip_5","dist_sup_precip_5",
	"dist_mod_precip_6","dist_int_precip_6","dist_sup_precip_6",
	"dist_mod_precip_7","dist_int_precip_7","dist_sup_precip_7",
	"dist_mod_precip_8","dist_int_precip_8","dist_sup_precip_8")
colnames(atl_2) = c("est_airways_blocked","median_airway_precip","median_airway_CAPE","max_airway_precip","est_airways_impacted")
colnames(atl_3) = c("est_fixes_blocked","median_fix_precip","median_fix_CAPE","max_fix_precip","est_fixes_impacted")
colnames(usa_1) = c("dist_mod_precip_1","dist_int_precip_1","dist_sup_precip_1",
	"dist_mod_precip_2","dist_int_precip_2","dist_sup_precip_2",
	"dist_mod_precip_3","dist_int_precip_3","dist_sup_precip_3",
	"dist_mod_precip_4","dist_int_precip_4","dist_sup_precip_4",
	"dist_mod_precip_5","dist_int_precip_5","dist_sup_precip_5",
	"dist_mod_precip_6","dist_int_precip_6","dist_sup_precip_6",
	"dist_mod_precip_7","dist_int_precip_7","dist_sup_precip_7",
	"dist_mod_precip_8","dist_int_precip_8","dist_sup_precip_8",
	"dist_mod_precip_1","dist_int_precip_1","dist_sup_precip_1",
	"dist_mod_precip_2","dist_int_precip_2","dist_sup_precip_2",
	"dist_mod_precip_3","dist_int_precip_3","dist_sup_precip_3",
	"dist_mod_precip_4","dist_int_precip_4","dist_sup_precip_4",
	"dist_mod_precip_5","dist_int_precip_5","dist_sup_precip_5",
	"dist_mod_precip_6","dist_int_precip_6","dist_sup_precip_6",
	"dist_mod_precip_7","dist_int_precip_7","dist_sup_precip_7",
	"dist_mod_precip_8","dist_int_precip_8","dist_sup_precip_8")
colnames(usa_2) = c("est_airways_blocked","median_airway_precip","median_airway_CAPE","max_airway_precip","est_airways_impacted")
colnames(usa_3) = c("est_fixes_blocked","median_fix_precip","median_fix_CAPE","max_fix_precip","est_fixes_impacted")

# in R, the max of a bunch of NA values returns -Inf.  NA is a bit clearer.
nyc_1[nyc_1==-Inf] = NA
nyc_2[nyc_2==-Inf] = NA
nyc_3[nyc_3==-Inf] = NA
atl_1[atl_1==-Inf] = NA
atl_2[atl_2==-Inf] = NA
atl_3[atl_3==-Inf] = NA
usa_1[usa_1==-Inf] = NA
usa_2[usa_2==-Inf] = NA
usa_3[usa_3==-Inf] = NA

# Save the results to .csv files
write.csv(nyc_1,paste(output_dir,"NY_RUC_expert_1.csv",sep=""),row.names=FALSE)
write.csv(nyc_2,paste(output_dir,"NY_RUC_expert_2.csv",sep=""),row.names=FALSE)
write.csv(nyc_3,paste(output_dir,"NY_RUC_expert_3.csv",sep=""),row.names=FALSE)
write.csv(atl_1,paste(output_dir,"ATL_RUC_expert_1.csv",sep=""),row.names=FALSE)
write.csv(atl_2,paste(output_dir,"ATL_RUC_expert_2.csv",sep=""),row.names=FALSE)
write.csv(atl_3,paste(output_dir,"ATL_RUC_expert_3.csv",sep=""),row.names=FALSE)
write.csv(usa_1,paste(output_dir,"USA_RUC_expert_1.csv",sep=""),row.names=FALSE)
write.csv(usa_2,paste(output_dir,"USA_RUC_expert_2.csv",sep=""),row.names=FALSE)
write.csv(usa_3,paste(output_dir,"USA_RUC_expert_3.csv",sep=""),row.names=FALSE)


