# Load in the relevant feature data
aspm = read.csv("./features_data/ASPM_features.csv")
taf = read.csv("./features_data/NY_TAF_expert.csv")
ruc1 = read.csv("./features_data/NY_RUC_expert_1.csv")
ruc2 = read.csv("./features_data/NY_RUC_expert_2.csv")
ruc3 = read.csv("./features_data/NY_RUC_expert_3.csv")
tfmi = read.csv("./features_data/TFMI_features.csv")

# Reformat date information
aspm$date = strptime(aspm$date,"%m/%d/%Y")
taf$date = strptime(taf$date,"%m/%d/%Y")
tfmi$date = strptime(tfmi$date,"%m/%d/%Y")
ruc1$date = strptime(seq(as.Date("2010/1/1"),as.Date("2014/12/31"),"days"),"%Y-%m-%d")
ruc2$date = strptime(seq(as.Date("2010/1/1"),as.Date("2014/12/31"),"days"),"%Y-%m-%d")
ruc3$date = strptime(seq(as.Date("2010/1/1"),as.Date("2014/12/31"),"days"),"%Y-%m-%d")

# Merge data into one data frame
all_data = merge(x=aspm,y=taf,by.x="date",by.y="date",all=T)
all_data = merge(x=all_data,y=tfmi,by.x="date",by.y="date",all=T)
all_data = merge(x=all_data,y=ruc1,by.x="date",by.y="date",all=T)
all_data = merge(x=all_data,y=ruc2,by.x="date",by.y="date",all=T)
all_data = merge(x=all_data,y=ruc3,by.x="date",by.y="date",all=T)

# Throw out the old data
rm(aspm,taf,ruc1,ruc2,ruc3,tfmi)

#
# Build a model of GDP during 3 hour blocks of time
#
# Start by reformating data
model_GDP = data.frame(is_GDP=c(all_data$GDP_6_9,all_data$GDP_9_12,all_data$GDP_12_15,all_data$GDP_15_18),
	LGA_traffic=c(all_data$LGA1,all_data$LGA2,all_data$LGA3,all_data$LGA4),
	JFK_traffic=c(all_data$JFK1,all_data$JFK2,all_data$JFK3,all_data$JFK4),
	EWR_traffic=c(all_data$EWR1,all_data$EWR2,all_data$EWR3,all_data$EWR4),
	cross_JFK_rwy13=c(all_data$cross_JFK_1,all_data$cross_JFK_2,all_data$cross_JFK_3,all_data$cross_JFK_4),
	cross_EWR_rwy4=c(all_data$cross_EWR_1,all_data$cross_EWR_2,all_data$cross_EWR_3,all_data$cross_EWR_4),
	cross_LGA_rwy4=c(all_data$cross_LGAa_1,all_data$cross_LGAa_2,all_data$cross_LGAa_3,all_data$cross_LGAa_4),
	cross_LGA_rwy13=c(all_data$cross_LGAb_1,all_data$cross_LGAb_2,all_data$cross_LGAb_3,all_data$cross_LGAb_4),
	vis_JFK=c(all_data$vis_JFK_1,all_data$vis_JFK_2,all_data$vis_JFK_3,all_data$vis_JFK_4),
	vis_EWR=c(all_data$vis_EWR_1,all_data$vis_EWR_2,all_data$vis_EWR_3,all_data$vis_EWR_4),
	vis_LGA=c(all_data$vis_LGA_1,all_data$vis_LGA_2,all_data$vis_LGA_3,all_data$vis_LGA_4),
	snow_JFK=c(all_data$snow_JFK_1,all_data$snow_JFK_2,all_data$snow_JFK_3,all_data$snow_JFK_4),
	snow_EWR=c(all_data$snow_EWR_1,all_data$snow_EWR_2,all_data$snow_EWR_3,all_data$snow_EWR_4),
	snow_LGA=c(all_data$snow_LGA_1,all_data$snow_LGA_2,all_data$snow_LGA_3,all_data$snow_LGA_4),
	TS_JFK=c(all_data$TS_JFK_1,all_data$TS_JFK_2,all_data$TS_JFK_3,all_data$TS_JFK_4),
	TS_EWR=c(all_data$TS_EWR_1,all_data$TS_EWR_2,all_data$TS_EWR_3,all_data$TS_EWR_4),
	TS_LGA=c(all_data$TS_LGA_1,all_data$TS_LGA_2,all_data$TS_LGA_3,all_data$TS_LGA_4),
	rain_JFK=c(all_data$rain_JFK_1,all_data$rain_JFK_2,all_data$rain_JFK_3,all_data$rain_JFK_4),
	rain_EWR=c(all_data$rain_EWR_1,all_data$rain_EWR_2,all_data$rain_EWR_3,all_data$rain_EWR_4),
	rain_LGA=c(all_data$rain_LGA_1,all_data$rain_LGA_2,all_data$rain_LGA_3,all_data$rain_LGA_4),
	dist_mod_precip=c(all_data$dist_mod_precip_3,all_data$dist_mod_precip_4,all_data$dist_mod_precip_5,all_data$dist_mod_precip_6),
	dist_int_precip=c(all_data$dist_int_precip_3,all_data$dist_int_precip_4,all_data$dist_int_precip_5,all_data$dist_int_precip_6),
	dist_sup_precip=c(all_data$dist_sup_precip_3,all_data$dist_sup_precip_4,all_data$dist_sup_precip_5,all_data$dist_sup_precip_6))
