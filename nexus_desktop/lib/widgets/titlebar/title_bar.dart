import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../providers/live_chat_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

/// Slim 40px custom title bar that blends into the background.
class NexusTitleBar extends ConsumerWidget {
  final String title;
  const NexusTitleBar({super.key, this.title = 'NexusAI'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectionProvider).valueOrNull ?? false;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(-.3, -.4),
                colors: [AppColors.goldLight, AppColors.gold, AppColors.bronze],
              ),
            ),
          ),
          Expanded(
            child: DragToMoveArea(
              child: Center(child: Text(title, style: AppText.meta)),
            ),
          ),
          Tooltip(
            message: online ? 'Connected to nexus-core' : 'Server offline',
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: online ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
          _Btn(Icons.remove, () => windowManager.minimize()),
          _Btn(Icons.crop_square, () async {
            (await windowManager.isMaximized())
                ? windowManager.unmaximize()
                : windowManager.maximize();
          }),
          _Btn(Icons.close, () => windowManager.close()),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 40,
          child: Icon(icon, size: 16, color: AppColors.platinum),
        ),
      );
}
