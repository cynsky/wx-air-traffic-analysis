# Read in the advisory details report data
test = read.csv("advisory_details_report_20110401_20110630.csv")

# Only keep the reports that mention JFK, LGA, EWR, or ZNY.  Drop columns not used here.
rel_lines = grep("JFK|LGA|EWR|ZNY",test$Advisory.Text)
rel_columns = c(1:9,13:14,16:54,57:80)
test = test[rel_lines,rel_columns]

# Remove data on "PROPOSED" TFMI
test = test[test$AdvisoryCategory!="PROPOSED",]

# Pick out rows where we have a GDP or GS start and end time
# NB: Valid.Bgn.Date.Time.UTC is uselses for these rows
GDP_rows = which(test$GDP.Bgn.Date.Time.UTC!="-" & test$GDP.End.Date.Time.UTC!="-")
GS_rows = which(test$GS.Bgn.Date.Time.UTC!="-" & test$GS.End.Date.Time.UTC!="-")

# Pick out rows where the "control element" is LGA, EWR, or JFK
EWR_rows = which(test$ControlElement=="EWR/ZNY")
LGA_rows = which(test$ControlElement=="LGA/ZNY")
JFK_rows = which(test$ControlElement=="JFK/ZNY")

# Look for the intersections, where there is a GDP or GS controlled by LGA, EWR, or JFK
EWR_GDP = intersect(GDP_rows,EWR_rows)
LGA_GDP = intersect(GDP_rows,LGA_rows)
JFK_GDP = intersect(GDP_rows,JFK_rows)
EWR_GS = intersect(GS_rows,EWR_rows)
LGA_GS = intersect(GS_rows,LGA_rows)
JFK_GS = intersect(GS_rows,JFK_rows)

# Calculate the numbers in each intersection
n_EWR_GDP = length(EWR_GDP)
n_LGA_GDP = length(LGA_GDP)
n_JFK_GDP = length(JFK_GDP)
n_EWR_GS = length(EWR_GS)
n_LGA_GS = length(LGA_GS)
n_JFK_GS = length(JFK_GS)

# Pick out rows where we have a REROUTE advisory for departures to EWR, LGA, or JFK
EWR_Re = intersect(which(test$AdvisoryCategory=="REROUTE"),grep("TO EWR",test$Include.Traffic))
LGA_Re = intersect(which(test$AdvisoryCategory=="REROUTE"),grep("TO LGA",test$Include.Traffic))
JFK_Re = intersect(which(test$AdvisoryCategory=="REROUTE"),grep("TO JFK",test$Include.Traffic))
# Calculate the numbers here too
n_EWR_Re = length(EWR_Re)
n_LGA_Re = length(LGA_Re)
n_JFK_Re = length(JFK_Re)

# Key question: what does it mean when AdvisoryCategory is OPERATIONS PLAN?
# NB: There aren't many advisories of AFPs and no way to pick out AFP data specifically related to conditions in New York

# Now ceate a data frame of the most relevant data for our purposes
TFMI = c(rep("GDP",n_EWR_GDP),rep("GDP",n_LGA_GDP),rep("GDP",n_JFK_GDP),rep("GS",n_EWR_GS),
	rep("GS",n_LGA_GS),rep("GS",n_JFK_GS),rep("Reroute",n_EWR_Re),rep("Reroute",n_LGA_Re),rep("Reroute",n_JFK_Re))
airport = c(rep("EWR",n_EWR_GDP),rep("LGA",n_LGA_GDP),rep("JFK",n_JFK_GDP),rep("EWR",n_EWR_GS),
	rep("LGA",n_LGA_GS),rep("JFK",n_JFK_GS),rep("EWR",n_EWR_Re),rep("LGA",n_LGA_Re),rep("JFK",n_JFK_Re))
test$Impacting.Condition = as.character(test$Impacting.Condition)
test$Reason = as.character(test$Reason)
cause = c(test$Impacting.Condition[EWR_GDP],test$Impacting.Condition[LGA_GDP],test$Impacting.Condition[JFK_GDP],
	test$Impacting.Condition[EWR_GS],test$Impacting.Condition[LGA_GS],test$Impacting.Condition[JFK_GS],
	test$Reason[EWR_Re],test$Reason[LGA_Re],test$Reason[JFK_Re])
