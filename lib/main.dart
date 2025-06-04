import 'package:flutter/material.dart';
import 'auth/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkSomethingBeforeLaunch() async {
    // Simula um processo de verificação ou carregamento (ex: autenticação, configs)
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App com Loading Global',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: checkSomethingBeforeLaunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 209, 2), // Dourado
              Color.fromARGB(255, 255, 62, 194), // Rosa
              Color.fromARGB(255, 130, 39, 254), // Roxo claro
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logos/vibemaker_logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
