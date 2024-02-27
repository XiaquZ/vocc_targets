calc_forward_vel <- function(tile_name,
                             tolerance,
                             max_distance,
                             present_files, # must contain
                             future_files) {
  print(paste("Now calculating:", tile_name))

  ## Load data
  pre <- rast(grep(tile_name, present_files, value = T))
  ## names(pre) <- "pre"
  fut <- rast(grep(tile_name, future_files, value = T))
  ## names(fut) <- "fut"

  ## Round pre and fut to one decimal
  pre_round <- round(pre, 1)
  pre_values <- freq(pre_round, digits = 1)$value
  fut_round <- round(fut, 1)

  ## Set tolerace for matching analogues

  ## apply over all of the pre_values in lis
  analogue_results <- lapply(pre_values, function(pre_value) {
    ## Filter only values in pre_round that are equal to pre_value
    pre_filt <- mask(pre_round,
      pre_round == pre_value,
      maskvalues = F
    )

    ## Filter future analogues which are within tolerance of pre_value
    fut_filt <- mask(fut_round,
      fut_round >= pre_value - tolerance & fut_round <= pre_value + tolerance,
      maskvalues = F
    )
    # Calculate distance to closest analogue
    fut_distance <- distance(fut_filt)
    # Calculate the aspects to the closest analogue
    fut_aspect <- terrain(fut_distance, v="aspect", neighbors = 8, unit = "degrees")
    ## Crop to tile to exclude buffer around tile
    analogue_result <- mask(crop(c(fut_distance, fut_aspect), pre_filt), pre_filt)
    ## all_analogue_distance <- sum(all_analogue_distance, analogue_distance, na.rm = T)
  })

  
  ds <- analogue_results[[1]] # Sum all layers of ds rast to make complete map
  asp <- analogue_results[[2]]

  distance <- app(ds, fun = sum, na.rm = T)
  aspectTotal <- app(asp, fun = sum, na.rm = T)
  names(distance) <- "distance"
  names(aspectTotal) <- "aspect"

  forward_vel_file <- paste0("/lustre1/scratch/348/vsc34871/output/VoCC/EastEU/fvocc_", tile_name, ".tif")
  forward_vel <- mask(distance, distance <= max_distance, maskvalues = F) / 75 # Calculate velocity 
  writeRaster(forward_vel, forward_vel_file, overwrite = T) # write

  asp_fvocc_file <- paste0("/lustre1/scratch/348/vsc34871/output/VoCC/EastEU/aspect/fvocc_asp", tile_name, ".tif")
  writeRaster(aspectTotal, asp_fvocc_file, overwrite = TRUE)

  return(forward_vel_file) # Return filename
  return(asp_fvocc_file)
  gc()
}
