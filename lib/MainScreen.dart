import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'TruthScreen.dart';
import 'DareScreen.dart';
import 'NeverHaveIEver.dart';
import 'WouldYouRather.dart';
import 'Paranoia.dart';
import 'auth_gate.dart';

// Firebase Initialization Provider
final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
});

// Firebase User Provider
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInit = ref.watch(firebaseInitProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: firebaseInit.when(
        loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
        data: (_) => AuthGate(),
      ),
    );
  }
}

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseUserProvider).value;

    final userName = user?.displayName ?? "Guest";
    final userEmail = user?.email ?? "No Email";

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.cyanAccent,
        title: Text(
          'My Profile',
          style: TextStyle(fontSize: 45, fontFamily: 'LondrinaSketch'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/truth or dare.jpg'),
                radius: 70.0,
              ),
            ),
            SizedBox(height: 30.0),
            Text(
              'Name:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              userName,
              style: TextStyle(color: Colors.cyan, fontSize: 30, letterSpacing: 2.0),
            ),
            SizedBox(height: 30.0),
            Text(
              'E-mail:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              userEmail,
              style: TextStyle(color: Colors.cyan, fontSize: 30, letterSpacing: 2.0),
            ),
            SizedBox(height: 70.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                backgroundColor: Colors.transparent.withOpacity(0.0),
                elevation: 0,
              ),
              child: Text(
                'Play',
                style: TextStyle(
                  fontFamily: 'LondrinaSketch',
                  fontSize: 40,
                  color: Colors.amber,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthGate()));
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                backgroundColor: Colors.transparent.withOpacity(0.0),
                elevation: 0,
              ),
              child: Text(
                'Sign Out',
                style: TextStyle(fontFamily: 'LondrinaSketch', fontSize: 40, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LikedQuestionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liked Questions", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('liked_questions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No liked questions yet!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final likedQuestions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: likedQuestions.length,
            itemBuilder: (context, index) {
              final question = likedQuestions[index]['question'];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    question,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikedQuestionsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.quiz_outlined),
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('User Profile'),
                    ),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                      }),
                    ],
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text('Check!Check!Check!'),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
        automaticallyImplyLeading: false,
        title: Text(
          "Choose your Destiny!",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/DALL·E 2024-10-15 00.35.32 - A cartoonish wooden table top with visible texture, showing white scratch marks and drawings representing a broken heart. The words 'Truth or Dare' ar.webp",
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildMainButton(context, 'Truth', Colors.greenAccent, TruthScreen()),
            buildMainButton(context, 'Dare', Colors.red, DareScreen()),
            buildMainButton(context, 'Never Have I Ever', Colors.pinkAccent, NeverEverScreen()),
            buildMainButton(context, 'Would You Rather', Colors.purpleAccent, WouldYouRatherScreen()),
            buildMainButton(context, 'Paranoia', Colors.cyanAccent, ParanoiaScreen()),
          ],
        ),
      ),
    );
  }







  Widget buildMainButton(BuildContext context, String text, Color color, Widget screen) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          backgroundColor: Colors.transparent.withOpacity(0.8),
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'LondrinaSketch',
            fontSize: 50,
            color: color,
          ),
        ),
      ),
    );
  }
}
