import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';


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


class WouldYouRatherNotifier extends StateNotifier<AsyncValue<String>> {
  WouldYouRatherNotifier() : super(AsyncValue.loading());

  Future<void> fetchQuestion() async {
    state = AsyncValue.loading();
    final url = Uri.parse("https://api.truthordarebot.xyz/api/wyr");

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

final wouldYouRatherProvider =
StateNotifierProvider<WouldYouRatherNotifier, AsyncValue<String>>((ref) {
  return WouldYouRatherNotifier();
});


final likedQuestionsProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('liked_wyr_questions')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => doc['question'] as String).toList());
});


class WouldYouRatherScreen extends ConsumerStatefulWidget {
  const WouldYouRatherScreen({Key? key}) : super(key: key);

  @override
  _WouldYouRatherScreenState createState() => _WouldYouRatherScreenState();
}

class _WouldYouRatherScreenState extends ConsumerState<WouldYouRatherScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        ref.read(wouldYouRatherProvider.notifier).fetchQuestion());
  }

  @override
  Widget build(BuildContext context) {
    final questionAsyncValue = ref.watch(wouldYouRatherProvider);
    final likedQuestionsAsync = ref.watch(likedQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Would You Rather"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: questionAsyncValue.when(
            loading: () => CircularProgressIndicator(),
            error: (err, _) => Text("Error: $err"),
            data: (question) {

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
                      "Would you rather:\n\n$question",
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
                                .collection('liked_wyr_questions');

                            if (!isLiked) {

                              await collection.add({
                                'question': question,
                                'timestamp': FieldValue.serverTimestamp(),
                              });
                            } else {

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
                          onPressed: () => ref
                              .read(wouldYouRatherProvider.notifier)
                              .fetchQuestion(),
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
              MaterialPageRoute(builder: (context) => WouldYouRatherScreen()),
            );
          },
          child: Text("Go to 'Would You Rather' Screen"),
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
