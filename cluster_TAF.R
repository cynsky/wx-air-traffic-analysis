# This is a script for using Partitioning Around Medoids (PAM) clustering to pick out
# sets of similar days based on features previously extracted from Terminal Area
# Forecast (TAF) data and found in Aviation System Performance Metrics (ASPM) data
# describing scheduled traffic and forecast weather at airports.
#
# Script author: Kenneth Kuhn
# Last modified: 6/16/2015

# Point out the base directories for reading in and saving data
features_dir = "/Volumes/NASA_data/features_data/"
ASPM_dir = "/Volumes/NASA_data/data_raw/airport_traffic/ASPM/csv_ASPM/"
output_dir = "/Volumes/NASA_data/output_clustering/"

# Read in the TAF feature data
TAF_features = read.csv(paste(features_dir,"NY_TAF_expert.csv",sep=""))

# Read in the ASPM data and pick out the scheduled air traffic
# Make a function for processing the ASPM data to get features
summarize <- function(ASPMdata,airport,time_ind,date_range) {
	traffic_count = c(rep(0,length(date_range)))
	cur_ASPM = ASPMdata[ASPMdata$Facility==airport,]
	start_time = 7+3*time_ind
	end_time = start_time+2
	cur_ASPM = cur_ASPM[cur_ASPM$GMTHour %in% c(start_time:end_time),]
	for (date_ind in 1:length(date_range)) {
		cur_date = date_range[date_ind]
		traffic_count[date_ind] = sum(cur_ASPM$ScheduledArrivals[cur_ASPM$Date==cur_date])
	}
	return(traffic_count)
}
# Set up a blank vectors to store feature data
date_vec = c()
JFK1 = c()
JFK2 = c()
JFK3 = c()
JFK4 = c()
EWR1 = c()
EWR2 = c()
EWR3 = c()
EWR4 = c()
LGA1 = c()
LGA2 = c()
LGA3 = c()
LGA4 = c()
# Pick out the feature now
for (cur_year in 2013:2015) {
	for (i1 in 1:36) {
		fname = paste(ASPM_dir,"ASPM-",cur_year,"-",i1,".csv",sep="")
		if (file.exists(fname)) {
			ASPM_file = read.csv(fname)
			ASPM_file$Date = as.character(ASPM_file$Date)
			date_list = unique(ASPM_file$Date)
			date_vec = c(date_vec,date_list)
			JFK1 = c(JFK1,summarize(ASPM_file," JFK",1,date_list))
			JFK2 = c(JFK2,summarize(ASPM_file," JFK",2,date_list))
			JFK3 = c(JFK3,summarize(ASPM_file," JFK",3,date_list))
			JFK4 = c(JFK4,summarize(ASPM_file," JFK",4,date_list))
			EWR1 = c(EWR1,summarize(ASPM_file," EWR",1,date_list))
			EWR2 = c(EWR2,summarize(ASPM_file," EWR",2,date_list))
			EWR3 = c(EWR3,summarize(ASPM_file," EWR",3,date_list))
			EWR4 = c(EWR4,summarize(ASPM_file," EWR",4,date_list))
			LGA1 = c(LGA1,summarize(ASPM_file," LGA",1,date_list))
			LGA2 = c(LGA2,summarize(ASPM_file," LGA",2,date_list))
			LGA3 = c(LGA3,summarize(ASPM_file," LGA",3,date_list))
			LGA4 = c(LGA4,summarize(ASPM_file," LGA",4,date_list))
		}
	}
}
# Put everything into feature data frame
ASPM_features = data.frame(Date=date_vec,JFK1=JFK1,JFK2=JFK2,JFK3=JFK3,JFK4=JFK4,
	EWR1=EWR1,EWR2=EWR2,EWR3=EWR3,EWR4=EWR4,LGA1=LGA1,LGA2=LGA2,LGA3=LGA3,LGA4=LGA4)

# Combine the feature data
TAF_features$date = as.Date(as.character(TAF_features$date),"%m/%d/%Y")
ASPM_features$Date = as.Date(as.character(ASPM_features$Date),"%m/%d/%Y")
feature_data = merge(x=TAF_features,y=ASPM_features,by.x="date",by.y="Date",all.x=T)

