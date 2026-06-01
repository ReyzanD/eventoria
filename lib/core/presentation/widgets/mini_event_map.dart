import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MiniEventMap extends StatelessWidget{
  final double latitude;
  final double longitude;
  final String venueName;

  const MiniEventMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venueName,
  });

  @override
  Widget build(BuildContext context){
    if (latitude == 0.0 && longitude == 0.0){
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Map location unpinned for this venue', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final targetCoordinates = LatLng(latitude, longitude);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: targetCoordinates,
              initialZoom: 14.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.venu.app',
              ),
              MarkerLayer(
                markers:[
                  Marker(
                    point: targetCoordinates,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.red, size:40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}