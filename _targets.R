library(targets)
library(tarchetypes)
library(clustermq)

## Running on HPC
# Settings for clustermq
options(
  clustermq.scheduler = "slurm",
  clustermq.template = "./cmq.tmpl" # if using your own template
)

# # Running locally on Windows
# options(clustermq.scheduler = "multiprocess")

## Settings for clustermq template when running clustermq on HPC
tar_option_set(
  resources = tar_resources(
    clustermq = tar_resources_clustermq(template = list(
      job_name = "auto-velocity",
      per_cpu_mem = "20000mb",
      n_tasks = 1,
      per_task_cpus = 36,
      walltime = "20:00:00"
    ))
  )
)

# Loads all R scripts in ./R/ directory.
# Here, all packages are loaded from the ./R/packages.R file
# The calc_forward_vel function is loaded from the ./R/calc_forward_vel.R file
tar_source()

tar_plan(
  tolerance = 0.25,
  max_distance = 100000,
  present_files = list.files("/lustre1/scratch/348/vsc34871/input/VoCC/prePTES/",
   full.names = T),
  future_files = list.files("/lustre1/scratch/348/vsc34871/input/VoCC/futPTES/",
   full.names = T),
  tar_target(tile_names,
    paste0(paste0(str_split(
      gsub("bio1_pre_SA_", "", tail(str_split(present_files, "/")[[1]], 1)),
      "_"
    )[[1]][1:2], collapse = "_"), "_"),
    pattern = map(present_files),
  ),
  tar_target(forward_vels,
    calc_forward_vel(
      tile_names,
      tolerance,
      max_distance,
      present_files,
      future_files
    ),
    pattern = map(tile_names),
    format = "file"
  )
)
