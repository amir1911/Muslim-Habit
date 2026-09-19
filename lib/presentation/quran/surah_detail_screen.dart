import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/surah_item.dart';
import '../../providers/baca_quran_provider.dart';
import '../../services/storage_service.dart';
import 'baca_quran_screen.dart';

class SurahDetailScreen extends StatelessWidget {
  final SurahItem surah;
  final int? initialAyah;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.initialAyah,
  });

  @override
  Widget build(BuildContext context) {
    final storageService = context.read<StorageService>();

    return ChangeNotifierProvider(
      create: (_) => BacaQuranProvider(
        surah: surah,
        storageService: storageService,
        initialAyah: initialAyah,
      ),
      child: BacaQuranScreen(
        surah: surah,
        initialAyah: initialAyah,
      ),
    );
  }
}
