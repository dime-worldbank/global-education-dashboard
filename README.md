# Global Education Dashboard

## Context
The Global Education Dashboard runs two surveys in each country that participates: a public officials survey and a school-level survey. The Public Official (PO) survey interviews civil servants in the ministry of education at various levels (central MinEDU, regional offices, and district offices). The School survey takes averaged measures of school infrastructure, teacher quality, and student test scores at the school level (thus the unit of observation is the school). The goal is to tell a story of if/how bureuacratic quality at MinEDU relates to school-level outcomes. We do this by creating averages of indicies of bureaucratic quality from the public officials survey by district and region and merging these averaged scores to schools in the same distrist or region. The main goal of this sctipt is to produce two master datasets: for the schools and public officials through geoprocessing using the simple features package in R. <br>

The workflow is a bit odd here. Because geography is important (i.e., knowing exacting where each observation is located in relation to others observations in terms of administrative regions), Kris suggested that I begin by creating a "master" dataset that contains only the raw ids, project ids, and geographic data so that I can refer/merge back to this at various points in the repo. The raw data contain gps coordinates, which are used by the simple features package map points in polygons and extract information from the polygons. I use the World Bank subnational boundaries geojson file to obtain the polygones. It's not terribly complicated but all this has to be perfect. <br>

 Also, since the data at this stage is raw, I've created a sample dataset in csv form that mimics key variables and features of the raw datasets. You'll note that there are many points with missing data, and this is somewhat intentional and realistic of my actual data. <br>

## Goal in code-review
Since I new to working in R this review for me is just as much about coding efficiency as it is about getting the 'product' I want. Here're my goals for the review in list form: <br>
1. Determine if my geoprocessing results are credible and if not, improve them. Specifically, I need to be 100% sure that: <br>
	- each observation is mapped to the *correct* administrative unit (point-in-poly problem) for both the schools and public officials datasets, and <br>
	- for the school dataset only, ensure that each school observation is matched to the correct district and regional offices and that the distances from each school to its associated district and regional office are calculated correctly.
2. Improve my R coding in general.



 ## Running the code
-While the project itself has many scripts, for this review we only need to run one script called "mdataset.R"
-I've shared/will share a folder on my WBOD that contains the data, which includes a massive geojson file which is only available/should be used on the WB intranet
-the code should be runable as-is, since it runs entirely off the shared folder once you clone the repo, but if you decide to copy locally just change line 46.
-The code takes about 10 minutes to run as R has to work through the geojson file.
