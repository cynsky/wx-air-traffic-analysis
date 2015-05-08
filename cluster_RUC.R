# This is a script for using k-means and DBSCAN clustering algorithms to pick out sets of similar days
# based on features previously extracted from RUC and RAP data to describe aviation forecast weather
# in the airspace around New York on days in 2010, 2011, 2012, and 2014.
#
# Script author: Kenneth Kuhn
# Last modified: 5/8/2015

# Point out the base directories for reading in and saving data
input_dir = "/Volumes/NASA_data_copy/features_data/"
output_dir = "/Volumes/NASA_data_copy/output_clustering/"

# Read in the feature data
raw_pca1 = read.csv(paste(input_dir,"NY_RUC_PCA.csv",sep=""))
raw_pca2 = read.csv(paste(input_dir,"NY_RUC_PCA_2.csv",sep=""))
raw_exp1 = read.csv(paste(input_dir,"NY_RUC_expert_1.csv",sep=""))
raw_exp2 = read.csv(paste(input_dir,"NY_RUC_expert_2.csv",sep=""))
raw_exp3 = read.csv(paste(input_dir,"NY_RUC_expert_3.csv",sep=""))

# Pick out the dates
date_list = as.Date(raw_pca1[,1])
date_list = date_list[1:1098] # Drop 2015 dates
d_list = as.character(date_list,"%m/%d/%Y")


# Drop the dates for which we have blank Expert Judgement Features
ref_d_list = seq(from=as.Date("2010/01/01"),len=1826,by="1 day")
compare_date_lists = ref_d_list %in% date_list
raw_exp1 = raw_exp1[compare_date_lists,]
raw_exp2 = raw_exp2[compare_date_lists,]
raw_exp3 = raw_exp3[compare_date_lists,]
raw_pca1 = raw_pca1[1:1098,] # Drop 2015 dates
raw_pca2 = raw_pca2[1:1098,] # Drop 2015 dates

# Remove the date vector from each data frame
raw_pca1 = raw_pca1[,2:15]
raw_pca2 = raw_pca2[,2:11]

# Scale the feature data
pca1 = scale(raw_pca1)
pca2 = scale(raw_pca2)
exp1 = scale(raw_exp1)
exp2 = scale(raw_exp2)
exp2[,2] = 0 # Something went wrong, no airway precipitation reported
exp3 = scale(raw_exp3)

# To use the elbow method and pick out the correct k for k means
# Run the following code and eyeball the resulting graph
wss = (nrow(exp3)-1)*sum(apply(exp3,2,var))
for (i1 in 2:25) { wss[i]=sum(kmeans(exp3,centers=i1)$withinss) }
plot(1:25,wss,type="b",xlab="Number of Clusters",ylab="Within groups sum of squares")
# Or calculate the BIC
kmeansBIC = function(fit){
  m = ncol(fit$centers)
  n = length(fit$cluster)
  k = nrow(fit$centers)
  D = fit$tot.withinss
  return(D+log(n)*m*k)
}
BIC = (nrow(exp3)-1)*sum(apply(exp3,2,var))
for (i1 in 2:25) {
  new_model = kmeans(exp3,centers=i1)
  BIC[i1] = kmeansBIC(new_model)
}

# Pick out clusters using k-means clustering where k is set to 5, 10, or 20
pca1_k5 = kmeans(pca1,5)
pca2_k5 = kmeans(pca2,5)
exp1_k5 = kmeans(exp1,5)
exp2_k5 = kmeans(exp2,5)
exp3_k5 = kmeans(exp3,5)
pca1_k10 = kmeans(pca1,10)
pca2_k10 = kmeans(pca2,10)
exp1_k10 = kmeans(exp1,10)
exp2_k10 = kmeans(exp2,10)
exp3_k10 = kmeans(exp3,10)
pca1_k20 = kmeans(pca1,20)
pca2_k20 = kmeans(pca2,20)
exp1_k20 = kmeans(exp1,20)
exp2_k20 = kmeans(exp2,20)
exp3_k20 = kmeans(exp3,20)

# Pick out clusters using DBSCAN clustering
library(fpc)
reach_dist = 1.5
pca1_d = dbscan(pca1,reach_dist)
pca2_d = dbscan(pca2,reach_dist)
exp1_d = dbscan(exp1,reach_dist)
exp2_d = dbscan(exp2,reach_dist)
exp3_d = dbscan(exp3,reach_dist)

# Make data frames for export. For each set of cluster results, include 5 variables.  (THe web app will show
# 5 features on a spider or parallel coordinates plot to let the user explore clusters.) In the case of PCA,
# the raw data has no intuitive meaning so use some of the features from the expert judgement feature set.
pca1_k5_df = data.frame(date=d_list,cluster=pca1_k5$cluster,fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
  fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])
pca2_k5_df = data.frame(date=d_list,cluster=pca2_k5$cluster,fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
  fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])
exp1_k5_df = data.frame(date=d_list,cluster=exp1_k5$cluster,dist_mod_precip_1=raw_exp1[,1],dist_int_precip_1=raw_exp1[,2],
 dist_sup_precip_1=raw_exp1[,3],dist_mod_precip_2=raw_exp1[,4],dist_int_precip_2=raw_exp1[,5])
exp2_k5_df = data.frame(date=d_list,cluster=exp2_k5$cluster,airways_blocked=raw_exp2[,1],airway_precip=raw_exp2[,2],
 airway_CAPE=raw_exp2[,3],max_airway_precip=raw_exp2[,4],airways_impacted=raw_exp2[,5])
