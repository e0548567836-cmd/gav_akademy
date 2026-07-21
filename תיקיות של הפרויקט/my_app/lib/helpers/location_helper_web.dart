// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Retrieves the current device location using the browser's geolocation API.
Future<({double? latitude, double? longitude, String? error})>
fetchCurrentLocation() async {
  try {
    final pos = await html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: true,
    );
    return (
      latitude: pos.coords?.latitude?.toDouble(),
      longitude: pos.coords?.longitude?.toDouble(),
      error: null,
    );
  } catch (e) {
    String message = 'שגיאה בקבלת מיקום';
    if (e is html.PositionError) {
      if (e.code == 1) message = 'הרשאת מיקום נדחתה';
      if (e.code == 2) message = 'המיקום אינו זמין';
    }
    return (latitude: null, longitude: null, error: message);
  }
}
