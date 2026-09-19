import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AudioPlayerPanel extends StatefulWidget {
  final int currentAyah;
  final int totalAyahs;
  final String surahName;
  final bool isPlaying;
  final bool isRepeat;
  final bool isAutoNext;
  final String selectedQari;
  final List<String> qariList;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleRepeat;
  final VoidCallback onToggleAutoNext;
  final ValueChanged<String> onSelectQari;
  final ValueChanged<Duration>? onSeek;

  const AudioPlayerPanel({
    super.key,
    required this.currentAyah,
    required this.totalAyahs,
    required this.surahName,
    required this.isPlaying,
    required this.isRepeat,
    required this.isAutoNext,
    required this.selectedQari,
    required this.qariList,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleRepeat,
    required this.onToggleAutoNext,
    required this.onSelectQari,
    this.onSeek,
  });

  @override
  State<AudioPlayerPanel> createState() => _AudioPlayerPanelState();
}

class _AudioPlayerPanelState extends State<AudioPlayerPanel> {
  bool _isExpanded = false;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B380E).withValues(alpha: 0.95), // Deep Islamic dark green
        borderRadius: BorderRadius.circular(_isExpanded ? 24 : 36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8BB750).withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── MAIN FLOATING BAR (Sesuai Screenshot) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Panah Kiri (Fast jump / prev surah)
                _buildCircleNavButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: widget.currentAyah > 1 ? widget.onPrevious : null,
                ),

                // Tombol Previous Verse
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  tooltip: 'Ayat Sebelumnya',
                  onPressed: widget.currentAyah > 1 ? widget.onPrevious : null,
                ),

                // Tombol Play / Pause Utama
                GestureDetector(
                  onTap: widget.onPlayPause,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                // Tombol Next Verse
                IconButton(
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  tooltip: 'Ayat Berikutnya',
                  onPressed: widget.currentAyah < widget.totalAyahs ? widget.onNext : null,
                ),

                // Tombol Panah Kanan (Fast jump / next surah)
                _buildCircleNavButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: widget.currentAyah < widget.totalAyahs ? widget.onNext : null,
                ),

                // Expand detail audio info button
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.more_horiz_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                  tooltip: 'Pengaturan Audio',
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),

          // ── EXPANDED PANEL (Progress bar, Qari, Repeat, Auto-Next) ──
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 10),

                  // Info Ayat & Qari
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.surahName} : Ayat ${widget.currentAyah}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      // Dropdown Qari
                      PopupMenuButton<String>(
                        initialValue: widget.selectedQari,
                        onSelected: widget.onSelectQari,
                        color: const Color(0xFF254817),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.selectedQari,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                            ],
                          ),
                        ),
                        itemBuilder: (ctx) => widget.qariList.map((qari) {
                          return PopupMenuItem<String>(
                            value: qari,
                            child: Text(
                              qari,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: qari == widget.selectedQari
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress Slider
                  Row(
                    children: [
                      Text(
                        _formatDuration(widget.position),
                        style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.5,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            activeTrackColor: const Color(0xFF8BB750),
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: widget.duration.inMilliseconds > 0
                                ? widget.position.inMilliseconds
                                    .clamp(0, widget.duration.inMilliseconds)
                                    .toDouble()
                                : 0.0,
                            max: widget.duration.inMilliseconds > 0
                                ? widget.duration.inMilliseconds.toDouble()
                                : 1.0,
                            onChanged: (val) {
                              if (widget.onSeek != null) {
                                widget.onSeek!(Duration(milliseconds: val.toInt()));
                              }
                            },
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(widget.duration),
                        style: GoogleFonts.inter(fontSize: 10.5, color: Colors.white70),
                      ),
                    ],
                  ),

                  // Toggle Repeat & Auto-Next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Repeat Toggle
                      _buildToggleButton(
                        icon: Icons.repeat_rounded,
                        label: 'Ulang Ayat',
                        isActive: widget.isRepeat,
                        onTap: widget.onToggleRepeat,
                      ),
                      // Auto Next Toggle
                      _buildToggleButton(
                        icon: Icons.skip_next_rounded,
                        label: 'Auto Putar Lanjut',
                        isActive: widget.isAutoNext,
                        onTap: widget.onToggleAutoNext,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCircleNavButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF142B0A) : Colors.black12,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.white30,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF557C2B) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
