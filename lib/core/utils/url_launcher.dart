import 'package:url_launcher/url_launcher.dart';

class MapUtility {
  static Future<void> openInGoogleMaps(
    double latitude,
    double longitude,
    String venueName,
  ) async {
    final String query = Uri.encodeComponent(venueName);
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude($query)',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not open the map for $venueName.');
    }
  }
}
