import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_supabase/pages/account_page.dart';
import 'package:flutter_supabase/pages/login_page.dart';
import 'package:flutter_supabase/pages/splash_page.dart';
import 'package:flutter_supabase/pages/task_list_page.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ujjnyfmmxkxoblgcrbfi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqam55Zm1teGt4b2JsZ2NyYmZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQyMDE2OTQsImV4cCI6MjAxOTc3NzY5NH0.NDyjozuL23mnUyCvYU8BfSIb-A5rlAwuXKcscTPDk4I',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),
        '/account': (_) => const AccountPage(),
        '/tasks': (_) => const TaskListPage(),
      },
    );
  }
}
