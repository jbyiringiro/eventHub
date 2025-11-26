import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/event_creation_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';
import 'providers/event_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); // init local notifications
  runApp(const EventHubApp());
}

class EventHubApp extends StatelessWidget {
  const EventHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()),
        // Add AuthProvider etc later
      ],
      child: MaterialApp(
        title: 'EventHub',
        theme: ThemeData(primarySwatch: Colors.indigo),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/create': (context) => const EventCreationScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
