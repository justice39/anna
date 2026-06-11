import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/notification_service.dart';
import 'theme/theme.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/home/home_shell.dart';
import 'features/reminder_editor/reminder_editor_screen.dart';
import 'features/incoming_call/incoming_call_screen.dart';

final _supabase = Supabase.instance.client;

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = _supabase.auth.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/welcome';

      if (!isLoggedIn && !isAuthRoute) return '/welcome';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(_supabase.auth.onAuthStateChange),
    routes: [
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeShell(),
        routes: [
          GoRoute(
            path: 'reminder/new',
            builder: (_, __) => const ReminderEditorScreen(),
          ),
          GoRoute(
            path: 'reminder/:id',
            builder: (ctx, st) =>
                ReminderEditorScreen(reminderId: st.pathParameters['id']),
          ),
          GoRoute(
            path: 'incoming-call/:reminderId',
            builder: (ctx, st) => IncomingCallScreen(
              reminderId: st.pathParameters['reminderId']!,
            ),
          ),
        ],
      ),
    ],
  );
});

class AnnaApp extends ConsumerWidget {
  const AnnaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Anna',
      debugShowCheckedModeBanner: false,
      theme: annaTheme(),
      routerConfig: router,
    );
  }
}

/// Helper that converts a Stream into a Listenable for GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}