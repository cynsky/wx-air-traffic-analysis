## Weather and Air Traffic Analysis

This repository contains scripts for collecting and analyzing aviation weather and air traffic data.

These scripts were created for a NASA-funded project to study the use of air traffic flow management initiatives.  The project focused on the years 2010 to 2015.

The project involved applying cluster analysis to find sets of similar days, in terms of (observed and/or forecast) aviation weather as well as (observed and scheduled) air traffic. A classification analysis was first undertaken to obtain measures of variable importance which were subsequently used to define a distance metric for the cluster analysis.

We broke the project up into a few steps, including:

 - data collection
 
 - data parsing
 
 - feature selection
 
 - classification analysis
 
 - cluster analysis

### Data collection

We collected all different types of data for this project. We first focused on publicly available data, and collected the following types of data.

- **Meteorological Aerodrome Report** or [METAR](http://en.wikipedia.org/wiki/METAR) data describe observed weather at airports.

- **North American Regional Reanalysis** or [NARR](http://www.ncdc.noaa.gov/data-access/model-data/model-datasets/north-american-regional-reanalysis-narr) data describe observed weather across North America.

- **Rapid Update Cycle** or [RUC](http://www.ncdc.noaa.gov/data-access/model-data/model-datasets/rapid-update-cycle-ruc) data describe forecast weather across North America before 5/2012.

- **Rapid Refresh** or [RAP](http://www.ncdc.noaa.gov/data-access/model-data/model-datasets/rapid-refresh-rap) data replaced RUC data and is a bit more detailed.  **High Resolution Rapid Refresh** data later replaced RAP data.

- **Aviation System Performance Metrics** or [ASPM](http://aspmhelp.faa.gov/index.php/ASPM_System_Overview) data describe scheduled and observed traffic at key airports.

We also collected data from the NASA Data Warehouse.

- **Terminal Area/Aerodrome Forecast** or [TAF](https://www.aviationweather.gov/static/help/taf-decode.php) data describe forecast weather at airports.

- **Traffic Flow Management advisory** data describe air traffic flow management initiatives implemented in the recent past.

- **Aircraft Situation Display to Industry** or [ASDI](https://en.wikipedia.org/wiki/Aircraft_Situation_Display_to_Industry) data describe aircraft fligt plans and flight plan modifications, but also include observations of aircraft positions.

### Data parsing

The weather and air traffic data come in formats that can be challenging to use and/or contain lots of data that we were not interested in.  We have included scripts in this repository for parsing the data and putting it in formats that could be, for example, easily read into and analyzed in R.

### Feature selection

Considering all the data sources described above, we ended up collecting several billion data points per day.  Of course, not all of these data points are relevant for our project.

Feature selection is really at the heart of our project.  The overall goal is to take massive amounts of data and boil it down until each day can be represented solely via a single variable: cluster membership.  After an extensive literature survey and discussion, we identified three methodologies for feature selection.  These methodologies can be applied separately or in tandem.  Different approaches will most useful in different circumstances. We have arranged the approaches below in order of least to most domain knowledge / data required to implement. We ended up favoring the third approach, **Knowledge-Based Feature Selection** based on our access to much data and the presence of a healthy body of relevant literature.

- **PCA:** reduce the dimensionality of collected data while keeping as much of the variation between days as possible.

- **Traffic Biasing:** weight weather observations by how much traffic is observed or scheduled to fly through the area at the time of the observation.

- **Knowledge-Based Feature Selection:** identify features based on the available literature, discussions with subject matter experts, and using our expert judgment.


### Classification analysis

We have identified several methodologies for defining different features describing conditions on different days.  A natural question to ask is how important / relevant are thsee features?  In order to quantify variable importance, we first use feaure data to model the presence or absence of different forms of air traffic flow management initiative.  We considered three model types, listed below, before settling on a **Weighted Random Forest model**.  Measures of variable importance can be easily extracted from developed models.

- **Decision Tree model**: split observed data sequentially based on the feature data until left with relatively homogenous sub-populations in terms of the presence / absence of traffic flow management actions.

- **Random Forest model**: develop tens of thousands of deep decision trees, each of which is based on a sample of the observed data. Reduced overfitting and increased accuracy as compared to decision tree models, but results are more difficult to interpret / explain.

- **Weighted Random Forest model**: similar to Random Forest model but particularly good at dealing with **imbalanced data**, e.g., when there are many more observations of there not being a traffic flow management initiative as opposed to there being an initiative.  Assign weights to classes (presence vs. absence of traffic flow management initiatives) and use weights both when deciding how to split data within a decision tree and when aggregating results across trees.

### Cluster analysis

The final step in our project was to perform cluster analysis and produce a listing of similar days.  We considered three forms of cluster analysis described below, before settling on **Partitioning Around Medoids** clustering.

- **k-means**: most popular form of cluster analysis.  Split observed data into ***k*** clusters minimizing the Within-Cluster Sum of Squares.

- **DBSCAN**: identify clusters of data points where all the data points within a cluster have many common 'neighboring' data points. Allow certain data points to be labeled 'outliers' and not assigned to a cluster.

- **PAM**: a very general form of cluster analysis.  Pick out ***k*** cluster centers or medoids. Assign all points to the closest medoid to define clusters, using your favorite distance metric. Evaluate the cluster assignment and refine the selection of medoids.  Repeat until satisfied with the results / until an objective function has been optimized.