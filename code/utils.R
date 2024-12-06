# Load interactive raster map from Stamen Toner (See https://docs.stadiamaps.com/maps-for-web/)
addStadiaMap <- function(map_widget, map_style, apikey, pane = NULL) {
  map <- addTiles(
    map_widget,
    urlTemplate = "https://tiles.stadiamaps.com/tiles/{variant}/{z}/{x}/{y}@2x.png?api_key={apikey}",
    attribution = FALSE,
    options = tileOptions(variant = map_style, apikey = stadiamaps_api_key, pane = pane)
  )
}

# For the stamen style maps the labels can be loaded separately to be overlaid on the plotted track
# (See section "Raster Layer Groups": https://docs.stadiamaps.com/map-styles/stamen-toner/)
addStadiaMapLabels <- function(map, map_style, apikey, pane = NULL) {
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

addGpxTracks <- function(map, gpx_track, colors, weight = 4, start_end_markers = FALSE, pane = NULL) {
  for (i in seq_len(nrow(gpx_track))) {
    color <- colors[[(i - 1) %% length(colors) + 1]]
    track_section <- gpx_track[i, ]
    map <- addPolylines(map, data = track_section, color = color, weight = weight, opacity = 1, smoothFactor = 1, options = tileOptions(pane = pane))
    
    if(start_end_markers) {
      if (i == 1) map <- addStartMarker(map, track_section, color, pane = pane)
      if (i == nrow(gpx_track)) map <- addEndMarker(map, track_section, color, pane = pane)
    }
  }
  return(map)
}

addStartMarker <- function(map, gpx_track, color, pane = NULL) {
  track_coords <- st_coordinates(gpx_track$geometry)
  start_point <- head(track_coords, 1)[1:2]
  map <- addCircleMarkers(
      map,
      lng = start_point[[1]],
      lat = start_point[[2]],
      radius = 4,
      weight = 4,
      color = color,
      opacity = 1,
      fillColor = color,
      fillOpacity = 1,
      options = markerOptions(pane = pane)
    )
  return(map)
}

addEndMarker <- function(map, gpx_track, color, pane = NULL) {
  track_coords <- st_coordinates(gpx_track$geometry)
  end_point <- tail(track_coords, 1)[1:2]
  map <- addCircleMarkers(
      map,
      lng = end_point[[1]],
      lat = end_point[[2]],
      radius = 5,
      weight = 4,
      color = color,
      opacity = 1,
      fillColor = "white",
      fillOpacity = 1,
      options = markerOptions(pane = pane)
    )
  return(map)
}

# estimate an appropriate zoom level for the map based on the boundig box of the displayed track
calculate_zoom <- function(bbox) {
  # Calculate the difference in longitude and latitude
  lon_diff <- bbox["xmax"] - bbox["xmin"]
  lat_diff <- bbox["ymax"] - bbox["ymin"]
  
  # Convert to degrees
  max_diff <- max(lon_diff, lat_diff)
  
  # Rough zoom level calculation
  zoom <- floor(log2(360 / max_diff)) +2
  
  # Ensure zoom is within reasonable bounds
  return(max(min(zoom, 18), 3))
}

# set map center and zoom level to appropriate values for the displayed track
setViewToGpx <- function(map, gpx_track, zoom_offset = 0) {
  bbox <- st_bbox(gpx_track)
  zoom_level <- calculate_zoom(bbox) + zoom_offset
  map <- setView(
    map,
    lng = (bbox[[1]] + bbox[[3]]) / 2,
    lat = (bbox[[2]] + bbox[[4]]) / 2,
    zoom = zoom_level  # zoom adjusts tile level
  )
  return(map)
}