model_GDP = model_GDP[which(complete.cases(model_GDP)),]
model_GDP$is_GDP = as.factor(model_GDP$is_GDP)
model_GDP$snow_JFK = as.factor(model_GDP$snow_JFK)
model_GDP$snow_EWR = as.factor(model_GDP$snow_EWR)
model_GDP$snow_LGA = as.factor(model_GDP$snow_LGA)
model_GDP$TS_JFK = as.factor(model_GDP$TS_JFK)
model_GDP$TS_EWR = as.factor(model_GDP$TS_EWR)
model_GDP$TS_LGA = as.factor(model_GDP$TS_LGA)
model_GDP$rain_JFK = as.factor(model_GDP$rain_JFK)
model_GDP$rain_EWR = as.factor(model_GDP$rain_EWR)
model_GDP$rain_LGA = as.factor(model_GDP$rain_LGA)
# Now build a classification model
library(wsrf)
wsrf_model = wsrf(is_GDP~.,data=model_GDP)
# Record variable importance
GDP_var_import = importance.wsrf(wsrf_model)
GDP_var_names = row.names(GDP_var_import)
GDP_var_importances = GDP_var_import[,1]
GDP_classification = data.frame(variable=GDP_var_names,importance=GDP_var_importances)
write.csv(GDP_classification,"GDP_importance.csv",row.names=F)

