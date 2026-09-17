import 'package:flutter/foundation.dart';
import '../models/hadith_item.dart';
import '../services/hadith_service.dart';
import '../services/storage_service.dart';

class HadithProvider extends ChangeNotifier {
  final StorageService _storageService;
  late final HadithService _hadithService;

  HadithItem? _currentHadith;
  bool _isLoading = false;
  String? _errorMessage;

  HadithProvider(this._storageService, [HadithService? hadithService]) {
    _hadithService = hadithService ?? HadithService(_storageService);
    loadRandomHadith();
  }

  HadithItem get currentHadith => _currentHadith ?? HadithItem.defaultHadith();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRandomHadith() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hadith = await _hadithService.fetchRandomHadith();
      _currentHadith = hadith;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat hadis: $e';
      _currentHadith ??= HadithItem.defaultHadith();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
