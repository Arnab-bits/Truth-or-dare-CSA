import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

// Never Have I Ever Notifier
class NeverEverNotifier extends StateNotifier<AsyncValue<String>> {
  NeverEverNotifier() : super(AsyncValue.loading());

  Future<void> fetchEver() async {
    state = AsyncValue.loading();
    try {
      final response = await http.get(
        Uri.parse("https://api.truthordarebot.xyz/api/nhie"),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
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

// Never Have I Ever Provider
final neverEverProvider =
StateNotifierProvider<NeverEverNotifier, AsyncValue<String>>((ref) {
  return NeverEverNotifier();
});

// Liked Questions Provider
final likedQuestionsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('liked_nhie_questions')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => doc['question'] as String).toList());
});

class NeverEverScreen extends ConsumerStatefulWidget {
  const NeverEverScreen({Key? key}) : super(key: key);

  @override
  _NeverEverScreenState createState() => _NeverEverScreenState();
}

class _NeverEverScreenState extends ConsumerState<NeverEverScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch a new question when the screen is first opened
    Future.microtask(() =>
        ref.read(neverEverProvider.notifier).fetchEver());
  }

  @override
  Widget build(BuildContext context) {
    final neverEverAsyncValue = ref.watch(neverEverProvider);
    final likedQuestionsAsync = ref.watch(likedQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Never Have I Ever"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: neverEverAsyncValue.when(
            loading: () => CircularProgressIndicator(),
            error: (err, _) => Text("Error: $err"),
            data: (question) {
              // Check if the current question is liked
              final isLiked = likedQuestionsAsync.whenOrNull(
                  data: (likedQuestions) =>
                      likedQuestions.contains(question)) ??
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
                      "Never have I ever:\n\n$question",
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
                            final collection = FirebaseFirestore.instance.collection('liked_questions');

                            if (!isLiked) {
                              // Add to liked questions
                              await collection.add({
                                'question': question,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                            } else {
                              // Remove from liked questions
                              final snapshot = await collection
                                  .where('question', isEqualTo: question)
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
                              ref.read(neverEverProvider.notifier).fetchEver(),
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

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

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
              MaterialPageRoute(builder: (context) => const NeverEverScreen()),
            );
          },
          child: Text("Go to Never Have I Ever"),
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