# Optimize data for clustering, including imputing missing values
Date_vec = format(feature_data$date,"%m/%d/%Y")
feature_data = feature_data[,2:77]
fake_features = feature_data
for (i1 in 1:length(fake_features[1,])) {
	fake_features[,i1] = as.numeric(fake_features[,i1])
	fake_features[is.na(fake_features[,i1]),i1] = mean(fake_features[,i1],na.rm=T)
	if (length(unique(fake_features[,i1]))>1) {
		fake_features[,i1] = scale(fake_features[,i1])
	} else {
		fake_features[,i1] = 0
	}
}

# Cluster
library(cluster)
# Make a table of representative dates at airports in the New York area
cluster_1 = pam(x=fake_features,k=10,diss=F,metric="manhattan",keep.diss=F,keep.data=F)
meds = sort(cluster_1$id.med)
representative = data.frame(date=Date_vec[meds],
	JFK_arr=JFK1[meds]+JFK2[meds]+JFK3[meds]+JFK4[meds],
	EWR_arr=EWR1[meds]+EWR2[meds]+EWR3[meds]+EWR4[meds],
	LGA_arr=LGA1[meds]+LGA2[meds]+LGA3[meds]+LGA4[meds],
	JFK_wind=round((TAF_features$cross_JFK_1[meds]+TAF_features$cross_JFK_2[meds]+TAF_features$cross_JFK_3[meds]+TAF_features$cross_JFK_4[meds])/4,1),
	EWR_wind=round((TAF_features$cross_EWR_1[meds]+TAF_features$cross_EWR_2[meds]+TAF_features$cross_EWR_3[meds]+TAF_features$cross_EWR_4[meds])/4,1),
	LGAa_wind=round((TAF_features$cross_LGAa_1[meds]+TAF_features$cross_LGAa_2[meds]+TAF_features$cross_LGAa_3[meds]+TAF_features$cross_LGAa_4[meds])/4,1),
	LGAa_wind=round((TAF_features$cross_LGAb_1[meds]+TAF_features$cross_LGAb_2[meds]+TAF_features$cross_LGAb_3[meds]+TAF_features$cross_LGAb_4[meds])/4,1))
representative
# Make graphs of avg silhouette width when clustering for NY area and for JFK alone
sil_widths = c()
for (i1 in 2:30) {
	cluster_1 = pam(x=fake_features,k=i1,diss=F,metric="manhattan",keep.diss=F,keep.data=F)
	sil_widths = c(sil_widths,cluster_1$silinfo$avg.width)
}
library(ggplot2)
plot_data = data.frame(k=c(2:30),sil_width=sil_widths)
pdf("Fig5.pdf",width=8,height=4)
ggplot(data=plot_data,aes(x=k,y=sil_width,group=1))+geom_line(colour="orange")+geom_point(colour="orange")+xlab("Number of Clusters")+ylab("Average Silhouette Width")+theme_bw()
dev.off()
JFK_features = c(1:4,17:20,29:32,41:44,53:56,65:68)
JFK_data = fake_features[,JFK_features]
sil_widths = c()
for (i1 in 2:30) {
	cluster_1 = pam(x=JFK_data,k=i1,diss=F,metric="manhattan",keep.diss=F,keep.data=F)
	sil_widths = c(sil_widths,cluster_1$silinfo$avg.width)
}
library(ggplot2)
plot_data = data.frame(k=c(2:30),sil_width=sil_widths)
pdf("Fig6.pdf",width=8,height=4)
ggplot(data=plot_data,aes(x=k,y=sil_width,group=1))+geom_line(colour="orange")+geom_point(colour="orange")+xlab("Number of Clusters")+ylab("Average Silhouette Width")+theme_bw()
dev.off()
# Run PAM clustering for a few reasonable values of k
pam4 = pam(x=fake_features,k=4,diss=F,metric="manhattan",keep.diss=F,keep.data=F)
pam8 = pam(x=fake_features,k=8,diss=F,metric="manhattan",keep.diss=F,keep.data=F)
pam12 = pam(x=fake_features,k=12,diss=F,metric="manhattan",keep.diss=F,keep.data=F)
pam16 = pam(x=fake_features,k=16,diss=F,metric="manhattan",keep.diss=F,keep.data=F)
pam20 = pam(x=fake_features,k=20,diss=F,metric="manhattan",keep.diss=F,keep.data=F)
# Use k means as a comparison
k4 = kmeans(x=fake_features,centers=4)
k8 = kmeans(x=fake_features,centers=8)
k12 = kmeans(x=fake_features,centers=12)
k16 = kmeans(x=fake_features,centers=16)
k20 = kmeans(x=fake_features,centers=20)

