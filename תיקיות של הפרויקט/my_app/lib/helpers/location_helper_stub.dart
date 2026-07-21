
/// Retrieves the current device location.
///
/// Returns `null` coordinates and an error message when the platform
/// does not support location services.
Future<({double? latitude, double? longitude, String? error})>
    fetchCurrentLocation() async {
  return (latitude: null, longitude: null, error: 'Platform not supported');
}
