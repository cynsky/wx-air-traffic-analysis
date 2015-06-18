#
# This is a script for creating png image files showing precipitation around New York, along with
# local airports, fixes, and airways.
# Script author: Kenneth Kuhn
# Last modified: 4/24/2015

# Load the required libraries
library(ncdf)
library(ggplot2)
library(maps)
library(RColorBrewer)
library(mapproj)
require(grid)

# Point to the useful directories
# data_dir <- "/Volumes/NASA_data_copy/data_raw/airspace_weather/NARR/"
RUC_data_dir <- "/Volumes/NASA_data/data_raw/airspace_weather/RUC/"
NARR_data_dir <- "/Volumes/NASA_data/data_raw/airspace_weather/NARR/"
TAF_data_dir <- "/Volumes/NASA_data/data_raw/airport_weather/TAF/NY_TAF/"
output_dir <- "/Volumes/NASA_data/output_other/nyc_wx_gifs/"

# Load the waypoints and airways
# ways <- read.csv("/Volumes/NASA_data_copy/data_raw/TFMI_data/waypoints.csv")
# airs <- read.csv("/Volumes/NASA_data_copy/data_raw/TFMI_data/airways.csv")

# Put the data in the proper format
# ways[,1] <- as.character(ways[,1])
# ways[,2] <- as.numeric(as.character(ways[,2]))
# ways[,3] <- as.numeric(as.character(ways[,3]))

# Pick out the New York area airways
# NYroutes <- airs$region=="NY"

# Note the locations of airports
airports <- data.frame(airport=c("LGA","EWR","JFK"),lat=c(40+(46/60)+(38.1/3600),40+(41/60)+(33/3600),
    40+(38/60)+(23/3600)),lon=c(-73-(52/60)-(21.4/3600),-74-(10/60)-(7/3600),-73-(46/60)-(44/3600)))

# Create a base map showing the US states
states_map <- map_data("state")
base_map <- ggplot()
base_map <- base_map+geom_polygon(data=states_map,aes(x=long,y=lat,group=group),colour="grey50",fill="lemonchiffon")

# Set up the color scale for showing preciptiation
precip_cuts <- 1.0+c(0:8)*1
base_sc <- brewer.pal(9,"YlOrBr")
col_scale <- c("1"=base_sc[2],"2"=base_sc[3],"3"=base_sc[4],"4"=base_sc[5],"5"=base_sc[6],"6"=base_sc[7],"7"=base_sc[8],"8"=base_sc[9],"9"=base_sc[9])

# Load in the lat, lon coordinates of NARR grid cells
fname <- paste(NARR_data_dir,"grid.nc",sep="")
temp.nc <- open.ncdf(fname)
NARR_grid_lat <- get.var.ncdf(temp.nc,"gridlat_221")
NARR_grid_lon <- get.var.ncdf(temp.nc,"gridlon_221")
close.ncdf(temp.nc)

# Load in the lat, lon coordinates of RUC/RAP grid cells
fname <- paste(RUC_data_dir,"ruc2_252_latlon.txt",sep="")
temp <- read.table(fname,header=FALSE)
RUC_grid_lat <- matrix(t(as.matrix(temp[1:4515,1:15])),nrow=301)
RUC_grid_lon <- matrix(t(as.matrix(temp[4516:9030,1:15])),nrow=301)

# List the years, months, and times of interest (days depend on month)
years <- c("2013","2014","2015")
months <- c("01","02","03","04","05","06","07","08","09","10","11","12")
times <- c("00","03","06","09","12","15","18","21")

