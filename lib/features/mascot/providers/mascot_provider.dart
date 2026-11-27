import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/storage_service.dart';
import '../../../providers/habit_provider.dart';
import '../models/costume_model.dart';
import '../models/shop_item_model.dart';

class MascotProvider extends ChangeNotifier {
  final StorageService _storageService;
  AudioPlayer? _audioPlayer;

  String _equippedCostume = 'normal';
  List<String> _ownedCostumes = ['normal', 'sorban_emas'];

  // Aksesoris unta independen (dapat digunakan bersamaan)
  List<String> _equippedAccessories = [];
  List<String> _ownedAccessories = ['peci', 'syal', 'lonceng'];

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
    _equippedAccessories = _storageService.getEquippedAccessories();
    _ownedAccessories = _storageService.getOwnedAccessories();
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

    // Sinkronisasi data kostum & aksesoris dari Firebase Cloud Firestore
    _syncMascotFromCloud();
  }

  // ── GETTERS ──
  String get equippedCostume => _equippedCostume;
  List<String> get ownedCostumes => _ownedCostumes;
  List<String> get equippedAccessories => List.unmodifiable(_equippedAccessories);
  List<String> get ownedAccessories => List.unmodifiable(_ownedAccessories);

  bool isAccessoryEquipped(String accessoryId) => _equippedAccessories.contains(accessoryId);
  bool isAccessoryOwned(String accessoryId) => _ownedAccessories.contains(accessoryId);

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

    _syncMascotToCloud();
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

  // =========================================================================
  // AKSI AKSESORIS MANDIRI (PECI, SYAL, LONCENG)
  // =========================================================================

  /// Pasang / Lepas aksesoris unta secara mandiri
  Future<void> toggleAccessory(String id) async {
    final acc = AccessoryModel.getById(id);
    final isAlreadyEquipped = _equippedAccessories.contains(id);

    if (isAlreadyEquipped) {
      _equippedAccessories.remove(id);
      _currentDialogue = 'Aksesoris ${acc?.name ?? id} berhasil dilepas.';
    } else {
      _equippedAccessories.add(id);
      if (id == 'lonceng') {
        playBellSound();
        _currentDialogue = 'Klining... Lonceng emas berbunyi merdu!';
      } else if (id == 'peci') {
        _currentDialogue = 'Alhamdulillah! Peci Islami terpasang pas di kepalaku.';
      } else if (id == 'syal') {
        _currentDialogue = 'Syal hijau emas ini nyaman banget di leher!';
      } else {
        _currentDialogue = 'Aksesoris ${acc?.name ?? id} berhasil dipasang!';
      }
    }

    await _storageService.setEquippedAccessories(_equippedAccessories);
    _syncMascotToCloud();
    notifyListeners();
  }

  /// Mainkan efek suara lonceng
  Future<void> playBellSound() async {
    try {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.setAsset('assets/audio/bel_tradisional.wav');
      await _audioPlayer!.seek(Duration.zero);
      await _audioPlayer!.play();
    } catch (e) {
      debugPrint('[MascotProvider] Gagal memutar suara lonceng: $e');
    }
  }

  // =========================================================================
  // INTEGRASI SINKRONISASI FIREBASE CLOUD FIRESTORE
  // =========================================================================

  Future<void> _syncMascotToCloud() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('mascot_state')
          .doc('wardrobe')
          .set({
        'equippedCostume': _equippedCostume,
        'equippedAccessories': _equippedAccessories,
        'ownedCostumes': _ownedCostumes,
        'ownedAccessories': _ownedAccessories,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[MascotProvider] Sync to cloud error: $e');
    }
  }

  Future<void> _syncMascotFromCloud() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('mascot_state')
          .doc('wardrobe')
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final cloudCostume = data['equippedCostume'] as String?;
        final cloudAccs = (data['equippedAccessories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
        final cloudOwnedCostumes = (data['ownedCostumes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
        final cloudOwnedAccs = (data['ownedAccessories'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();

        bool hasChanges = false;
        if (cloudCostume != null && cloudCostume != _equippedCostume) {
          _equippedCostume = cloudCostume;
          _storageService.setEquippedCostume(cloudCostume);
          hasChanges = true;
        }
        if (cloudAccs != null) {
          _equippedAccessories = cloudAccs;
          _storageService.setEquippedAccessories(cloudAccs);
          hasChanges = true;
        }
        if (cloudOwnedCostumes != null) {
          _ownedCostumes = {..._ownedCostumes, ...cloudOwnedCostumes}.toList();
          _storageService.setOwnedCostumes(_ownedCostumes);
          hasChanges = true;
        }
        if (cloudOwnedAccs != null) {
          _ownedAccessories = {..._ownedAccessories, ...cloudOwnedAccs}.toList();
          _storageService.setOwnedAccessories(_ownedAccessories);
          hasChanges = true;
        }
        if (hasChanges) {
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[MascotProvider] Sync from cloud error: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}
