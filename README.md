## Weather and Air Traffic Analysis

This repository contains scripts for collecting and analyzing aviation weather and air traffic data.

These scripts were created for a NASA-funded project to study the use of air traffic flow management initiatives.  The project focused on the years 2010 to 2014.

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

We also collected data from the NASA Data Warehouse.

### Data parsing

The weather and air traffic data come in formats that can be challenging to use and/or contain lots of data that we were not interested in.  We have included scripts in this repository for parsing the data and putting it in formats that could be, for example, easily read into and analyzed in R.

### Feature selection

Considering all the data sources described above, we ended up collecting several billion data points per day.  Of course, not all of these data points are relevant for our project.

Feature selection is really at the heart of our project.  The overall goal is to take massive amounts of data and boil it down until each day can be represented solely via a single variable: cluster membership.  After an extensive literature survey and discussion, we identified four methodologies for feature selection.  These methodologies can be applied separately or in tandem.  There is no single correct way to select features and different approaches will most useful in different circumstances.

- **PCA:** reduce the dimensionality of collected data while keeping as much of the variation between days as possible.

- **Knowledge Based Feature Selection:** identify features based on the available literature, discussions with subject matter experts, and using our expert judgment.

- **Regression / Synthetic Knowledge:** build regression models relating many weather and traffic variables to statistics summarizing conditions, measuring system performance, summarizing air traffic management decisions, etc. Use variables identified as important or model outputs as features to cluster on subsequently.

- **Traffic Biasing:** weight weather observations by how much traffic is observed or scheduled to fly through the area at the time of the observation.

### Cluster analysis

- **k-means:** 

- **DBSCAN:** 