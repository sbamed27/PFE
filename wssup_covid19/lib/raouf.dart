import 'package:flutter/material.dart';

class Raouf extends StatefulWidget {
  const Raouf({Key? key}) : super(key: key);

  @override
  State<Raouf> createState() => _RaoufState();
}

class _RaoufState extends State<Raouf> {

  String myText='Hi';
  void changing(){
    myText='Hey';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Raouf bar"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
        children: [
          Text(myText),
          TextButton(onPressed: (){setState(() {
            changing();
          });}, child: const Text('Change'))
        ],
      ),),
    );
  }
}
