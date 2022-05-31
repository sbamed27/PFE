import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:wssup_covid19/Dashboard/questions.dart';

class Answers extends StatefulWidget {
  const Answers({Key? key}) : super(key: key);

  @override
  State<Answers> createState() => _AnswersState();
}

class _AnswersState extends State<Answers> {
  Widget question(BuildContext context, String? idQuest, String? data,
      String? idUser, int vote) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF7E93B2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .where('uid', isEqualTo: idUser)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator.adaptive();
                      }
                      return Text(
                        snapshot.data!.docs.first.get('email').toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Questions')
                    .where('idQuestion', isEqualTo: idQuest)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator.adaptive();
                  }
                  return ReadMoreText(
                    snapshot.data!.docs.first.get('text').toString(),
                    style: const TextStyle(color: Colors.white),
                    trimLines: 2,
                    colorClickableText: Colors.pink,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Show more',
                    trimExpandedText: 'Show less',
                  );
                },
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              vote.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                //isLikedFunc(idQuest!);
              },
              child: const Text(
                'J\'aime',
                style: TextStyle(
                  //color: Colors.blue,
                  //color: isLikedFunc(idQuest!) ? Colors.blue : Colors.white,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget answer2(BuildContext ctx, DocumentSnapshot doc) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF7E93B2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .where('uid', isEqualTo: doc['idUser'])
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator.adaptive();
                  }
                  return Text(
                    snapshot.data!.docs.first.get('email').toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
          const SizedBox(
            height: 3,
          ),
          ReadMoreText(
            doc['text'],
            style: const TextStyle(color: Colors.white),
            trimLines: 2,
            colorClickableText: Colors.pink,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Show more',
            trimExpandedText: 'Show less',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _controller = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xFF222831),
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Column(
              children: [
                question(context, Questions.idQuestion, Questions.text,
                    Questions.idUser, Questions.vote),
                Flexible(
                  flex: 7,
                  child: Container(
                    margin: const EdgeInsets.only(left: 30),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Answers')
                          .where('idQuest', isEqualTo: Questions.idQuestion)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Loading");
                        }

                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            //itemExtent: 145,
                            itemBuilder: (context, index) =>
                                answer2(context, snapshot.data!.docs[index]));
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                              hintText: 'Ask here',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 3, color: Colors.blue),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 3, color: Colors.red),
                                borderRadius: BorderRadius.circular(15),
                              )),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          DocumentReference ref = FirebaseFirestore.instance
                              .collection("Answers")
                              .doc();
                          ref.set({
                            "idQuest": Questions.idQuestion,
                            "idAnswer": ref.id,
                            "idUser": FirebaseAuth.instance.currentUser?.uid,
                            "date_time": DateTime.now(),
                            "text": _controller.text,
                          });
                          FirebaseFirestore.instance
                              .collection("Questions")
                              .doc(Questions.idQuestion).update({
                            'answers':FieldValue.increment(1),
                          });
                          //_controller.clear();
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
