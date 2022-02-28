import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get/get.dart';
import 'package:live_location/controllers/LocationController.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class UserTracker extends StatefulWidget {
  const UserTracker({Key? key}) : super(key: key);

  @override
  State<UserTracker> createState() => _UserTrackerState();
}

class _UserTrackerState extends State<UserTracker> {
  LocationController locationController = Get.put(LocationController());

  MapController mapController = MapController();

  Marker? userMarker;

  var locationStatus;

  StreamController<LocationMarkerPosition>? positionStreamController;

  @override
  void initState() {
    super.initState();

    locationController.location.enableBackgroundMode(enable: true);
    locationController.location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000, distanceFilter: 0);
    locationController.getLocation();
    positionStreamController?.add(
      LocationMarkerPosition(
        latitude: locationController.lat.value,
        longitude: locationController.lng.value,
        accuracy: 0,
      ),
    );

    locationStatus = locationController.location.onLocationChanged.listen((LocationData currentLocation) async {
      // print(locationController.location.isBackgroundModeEnabled());
      locationController.getLocation();
      positionStreamController?.add(
        LocationMarkerPosition(
          latitude: locationController.lat.value,
          longitude: locationController.lng.value,
          accuracy: 0,
        ),
      );
      print('location changed');
      print(currentLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
      ),
      body: Obx(() {
        print("location Changed");
        return Container(
          child: FlutterMap(
            mapController: locationController.mapController,
            options: MapOptions(
              onPositionChanged: (mapController, guesture) {
                print('------------------------------------');
                print(mapController.zoom);
                locationController.zoom(mapController.zoom);
              },
              center: LatLng(locationController.lat.value, locationController.lng.value),
              zoom: 2.0,
              maxZoom: 20,
              rotation: 0,
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
            children: [
              TileLayerWidget(
                options: TileLayerOptions(
                  urlTemplate: "http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
                  subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                  maxZoom: 20,
                  attributionBuilder: (_) {
                    return const Text("© OpenStreetMap contributors");
                  },
                ),
              ),
              LocationMarkerLayerWidget(
                options: LocationMarkerLayerOptions(
                  marker: const DefaultLocationMarker(
                    color: Colors.green,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: const Size(40, 40),
                  accuracyCircleColor: Colors.green.withOpacity(0.1),
                  headingSectorColor: Colors.green.withOpacity(0.8),
                  headingSectorRadius: 120,
                  positionStream: positionStreamController?.stream,
                  // positionStream: const LocationMarkerDataStreamFactory().geolocatorPositionStream(
                  //   stream: locationStatus!,
                  // ),
                  // markerAnimationDuration: Duration.zero, // disable animation
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
