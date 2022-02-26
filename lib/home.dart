import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:live_location/controllers/LocationController.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Location location = new Location();

  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  LocationData? coordinates;
  MapController mapController = MapController();

  LocationController locationController = Get.put(LocationController());

  getLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  bool isMapRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          child: const Text('Get Location'),
          onPressed: () async {
            // print(mapController);
            _locationData = await location.getLocation().then((value) {
              locationController.getLocation();
              setState(() {
                mapController.move(LatLng(locationController.lat.value, locationController.lng.value), 5);
                coordinates = value;
                // mapController.centerZoomFitBounds(LatLngBounds());
              });
            });
          },
        ),
      ),
      body: Obx(() {
        locationController.location.onLocationChanged.listen((LocationData currentLocation) async {
          _locationData = await locationController.location.getLocation().then((value) {
            // print('Set Location');
            locationController.lat = Rx(double.parse('${value.latitude}'));
            locationController.lng = Rx(double.parse('${value.longitude}'));
            setState(() {
              mapController.move(LatLng(locationController.lat.value, locationController.lng.value), 5);
              coordinates = currentLocation;
              // mapController.centerZoomFitBounds(LatLngBounds());
            });
          });
          locationController.getLocation();

          print('Location Changed');
        });

        print(locationController.lat);
        print(locationController.lng);

        // mapController?.move(LatLng(locationController.lat.value, locationController.lng.value), 15);

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: LatLng(locationController.lat.value, locationController.lng.value),
            zoom: 2.0,
            maxZoom: 20,
            rotation: 0,
            interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
          layers: [
            TileLayerOptions(
              // retinaMode: true,
              // fastReplace: true,
              // urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              // subdomains: ['a', 'b', 'c'],
              urlTemplate: "http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
              subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
              maxZoom: 15,
              attributionBuilder: (_) {
                return const Text("© OpenStreetMap contributors");
              },
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                  width: 50.0,
                  height: 50.0,
                  point: LatLng(locationController.lat.value, locationController.lng.value),
                  builder: (ctx) => Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.5),
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: const Center(
                        child: Text(
                      "DS",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    )),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
      // body:
    );
  }
}

// Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: (coordinates != null)
//                     ? [
//                         Text('accuracy: ${coordinates!.accuracy}'),
//                         Text('altitude: ${coordinates!.altitude}'),
//                         Text('elapsedRealtimeNanos: ${coordinates!.elapsedRealtimeNanos}'),
//                         Text('elapsedRealtimeUncertaintyNanos: ${coordinates!.elapsedRealtimeUncertaintyNanos}'),
//                         Text('heading: ${coordinates!.heading}'),
//                         Text('headingAccuracy: ${coordinates!.headingAccuracy}'),
//                         Text('isMock: ${coordinates!.isMock}'),
//                         Text('latitude: ${coordinates!.latitude}'),
//                         Text('longitude: ${coordinates!.longitude}'),
//                         Text('provider: ${coordinates!.provider}'),
//                         Text('satelliteNumber: ${coordinates!.satelliteNumber}'),
//                         Text('speed: ${coordinates!.speed}'),
//                         Text('speedAccuracy: ${coordinates!.speedAccuracy}'),
//                         Text('time: ${coordinates!.time}'),
//                         Text('verticalAccuracy: ${coordinates!.verticalAccuracy}'),
//                       ]
//                     : [],
//               ),
