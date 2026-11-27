import 'package:flutter/material.dart';

/// Tombol kembali bulat standar Muslim Habbit.
///
/// Desain: Lingkaran 40dp, background putih semi-transparan (di atas AppBar hijau),
/// atau hijau Muslim Habbit (#518427) jika berada di latar belakang terang.
/// Ikon arrow_back_ios_new_rounded putih dengan efek ripple halus.
class CustomBackButton extends StatelessWidget {
  /// Override callback navigasi. Default: Navigator.pop(context, popResult).
  final VoidCallback? onTap;

  /// Ukuran lingkaran tombol. Default 40.
  final double size;

  /// Warna background lingkaran (opsional custom).
  final Color? backgroundColor;

  /// Warna ikon. Default putih.
  final Color? iconColor;

  /// Ukuran ikon. Default 18.
  final double iconSize;

  /// Apakah tombol diletakkan di atas background terang (putih/krem).
  /// Jika true, background otomatis berwarna hijau (#518427) dengan ikon putih.
  final bool isLightBackground;

  /// Nilai yang dikembalikan ke Navigator.pop().
  final dynamic popResult;

  const CustomBackButton({
    super.key,
    this.onTap,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 18,
    this.isLightBackground = false,
    this.popResult,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ??
        (isLightBackground
            ? const Color(0xFF518427)
            : Colors.white.withValues(alpha: 0.22));

    final effectiveIconColor = iconColor ?? Colors.white;

    return Center(
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ??
              () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, popResult);
                }
              },
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: effectiveBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: effectiveIconColor,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
