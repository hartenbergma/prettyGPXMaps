calculate_zoom <- function(bbox) {
  # Calculate the difference in longitude and latitude
  lon_diff <- bbox["xmax"] - bbox["xmin"]
  lat_diff <- bbox["ymax"] - bbox["ymin"]
  
  # Convert to degrees
  max_diff <- max(lon_diff, lat_diff)
  
  # Rough zoom level calculation
  # You might need to adjust this based on your specific needs
  zoom <- floor(log2(360 / max_diff))
  
  # Ensure zoom is within reasonable bounds
  return(max(min(zoom, 18), 3))
}

addStartEndMarkers <- function(map, gpx_track, color) {
  track_coords <- st_coordinates(gpx_track$geometry)
  start_point <- head(track_coords, 1)[1:2]
  end_point <- tail(track_coords, 1)[1:2]
  map <- map |>
    addCircleMarkers(
      lng = start_point[1],
      lat = start_point[2],
      radius = 6,
      weight = 4,
      color = track_color,
      opacity = 1,
      fillColor = track_color,
      fillOpacity = 1
    ) |>
    addCircleMarkers(
      lng = end_point[1],
      lat = end_point[2],
      radius = 6,
      weight = 4,
      color = track_color,
      opacity = 1,
      fillColor = "white",
      fillOpacity = 1
    )
  return(map)
}

setViewToGpx <- function(map, gpx_track) {
  bbox <- st_bbox(gpx_track)
  zoom_level <- calculate_zoom(bbox) + 2
  map <- setView(
    map,
    lng = (bbox[[1]] + bbox[[3]]) / 2,
    lat = (bbox[[2]] + bbox[[4]]) / 2,
    zoom = zoom_level  # zoom adjusts tile level
  )
  return(map)
}

# For the stamen style maps the labels can be loaded seprately
# to be overlayed on the gpx track
addStadiaMapLabels <- function(map, map_style, apikey, pane = NA) {
  if (grepl("stamen", map_style)) {
    if (grepl("stamen_toner", map_style)) {
      label_style <- "stamen_toner_labels"
    } else if (grepl("stamen_terrain", map_style)) {
      label_style <- "stamen_terrain_labels"
    }
    map <- addStadiaMap(map, label_style, apikey, pane)
  }
  return(map)
}

# https://docs.stadiamaps.com/maps-for-web/
addStadiaMap <- function(map_widget, map_style, apikey, pane = NA) {
  if (is.na(pane)) {
    options <- tileOptions(variant = map_style, apikey = stadiamaps_api_key)
  } else {
    options <- tileOptions(variant = map_style, apikey = stadiamaps_api_key, pane = pane)
  }
  map <- addTiles(
    map_widget,
    urlTemplate = "https://tiles.stadiamaps.com/tiles/{variant}/{z}/{x}/{y}@2x.png?api_key={apikey}",
    attribution = FALSE,
    options = options
  )
}