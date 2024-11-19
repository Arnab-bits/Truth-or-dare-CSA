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

// Dare Question Notifier
class DareNotifier extends StateNotifier<AsyncValue<String>> {
  DareNotifier() : super(AsyncValue.loading());

  Future<void> fetchDare() async {
    state = AsyncValue.loading();
    try {
      final response = await http.get(
        Uri.parse("https://api.truthordarebot.xyz/v1/dare"),
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

// Dare Provider
final dareProvider = StateNotifierProvider<DareNotifier, AsyncValue<String>>((ref) {
  return DareNotifier();
});

// Liked Questions Provider
final likedQuestionsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('liked_dares')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => doc['question'] as String).toList());
});

class DareScreen extends ConsumerStatefulWidget {
  const DareScreen({Key? key}) : super(key: key);

  @override
  _DareScreenState createState() => _DareScreenState();
}

class _DareScreenState extends ConsumerState<DareScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch a new dare when the screen is first opened
    Future.microtask(() => ref.read(dareProvider.notifier).fetchDare());
  }

  @override
  Widget build(BuildContext context) {
    final dareAsyncValue = ref.watch(dareProvider);
    final likedQuestionsAsync = ref.watch(likedQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Dare"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: dareAsyncValue.when(
            loading: () => CircularProgressIndicator(),
            error: (err, _) => Text("Error: $err"),
            data: (dare) {
              // Check if the current dare is liked
              final isLiked = likedQuestionsAsync.whenOrNull(
                  data: (likedQuestions) => likedQuestions.contains(dare)) ??
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
                      "Your dare question is:\n\n$dare",
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
                                .collection('liked_questions');

                            if (!isLiked) {
                              // Add to liked dares
                              await collection.add({
                                'question': dare,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                            } else {
                              // Remove from liked dares
                              final snapshot = await collection
                                  .where('question', isEqualTo: dare)
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
                              ref.read(dareProvider.notifier).fetchDare(),
                          child: Text('New Dare'),
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
