import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/guide/guide_screen.dart';
import '../features/play/play_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/worlds/worlds_screen.dart';
import '../widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/play',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/play', builder: (context, state) => const PlayScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/worlds', builder: (context, state) => const WorldsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/guide', builder: (context, state) => const GuideScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );
});
