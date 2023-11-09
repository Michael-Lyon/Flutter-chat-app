import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  final _formKey = GlobalKey<FormState>();

  // password check function
  bool isPasswordValid(String? password) {
    // Define your password criteria
    if (password != null) {
      const minLength = 6;
      final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      final hasDigits = RegExp(r'[0-9]').hasMatch(password);
      final hasSpecialCharacters =
          RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);

      // Check if the password meets all criteria
      return password.length >= minLength &&
          hasUppercase &&
          hasLowercase &&
          hasDigits &&
          hasSpecialCharacters;
    }
    return false;
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ensure all fields are valid."),
        ),
      );
      return; // Stop processing if form validation fails
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        // Log users in
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Handle successful login (e.g., navigate to the next screen)
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Upload User's Profile picture to Firebase
        final storageRef = await FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredentials.user!.uid}.jpg");

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        // connect to actual db on FireBase
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({
          "username": _enteredUsername,
          "email": _enteredEmail,
          "image_url": imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message!),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(onSelectImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            }),
                          TextFormField(
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              labelText: "Email Address",
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return "Please enter a valid email address";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),

                          if(!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                                labelText: "Username",
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              enableSuggestions: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 4) {
                                  return "Please enter a valid useranme";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              contentPadding:  EdgeInsets.all(10),
                              labelText: "Password",
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (isPasswordValid(value)) {
                                return null;
                              }
                              return "Please enter a valid password(>6 characters)";
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_isLogin ? "Login" : "Signup"),
                            ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? "Don't have an account?"
                                : "Already have an account?"),
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator.adaptive()
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