# Repeat but for GS
model_GS = data.frame(is_GS=c(all_data$GS_6_9,all_data$GS_9_12,all_data$GS_12_15,all_data$GS_15_18),
	LGA_traffic=c(all_data$LGA1,all_data$LGA2,all_data$LGA3,all_data$LGA4),
	JFK_traffic=c(all_data$JFK1,all_data$JFK2,all_data$JFK3,all_data$JFK4),
	EWR_traffic=c(all_data$EWR1,all_data$EWR2,all_data$EWR3,all_data$EWR4),
	cross_JFK_rwy13=c(all_data$cross_JFK_1,all_data$cross_JFK_2,all_data$cross_JFK_3,all_data$cross_JFK_4),
	cross_EWR_rwy4=c(all_data$cross_EWR_1,all_data$cross_EWR_2,all_data$cross_EWR_3,all_data$cross_EWR_4),
	cross_LGA_rwy4=c(all_data$cross_LGAa_1,all_data$cross_LGAa_2,all_data$cross_LGAa_3,all_data$cross_LGAa_4),
	cross_LGA_rwy13=c(all_data$cross_LGAb_1,all_data$cross_LGAb_2,all_data$cross_LGAb_3,all_data$cross_LGAb_4),
	vis_JFK=c(all_data$vis_JFK_1,all_data$vis_JFK_2,all_data$vis_JFK_3,all_data$vis_JFK_4),
	vis_EWR=c(all_data$vis_EWR_1,all_data$vis_EWR_2,all_data$vis_EWR_3,all_data$vis_EWR_4),
	vis_LGA=c(all_data$vis_LGA_1,all_data$vis_LGA_2,all_data$vis_LGA_3,all_data$vis_LGA_4),
	snow_JFK=c(all_data$snow_JFK_1,all_data$snow_JFK_2,all_data$snow_JFK_3,all_data$snow_JFK_4),
	snow_EWR=c(all_data$snow_EWR_1,all_data$snow_EWR_2,all_data$snow_EWR_3,all_data$snow_EWR_4),
	snow_LGA=c(all_data$snow_LGA_1,all_data$snow_LGA_2,all_data$snow_LGA_3,all_data$snow_LGA_4),
	TS_JFK=c(all_data$TS_JFK_1,all_data$TS_JFK_2,all_data$TS_JFK_3,all_data$TS_JFK_4),
	TS_EWR=c(all_data$TS_EWR_1,all_data$TS_EWR_2,all_data$TS_EWR_3,all_data$TS_EWR_4),
	TS_LGA=c(all_data$TS_LGA_1,all_data$TS_LGA_2,all_data$TS_LGA_3,all_data$TS_LGA_4),
	rain_JFK=c(all_data$rain_JFK_1,all_data$rain_JFK_2,all_data$rain_JFK_3,all_data$rain_JFK_4),
	rain_EWR=c(all_data$rain_EWR_1,all_data$rain_EWR_2,all_data$rain_EWR_3,all_data$rain_EWR_4),
	rain_LGA=c(all_data$rain_LGA_1,all_data$rain_LGA_2,all_data$rain_LGA_3,all_data$rain_LGA_4),
	dist_mod_precip=c(all_data$dist_mod_precip_3,all_data$dist_mod_precip_4,all_data$dist_mod_precip_5,all_data$dist_mod_precip_6),
	dist_int_precip=c(all_data$dist_int_precip_3,all_data$dist_int_precip_4,all_data$dist_int_precip_5,all_data$dist_int_precip_6),
	dist_sup_precip=c(all_data$dist_sup_precip_3,all_data$dist_sup_precip_4,all_data$dist_sup_precip_5,all_data$dist_sup_precip_6))
model_GS = model_GS[which(complete.cases(model_GS)),]
model_GS$is_GS = as.factor(model_GS$is_GS)
model_GS$snow_JFK = as.factor(model_GS$snow_JFK)
model_GS$snow_EWR = as.factor(model_GS$snow_EWR)
model_GS$snow_LGA = as.factor(model_GS$snow_LGA)
model_GS$TS_JFK = as.factor(model_GS$TS_JFK)
model_GS$TS_EWR = as.factor(model_GS$TS_EWR)
model_GS$TS_LGA = as.factor(model_GS$TS_LGA)
model_GS$rain_JFK = as.factor(model_GS$rain_JFK)
model_GS$rain_EWR = as.factor(model_GS$rain_EWR)
model_GS$rain_LGA = as.factor(model_GS$rain_LGA)
# Now build a classification model
GS_model = wsrf(is_GS~.,data=model_GS)
# Record variable importance
GS_var_import = importance.wsrf(GS_model)
GS_var_names = row.names(GS_var_import)
GS_var_importances = GS_var_import[,1]
GS_classification = data.frame(variable=GS_var_names,importance=GS_var_importances)
write.csv(GS_classification,"GS_importance.csv",row.names=F)

