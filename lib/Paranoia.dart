import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';

// Question Model
class Ques {
  final String id;
  final String type;
  final String rating;
  final String question;

  Ques({
    required this.id,
    required this.type,
    required this.rating,
    required this.question,
  });

  factory Ques.fromJson(Map<String, dynamic> json) {
    return Ques(
      id: json['id'],
      type: json['type'],
      rating: json['rating'],
      question: json['question'],
    );
  }
}

// Paranoia Question Notifier
class ParanoiaNotifier extends StateNotifier<AsyncValue<String>> {
  ParanoiaNotifier() : super(AsyncValue.loading());

  Future<void> fetchParanoia() async {
    state = AsyncValue.loading();
    final url = Uri.parse("https://api.truthordarebot.xyz/api/paranoia");

    try {
      final HttpClient client = HttpClient();
      final HttpClientRequest request = await client.getUrl(url);
      final HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody);
        final ques = Ques.fromJson(json);
        state = AsyncValue.data(ques.question);
      } else {
        state = AsyncValue.error(
          Exception("Failed to load question"),
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Paranoia Provider
final paranoiaProvider =
StateNotifierProvider<ParanoiaNotifier, AsyncValue<String>>((ref) {
  return ParanoiaNotifier();
});

// Liked Questions Provider
final likedParanoiaQuestionsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('liked_paranoia_questions')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => doc['question'] as String).toList());
});

// Paranoia Screen
class ParanoiaScreen extends ConsumerStatefulWidget {
  const ParanoiaScreen({Key? key}) : super(key: key);

  @override
  _ParanoiaScreenState createState() => _ParanoiaScreenState();
}

class _ParanoiaScreenState extends ConsumerState<ParanoiaScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch a new paranoia question when the screen is first opened
    Future.microtask(() =>
        ref.read(paranoiaProvider.notifier).fetchParanoia());
  }

  @override
  Widget build(BuildContext context) {
    final paranoiaAsyncValue = ref.watch(paranoiaProvider);
    final likedQuestionsAsync = ref.watch(likedParanoiaQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Paranoia"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: paranoiaAsyncValue.when(
            loading: () => CircularProgressIndicator(),
            error: (err, _) => Text("Error: $err"),
            data: (paranoiaQuestion) {
              // Check if the current paranoia question is liked
              final isLiked = likedQuestionsAsync.whenOrNull(
                  data: (likedQuestions) =>
                      likedQuestions.contains(paranoiaQuestion)) ??
                  false;

              return ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Your paranoia question is:\n\n$paranoiaQuestion",
                      style: TextStyle(
                        fontSize: 38,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                            size: 36,
                          ),
                          onPressed: () async {
                            final collection = FirebaseFirestore.instance
                                .collection('liked_paranoia_questions');

                            if (!isLiked) {
                              // Add to liked questions
                              await collection.add({
                                'question': paranoiaQuestion,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                            } else {
                              // Remove from liked questions
                              final snapshot = await collection
                                  .where('question', isEqualTo: paranoiaQuestion)
                                  .get();

                              for (var doc in snapshot.docs) {
                                await doc.reference.delete();
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(paranoiaProvider.notifier).fetchParanoia(),
                          child: Text('New Question'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Main Screen
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
              MaterialPageRoute(builder: (context) => ParanoiaScreen()),
            );
          },
          child: Text("Go to Paranoia Screen"),
        ),
      ),
    );
  }
}

void main() {
  runApp(ProviderScope(
    child: MaterialApp(
      home: MainScreen(),
    ),
  ));
}
