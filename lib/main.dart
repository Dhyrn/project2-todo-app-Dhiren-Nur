import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:project1/providers/task_provider.dart';
import 'package:project1/screens/list_screen.dart';

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
        // Adicione outros providers aqui, se necessário (configuração, theme etc.)
      ],
      child: MaterialApp(
        title: 'Todo App com Firestore',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const ListScreen(),
        routes: {
          // Adicione aqui as rotas adicionais quando criar as telas Add/Edit e Detail
          // AddEditScreen.routeName: (ctx) => AddEditScreen(),
          // DetailScreen.routeName: (ctx) => DetailScreen(),
        },
      ),
    );
  }
}