# Make some summary stats for web app
JFK_arrivals = feature_data$JFK1+feature_data$JFK2+feature_data$JFK3+feature_data$JFK4
EWR_arrivals = feature_data$EWR1+feature_data$EWR2+feature_data$EWR3+feature_data$EWR4
LGA_arrivals = feature_data$LGA1+feature_data$LGA2+feature_data$LGA3+feature_data$LGA4
NYC_arrivals = JFK_arrivals+EWR_arrivals+LGA_arrivals
mean_cross = apply(X=feature_data[,1:16],MARGIN=1,FUN=mean,na.rm=T)
mean_vis = apply(X=feature_data[,17:28],MARGIN=1,FUN=mean,na.rm=T)
is_snow = apply(X=feature_data[,29:40],MARGIN=1,FUN=sum,na.rm=T)
is_snow[is_snow>0] = 1
is_TS = apply(X=feature_data[,41:52],MARGIN=1,FUN=sum,na.rm=T)
is_TS[is_TS>0] = 1
is_rain = apply(X=feature_data[,53:64],MARGIN=1,FUN=sum,na.rm=T)
is_rain[is_rain>0] = 1
sum_stats = data.frame(rain=is_rain,snow=is_snow,thunderstorm=is_TS,visibility=round(mean_vis,1),crosswind=round(mean_cross,1),scheduled=NYC_arrivals)

# Write out the results as csv files
results = data.frame(date=Date_vec,cluster=pam4$cluster,sum_stats)
fname = paste(output_dir,"NY_pam_4.csv",sep="")
write.csv(results,fname,row.names=F)
results = data.frame(date=Date_vec,cluster=pam8$cluster,sum_stats)
fname = paste(output_dir,"NY_pam_8.csv",sep="")
write.csv(results,fname,row.names=F)
results = data.frame(date=Date_vec,cluster=pam12$cluster,sum_stats)
fname = paste(output_dir,"NY_pam_12.csv",sep="")
write.csv(results,fname,row.names=F)
results = data.frame(date=Date_vec,cluster=pam16$cluster,sum_stats)
fname = paste(output_dir,"NY_pam_16.csv",sep="")
write.csv(results,fname,row.names=F)
results = data.frame(date=Date_vec,cluster=pam20$cluster,sum_stats)
fname = paste(output_dir,"NY_pam_20.csv",sep="")
write.csv(results,fname,row.names=F)

results = data.frame(date=Date_vec,cluster=k4$cluster,sum_stats)
fname = paste(output_dir,"NY_kmeans_4.csv",sep="")
write.csv(results,fname,row.names=F)
results = data.frame(date=Date_vec,cluster=k8$cluster,sum_stats)
fname = paste(output_dir,"NY_kmeans_8.csv",sep="")
write.csv(results,fname,row.names=F)
results = data.frame(date=Date_vec,cluster=k12$cluster,sum_stats)
fname = paste(output_dir,"NY_kmeans_12.csv",sep="")
write.csv(results,fname,row.names=F)
results = data.frame(date=Date_vec,cluster=k16$cluster,sum_stats)
fname = paste(output_dir,"NY_kmeans_16.csv",sep="")
write.csv(results,fname,row.names=F)
results = data.frame(date=Date_vec,cluster=k20$cluster,sum_stats)
fname = paste(output_dir,"NY_kmeans_20.csv",sep="")
write.csv(results,fname,row.names=F)