exp3_k5_df = data.frame(date=d_list,cluster=exp3_k5$cluster,fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
 fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])

pca1_k10_df = data.frame(date=d_list,cluster=pca1_k10$cluster,fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
  fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])
pca2_k10_df = data.frame(date=d_list,cluster=pca2_k10$cluster,fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
  fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])
exp1_k10_df = data.frame(date=d_list,cluster=exp1_k10$cluster,dist_mod_precip_1=raw_exp1[,1],dist_int_precip_1=raw_exp1[,2],
 dist_sup_precip_1=raw_exp1[,3],dist_mod_precip_2=raw_exp1[,4],dist_int_precip_2=raw_exp1[,5])
exp2_k10_df = data.frame(date=d_list,cluster=exp2_k10$cluster,airways_blocked=raw_exp2[,1],airway_precip=raw_exp2[,2],
 airway_CAPE=raw_exp2[,3],max_airway_precip=raw_exp2[,4],airways_impacted=raw_exp2[,5])
exp3_k10_df = data.frame(date=d_list,cluster=exp3_k10$cluster,fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
 fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])

pca1_k20_df = data.frame(date=d_list,cluster=pca1_k20$cluster,fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
  fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])
pca2_k20_df = data.frame(date=d_list,cluster=pca2_k20$cluster,fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
  fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])
exp1_k20_df = data.frame(date=d_list,cluster=exp1_k20$cluster,dist_mod_precip_1=raw_exp1[,1],dist_int_precip_1=raw_exp1[,2],
 dist_sup_precip_1=raw_exp1[,3],dist_mod_precip_2=raw_exp1[,4],dist_int_precip_2=raw_exp1[,5])
exp2_k20_df = data.frame(date=d_list,cluster=exp2_k20$cluster,airways_blocked=raw_exp2[,1],airway_precip=raw_exp2[,2],
 airway_CAPE=raw_exp2[,3],max_airway_precip=raw_exp2[,4],airways_impacted=raw_exp2[,5])
exp3_k20_df = data.frame(date=d_list,cluster=exp3_k20$cluster,fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
 fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])

pca1_d_df = data.frame(date=d_list,cluster=I(1+pca1_d$cluster),fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
  fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])
pca2_d_df = data.frame(date=d_list,cluster=I(1+pca2_d$cluster),fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
  fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])
exp1_d_df = data.frame(date=d_list,cluster=I(1+exp1_d$cluster),dist_mod_precip_1=raw_exp1[,1],dist_int_precip_1=raw_exp1[,2],
 dist_sup_precip_1=raw_exp1[,3],dist_mod_precip_2=raw_exp1[,4],dist_int_precip_2=raw_exp1[,5])
exp2_d_df = data.frame(date=d_list,cluster=I(1+exp2_d$cluster),airways_blocked=raw_exp2[,1],airway_precip=raw_exp2[,2],
 airway_CAPE=raw_exp2[,3],max_airway_precip=raw_exp2[,4],airways_impacted=raw_exp2[,5])
exp3_d_df = data.frame(date=d_list,cluster=I(1+exp3_d$cluster),fixes_blocked=raw_exp3[,1],fix_precip=raw_exp3[,2],
 fix_CAPE=raw_exp3[,3],max_fix_precip=raw_exp3[,4],fixes_impacted=raw_exp3[,5])

# Write csv files, exporting the data frames for incorporation into the web app
setwd(output_dir)
write.csv(pca1_k5_df,file="NY_RUC_clust_pca1_k5.csv",row.names=F)
write.csv(pca2_k5_df,file="NY_RUC_clust_pca2_k5.csv",row.names=F)
write.csv(exp1_k5_df,file="NY_RUC_clust_exp1_k5.csv",row.names=F)
write.csv(exp2_k5_df,file="NY_RUC_clust_exp2_k5.csv",row.names=F)
write.csv(exp3_k5_df,file="NY_RUC_clust_exp3_k5.csv",row.names=F)

write.csv(pca1_k10_df,file="NY_RUC_clust_pca1_k10.csv",row.names=F)
write.csv(pca2_k10_df,file="NY_RUC_clust_pca2_k10.csv",row.names=F)
write.csv(exp1_k10_df,file="NY_RUC_clust_exp1_k10.csv",row.names=F)
write.csv(exp2_k10_df,file="NY_RUC_clust_exp2_k10.csv",row.names=F)
write.csv(exp3_k10_df,file="NY_RUC_clust_exp3_k10.csv",row.names=F)

write.csv(pca1_k20_df,file="NY_RUC_clust_pca1_k20.csv",row.names=F)
write.csv(pca2_k20_df,file="NY_RUC_clust_pca2_k20.csv",row.names=F)
write.csv(exp1_k20_df,file="NY_RUC_clust_exp1_k20.csv",row.names=F)
write.csv(exp2_k20_df,file="NY_RUC_clust_exp2_k20.csv",row.names=F)
write.csv(exp3_k20_df,file="NY_RUC_clust_exp3_k20.csv",row.names=F)

write.csv(pca1_d_df,file="NY_RUC_clust_pca1_d.csv",row.names=F)
write.csv(pca2_d_df,file="NY_RUC_clust_pca2_d.csv",row.names=F)
write.csv(exp1_d_df,file="NY_RUC_clust_exp1_d.csv",row.names=F)
write.csv(exp2_d_df,file="NY_RUC_clust_exp2_d.csv",row.names=F)
write.csv(exp3_d_df,file="NY_RUC_clust_exp3_d.csv",row.names=F)