# Cycle through the years and months
for (year_ind in 1:3) {
  for (month_ind in 1:12) {
    # Identify the days - in the relevant month - for which we have data
    days = c("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28")
    if (month_ind %in% c(1,3,5,7,8,10,12)) { days=c(days,"29","30","31") }
    if (month_ind %in% c(4,6,9,11)) { days=c(days,"29","30") }
    if (month_ind==2 & year_ind==3) { days=c(days,"29") }
    # Cycle through the days and times
    for (day_ind in 1:length(days)) {
      # We only care about days where we have TAF data
      TAF_name = paste(TAF_data_dir,"TAF_",years[year_ind],"_",month_ind,"_",day_ind,".txt",sep="")
      if (file.exists(TAF_name)) {
          for (time_ind in 1:length(times)) {
            # If there is RUC/RAP data, let's use that
            # fname <- paste(cur_dir,"ruc2_252_",years[year_ind],months[month_ind],days[day_ind],"_",times[time_ind],"00_002.nc",sep="")
            fname <- paste(RUC_data_dir,years[year_ind],months[month_ind],"/rap_252_",years[year_ind],months[month_ind],days[day_ind],"_",times[time_ind],"00_002.nc",sep="")
            if (file.exists(fname)) {
                temp.nc <- open.ncdf(fname)
                # total_precip <- get.var.ncdf(temp.nc,"ACPCP_252_SFC_acc2h")
                total_precip <- get.var.ncdf(temp.nc,"ACPCP_P8_L1_GLC0_acc2h")
                total_precip[is.na(total_precip)] <- 0
                close.ncdf(temp.nc)
                # Turn the precipitation data into a data frame with a factor variable for precip
                ndf <- data.frame(lat=c(RUC_grid_lat),lon=c(RUC_grid_lon),precip=c(total_precip))
                ndf <- ndf[ndf$precip>=precip_cuts[1],]
                precip_factor <- c(rep("1",length(ndf$lat)))
                for (i1 in 2:length(precip_cuts)) { precip_factor[which(ndf$precip>=precip_cuts[i1])] <- as.character(i1) }
                ndf$precip <- precip_factor
                # Make the map of precipitation in the New York area
                # Show the airports and fixes
                # cur_map <- base_map+geom_point(data=ways[which(ways$type=="departures"),],aes(x=lon,y=lat),colour="blue",size=2,shape=15)
                # cur_map <- cur_map+geom_point(data=ways[which(ways$type=="arivals"),],aes(x=lon,y=lat),colour="blue",size=2,shape=16)
                cur_map <- base_map+geom_point(data=airports[which(airports$airport=="LGA"),],aes(x=lon,y=lat),colour="black",size=8,shape="*")
                cur_map <- cur_map+geom_point(data=airports[which(airports$airport=="EWR"),],aes(x=lon,y=lat),colour="black",size=8,shape="*")
                cur_map <- cur_map+geom_point(data=airports[which(airports$airport=="JFK"),],aes(x=lon,y=lat),colour="black",size=8,shape="*")
                # Show the airways
                # cur_map <- cur_map+geom_segment(data=airs[NYroutes,],aes(x=pt1_lon,y=pt1_lat,xend=pt2_lon,yend=pt2_lat),colour="black",size=1.6,alpha=0.35)
                # Show the precipitation
                cur_map <- cur_map+geom_point(data=ndf,aes(x=lon,y=lat,color=precip),alpha=I(0.4),size=6)+scale_colour_manual(values=col_scale)
                # Finish up the map
                cur_map <- cur_map + theme(legend.position="none",axis.ticks = element_blank(),
                  axis.text.x = element_blank(),axis.text.y = element_blank(),
                  panel.grid.minor=element_blank(),panel.grid.major=element_blank(),
                  axis.title.x = element_blank(),axis.title.y = element_blank(),
                  panel.border = element_blank(),panel.background=element_rect(fill="aquamarine3",colour="aquamarine3"))
                cur_map <- cur_map + coord_map(projection="conic",lat0=41,xlim=c(-81.5,-67.0),ylim=c(36.0,45.5))
                fname <- paste(output_dir,"Wx_",years[year_ind],"_",months[month_ind],"_",days[day_ind],"_",times[time_ind],".png",sep="")
                png(file=fname,width=600,height=500)
                plot(cur_map)
                dev.off()
            } else {
                # See if there is relevant NARR data
                fname <- paste(NARR_data_dir,years[year_ind],months[month_ind],"/narr-a_221_",years[year_ind],months[month_ind],days[day_ind],"_",times[time_ind],"00_000.nc",sep="")
                if (file.exists(fname)) {
                    temp.nc <- open.ncdf(fname)
                    total_precip <- get.var.ncdf(temp.nc,"A_PCP_221_SFC_acc3h")
                    total_precip[is.na(total_precip)] <- 0
                    close.ncdf(temp.nc)
                    ndf <- data.frame(lat=c(NARR_grid_lat),lon=c(NARR_grid_lon),precip=c(total_precip))
                    ndf <- ndf[ndf$precip>=precip_cuts[1],]
                    precip_factor <- c(rep("1",length(ndf$lat)))
                    for (i1 in 2:length(precip_cuts)) { precip_factor[which(ndf$precip>=precip_cuts[i1])] <- as.character(i1) }
                    ndf$precip <- precip_factor
                    cur_map <- base_map+geom_point(data=airports[which(airports$airport=="LGA"),],aes(x=lon,y=lat),colour="black",size=8,shape="*")
                    cur_map <- cur_map+geom_point(data=airports[which(airports$airport=="EWR"),],aes(x=lon,y=lat),colour="black",size=8,shape="*")
                    cur_map <- cur_map+geom_point(data=airports[which(airports$airport=="JFK"),],aes(x=lon,y=lat),colour="black",size=8,shape="*")
                    cur_map <- cur_map+geom_point(data=ndf,aes(x=lon,y=lat,color=precip),alpha=I(0.4),size=6)+scale_colour_manual(values=col_scale)
                    cur_map <- cur_map + theme(legend.position="none",axis.ticks = element_blank(),
                      axis.text.x = element_blank(),axis.text.y = element_blank(),
                      panel.grid.minor=element_blank(),panel.grid.major=element_blank(),
                      axis.title.x = element_blank(),axis.title.y = element_blank(),
                      panel.border = element_blank(),panel.background=element_rect(fill="aquamarine3",colour="aquamarine3"))                
                    cur_map <- cur_map + coord_map(projection="conic",lat0=41,xlim=c(-81.5,-67.0),ylim=c(36.0,45.5))
                    fname <- paste(output_dir,"Wx_",years[year_ind],"_",months[month_ind],"_",days[day_ind],"_",times[time_ind],".png",sep="")
                    png(file=fname,width=600,height=500)
                    plot(cur_map)
                    dev.off()
                }
            }
        }
      }
    }
  }
}