begin_year = c(as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[EWR_GDP]),1,4)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[LGA_GDP]),1,4)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[JFK_GDP]),1,4)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[EWR_GS]),1,4)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[LGA_GS]),1,4)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[JFK_GS]),1,4)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[EWR_Re]),1,4)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[LGA_Re]),1,4)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[JFK_Re]),1,4)))
begin_month = c(as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[EWR_GDP]),6,7)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[LGA_GDP]),6,7)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[JFK_GDP]),6,7)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[EWR_GS]),6,7)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[LGA_GS]),6,7)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[JFK_GS]),6,7)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[EWR_Re]),6,7)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[LGA_Re]),6,7)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[JFK_Re]),6,7)))
begin_day = c(as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[EWR_GDP]),9,10)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[LGA_GDP]),9,10)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[JFK_GDP]),9,10)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[EWR_GS]),9,10)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[LGA_GS]),9,10)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[JFK_GS]),9,10)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[EWR_Re]),9,10)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[LGA_Re]),9,10)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[JFK_Re]),9,10)))
begin_hour = c(as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[EWR_GDP]),12,13)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[LGA_GDP]),12,13)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[JFK_GDP]),12,13)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[EWR_GS]),12,13)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[LGA_GS]),12,13)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[JFK_GS]),12,13)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[EWR_Re]),12,13)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[LGA_Re]),12,13)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[JFK_Re]),12,13)))
begin_minute = c(as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[EWR_GDP]),15,16)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[LGA_GDP]),15,16)),
	as.numeric(substr(as.character(test$GDP.Bgn.Date.Time.UTC[JFK_GDP]),15,16)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[EWR_GS]),15,16)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[LGA_GS]),15,16)),
	as.numeric(substr(as.character(test$GS.Bgn.Date.Time.UTC[JFK_GS]),15,16)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[EWR_Re]),15,16)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[LGA_Re]),15,16)),
	as.numeric(substr(as.character(test$Valid.Bgn.Date.Time.UTC[JFK_Re]),15,16)))
end_year = c(as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[EWR_GDP]),1,4)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[LGA_GDP]),1,4)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[JFK_GDP]),1,4)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[EWR_GS]),1,4)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[LGA_GS]),1,4)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[JFK_GS]),1,4)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[EWR_Re]),1,4)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[LGA_Re]),1,4)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[JFK_Re]),1,4)))
end_month = c(as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[EWR_GDP]),6,7)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[LGA_GDP]),6,7)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[JFK_GDP]),6,7)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[EWR_GS]),6,7)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[LGA_GS]),6,7)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[JFK_GS]),6,7)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[EWR_Re]),6,7)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[LGA_Re]),6,7)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[JFK_Re]),6,7)))
end_day = c(as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[EWR_GDP]),9,10)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[LGA_GDP]),9,10)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[JFK_GDP]),9,10)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[EWR_GS]),9,10)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[LGA_GS]),9,10)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[JFK_GS]),9,10)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[EWR_Re]),9,10)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[LGA_Re]),9,10)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[JFK_Re]),9,10)))
end_hour = c(as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[EWR_GDP]),12,13)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[LGA_GDP]),12,13)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[JFK_GDP]),12,13)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[EWR_GS]),12,13)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[LGA_GS]),12,13)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[JFK_GS]),12,13)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[EWR_Re]),12,13)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[LGA_Re]),12,13)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[JFK_Re]),12,13)))
end_minute = c(as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[EWR_GDP]),15,16)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[LGA_GDP]),15,16)),
	as.numeric(substr(as.character(test$GDP.End.Date.Time.UTC[JFK_GDP]),15,16)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[EWR_GS]),15,16)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[LGA_GS]),15,16)),
	as.numeric(substr(as.character(test$GS.End.Date.Time.UTC[JFK_GS]),15,16)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[EWR_Re]),15,16)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[LGA_Re]),15,16)),
	as.numeric(substr(as.character(test$Valid.End.Date.Time.UTC[JFK_Re]),15,16)))
test_df = data.frame(TFMI=TFMI,airport=airport,cause=cause,begin_year=begin_year,begin_month=begin_month,begin_day=begin_day,
	begin_hour=begin_hour,begin_minute=begin_minute,end_year=end_year,end_month=end_month,end_day=end_day,
	end_hour=end_hour,end_minute=end_minute)

# Quick QA checks
head(test_df)
head(test_df[test_df$TFMI=="GS",])
head(test_df[test_df$TFMI=="Reroute",])



