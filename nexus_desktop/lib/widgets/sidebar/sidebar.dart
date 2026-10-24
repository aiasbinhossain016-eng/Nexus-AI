import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/chat/chat_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../common/glass_container.dart';
import 'sidebar_item.dart';

class NexusSidebar extends ConsumerStatefulWidget {
  const NexusSidebar({super.key});

  @override
  ConsumerState<NexusSidebar> createState() => _NexusSidebarState();
}

class _NexusSidebarState extends ConsumerState<NexusSidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final userMessages = chatState.messages
        .where((message) => message.role == 'user')
        .toList();
    final currentTitle = userMessages.isEmpty
        ? 'New conversation'
        : userMessages.first.content;
    final searchResults = _query.trim().isEmpty
        ? const []
        : userMessages
              .where(
                (message) => message.content.toLowerCase().contains(
                  _query.trim().toLowerCase(),
                ),
              )
              .toList()
              .reversed
              .toList();
    final currentPath = GoRouterState.of(context).uri.path;

    return SizedBox(
      width: 260,
      child: GlassContainer(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-.3, -.4),
                      colors: [
                        AppColors.goldLight,
                        AppColors.gold,
                        AppColors.bronze,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: .5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('NexusAI', style: AppText.display(24)),
              ],
            ),
            const SizedBox(height: 24),
            _NewChatButton(
              onTap: () {
                ref.read(chatProvider.notifier).clearChat();
                context.go('/');
              },
            ),
            const SizedBox(height: 8),
            SidebarItem(
              title: 'Dashboard',
              icon: Icons.dashboard_outlined,
              active: currentPath == '/dashboard',
              onTap: () => context.go('/dashboard'),
            ),
            const SizedBox(height: 12),
            _SearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              onClear: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _query.trim().isEmpty
                  ? ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Text('CURRENT CHAT', style: AppText.caption),
                        const SizedBox(height: 8),
                        SidebarItem(
                          title: currentTitle,
                          active: currentPath == '/chat',
                          onTap: () => context.go('/chat'),
                        ),
                      ],
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Text('SEARCH RESULTS', style: AppText.caption),
                        const SizedBox(height: 8),
                        if (searchResults.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              'No matching messages',
                              style: AppText.meta,
                            ),
                          )
                        else
                          for (final message in searchResults)
                            SidebarItem(
                              title: message.content,
                              onTap: () {
                                _searchController.clear();
                                setState(() => _query = '');
                                context.go('/chat');
                              },
                            ),
                      ],
                    ),
            ),
            const _ProfileCard(),
          ],
        ),
      ),
    );
  }
}

class _NewChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 18, color: AppColors.background),
            const SizedBox(width: 8),
            Text(
              'New chat',
              style: AppText.meta.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppText.meta,
        decoration: InputDecoration(
          hintText: 'Search this chat',
          hintStyle: AppText.meta,
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 16),
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: Colors.white.withValues(alpha: .03),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderHover),
            ),
            child: Text(
              'N',
              style: AppText.meta.copyWith(color: AppColors.gold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nexus User',
                  style: AppText.meta.copyWith(color: AppColors.text),
                ),
                Text('Private plan', style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
