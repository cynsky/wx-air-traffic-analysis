# This is an R script for selecting features from Traffic Flow Management advisory data from the New York area.
# Script author: Kenneth Kuhn
# Last modified: 8/9/2015


# Read in the advisory data
advisory_data = read.csv("TFMI_data.csv")

# Optional: Only pick out volume or weather related ATFMI
volume_rows = which(advisory_data$cause %in% c("VOLUME","VOLUME / COMPACTED DEMAND",
	"VOLUME / MULTI-TAXI","VOLUME / VOLUME"))
# wx_rows = which(advisory_data$cause %in% c("WEATHER","WEATHER / BRAKING ACTION",
# 	"WEATHER / FOG","WEATHER / LOW CEILINGS","WEATHER / LOW VISIBILITY","WEATHER / RAIN",
# 	"WEATHER / RUNWAY TREATMENT","WEATHER / SNOW-ICE","WEATHER / THUNDERSTORMS",
# 	"WEATHER / TORNADO-HURRICANE","WEATHER / WIND","WEATHER/ LOW CEILINGS"))
advsiory_data = advisory_data[volume_rows,]
# advisory_data = advisory_data[wx_rows,]


# Reformat the date and time information for R
begin_dates = as.Date(paste(advisory_data$begin_month,advisory_data$begin_day,
	advisory_data$begin_year,sep="/"),"%m/%d/%Y")
end_dates = as.Date(paste(advisory_data$end_month,advisory_data$end_day,
	advisory_data$end_year,sep="/"),"%m/%d/%Y")
begin_times = strptime(paste(advisory_data$begin_month,advisory_data$begin_day,
	advisory_data$begin_year,advisory_data$begin_hour,advisory_data$begin_minute,sep="/"),
	"%m/%d/%Y/%H/%M",tz="GMT")
end_times = strptime(paste(advisory_data$end_month,advisory_data$end_day,
	advisory_data$end_year,advisory_data$end_hour,advisory_data$end_minute,sep="/"),
	"%m/%d/%Y/%H/%M",tz="GMT")

# Pick out the days we have data for
day_seq = seq(from=begin_dates[1],to=begin_dates[length(begin_dates)],by="day")
num_days = length(day_seq)

# Create a vectors of strings noting the dates we have data for
char_day_seq = as.character(day_seq)
date_v = paste(substr(char_day_seq,6,7),substr(char_day_seq,9,10),substr(char_day_seq,1,4),sep="/")

# Set up a blank matrix for the features of interest
# We will have one row for each day and one column for each feature
# Features are binary, is there a type of TFMI during a time window on the given day
TFMI_time = matrix(0,nrow=num_days,ncol=24)
rownames(TFMI_time) = date_v
colnames(TFMI_time) = c("anyTFMI_anytime","GDP_anytime","GS_anytime","Reroute_anytime",
	"anyTFMI_6_18","GDP_6_18","GS_6_18","Reroute_6_18",
	"anyTFMI_6_9","GDP_6_9","GS_6_9","Reroute_6_9",
	"anyTFMI_9_12","GDP_9_12","GS_9_12","Reroute_9_12",
	"anyTFMI_12_15","GDP_12_15","GS_12_15","Reroute_12_15",
	"anyTFMI_15_18","GDP_15_18","GS_15_18","Reroute_15_18")

