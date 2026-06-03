import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EventLocationMap extends StatelessWidget {
  final TextEditingController venueController;
  final LatLng pickedLocation;
  final bool hasPickedLocation;
  final Function(TapPosition, LatLng) onMapTapped;

  const EventLocationMap({
    super.key,
    required this.venueController,
    required this.pickedLocation,
    required this.hasPickedLocation,
    required this.onMapTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Venue Name
        const Text(
          'VENUE',
          style: TextStyle(
            color: Color(0xFF717F8C),
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: venueController,
          decoration: InputDecoration(
            hintText: 'SoFi Stadium, Los Angeles',
            hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF717F8C),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B4FEB), width: 2),
            ),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Venue is required' : null,
        ),
        const SizedBox(height: 12),

        // Map placement widget
        const Text(
          'Pin Location on Map',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF717F8C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: pickedLocation,
              initialZoom: 13.0,
              onTap: onMapTapped,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.venu.app',
              ),
              if (hasPickedLocation)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pickedLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Color(0xFFF45E65),
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            hasPickedLocation
                ? 'Coordinates Saved: [Lat: ${pickedLocation.latitude.toStringAsFixed(4)}, Lng: ${pickedLocation.longitude.toStringAsFixed(4)}]'
                : '💡 Click anywhere on the map to set precise coordinates',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF717F8C),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
