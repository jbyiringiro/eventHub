import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/create_event_page.dart';
import 'core/constants/app_colors.dart';
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
  
  runApp(EventEaseApp());
}

class EventEaseApp extends StatelessWidget {
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
        theme: ThemeData(
          primaryColor: AppColors.emerald600,
          scaffoldBackgroundColor: AppColors.gray50,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        home: LoginPage(),
        routes: {
          '/home': (context) => MainAppShell(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/dashboard': (context) => MainAppShell(initialTab: 2),
          '/events': (context) => MainAppShell(initialTab: 1),
          '/create-event': (context) => CreateEventPage(),
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