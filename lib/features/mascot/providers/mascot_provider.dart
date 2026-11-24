import 'dart:math';
import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';
import '../../../providers/habit_provider.dart';
import '../models/costume_model.dart';
import '../models/shop_item_model.dart';

class MascotProvider extends ChangeNotifier {
  final StorageService _storageService;

  String _equippedCostume = 'normal';
  List<String> _ownedCostumes = ['normal', 'sorban_emas'];
  int _friendshipPoints = 75; // 0 - 100
  int _friendshipLevel = 4;
  DateTime? _boosterExpiresAt;
  List<String> _ownedRewards = [];

  String _currentDialogue = 'Keren Banget Gak Sih Aku?';

  static const List<String> _idleDialogues = [
    'Keren Banget Gak Sih Aku?',
    'Assalamualaikum! Apa kabar hari ini?',
    'Yuk, semangat ibadah hari ini!',
    'Terima kasih sudah merawatku!',
    'Sholat tepat waktu bikin hati jadi tenang lho!',
    'Aku selalu siap nemenin kamu beribadah!',
    'Sudah tilawah Al-Qur\'an hari ini belum?',
    'Tetap istiqomah ya, sahabatku!',
  ];

  MascotProvider(this._storageService) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    _equippedCostume = _storageService.getEquippedCostume();
    _ownedCostumes = _storageService.getOwnedCostumes();
    _friendshipPoints = _storageService.getFriendshipPoints();
    _friendshipLevel = _storageService.getFriendshipLevel();
    _ownedRewards = _storageService.getOwnedRewards();

    final boosterTimestamp = _storageService.getBoosterExpiresAt();
    if (boosterTimestamp != null) {
      final exp = DateTime.fromMillisecondsSinceEpoch(boosterTimestamp);
      if (exp.isAfter(DateTime.now())) {
        _boosterExpiresAt = exp;
      }
    }
  }

  // ── GETTERS ──
  String get equippedCostume => _equippedCostume;
  List<String> get ownedCostumes => _ownedCostumes;
  int get friendshipPoints => _friendshipPoints;
  int get friendshipLevel => _friendshipLevel;
  double get friendshipProgressFraction => (_friendshipPoints % 100) / 100.0;
  String get currentDialogue => _currentDialogue;
  List<String> get ownedRewards => _ownedRewards;

  CostumeModel get currentCostumeModel => CostumeModel.getById(_equippedCostume);

  bool get isBoosterActive =>
      _boosterExpiresAt != null && DateTime.now().isBefore(_boosterExpiresAt!);

  String get boosterTimeRemaining {
    if (!isBoosterActive || _boosterExpiresAt == null) return '';
    final diff = _boosterExpiresAt!.difference(DateTime.now());
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    return '${hours}j ${mins}m';
  }

  // ── ACTIONS ──

  /// Acak dialog Nunu saat disentuh
  void cycleDialogue({String? customDialogue}) {
    if (customDialogue != null) {
      _currentDialogue = customDialogue;
    } else {
      final random = Random();
      final candidates = _idleDialogues.where((d) => d != _currentDialogue).toList();
      _currentDialogue = candidates[random.nextInt(candidates.length)];
    }
    notifyListeners();
  }

  /// Pasang kostum (Equip)
  bool equipCostume(String costumeId) {
    if (!_ownedCostumes.contains(costumeId)) return false;

    _equippedCostume = costumeId;
    _storageService.setEquippedCostume(costumeId);

    // Dialog respon kostum
    if (costumeId == 'sorban_emas') {
      _currentDialogue = 'Wah, Sorban Emas ini bikin aku makin bercahaya!';
    } else if (costumeId == 'jubah_zamrud') {
      _currentDialogue = 'MasyaAllah, Jubah Zamrud ini nyaman dan anggun!';
    } else {
      _currentDialogue = 'Kembali ke gaya natural! Keren Banget Gak Sih Aku?';
    }

    notifyListeners();
    return true;
  }

  /// Cek apakah suatu kostum dimiliki
  bool isCostumeOwned(String costumeId) => _ownedCostumes.contains(costumeId);

  /// Cek apakah suatu item toko sudah dimiliki
  bool isItemPurchased(String itemId) {
    if (_ownedCostumes.contains(itemId)) return true;
    if (_ownedRewards.contains(itemId)) return true;
    if (itemId == 'ramuan_bintang' && isBoosterActive) return true;
    return false;
  }

  /// Pembelian item toko
  String? buyShopItem(ShopItemModel item, HabitProvider habitProv) {
    // 1. Cek kepemilikan unik
    if (item.category == ShopCategory.kostum && isCostumeOwned(item.id)) {
      return 'Kamu sudah memiliki kostum ${item.name}!';
    }
    if (item.id == 'ramuan_bintang' && isBoosterActive) {
      return 'Booster 2x XP kamu saat ini masih aktif!';
    }

    // 2. Cek saldo bintang
    if (habitProv.userPoints < item.price) {
      return 'Saldo bintangmu kurang (${habitProv.userPoints}/${item.price} ⭐)';
    }

    // 3. Potong saldo bintang
    final success = habitProv.deductPoints(item.price);
    if (!success) return 'Gagal melakukan transaksi.';

    // 4. Efek item
    if (item.category == ShopCategory.kostum) {
      if (!_ownedCostumes.contains(item.id)) {
        _ownedCostumes.add(item.id);
        _storageService.setOwnedCostumes(_ownedCostumes);
      }
      _currentDialogue = 'Alhamdulillah, terima kasih kostum ${item.name}-nya!';
    } else if (item.id == 'ramuan_penyegar') {
      // Langsung berikan kepada Nunu
      feedRefreshPotion();
      return 'SUCCESS_FEED';
    } else if (item.id == 'ramuan_bintang') {
      // Aktifkan booster 24 jam
      final expires = DateTime.now().add(const Duration(hours: 24));
      _boosterExpiresAt = expires;
      _storageService.setBoosterExpiresAt(expires.millisecondsSinceEpoch);
      _currentDialogue = 'Yeyy! Booster 2x XP aktif selama 24 jam penuh!';
    } else {
      // Kategori lainnya
      _ownedRewards.add(item.id);
      _storageService.setOwnedRewards(_ownedRewards);
      _currentDialogue = 'Hadiah ${item.name} berhasil disimpan di inventory!';
    }

    notifyListeners();
    return null; // Null menandakan sukses standar
  }

  /// Beri Ramuan Penyegar ke Nunu (Naikkan Afeksi & Level Persahabatan)
  void feedRefreshPotion() {
    _friendshipPoints += 35;
    if (_friendshipPoints >= 100) {
      _friendshipLevel += 1;
      _friendshipPoints = _friendshipPoints % 100;
      _storageService.setFriendshipLevel(_friendshipLevel);
      _currentDialogue = 'Slurrp! Segar banget! Level persahabatan kita naik jadi Lv. $_friendshipLevel!';
    } else {
      _currentDialogue = 'Slurrp! Segar banget rasanya seperti blueberry! Terima kasih sahabatku!';
    }
    _storageService.setFriendshipPoints(_friendshipPoints);
    notifyListeners();
  }
}
