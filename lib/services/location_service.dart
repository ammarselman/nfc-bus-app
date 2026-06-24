import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _sub;

  Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position> getCurrent() async {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  StreamSubscription<Position> startListening({
    required void Function(Position p) onData,
    void Function(Object e)? onError,
    LocationAccuracy accuracy = LocationAccuracy.high,
    int intervalSec = 10,
    double distanceFilterM = 5,
  }) {
    _sub?.cancel();
    final stream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterM.toInt(),
        timeLimit: null,
      ),
    );
    _sub = stream.listen(onData, onError: onError, cancelOnError: false);
    return _sub!;
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
