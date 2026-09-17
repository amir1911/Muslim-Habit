import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../models/qibla_info.dart';
import '../services/qibla_service.dart';

class QiblaProvider with ChangeNotifier {
  final QiblaService _service;

  QiblaInfo _qiblaInfo = QiblaInfo.defaultInfo();
  double? _deviceHeading;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasCompassSensor = true;
  StreamSubscription<CompassEvent>? _compassSubscription;

  QiblaProvider({required QiblaService service}) : _service = service {
    _initCompassListener();
  }

  QiblaInfo get qiblaInfo => _qiblaInfo;
  double get qiblaDirection => _qiblaInfo.direction;
  double? get deviceHeading => _deviceHeading;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasCompassSensor => _hasCompassSensor;

  /// Hitung selisih sudut dari heading perangkat ke arah kiblat.
  /// Bila 0 (atau mendekati 0 / 360), artinya perangkat lurus menghadap kiblat.
  double get relativeAngle {
    final heading = _deviceHeading ?? 0.0;
    return (_qiblaInfo.direction - heading) % 360;
  }

  /// Indikator apakah sudah mengarah tepat ke kiblat (toleransi ±3 derajat)
  bool get isFacingQibla {
    if (_deviceHeading == null) return false;
    final diff = (relativeAngle).abs();
    return diff <= 3 || diff >= 357;
  }

  void _initCompassListener() {
    try {
      final compassEvents = FlutterCompass.events;
      if (compassEvents == null) {
        _hasCompassSensor = false;
        notifyListeners();
        return;
      }

      _compassSubscription = compassEvents.listen(
        (CompassEvent event) {
          if (event.heading != null) {
            _deviceHeading = event.heading;
            _hasCompassSensor = true;
            notifyListeners();
          }
        },
        onError: (err) {
          _hasCompassSensor = false;
          notifyListeners();
        },
      );
    } catch (_) {
      _hasCompassSensor = false;
      notifyListeners();
    }
  }

  Future<void> determineLocationAndQibla() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'GPS / Layanan lokasi tidak aktif. Menggunakan arah kiblat standar.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Izin lokasi ditolak. Menggunakan arah kiblat standar.';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Izin lokasi ditolak permanen. Buka pengaturan untuk mengizinkan.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Ambil posisi sekarang dengan timeout 8 detik
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        final result = await _service.getQiblaDirection(
          position.latitude,
          position.longitude,
        );
        _qiblaInfo = result;
        _errorMessage = null;
      } else {
        _errorMessage = 'Tidak dapat mendeteksi posisi akurat. Menggunakan data standar.';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat arah kiblat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }
}
