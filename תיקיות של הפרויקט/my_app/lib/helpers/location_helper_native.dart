import 'package:geolocator/geolocator.dart';

/// Retrieves the device's current location.
///
/// Returns a record containing:
/// - [latitude]: The current latitude, or `null` if unavailable.
/// - [longitude]: The current longitude, or `null` if unavailable.
/// - [error]: An error message if the location could not be retrieved.
Future<({double? latitude, double? longitude, String? error})>
    fetchCurrentLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return (latitude: null, longitude: null, error: 'יש להפעיל GPS במכשיר');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return (latitude: null, longitude: null, error: 'הרשאת מיקום נדחתה');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return (
      latitude: null,
      longitude: null,
      error: 'יש לאפשר הרשאת מיקום בהגדרות המכשיר',
    );
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return (
      latitude: position.latitude,
      longitude: position.longitude,
      error: null,
    );
  } catch (e) {
    return (latitude: null, longitude: null, error: 'שגיאה: $e');
  }
}
