import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/player.dart';
import '../core/config/app_config.dart';

class AccountProfileDialog extends StatefulWidget {
  final List<Player> players;
  final String activeSessionId;
  final ValueChanged<String>? onAccountNameUpdated;

  const AccountProfileDialog({
    super.key,
    required this.players,
    required this.activeSessionId,
    this.onAccountNameUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Player> players,
    required String activeSessionId,
    ValueChanged<String>? onAccountNameUpdated,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => AccountProfileDialog(
        players: players,
        activeSessionId: activeSessionId,
        onAccountNameUpdated: onAccountNameUpdated,
      ),
    );
  }

  @override
  State<AccountProfileDialog> createState() => _AccountProfileDialogState();
}

class _AccountProfileDialogState extends State<AccountProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _hostCodeController;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "Ayush's Living Room");
    _hostCodeController = TextEditingController(text: AppConfig.defaultHostCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostCodeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && widget.onAccountNameUpdated != null) {
      widget.onAccountNameUpdated!(newName);
    }
    setState(() => isSaved = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 780,
        constraints: const BoxConstraints(maxHeight: 680),
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.25),
              blurRadius: 36,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.black87,
              blurRadius: 40,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: const Border(
                  bottom: BorderSide(color: Color(0x337BD0FF), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryContainer, AppColors.secondaryContainer],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: AppColors.secondary.withValues(alpha: 0.4), blurRadius: 12),
                          ],
                        ),
                        child: const Icon(Icons.account_circle, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Host Account & Family Profiles', style: AppStyles.headlineMd()),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.emeraldReady,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ONLINE • SYNCED TO LIVE SUPABASE CLOUD',
                                style: AppStyles.labelMd(color: AppColors.emeraldReady),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 24),
                    tooltip: 'Close Account Form',
                  ),
                ],
              ),
            ),

            // 2. Scrollable Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Row 1: Living Room Account Name & Host PIN
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HOUSEHOLD / ACCOUNT NAME', style: AppStyles.labelMd(color: AppColors.secondary)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.surfaceLowest,
                                  prefixIcon: const Icon(Icons.home, color: AppColors.secondary, size: 20),
                                  hintText: 'Enter Living Room Name',
                                  hintStyle: TextStyle(color: AppColors.outlineVariant),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: AppColors.outlineVariant),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.secondary, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FIRE TV HOST PIN', style: AppStyles.labelMd(color: AppColors.secondary)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _hostCodeController,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.surfaceLowest,
                                  prefixIcon: const Icon(Icons.vpn_key, color: AppColors.secondary, size: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: AppColors.outlineVariant),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.secondary, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Supabase Cloud Infrastructure Pill
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cloud_done, color: AppColors.emeraldReady, size: 20),
                              const SizedBox(width: 10),
                              Text('Cloud Database Infrastructure', style: AppStyles.labelLg(color: Colors.white)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.emeraldReady.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.emeraldReady.withValues(alpha: 0.5)),
                                ),
                                child: Text('PostgreSQL / RLS Active', style: AppStyles.labelMd(color: AppColors.emeraldReady)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Supabase Host: xwgslqfpymsysastllnk.supabase.co',
                                  style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Session: ${widget.activeSessionId.isNotEmpty ? widget.activeSessionId : "Live"}',
                                style: AppStyles.labelMd(color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Connected Player Profiles Section
                    Text('CONNECTED HOUSEHOLD PLAYER PROFILES', style: AppStyles.labelMd(color: AppColors.secondary)),
                    const SizedBox(height: 12),
                    Row(
                      children: widget.players.map((p) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHigh.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: p.accentColor.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: p.accentColor,
                                  child: Icon(p.icon, color: Colors.white, size: 20),
                                ),
                                const SizedBox(height: 8),
                                Text(p.name, style: AppStyles.labelLg(), overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(p.roleTag, style: AppStyles.labelMd(color: AppColors.secondary), overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('${p.score} pts', style: AppStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Footer Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                border: const Border(
                  top: BorderSide(color: Color(0x337BD0FF), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: AppStyles.bodyLg(color: AppColors.onSurfaceVariant)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: Icon(isSaved ? Icons.check_circle : Icons.save, color: Colors.black, size: 20),
                    label: Text(
                      isSaved ? 'SAVED SUCCESSFULLY!' : 'SAVE ACCOUNT DETAILS [OK]',
                      style: AppStyles.labelLg(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSaved ? AppColors.emeraldReady : AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