# Repeat but for reroutes
model_Reroute = data.frame(is_Reroute=c(all_data$Reroute_6_9,all_data$Reroute_9_12,all_data$Reroute_12_15,all_data$Reroute_15_18),
	LGA_traffic=c(all_data$LGA1,all_data$LGA2,all_data$LGA3,all_data$LGA4),
	JFK_traffic=c(all_data$JFK1,all_data$JFK2,all_data$JFK3,all_data$JFK4),
	EWR_traffic=c(all_data$EWR1,all_data$EWR2,all_data$EWR3,all_data$EWR4),
	cross_JFK_rwy13=c(all_data$cross_JFK_1,all_data$cross_JFK_2,all_data$cross_JFK_3,all_data$cross_JFK_4),
	cross_EWR_rwy4=c(all_data$cross_EWR_1,all_data$cross_EWR_2,all_data$cross_EWR_3,all_data$cross_EWR_4),
	cross_LGA_rwy4=c(all_data$cross_LGAa_1,all_data$cross_LGAa_2,all_data$cross_LGAa_3,all_data$cross_LGAa_4),
	cross_LGA_rwy13=c(all_data$cross_LGAb_1,all_data$cross_LGAb_2,all_data$cross_LGAb_3,all_data$cross_LGAb_4),
	vis_JFK=c(all_data$vis_JFK_1,all_data$vis_JFK_2,all_data$vis_JFK_3,all_data$vis_JFK_4),
	vis_EWR=c(all_data$vis_EWR_1,all_data$vis_EWR_2,all_data$vis_EWR_3,all_data$vis_EWR_4),
	vis_LGA=c(all_data$vis_LGA_1,all_data$vis_LGA_2,all_data$vis_LGA_3,all_data$vis_LGA_4),
	snow_JFK=c(all_data$snow_JFK_1,all_data$snow_JFK_2,all_data$snow_JFK_3,all_data$snow_JFK_4),
	snow_EWR=c(all_data$snow_EWR_1,all_data$snow_EWR_2,all_data$snow_EWR_3,all_data$snow_EWR_4),
	snow_LGA=c(all_data$snow_LGA_1,all_data$snow_LGA_2,all_data$snow_LGA_3,all_data$snow_LGA_4),
	TS_JFK=c(all_data$TS_JFK_1,all_data$TS_JFK_2,all_data$TS_JFK_3,all_data$TS_JFK_4),
	TS_EWR=c(all_data$TS_EWR_1,all_data$TS_EWR_2,all_data$TS_EWR_3,all_data$TS_EWR_4),
	TS_LGA=c(all_data$TS_LGA_1,all_data$TS_LGA_2,all_data$TS_LGA_3,all_data$TS_LGA_4),
	rain_JFK=c(all_data$rain_JFK_1,all_data$rain_JFK_2,all_data$rain_JFK_3,all_data$rain_JFK_4),
	rain_EWR=c(all_data$rain_EWR_1,all_data$rain_EWR_2,all_data$rain_EWR_3,all_data$rain_EWR_4),
	rain_LGA=c(all_data$rain_LGA_1,all_data$rain_LGA_2,all_data$rain_LGA_3,all_data$rain_LGA_4),
	dist_mod_precip=c(all_data$dist_mod_precip_3,all_data$dist_mod_precip_4,all_data$dist_mod_precip_5,all_data$dist_mod_precip_6),
	dist_int_precip=c(all_data$dist_int_precip_3,all_data$dist_int_precip_4,all_data$dist_int_precip_5,all_data$dist_int_precip_6),
	dist_sup_precip=c(all_data$dist_sup_precip_3,all_data$dist_sup_precip_4,all_data$dist_sup_precip_5,all_data$dist_sup_precip_6))
model_Reroute = model_Reroute[which(complete.cases(model_Reroute)),]
model_Reroute$is_Reroute = as.factor(model_Reroute$is_Reroute)
model_Reroute$snow_JFK = as.factor(model_Reroute$snow_JFK)
model_Reroute$snow_EWR = as.factor(model_Reroute$snow_EWR)
model_Reroute$snow_LGA = as.factor(model_Reroute$snow_LGA)
model_Reroute$TS_JFK = as.factor(model_Reroute$TS_JFK)
model_Reroute$TS_EWR = as.factor(model_Reroute$TS_EWR)
model_Reroute$TS_LGA = as.factor(model_Reroute$TS_LGA)
model_Reroute$rain_JFK = as.factor(model_Reroute$rain_JFK)
model_Reroute$rain_EWR = as.factor(model_Reroute$rain_EWR)
model_Reroute$rain_LGA = as.factor(model_Reroute$rain_LGA)
# Now build a classification model
Reroute_model = wsrf(is_Reroute~.,data=model_Reroute)
# Record variable importance
Reroute_var_import = importance.wsrf(Reroute_model)
Reroute_var_names = row.names(Reroute_var_import)
Reroute_var_importances = Reroute_var_import[,1]
Reroute_classification = data.frame(variable=Reroute_var_names,importance=Reroute_var_importances)
write.csv(Reroute_classification,"Reroute_importance.csv",row.names=F)
# Get an averaged measure of variable importance
avg_imp = Reroute_classification$importance+GS_classification$importance+GDP_classification$importance
var_df = data.frame(Variable=GS_classification$variable,Importance=avg_imp)
var_df = var_df[which(var_df$Importance>4),]
var.barplot = ggplot(var_df,aes(x=reorder(Variable,-Importance),y=Importance))+geom_bar(stat="identity",fill="orange",colour="black")
var.barplot = var.barplot+theme_bw()+theme(axis.text=element_text(size=7))+labs(x="Variable")
pdf("VariableImportance.pdf",width=9,height=4)
var.barplot
dev.off()


