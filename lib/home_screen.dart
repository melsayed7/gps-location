import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Location location = Location();

  late PermissionStatus permissionStatus;

  bool serviceEnabled = false;

  LocationData? locationData = null;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.0590933, 31.3221817),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(30.0590933, 31.3221817),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  Set<Marker> markers = {};

  double defLat = 30.0590933;

  double defLon = 31.3221817;

  StreamSubscription<LocationData>? streamSubscription = null;

  @override
  void initState() {
    super.initState();
    getUserLocation();
    var userMarker = Marker(
      markerId: const MarkerId('user location'),
      position: LatLng(
          locationData?.latitude ?? defLat, locationData?.longitude ?? defLon),
    );
    markers.add(userMarker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Tracker Map'),
        centerTitle: true,
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('Get location'),
        icon: const Icon(Icons.directions),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

  Future<bool> isServiceEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == false) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

  void getUserLocation() async {
    var permissionGranted = await isPermissionGranted();
    if (permissionGranted == false) return;
    var serviceEnabled = await isServiceEnabled();
    if (serviceEnabled == false) return;
    locationData = await location.getLocation();
    print(
        'Before ${locationData?.latitude ?? 0} , ${locationData?.longitude ?? 0}');
    streamSubscription = location.onLocationChanged.listen((newLocation) {
      locationData = newLocation;
      updateUserMarker();
      print(
          'After ${locationData?.latitude ?? 0} , ${locationData?.longitude ?? 0}');
    });
  }

  void updateUserMarker() async {
    var userMarker = Marker(
      markerId: const MarkerId('user location'),
      position: LatLng(
          locationData?.latitude ?? defLat, locationData?.longitude ?? defLon),
    );
    markers.add(userMarker);
    setState(() {});
    var newCameraPosition = CameraPosition(
      target: LatLng(
          locationData?.latitude ?? defLat, locationData?.longitude ?? defLon),
      zoom: 19,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }
}
//AIzaSyCK_xEzgBHokxMpKTXHdFiV1kwV1gLqjT8
