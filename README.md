# Global Education Dashboard

## Context
The Global Education Dashboard runs two surveys in each country that participates: a public officials survey and a school-level survey. The Public Official (PO) survey interviews civil servants in the ministry of education at various levels (central MinEDU, regional offices, and district offices). The School survey takes averaged measures of school infrastructure, teacher quality, and student test scores at the school level (thus the unit of observation is the individual school). The goal is to tell a story of if/how bureuacratic quality at MinEDU relates to school-level outcomes. We do this by creating averages of indicies of bureaucratic quality from the public officials survey by district and region and merging these averaged scores to schools in the same distrist or region.

## Goal in code-review
The script titled 'mdataset.R' in essence creates master datasets for the schools and public officials through geoprocessing using simple features in R. I'm very new to R to my goal is simple: does the code to generate school_dist object make sense?

The workflow is a bit odd here. Because geography (i.e., knowing exacting where each observation is located in relation to others observations in terms of administrative regions), Kris suggested that I begin by creating a "master" dataset that contains only the raw ids, project ids, and geographic data so that I can refer/merge back to this at various points in the repo. It's not terribly complicated but it has to be perfect.

 Also, since the data at this stage is raw, I've created a sample dataset in csv form that mimics key variables and features of the raw datasets.



 ## Running the code,
-While the project itself has many scripts, for this review we only need to run one script called "mdataset.R"
-I've shared/will share a folder on my WBOD that contains the data, which includes a massive geojson file which is only available/should be used on the WB intranet
-the code should be runable as-is, since it runs entirely off the shared folder once you clone the repo, but if you decide to copy locally just change line 40.
-The code takes about 10 minutes to run as it has R has to work through the geojson file.
