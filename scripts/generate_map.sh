#!/usr/bin/env bash
set -euo pipefail

OUTPUT="index.html"
CITY_DATA=$(cat data/cities.json | sed 's/"/\\"/g')

cat > "$OUTPUT" << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Washington State ArcGIS Map</title>

  <!-- ArcGIS CSS (required for proper styling) -->
  <link rel="stylesheet" href="https://js.arcgis.com/4.29/esri/themes/light/main.css">

  <style>
    html, body {
      height: 100%;
      margin: 0;
      font-family: Arial, sans-serif;
    }

    /* Container for the "window" holding the map */
    #mapWindow {
      position: absolute;
      top: 50px;
      left: 50px;
      right: 50px;
      bottom: 50px;
      border: 2px solid #555;
      border-radius: 8px;
      background: #fff;
      box-shadow: 0 4px 12px rgba(0,0,0,0.2);
      overflow: hidden;
    }

    #viewDiv {
      width: 100%;
      height: 100%;
    }

    #controls {
      position: absolute;
      top: 10px;
      left: 10px;
      background: rgba(255,255,255,0.9);
      padding: 8px;
      border-radius: 5px;
      z-index: 99;
      font-size: 14px;
    }
  </style>

  <script src="https://js.arcgis.com/4.29/"></script>
</head>

<body>

<div id="controls">
  <label><input type="checkbox" id="citiesToggle" checked> Show Cities</label><br>
  <label><input type="checkbox" id="countiesToggle" checked> Show Counties</label>
</div>

<div id="mapWindow">
  <div id="viewDiv"></div>
</div>

<script>
const cityData = JSON.parse("${CITY_DATA}");

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
    container: "viewDiv",   // Must match the ID of the div in the page
    map: map,
    center: [-120.7401, 47.7511],
    zoom: 7
  });

  // ============================
  // Counties Layer (public REST)
  // ============================
  const counties = new FeatureLayer({
    url: "https://services.arcgis.com/jsIt88o09Q0r1j8h/ArcGIS/rest/services/Washington_State_Counties/FeatureServer/0",
    opacity: 0.4
  });
  map.add(counties);

  // ============================
  // Cities
  // ============================
  const cityLayer = new GraphicsLayer();
  map.add(cityLayer);

  cityData.forEach(city => {
    const pt = {
      type: "point",
      longitude: city.lon,
      latitude: city.lat
    };

    const marker = new Graphic({
      geometry: pt,
      symbol: {
        type: "simple-marker",
        size: 10,
        color: "blue"
      },
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
        color: "#000",
        font: { size: 12, weight: "bold" }
      }
    });

    cityLayer.add(marker);
    cityLayer.add(label);
  });

  // ============================
  // Toggle layer visibility
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