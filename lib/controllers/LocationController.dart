import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationController extends GetxController {
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  Location location = Location();
  LocationData? _locationData;
  MapController mapController = MapController();

  Rx<double> zoom = 3.0.obs;

  Rx<double> lat = 0.0.obs;
  Rx<double> lng = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    getLocationPermission();
  }

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

  getLocation() async {
    _locationData = await location.getLocation().then((value) {
      lat = Rx(double.parse('${value.latitude}'));
      lng = Rx(double.parse('${value.longitude}'));
      mapController.move(LatLng(value.latitude!, value.longitude!), double.parse('${zoom}'));
    });
  }
}
