import 'package:get/get.dart';
import 'package:location/location.dart';

class LocationController extends GetxController {
  Location location = new Location();

  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  Rx<double> lat = 0.0.obs;
  Rx<double> lng = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    getLocationPermission();
  }

  getLocation() async {
    _locationData = await location.getLocation().then((value) {
      lat = Rx(double.parse('${value.latitude}'));
      lng = Rx(double.parse('${value.longitude}'));
    });
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
}
