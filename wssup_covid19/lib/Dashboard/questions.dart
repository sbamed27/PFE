import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../main.dart';

class Questions extends StatefulWidget {
  static String idQuestion = '';
  static String text = '';
  static String idUser = '';
  static int vote = -1;

  const Questions({Key? key}) : super(key: key);

  @override
  State<Questions> createState() => _ForumState();
}

class _ForumState extends State<Questions> {
  String? _choice = 'recent';
  bool isLiked = false;

  //String questID = '';

  bool isLikedFunc(String idQst, String idUser) {
    bool flag = false;
    //List<String> likerslist = [];
    FirebaseFirestore.instance
        .collection('Questions')
        .doc(idQst)
        .get()
        .then((value) {
          print(idQst+" "+List.from(value.get('likers')).first);
      List.from(value.get('likers')).forEach((element) {
        if (element.toString() == idUser) flag = true;
        //likerslist.add(element.toString());
      });
    });/*
    likerslist.forEach((element) {
      if (element.toString() == idUser) flag = true;
    });*/
    //var likers = documentSnapshot.data()!['contacts'];
    return flag;
  }

  Widget nameCr(BuildContext ctx, DocumentSnapshot doc) {
    return question(
        ctx, doc['idQuestion'], doc['text'], doc['idUser'], doc['vote']);
  }

  Widget question(BuildContext context, String? idQuest, String? data,
      String? idUser, int vote) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //user
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF7E93B2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    //const Icon(Icons.photo),
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
                ReadMoreText(
                  data!,
                  style: const TextStyle(color: Colors.white),
                  trimLines: 2,
                  colorClickableText: Colors.pink,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Show more',
                  trimExpandedText: 'Show less',
                ),
              ],
            ),
          ),
          // question text
          //interaction buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                vote.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(idQuest!)
                      .update(
                    {
                      "likes": FieldValue.increment(
                        (isLikedFunc(idQuest, idUser!) ? (-1) : (1)),
                      ),
                    },
                  );
                  setState(() {
                    //liked = !liked;
                  });
                },
                child: Text(
                  'J\'aime',
                  style: TextStyle(
                    color: isLikedFunc(idQuest!, idUser!)
                        ? Colors.blue
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Questions.idQuestion = idQuest;
                  Questions.text = data;
                  Questions.idUser = idUser;
                  Questions.vote = vote;
                  Navigator.pushNamed(context, '/answers');
                },
                child: const Text(
                  'Répondre',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _controller = TextEditingController();
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Flexible(
              flex: 1,
              //width: MediaQuery.of(context).size.width,
              //height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Sort them by: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  DropdownButton<String>(
                      dropdownColor: Colors.grey,
                      underline: Container(),
                      value: _choice,
                      items: ["recent", "liked", "answered"]
                          .map<DropdownMenuItem<String>>(
                            (String _value) => DropdownMenuItem<String>(
                              value: _value,
                              // add this property an pass the _value to it
                              child: Text(
                                _value,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (_value) {
                        setState(() {
                          _choice = _value;
                        });
                      }),
                ],
              ),
            ),
            Flexible(
              flex: 8,
              //height: MediaQuery.of(context).size.height * 0.5,
              child: StreamBuilder(
                stream: _choice == 'recent'
                    ? FirebaseFirestore.instance
                        .collection('Questions')
                        .orderBy('date_time', descending: true)
                        .snapshots()
                    : _choice == 'liked'
                        ? FirebaseFirestore.instance
                            .collection('Questions')
                            .orderBy('vote', descending: true)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('Questions')
                            .orderBy('answers', descending: true)
                            .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("Loading");
                  }

                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      //itemExtent: 150,
                      itemBuilder: (context, index) =>
                          nameCr(context, snapshot.data!.docs[index]));
                },
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
                            borderSide:
                                const BorderSide(width: 3, color: Colors.blue),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(width: 3, color: Colors.red),
                            borderRadius: BorderRadius.circular(15),
                          )),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      DocumentReference ref = FirebaseFirestore.instance
                          .collection("Questions")
                          .doc();
                      ref.set({
                        "idQuestion": ref.id,
                        "idUser": FirebaseAuth.instance.currentUser?.uid,
                        "answers": 0,
                        "date_time": DateTime.now(),
                        "text": _controller.text,
                        "vote": 0,
                        "likers": [],
                      });
                      _controller.clear();
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
    );
  }
}