# OK now on to the cluster analysis
#
# Get just the feature data into a data frame
just_these = c(2:77,108:119)
just_features = all_data[,just_these]
# Rescale the feature data using the variable importance data
scaled_features = scale(just_features)
for (i1 in 1:22) {
	for (i2 in 1:4) {
		i3 = 4*(i1-1)+i2
		scaled_features[,i3] = avg_imp[i1]*scaled_features[,i3]
	}
}
# Wow, there's a lot of missing data.  Remove rows with more than 10 missing values.
nrows = length(scaled_features[,1])
missings = c(rep(0,nrows))
for (i1 in 1:nrows) {
	missings[i1] = sum(is.na(scaled_features[i1,]))
}
bad_data = which(missings>40)
scaled_features = scaled_features[-bad_data,]
# Now cluster
library(cluster)
pam5 = pam(scaled_features,k=5,metric="manhattan")
pam10 = pam(scaled_features,k=10,metric="manhattan")
pam15 = pam(scaled_features,k=15,metric="manhattan")
pam20 = pam(scaled_features,k=20,metric="manhattan")
pam25 = pam(scaled_features,k=25,metric="manhattan")
# Pick out five key statistics about each day to display in the web app
new_dates = all_data$date[-bad_data]
new_dates = as.character(new_dates,"%m/%d/%Y")
new_traffic = all_data$LGA1[-bad_data]+all_data$LGA2[-bad_data]+all_data$LGA3[-bad_data]+all_data$LGA4[-bad_data]+
	all_data$JFK1[-bad_data]+all_data$JFK2[-bad_data]+all_data$JFK3[-bad_data]+all_data$JFK4[-bad_data]+
	all_data$EWR1[-bad_data]+all_data$EWR2[-bad_data]+all_data$EWR3[-bad_data]+all_data$EWR4[-bad_data]
new_traffic[is.na(new_traffic)] = mean(new_traffic,na.rm=T)
new_traffic = (new_traffic-min(new_traffic,na.rm=T))/(max(new_traffic,na.rm=T)-min(new_traffic,na.rm=T))
new_cross = all_data$cross_JFK_1[-bad_data]+all_data$cross_JFK_2[-bad_data]+all_data$cross_JFK_3[-bad_data]+all_data$cross_JFK_4[-bad_data]+
	all_data$cross_EWR_1[-bad_data]+all_data$cross_EWR_2[-bad_data]+all_data$cross_EWR_3[-bad_data]+all_data$cross_EWR_4[-bad_data]+
	all_data$cross_LGAa_1[-bad_data]+all_data$cross_LGAa_2[-bad_data]+all_data$cross_LGAa_3[-bad_data]+all_data$cross_LGAa_4[-bad_data]+
	all_data$cross_LGAb_1[-bad_data]+all_data$cross_LGAb_2[-bad_data]+all_data$cross_LGAb_3[-bad_data]+all_data$cross_LGAb_4[-bad_data]
