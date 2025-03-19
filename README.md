# vocc_targets
This repository uses targets pipeline to calculate velocity of microclimate change on both local PC (Windows system) and HPC (Linux)

Before running this function in the pipeline. Data need to be pre-processed. 
Data preprocess scripts were not included here. Steps to follow:
- First, the current temperature were split into tiles.
- Second, based on the current temperature tiles (present_files), crop future temperature tiles with searching distance and temperature threshold value.

# About targets R package：
- It is recommanded to first follow this manual: https://books.ropensci.org/targets/ to get start with the targets packages. 
- File structure of target initiate by targets itself, you don't need to create it manually.

# _targets.R
- This scripts sets up the pipeline.
- In the options(), HPC job scripts and tempelate for submitting job on each worker through were added.
- In the tar_option_set(), you can set up the resources you need for each worker to run the job.
- tar_source() load the R packages (packages.R) and the function scripts (calc_forward_vel.R) to the pipeline.
- tar_plan() build up the workflow for running the pipeline.

# Function scripts: calc_forward_vel.R
For this script, we calculate forward velocity of microclimate change. 
- Based on the tile name created from _targets.R, every worker will start with one tile that has not been processed before. When this tile is done, move to next tile.
- tile_name allow us to know the progress of the calculation.


