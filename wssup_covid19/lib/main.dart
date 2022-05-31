import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wssup_covid19/Dashboard/dash.dart';
import 'Dashboard/answers.dart';
import 'Dashboard/questions.dart';
import 'Inscription/signUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  HttpOverrides.global = MyHttpOverrides();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/dash': (context) => const Dash(),
        '/questions': (context) => const Questions(),
        '/username': (context) => const UsernameScreen(),
        '/answers': (context) => const Answers(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User? loggedInUser;
  String _em = '';
  String _pw = '';
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //using this function you can use the credentials of the user
  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  Widget nameCr(BuildContext ctx, DocumentSnapshot doc) {
    return Text(doc['full_name']);
  }

  @override
  Widget build(BuildContext context) {
    //if (_auth.currentUser != null) _auth.signOut();
    return Scaffold(
      backgroundColor: const Color(0xFF222831),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            //color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          labelText: "Email",
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                          ),
                        ),
                        validator: (email) => EmailValidator.validate(email!)
                            ? null
                            : "Email invalid",
                        onChanged: (value) => _em = value,
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          labelText: "Password",
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        validator: (pass) =>
                            pass!.length >= 8 ? null : "Password invalid",
                        onChanged: (value) => _pw = value,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        margin: const EdgeInsets.symmetric(vertical: 25),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: const Color(0xFF1ABAB0),
                            // background (button) color
                            onPrimary: Colors.white, // foreground (text) color
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final String email = emailController.text.trim();
                              final String password =
                                  passwordController.text.trim();
                              await _auth.signInWithEmailAndPassword(
                                  email: email, password: password);
                              emailController.clear();
                              passwordController.clear();
                              Navigator.pushNamed(context, '/dash');
                            }
                          },
                          child: const Text("Connexion"),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF1ABAB0),
                      // background (button) color
                      onPrimary: Colors.white, // foreground (text) color
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/username');
                    },
                    child: const Text("Inscription"),
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
