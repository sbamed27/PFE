import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../auth_services.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({Key? key}) : super(key: key);

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _pword = '';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: const Color(0xFF222831),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 380,
              height: 750,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onChanged: (value) => _email = value,
                        validator: (email) {
                          if (EmailValidator.validate(email!)) {
                            return null;
                          }
                          return "Email invalid";
                        }),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (value) => _pword = value,
                      obscureText: true,
                      validator: (value) =>
                          (value!.length >= 8) ? null : "Password invalid",
                    ),

                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: const Color(0xFF1ABAB0), // background (button) color
                          onPrimary: Colors.white, // foreground (text) color
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            AuthService().signUp(_email, _pword);
                            Navigator.pushNamed(context, '/dash');
                          }
                        },
                        child: const Text("Sign up")),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
