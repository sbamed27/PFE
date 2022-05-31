import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wssup_covid19/main.dart';

import 'Models/user.dart';

class AuthService {
  AuthService();

  AppUser _userFormFirebaseUser(User user) {
    return AppUser(uid: user.uid);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.idTokenChanges();

  Future login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) return _userFormFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future<Object?> signUp(String email, String password) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        DocumentReference ref =
            FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser?.uid);
            ref.set({
          'uid': ref.id,
          'email': email,
          'password': password,
        });
      });
      return "Signed Up";
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future logOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
