#!/usr/bin/env bash
set -euo pipefail

OUTPUT="index.html"

cat > "$OUTPUT" << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Washington State Map</title>
  <style>
    html, body, #viewDiv {
      padding: 0;
      margin: 0;
      height: 100%;
      width: 100%;
    }
  </style>
  <script src="https://js.arcgis.com/4.29/"></script>
</head>
<body>
<div id="viewDiv"></div>

<script>
require([
  "esri/Map",
  "esri/views/MapView",
  "esri/layers/GraphicsLayer",
  "esri/Graphic"
], function(Map, MapView, GraphicsLayer, Graphic) {

  const map = new Map({ basemap: "streets-navigation-vector" });

  const view = new MapView({
    container: "viewDiv",
    map: map,
    center: [-120.7401, 47.7511], // Washington center
    zoom: 7
  });

  const cities = [
    { name: "Seattle",       coords: [-122.3321, 47.6062] },
    { name: "Spokane",       coords: [-117.4260, 47.6588] },
    { name: "Tacoma",        coords: [-122.4443, 47.2529] },
    { name: "Vancouver",     coords: [-122.6615, 45.6300] },
    { name: "Bellevue",      coords: [-122.2007, 47.6101] },
    { name: "Everett",       coords: [-122.2015, 47.9780] },
    { name: "Olympia",       coords: [-122.9007, 47.0379] },
    { name: "Bellingham",    coords: [-122.4787, 48.7491] },
    { name: "Yakima",        coords: [-120.5059, 46.6021] },
    { name: "Kennewick",     coords: [-119.1372, 46.2112] },
    { name: "Richland",      coords: [-119.2845, 46.2857] },
    { name: "Pasco",         coords: [-119.1006, 46.2396] },
    { name: "Wenatchee",     coords: [-120.3103, 47.4235] }
  ];

  const layer = new GraphicsLayer();
  map.add(layer);

  cities.forEach(city => {
    const point = {
      type: "point",
      longitude: city.coords[0],
      latitude: city.coords[1]
    };

    const marker = new Graphic({
      geometry: point,
      symbol: {
        type: "simple-marker",
        size: 10
      },
      attributes: city,
      popupTemplate: {
        title: "{name}"
      }
    });

    const text = new Graphic({
      geometry: point,
      symbol: {
        type: "text",
        text: city.name,
        yoffset: 12,
        font: { size: 10, weight: "bold" }
      }
    });

    layer.add(marker);
    layer.add(text);
  });

});
</script>

</body>
</html>
EOF

echo "Generated $OUTPUT"