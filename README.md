## Weather and Air Traffic Analysis

This repository contains scripts for collecting and analyzing aviation weather and air traffic data.

These scripts were created for a NASA-funded project to study the use of air traffic flow management initiatives.  Obviously, feel free to use them for whatever purpose you like. The project focused on the years 2010 to 2014, and so the scripts refer to data covering this time period.

The project involved applying cluster analysis to find sets of similar days, in terms of (observed and/or forecast) aviation weather as well as (observed and scheduled) air traffic.

We broke the project up into a few steps, including:

 - data collection
 
 - data parsing
 
 - feature selection
 
 - cluster analysis

### Data collection

We collected all different types of data for this project. We first focused on publicly available data, and collected the following types of data.

- **Meteorological Aerodrome Report** or [METAR](http://en.wikipedia.org/wiki/METAR) data describe observed weather at airports.

- **North American Regional Reanalysis** or [NARR](http://www.ncdc.noaa.gov/data-access/model-data/model-datasets/north-american-regional-reanalysis-narr) data describe observed weather across North America.

- **Rapid Update Cycle** or [RUC](http://www.ncdc.noaa.gov/data-access/model-data/model-datasets/rapid-update-cycle-ruc) data describe forecast weather across North America before 5/2012.

- **Rapid Refresh** or [RAP](http://www.ncdc.noaa.gov/data-access/model-data/model-datasets/rapid-refresh-rap) data replaced RUC data and is a bit more detailed.

We next collected data from the NASA Data Warehouse, including the following types of data.

### Data parsing

The weather and air traffic data come in formats that can be challenging to use and/or contain lots of data that we were not interested in.  We have included scripts in this repository for parsing the data and putting it in formats that could be, for example, easily read into and analyzed in R.

### Feature selection

Considering all the data sources described above, we ended up collecting several billion data points per day.  This would be a challenging data set to cluster on.  Of course, not all of these data points are relevant for our project.  Relevant here means we can concieve of an aviation systems analyst wanting to pick out similar days and being interested in the variable.  A variable that takes on the same value almost every day would likely not be relevant as it would not allow an analyst to pick out similar days.  A variable that has little to do with the planning or operation of air traffic flow management initiatives would not be relevant.

Feature selection is really at the heart of our project.  The overall goal is to take massive amounts of data and boil it down until each day can be reprsented solely via a single variable, cluster membershp.  After an extensive literature survey and discussion, we identified four methodologies for feature selection.  Different methdologies will most useful in different circumstances.

- **PCA:** We apply Principal Component Analysis to reduce the dimensionality of collected data while keeping as much of the variation between days as possible. This makes a lot of sense in cases where it's not clear what variables are most important but looking at statistics like sample averages or medians doesn't make sense.

- **Knowledge Based Feature Selection:** We identify features from the available literature, discussions with subject matter experts, and using our expert judgment. This is most helpful when there is a lot of available knowledge, for example when looking at an airport that has been studied extensively before or where we can talk to controllers.  For example, it's well known that stratus burn-off is a key concern for operations at SFO.

- **Regression / Synthetic Knowledge:** This approach sits between the two approaches mentioned above. We can build regression models relating many weather variables to statistics summarizing conditions or measuring system performance. We can then use variables identified as important or model outputs as features to cluster on subsequently. For example, if convective precipitation totals in the area around Harrisburg, PA are correlated with delays at EWR, then we can pick this out as a feature of interest.  Alternately, we can use estimates of the capacity of the local airspace as a feature.

- **Traffic Biasing:** We have weather observations from many locations in space and points in time. We also have data on (observed and scheduled) air traffic. We can weight weather observations by how much traffic is observed or scheduled to fly through the area at the time of the observation.

### Cluster analysis