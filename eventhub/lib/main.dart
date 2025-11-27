import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/create_event_page.dart';
import 'core/constants/app_colors.dart';
import 'core/services/preferences_service.dart';
import 'presentation/widgets/main_app_shell.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/event/event_bloc.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/event_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint('🔄 Step 1: Starting Firebase initialization...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    // Show error screen instead of white screen
    runApp(ErrorApp(error: e.toString()));
    return;
  }
  
  runApp(const EventEaseApp());
}

class EventEaseApp extends StatefulWidget {
  const EventEaseApp({Key? key}) : super(key: key);

  @override
  State<EventEaseApp> createState() => _EventEaseAppState();

  /// Access theme change from anywhere in the app
  static _EventEaseAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_EventEaseAppState>();
}

class _EventEaseAppState extends State<EventEaseApp> {
  final PreferencesService _prefsService = PreferencesService();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final theme = await _prefsService.getThemeMode();
    setState(() => _themeMode = theme);
  }

  void changeTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository: AuthRepositoryImpl()),
        ),
        BlocProvider(
          create: (context) => EventBloc(eventRepository: EventRepositoryImpl()),
        ),
      ],
      child: MaterialApp(
        title: 'EventEase',
        themeMode: _themeMode,
        theme: ThemeData(
          primaryColor: AppColors.emerald600,
          scaffoldBackgroundColor: AppColors.gray50,
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        darkTheme: ThemeData(
          primaryColor: AppColors.emerald600,
          scaffoldBackgroundColor: const Color(0xFF121212),
          brightness: Brightness.dark,
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1E1E1E),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: LoginPage(),
        routes: {
          '/home': (context) => MainAppShell(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/dashboard': (context) => const MainAppShell(initialTab: 2),
          '/events': (context) => const MainAppShell(initialTab: 1),
          '/create-event': (context) => const CreateEventPage(),
        },
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 64),
                SizedBox(height: 20),
                Text(
                  'Firebase Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  error,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    runApp(EventEaseApp());
                  },
                  child: Text('Retry without Firebase'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}