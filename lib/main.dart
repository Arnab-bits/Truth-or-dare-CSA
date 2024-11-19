import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'MainScreen.dart';
import 'auth_gate.dart';

// Riverpod Provider for Firebase Initialization
final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
});

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _hasNavigated = false; // Prevent multiple navigations

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseState = ref.watch(firebaseInitProvider);

    ref.listen<AsyncValue<void>>(firebaseInitProvider, (previous, next) {
      if (next is AsyncData && !_hasNavigated) {
        _hasNavigated = true; // Set the flag to true
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AuthGate(),
          ),
        );
      }
    });

    return Scaffold(
      body: firebaseState.when(
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error initializing Firebase: $error',
            style: TextStyle(color: Colors.red),
          ),
        ),
        data: (_) => FadeTransition(
          opacity: _animation,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              "assets/truth or dare.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

