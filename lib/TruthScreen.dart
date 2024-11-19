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

class TruthNotifier extends StateNotifier<AsyncValue<String>> {
  TruthNotifier() : super(AsyncValue.loading());

  Future<void> fetchTruth() async {
    state = AsyncValue.loading();
    try {
      final response = await http.get(
          Uri.parse("https://api.truthordarebot.xyz/v1/truth")
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final ques = Ques.fromJson(json);
        state = AsyncValue.data(ques.question);
      } else {
        state = AsyncValue.error(
            Exception("Failed to load question"),
            StackTrace.current
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final truthProvider = StateNotifierProvider<TruthNotifier, AsyncValue<String>>((ref) {
  return TruthNotifier();
});

final likedQuestionsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('liked_questions')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => doc['question'] as String).toList()
  );
});

class TruthScreen extends ConsumerStatefulWidget {
  const TruthScreen({Key? key}) : super(key: key);

  @override
  _TruthScreenState createState() => _TruthScreenState();
}

class _TruthScreenState extends ConsumerState<TruthScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(truthProvider.notifier).fetchTruth()
    );
  }

  @override
  Widget build(BuildContext context) {
    final truthAsyncValue = ref.watch(truthProvider);
    final likedQuestionsAsync = ref.watch(likedQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Truth"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: truthAsyncValue.when(
            loading: () => CircularProgressIndicator(),
            error: (err, _) => Text("Error: $err"),
            data: (truth) {
              final isLiked = likedQuestionsAsync.whenOrNull(
                  data: (likedQuestions) => likedQuestions.contains(truth)
              ) ?? false;

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
                      "Your truth question is:\n\n$truth",
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

                              await collection.add({
                                'question': truth,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                            } else {

                              final snapshot = await collection
                                  .where('question', isEqualTo: truth)
                                  .get();

                              for (var doc in snapshot.docs) {
                                await doc.reference.delete();
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => ref.read(truthProvider.notifier).fetchTruth(),
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
              MaterialPageRoute(builder: (context) => const TruthScreen()),
            );
          },
          child: Text("Go to Truth Screen"),
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