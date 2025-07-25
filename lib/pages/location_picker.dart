import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? mapController;
  LatLng _selectedLocation = const LatLng(37.7749, -122.4194); // Default: San Francisco
  String _address = "Select a location";
  Set<Marker> _markers = {}; // Markers for nearby services

  final String googleApiKey = "AlzaSywruW5Xz5UQuG1lprUNZDUVFgp1WvCcsIm"; // Replace with actual key

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _updateAddress(LatLng(position.latitude, position.longitude));
    _fetchNearbyCleaningServices(position.latitude, position.longitude);
  }

  Future<void> _updateAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedLocation = position;
          _address = "${place.street}, ${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
    }
  }

  Future<void> _fetchNearbyCleaningServices(double lat, double lng) async {
    final String placesUrl =
        "https://maps.gomapspro.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=5000&type=laundry&keyword=cleaning&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(placesUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> places = data['results'];

        Set<Marker> newMarkers = {};
        for (var place in places) {
          final String name = place['name'];
          final double placeLat = place['geometry']['location']['lat'];
          final double placeLng = place['geometry']['location']['lng'];

          newMarkers.add(
            Marker(
              markerId: MarkerId(name),
              position: LatLng(placeLat, placeLng),
              infoWindow: InfoWindow(title: name),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        }

        setState(() {
          _markers = newMarkers;
        });
      } else {
        debugPrint("Failed to fetch places: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching places: $e");
    }
  }

  void _openGoogleMaps() async {
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${_selectedLocation.latitude},${_selectedLocation.longitude}";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      debugPrint("Could not open Google Maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 14),
              onMapCreated: (controller) {
                mapController = controller;
                setState(() {}); // Ensure UI rebuilds after map is initialized
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId("selectedLocation"),
                  position: _selectedLocation,
                  draggable: true,
                  onDragEnd: (newPosition) {
                    _updateAddress(newPosition);
                    _fetchNearbyCleaningServices(newPosition.latitude, newPosition.longitude);
                  },
                ),
                ..._markers, // Add nearby service markers
              },
              onTap: (latLng) {
                _updateAddress(latLng);
                _fetchNearbyCleaningServices(latLng.latitude, latLng.longitude);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(_address, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _openGoogleMaps,
                  child: const Text("Open in Google Maps"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {"latLng": _selectedLocation, "address": _address});
                  },
                  child: const Text("Confirm Location"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
