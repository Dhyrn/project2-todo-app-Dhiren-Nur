import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project1/screens/add_edit_screen.dart';
import 'package:project1/screens/detail_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:project1/providers/task_provider.dart';
import 'package:project1/screens/list_screen.dart';
import 'package:project1/models/task.dart';

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
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Todo App com Firestore',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const ListScreen(),
        routes: {
          ListScreen.routeName: (ctx) => const ListScreen(),
          AddEditScreen.routeName: (ctx) => AddEditScreen(),

        },
          onGenerateRoute: (settings) {
            if (settings.name == DetailScreen.routeName) {
              final task = settings.arguments as Task;
              return MaterialPageRoute(
                builder: (context) => DetailScreen(task: task),
              );
            }
            // Retorne null se não reconhecer, ou um fallback
            return null;
          }
      ),
    );
  }
}
