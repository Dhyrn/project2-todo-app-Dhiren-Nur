import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project1/providers/user_provider.dart';
import 'package:project1/providers/weather_provider.dart';
import 'package:project1/services/firestore_service.dart';
import 'screens/add_edit_screen.dart';
import 'screens/detail_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/task_provider.dart';
import 'screens/list_screen.dart';
import 'models/task.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider(FirestoreService())),
        ChangeNotifierProvider(create: (_) => WeatherProvider()..fetchCurrentWeather()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const _RootApp(),
    );
  }
}

class _RootApp extends StatelessWidget {
  const _RootApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // agenda a atualização dos providers para depois deste build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          taskProvider.updateUser(auth.user?.uid);

          final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
          projectProvider.updateUser(auth.user?.uid);
        });

        return MaterialApp(
          title: 'Todo App com Firestore',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: auth.isAuthenticated
              ? const ListScreen()
              : const LoginScreen(),
          routes: {
            ListScreen.routeName: (ctx) => const ListScreen(),
            AddEditScreen.routeName: (ctx) => const AddEditScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == DetailScreen.routeName) {
              final task = settings.arguments as Task;
              return MaterialPageRoute(
                builder: (context) => DetailScreen(task: task),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
