# Notes for 30 Nov

## Changes from last time

### First and second-shift schools
I've since gone back to the school roster data and added indicator variables for public/private schools and for first/second-shift schools. Two quick points about these: <br>
- I assumed that schools with semi-public funding also were semi-controlled or affected by the public administration, so only schools that were classified as "private" got categorized as private (or non-public). <br>
- Including these controls reduces the number of schools by a count of 3, since in the school roster data there are a few schools that cannot be matched to the survey data by either school code, name, or any other manually-interpreted characterestics. <br><br>

### Re-aggregating Rwanda's bureaucracy scores by region instead of district
I've also averaged the bureaucracy scores in Rwanda by Region and not district since we decided that the region level was the de-facto decision-making level. This resulted in two major changes: <br>
- the schools dataset grew to a 391 total school observations and 200 of those 391 are from Rwanda. This grew significantly because the overlap of schools and public officials in Rwanda expanded since we are now aggregating bureaucrat scores at the region level. <br>
- Even though bureaucracy indicator are computed at the region level in Rwanda, all other local controls -- such as size of school district, gdp, literacy rate, etc -- are still calculated at the district level. I thought it made the most sense to keep consistency with other countries for these localized controls. 
  
  
# Notes for 22 Oct

### Are Brian's scatterplots consistent with Tom's?
- Yes, generally they show the same patterns
- However, Brian's data is merged at the region level, whereas Tom's is merged at the district level.
  - These superficial similarities between scatters of district- vs region-level merging themselves may be intresting.
  - Recall that the BI indicators are averaged at the region/district level (x-axis in the scatters), so averaging at different levels of disaggregation could, in theory, produce different points on the xaxis.
  - It seems that this is happening for a few indicators: upward skweing in my/district-level data compared to his/region-level in BI indicators

### Stylized facts in the bivariate correlations
  - Scatterplots are most convincing for Peru,
  - A few piecemeal correlations that are positive:
    - BI-infrastructure,
    - NLG-infrastructure, content knowledge, inst. leadership,
    - IDM-motivation,
  - And some that are mixed:
    -IDM-1st student knowledge

###	Do these relationships persist after introducing covariates?
- Yes, these do persist after adding all covariates:
  - BI-infrastructure (combined)
  - NLG-instructional leadership

- But some patterns hold that are in the unexpected direction
  - NLG-Principal Knowledge Score

- New patterns:
  - IDM and ECD Student Scores?

- Piecemeal patterns -- only for specific countries:
  - JOR: QB and NLG to Principal Management
  - RWA: NLG to Content Knowledge, QB to infrastructure, IDM to infrastructure




### If these patterns persist, what might explain the BL variables working better as predictors in Peru—is this a actual relationship, or is it an artifact of something about data collection in these countries?
- It seems this relationship is real for the data in the model, but there's such a large chance that the data is not representative that it may inadvertantly be an artifact of data collection (ie, merging on district in Peru results in only 26 schools there)
- More specifically, this could be a function of the number of clusters. We see that Peru only has 10 clusters.
- We also see that Peru is not the only country where the model predicts well for some groups of indicators. In Jordan, variables that measure school operations/management are generally predicted well by National Learning Goals and Quality of Bureaucracy.


credit to RColorBrewer for some of the color paletting. 