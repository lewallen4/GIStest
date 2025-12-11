#!/usr/bin/env bash
set -euo pipefail

OUTPUT="index.html"
CITY_DATA=$(cat data/cities.json | sed 's/"/\\"/g')

cat > "$OUTPUT" << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Washington State Map</title>
  <style>
    html, body, #viewDiv {
      margin: 0;
      padding: 0;
      height: 100%;
      width: 100%;
      font-family: sans-serif;
    }

    #controls {
      position: absolute;
      top: 10px;
      left: 10px;
      background: white;
      padding: 10px;
      border-radius: 6px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.2);
      z-index: 99;
    }
  </style>
  <script src="https://js.arcgis.com/4.29/"></script>
</head>

<body>
<div id="controls">
  <label><input type="checkbox" id="citiesToggle" checked> Show Cities</label><br>
  <label><input type="checkbox" id="countiesToggle" checked> Show Counties</label>
</div>
<div id="viewDiv"></div>

<script>
// ================================
// Load city data
// ================================
const cityData = JSON.parse("${CITY_DATA}");

// ================================
// Setup ArcGIS map
// ================================
require([
  "esri/Map",
  "esri/views/MapView",
  "esri/layers/FeatureLayer",
  "esri/layers/GraphicsLayer",
  "esri/Graphic"
], function(Map, MapView, FeatureLayer, GraphicsLayer, Graphic) {

  const map = new Map({
    basemap: "topo-vector"
  });

  const view = new MapView({
    container: "viewDiv",
    map: map,
    center: [-120.7401, 47.7511],
    zoom: 7
  });

  // ============================
  // Washington Counties Layer
  // ============================
  const counties = new FeatureLayer({
    url: "https://services.arcgis.com/jsIt88o09Q0r1j8h/ArcGIS/rest/services/Washington_State_Counties/FeatureServer/0",
    opacity: 0.5
  });
  map.add(counties);

  // ============================
  // Cities Layer
  // ============================
  const cityLayer = new GraphicsLayer();
  map.add(cityLayer);

  cityData.forEach(city => {
    const pt = {
      type: "point",
      latitude: city.lat,
      longitude: city.lon
    };

    const marker = new Graphic({
      geometry: pt,
      symbol: { type: "simple-marker", size: 10, color: "red" },
      attributes: city,
      popupTemplate: {
        title: "{name}",
        content: "<b>Population:</b> {population}"
      }
    });

    const label = new Graphic({
      geometry: pt,
      symbol: {
        type: "text",
        text: city.name,
        yoffset: 12,
        color: "black",
        font: { size: 11, weight: "bold" }
      }
    });

    cityLayer.add(marker);
    cityLayer.add(label);
  });

  // ============================
  // Toggle controls
  // ============================
  document.getElementById("citiesToggle").addEventListener("change", e => {
    cityLayer.visible = e.target.checked;
  });

  document.getElementById("countiesToggle").addEventListener("change", e => {
    counties.visible = e.target.checked;
  });

});
</script>

</body>
</html>
EOF

echo "Generated $OUTPUT"