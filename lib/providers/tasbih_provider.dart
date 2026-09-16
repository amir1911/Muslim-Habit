import 'package:flutter/material.dart';
import '../models/dhikr_item.dart';
import '../services/storage_service.dart';

class TasbihProvider extends ChangeNotifier {
  final StorageService _storageService;

  TasbihProvider(this._storageService) {
    _totalAllTime = _storageService.getDhikrTotal();
  }

  int _selectedIndex = 0;
  int _target = 33;
  int _totalAllTime = 0;
  bool _vibrationEnabled = true;

  int get selectedIndex => _selectedIndex;
  int get target => _target;
  int get totalAllTime => _totalAllTime;
  bool get vibrationEnabled => _vibrationEnabled;

  final List<DhikrItem> _dhikrList = [
    DhikrItem(
      id: 'subhanallah',
      arabic: 'سُبْحَانَ اللَّهِ',
      latin: 'Subhanallah',
      translation: 'Maha Suci Allah',
      targetCount: 33,
    ),
    DhikrItem(
      id: 'alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      latin: 'Alhamdulillah',
      translation: 'Segala Puji Bagi Allah',
      targetCount: 33,
    ),
    DhikrItem(
      id: 'allahuakbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      latin: 'Allahu Akbar',
      translation: 'Allah Maha Besar',
      targetCount: 33,
    ),
    DhikrItem(
      id: 'astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      latin: 'Astaghfirullah',
      translation: 'Aku memohon ampun kepada Allah',
      targetCount: 100,
    ),
    DhikrItem(
      id: 'lailahaillallah',
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      latin: 'Laa Ilaaha Illallah',
      translation: 'Tiada Tuhan selain Allah',
      targetCount: 100,
    ),
    DhikrItem(
      id: 'sholawat',
      arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
      latin: 'Allahumma Sholli \'Ala Muhammad',
      translation: 'Ya Allah, limpahkanlah rahmat kepada Nabi Muhammad',
      targetCount: 33,
    ),
  ];

  List<DhikrItem> get dhikrList => _dhikrList;
  DhikrItem get currentDhikr => _dhikrList[_selectedIndex];

  void selectDhikr(int index) {
    if (index >= 0 && index < _dhikrList.length) {
      _selectedIndex = index;
      _target = _dhikrList[index].targetCount;
      notifyListeners();
    }
  }

  void setTarget(int newTarget) {
    _target = newTarget;
    notifyListeners();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
  }

  bool incrementCount() {
    final item = currentDhikr;
    item.currentCount++;
    _totalAllTime++;
    _storageService.setDhikrTotal(_totalAllTime);

    bool reachedTarget = false;
    if (_target > 0 && item.currentCount >= _target) {
      item.totalCompletedCycles++;
      item.currentCount = 0;
      reachedTarget = true;
    }

    notifyListeners();
    return reachedTarget;
  }

  void resetCurrentCount() {
    currentDhikr.currentCount = 0;
    notifyListeners();
  }
}
