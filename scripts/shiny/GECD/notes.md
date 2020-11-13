# Pre-Meeting Notes for 22 Oct

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