new_cross[is.na(new_cross)] = mean(new_cross,na.rm=T)
new_cross = (new_cross-min(new_cross,na.rm=T))/(max(new_cross,na.rm=T)-min(new_cross,na.rm=T))
new_vis = all_data$vis_JFK_1[-bad_data]+all_data$vis_JFK_2[-bad_data]+all_data$vis_JFK_3[-bad_data]+all_data$vis_JFK_4[-bad_data]+
	all_data$vis_EWR_1[-bad_data]+all_data$vis_EWR_2[-bad_data]+all_data$vis_EWR_3[-bad_data]+all_data$vis_EWR_4[-bad_data]+
	all_data$vis_LGA_1[-bad_data]+all_data$vis_LGA_2[-bad_data]+all_data$vis_LGA_3[-bad_data]+all_data$vis_LGA_4[-bad_data]
new_vis = (new_vis-min(new_vis,na.rm=T))/(max(new_vis,na.rm=T)-min(new_vis,na.rm=T))
new_TS = all_data$TS_JFK_1[-bad_data]+all_data$TS_JFK_2[-bad_data]+all_data$TS_JFK_3[-bad_data]+all_data$TS_JFK_4[-bad_data]+
	all_data$TS_EWR_1[-bad_data]+all_data$TS_EWR_2[-bad_data]+all_data$TS_EWR_3[-bad_data]+all_data$TS_EWR_4[-bad_data]+
	all_data$TS_LGA_1[-bad_data]+all_data$TS_LGA_2[-bad_data]+all_data$TS_LGA_3[-bad_data]+all_data$TS_LGA_4[-bad_data]
new_TS = (new_TS-min(new_TS,na.rm=T))/(max(new_TS,na.rm=T)-min(new_TS,na.rm=T))
new_rain = all_data$rain_JFK_1[-bad_data]+all_data$rain_JFK_2[-bad_data]+all_data$rain_JFK_3[-bad_data]+all_data$rain_JFK_4[-bad_data]+
	all_data$rain_EWR_1[-bad_data]+all_data$rain_EWR_2[-bad_data]+all_data$rain_EWR_3[-bad_data]+all_data$rain_EWR_4[-bad_data]+
	all_data$rain_LGA_1[-bad_data]+all_data$rain_LGA_2[-bad_data]+all_data$rain_LGA_3[-bad_data]+all_data$rain_LGA_4[-bad_data]
new_rain = (new_rain-min(new_rain,na.rm=T))/(max(new_rain,na.rm=T)-min(new_rain,na.rm=T))
# Save the results
results5 = data.frame(date=new_dates,cluster=pam5$clustering,traffic=new_traffic,crosswind=new_cross,
	visibility=new_vis,thunderstorm=new_TS,rain=new_rain)
write.csv(results5,"PAM_5.csv",row.names=F)
results10 = data.frame(date=new_dates,cluster=pam10$clustering,traffic=new_traffic,crosswind=new_cross,
	visibility=new_vis,thunderstorm=new_TS,rain=new_rain)
write.csv(results10,"PAM_10.csv",row.names=F)
results15 = data.frame(date=new_dates,cluster=pam15$clustering,traffic=new_traffic,crosswind=new_cross,
	visibility=new_vis,thunderstorm=new_TS,rain=new_rain)
write.csv(results15,"PAM_15.csv",row.names=F)
results20 = data.frame(date=new_dates,cluster=pam20$clustering,traffic=new_traffic,crosswind=new_cross,
	visibility=new_vis,thunderstorm=new_TS,rain=new_rain)
write.csv(results20,"PAM_20.csv",row.names=F)
results25 = data.frame(date=new_dates,cluster=pam25$clustering,traffic=new_traffic,crosswind=new_cross,
	visibility=new_vis,thunderstorm=new_TS,rain=new_rain)
write.csv(results25,"PAM_25.csv",row.names=F)

sils = c(rep(-99,49))
key_features = c(1:12,15:20)
new_data = scaled_features[complete.cases(scaled_features[,key_features]),key_features]
for (i1 in 1:49) {
	new_model = pam(new_data,k=i1+1,metric="manhattan")
	sils[i1] = new_model$silinfo$avg.width
}
plot_data = data.frame(k=c(2:50),sil_width=sils)
pdf("SilWidth.pdf",width=8,height=4)
ggplot(data=plot_data,aes(x=k,y=sil_width,group=1))+geom_line(colour="orange")+geom_point(colour="orange")+xlab("Number of Clusters")+ylab("Average Silhouette Width")+theme_bw()
dev.off()

