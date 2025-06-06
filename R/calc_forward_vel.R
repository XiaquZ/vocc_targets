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
  analogue_distances <- lapply(pre_values, function(pre_value) {
    ## Filter only values in pre_round that are equal to pre_value
    pre_filt <- terra::mask(pre_round,
      pre_round == pre_value,
      maskvalues = F
    )

    ## Filter future analogues which are within tolerance of pre_value
    fut_filt <- terra::mask(fut_round,
      fut_round >= pre_value - tolerance & fut_round <= pre_value + tolerance,
      maskvalues = F
    )
    # Calculate distance to closest analogue
    fut_distance <- distance(fut_filt)
    names(fut_distance) <- "distance"
    analogue_result <- mask(crop(fut_distance, pre_filt), pre_filt)
    
  })

    ds <- rast(analogue_distances)
    distance <- app(ds, fun = sum, na.rm = T) # Sum all layers of ds rast to make complete map
    names(distance) <- "distance"
  # Save results as rasters.
    forward_vel_file <- paste0(
      "/lustre1/scratch/348/vsc34871/output/FVoMC/France/fvocc_100kmBufferRing_", tile_name, ".tif"
      )
    forward_vel <- mask(distance, distance <= max_distance, maskvalues = F) / 75 # Calculate velocity 
    forward_vel <- round(forward_vel,1)
    print(forward_vel)
    writeRaster(forward_vel, forward_vel_file, overwrite = T) # write

    return(forward_vel_file) # Return filename

}
