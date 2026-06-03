import 'package:eventoria/features/dashboard/presentation/screens/organizer_dashboard_screen.dart';
import 'package:eventoria/features/discover/presentation/screens/attendee_discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/domain/entities/profile_entity.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'core/network/supabase_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  if (!SupabaseConfig.isValid) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Configuration Error:\nMissing SUPABASE_URL or SUPABASE_ANON_KEY inside your .env file.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: VenuApp()));
}

class VenuApp extends StatelessWidget {
  const VenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Venu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3B4FEB),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (profile) {
        if (profile == null) {
          return const SignInScreen();
        }

        if (profile.role == UserRole.organizer) {
          return const OrganizerDashboardScreen();
        } else {
          return const AttendeeDiscoverScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
      ),
      error: (error, stackTrace) => const SignInScreen(),
    );
  }
}

class PlaceholderDashboard extends ConsumerWidget {
  final String title;
  const PlaceholderDashboard({required this.title, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              ref
                  .read(authControllerProvider.notifier)
                  .logout(onError: (err) {});
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to $title\n(Authentication Successful)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
    );
  }
}
