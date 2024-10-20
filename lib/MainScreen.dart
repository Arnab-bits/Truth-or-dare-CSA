import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'TruthScreen.dart';
import 'DareScreen.dart';
import 'NeverHaveIEver.dart';
import 'WouldYouRather.dart';
import 'Paranoia.dart';
import 'auth_gate.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {

  String? _userName;
  @override

  void initState() {
    super.initState();
    _getCurrentUser();
    _getCurrentUserEmail();
  }
  void _getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userName = user?.displayName ?? "Guest";
    });
  }

  String? _userEmail;



  void _getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email ?? "No Email";
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.cyanAccent,
        title: Text('My Profile', style: TextStyle(fontSize: 45, fontFamily: 'LondrinaSketch'),),
        centerTitle: true,



      ),
      body: Padding(padding: EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),

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
            Text('Name:', style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 2.0, fontWeight: FontWeight.w800 ),
            ),
            Text('$_userName', style: TextStyle(color: Colors.cyan, fontSize: 30, letterSpacing: 2.0),
            ),

            SizedBox(height: 30.0),
            Text('E-mail:', style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 2.0, fontWeight: FontWeight.w800 ),
            ),
            Text('$_userEmail', style: TextStyle(color: Colors.cyan, fontSize: 30, letterSpacing: 2.0),
            ),


            SizedBox(height: 70.0),
            ElevatedButton(
              onPressed: () {Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                alignment: Alignment.center,

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
            ElevatedButton(onPressed: () async{
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthGate()),
              );
            },
                style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
                alignment: Alignment.center,

                backgroundColor: Colors.transparent.withOpacity(0.0),

                elevation: 0,
            ),
             child: Text('SignOut', style: TextStyle(fontFamily: 'LondrinaSketch', fontSize: 40, color: Colors.amber), ))

          ],
        ),
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
                      })
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
        title: Text("Choose your Destiny!", style: TextStyle(fontSize: 30, color: Colors.white),),
        backgroundColor: Colors.grey[900],
      ),

      body: Container(
        // Set the background image
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/DALL·E 2024-10-15 00.35.32 - A cartoonish wooden table top with visible texture, showing white scratch marks and drawings representing a broken heart. The words 'Truth or Dare' ar.webp"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TruthScreen()),
                );},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),

                  backgroundColor: Colors.transparent.withOpacity(0.8),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                child: Text(
                  'Truth',
                  style: TextStyle(
                    fontFamily: 'LondrinaSketch',
                    fontSize: 50,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DareScreen()),
                );},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  backgroundColor: Colors.transparent.withOpacity(0.8),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                child: Text(
                  'Dare',
                  style: TextStyle(
                    fontFamily: 'LondrinaSketch',
                    fontSize: 50,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NeverEver()),
                );},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  backgroundColor: Colors.transparent.withOpacity(0.8),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                child: Text(
                  'Never Have I Ever',
                  style: TextStyle(
                    fontFamily: 'LondrinaSketch',
                    fontSize: 50,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WouldYou()),
                );},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  backgroundColor: Colors.transparent.withOpacity(0.8),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                child: Text(
                  'Would You Rather',
                  style: TextStyle(
                    fontFamily: 'LondrinaSketch',
                    fontSize: 50,
                    color: Colors.purpleAccent,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Paranoia()),
                );},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  backgroundColor: Colors.transparent.withOpacity(0.8),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                child: Text(
                  'Paranoia',
                  style: TextStyle(
                    fontFamily: 'LondrinaSketch',
                    fontSize: 50,
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}