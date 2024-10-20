import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';  // Importing dart:io for HttpClient

class Ques {
  final String id;
  final String type;
  final String rating;
  final String question;

  Ques({required this.id, required this.type, required this.rating, required this.question});

  factory Ques.fromJson(Map<String, dynamic> json) {
    return Ques(
      id: json['id'],
      type: json['type'],
      rating: json['rating'],
      question: json['question'],
    );
  }
}

class Rather extends ChangeNotifier {
  String rather = "Loading...";

  Future<void> fetch() async {
    final url = Uri.parse("https://api.truthordarebot.xyz/api/wyr");

    try {
      final HttpClient client = HttpClient();
      final HttpClientRequest request = await client.getUrl(url);
      final HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody);
        final ques = Ques.fromJson(json);
        rather = ques.question;
      } else {
        rather = "Failed to load question";
      }
    } catch (e) {
      rather = "Error loading question";
    }

    notifyListeners();
  }
}

class WouldYou extends StatefulWidget {
  @override
  _WouldYouState createState() => _WouldYouState();
}

class _WouldYouState extends State<WouldYou> {
  final Rather ques = Rather();

  @override
  void initState() {
    super.initState();
    ques.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Would you Rather"),
        backgroundColor: Colors.white,  // AppBar background white
        iconTheme: IconThemeData(color: Colors.black),  // Back button color
      ),
      body: Container(
        color: Colors.white,  // Body background white
        child: Center(
          child: AnimatedBuilder(
            animation: ques,
            builder: (context, _) {
              return ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  "Would you rather:\n\n${ques.rather}",
                  style: TextStyle(
                    fontSize: 38,
                    color: Colors.white,  // Text color must be white for ShaderMask to work
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
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
        title: Text("Main Screen"),
        backgroundColor: Colors.white,  // AppBar background white
        iconTheme: IconThemeData(color: Colors.black),  // Back button color
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WouldYou()),
            );
          },
          child: Text("Go to Truth Screen"),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MainScreen(),
  ));
}