# Cycle through the days
for (i1 in 1:num_days) {
	# Find the relevant rows of the advisory data
	cur_day = day_seq[i1]
	focus = which(begin_dates<=cur_day&end_dates>=cur_day)
	num_rows = length(focus)
	if (num_rows>0) {
		# If there are relevant rows, we have observed some form of TFMI
		TFMI_time[i1,1] = 1
		# Cycle through the relevant rows for a closer look
		for (i2 in 1:num_rows) {
			cur_row = focus[i2]
			# Did we observe a GDP, GS, or Reroute?
			if (advisory_data$TFMI[cur_row]=="GDP") TFMI_time[i1,2]=1
			if (advisory_data$TFMI[cur_row]=="GS") TFMI_time[i1,3]=1
			if (advisory_data$TFMI[cur_row]=="Reroute") TFMI_time[i1,4]=1
			# Did we observe TFMI during the 6:00 to 18:00 time window?
			cur_day_string = as.character(cur_day)
			start_window = strptime(paste(cur_day_string,"6","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			end_window = strptime(paste(cur_day_string,"18","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			if ((begin_times[cur_row]<=end_window)&(end_times[cur_row]>=start_window)) {
				TFMI_time[i1,5] = 1
				if (advisory_data$TFMI[cur_row]=="GDP") TFMI_time[i1,6]=1
				if (advisory_data$TFMI[cur_row]=="GS") TFMI_time[i1,7]=1
				if (advisory_data$TFMI[cur_row]=="Reroute") TFMI_time[i1,8]=1
			}
			# Did we observe TFMI during the 6:00 to 9:00 time window?
			start_window = strptime(paste(cur_day_string,"6","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			end_window = strptime(paste(cur_day_string,"9","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			if ((begin_times[cur_row]<=end_window)&(end_times[cur_row]>=start_window)) {
				TFMI_time[i1,9] = 1
				if (advisory_data$TFMI[cur_row]=="GDP") TFMI_time[i1,10]=1
				if (advisory_data$TFMI[cur_row]=="GS") TFMI_time[i1,11]=1
				if (advisory_data$TFMI[cur_row]=="Reroute") TFMI_time[i1,12]=1
			}
			# Did we observe TFMI during the 9:00 to 12:00 time window?
			start_window = strptime(paste(cur_day_string,"9","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			end_window = strptime(paste(cur_day_string,"12","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			if ((begin_times[cur_row]<=end_window)&(end_times[cur_row]>=start_window)) {
				TFMI_time[i1,13] = 1
				if (advisory_data$TFMI[cur_row]=="GDP") TFMI_time[i1,14]=1
				if (advisory_data$TFMI[cur_row]=="GS") TFMI_time[i1,15]=1
				if (advisory_data$TFMI[cur_row]=="Reroute") TFMI_time[i1,16]=1
			}
			# Did we observe TFMI during the 12:00 to 15:00 time window?
			start_window = strptime(paste(cur_day_string,"12","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			end_window = strptime(paste(cur_day_string,"15","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			if ((begin_times[cur_row]<=end_window)&(end_times[cur_row]>=start_window)) {
				TFMI_time[i1,17] = 1
				if (advisory_data$TFMI[cur_row]=="GDP") TFMI_time[i1,18]=1
				if (advisory_data$TFMI[cur_row]=="GS") TFMI_time[i1,19]=1
				if (advisory_data$TFMI[cur_row]=="Reroute") TFMI_time[i1,20]=1
			}
			# Did we observe TFMI during the 15:00 to 18:00 time window?
			start_window = strptime(paste(cur_day_string,"15","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			end_window = strptime(paste(cur_day_string,"18","00",sep="-"),"%Y-%m-%d-%H-%M",tz="GMT")
			if ((begin_times[cur_row]<=end_window)&(end_times[cur_row]>=start_window)) {
				TFMI_time[i1,21] = 1
				if (advisory_data$TFMI[cur_row]=="GDP") TFMI_time[i1,22]=1
				if (advisory_data$TFMI[cur_row]=="GS") TFMI_time[i1,23]=1
				if (advisory_data$TFMI[cur_row]=="Reroute") TFMI_time[i1,24]=1
			}
		}
	}
}

# Save the results
put_in_df = data.frame(date=date_v,TFMI_time)
# write.csv(put_in_df,"TFMI_features.csv",row.names=FALSE)
write.csv(put_in_df,"TFMI_volume_only_features.csv",row.names=FALSE)
# write.csv(put_in_df,"TFMI_wx_only_features.csv",row.names=FALSE)


