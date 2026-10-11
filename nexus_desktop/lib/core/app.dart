import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/live_chat_provider.dart';
import '../theme/app_theme.dart';
import 'router.dart';

class NexusApp extends ConsumerWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(webSocketProvider); // connect to nexus-core at launch
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'NexusAI',
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
