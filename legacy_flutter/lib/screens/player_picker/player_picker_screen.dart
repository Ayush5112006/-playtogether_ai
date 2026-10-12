import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/player.dart';

class PlayerPickerScreen extends StatefulWidget {
  final Player player;
  final ValueChanged<Player> onSave;
  final VoidCallback onBack;

  const PlayerPickerScreen({
    super.key,
    required this.player,
    required this.onSave,
    required this.onBack,
  });

  @override
  State<PlayerPickerScreen> createState() => _PlayerPickerScreenState();
}

class _PlayerPickerScreenState extends State<PlayerPickerScreen> {
  late String name;
  late IconData selectedIcon;
  late Color selectedColor;

  final List<IconData> avatars = [
    Icons.face_3,
    Icons.face_6,
    Icons.smart_toy,
    Icons.sentiment_very_satisfied,
    Icons.stars,
    Icons.pets,
  ];

  final List<Color> colors = [
    AppColors.tertiary,
    AppColors.secondary,
    AppColors.primary,
    AppColors.goldAccent,
    AppColors.successGreen,
  ];

  @override
  void initState() {
    super.initState();
    name = widget.player.name;
    selectedIcon = widget.player.icon;
    selectedColor = widget.player.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 12),
              Text('Edit Player Profile', style: AppTextStyles.headlineLg()),
            ],
          ),

          const SizedBox(height: 32),

          // Current Avatar Preview
          CircleAvatar(
            radius: 54,
            backgroundColor: selectedColor,
            child: Icon(selectedIcon, size: 64, color: Colors.white),
          ),

          const SizedBox(height: 16),

          Text(name, style: AppTextStyles.headlineMd(color: Colors.white)),

          const SizedBox(height: 32),

          // Selectable Avatars
          Text('CHOOSE AVATAR', style: AppTextStyles.labelMd(color: AppColors.secondary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: avatars.map((ic) {
              final isSel = ic == selectedIcon;
              return GestureDetector(
                onTap: () => setState(() => selectedIcon = ic),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primaryContainer : AppColors.surfaceHigh,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? AppColors.secondary : Colors.transparent, width: 2),
                  ),
                  child: Icon(ic, size: 36, color: Colors.white),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Selectable Accent Color
          Text('CHOOSE TEAM COLOR', style: AppTextStyles.labelMd(color: AppColors.secondary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: colors.map((c) {
              final isSel = c == selectedColor;
              return GestureDetector(
                onTap: () => setState(() => selectedColor = c),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? Colors.white : Colors.transparent, width: 3),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          // Save & Back Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
                child: Text('Cancel [BACK]', style: AppTextStyles.labelLg()),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                onPressed: () {
                  widget.player.name = name;
                  widget.player.icon = selectedIcon;
                  widget.player.accentColor = selectedColor;
                  widget.onSave(widget.player);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: AppColors.primaryContainer,
                ),
                child: Text('Save Profile [OK]', style: AppTextStyles.headlineMd(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
