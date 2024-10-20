import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

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

class Truth extends ChangeNotifier {
  String truth = "Loading...";

  Future<void> fetch() async {
    final url = Uri.parse("https://api.truthordarebot.xyz/v1/truth");

    try {
      final HttpClient client = HttpClient();
      final HttpClientRequest request = await client.getUrl(url);
      final HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody);
        final ques = Ques.fromJson(json);
        truth = ques.question;
      } else {
        truth = "Failed to load question";
      }
    } catch (e) {
      truth = "Error loading question";
    }

    notifyListeners();
  }
}

class TruthScreen extends StatefulWidget {
  @override
  _TruthScreenState createState() => _TruthScreenState();
}

class _TruthScreenState extends State<TruthScreen> {
  final Truth ques = Truth();

  @override
  void initState() {
    super.initState();
    ques.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Truth"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
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
                  "Your truth question is:\n\n${ques.truth}",
                  style: TextStyle(
                    fontSize: 38,
                    color: Colors.white,
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
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TruthScreen()),
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
