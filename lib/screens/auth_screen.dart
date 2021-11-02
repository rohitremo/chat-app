import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  //instance of the auth objest which is automativally setup by firebase auth pacakage
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String username,
    File profileImage,
    bool isLogin,
  ) async {
    //data will come here from AuthForm ie email,pass etc
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password); //Login
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password); //Signup

        //for getting a reference to the storage, will create it on first run
        final ref = FirebaseStorage.instance
            .ref() //root bucket
            .child('user_image') //folder
            .child(authResult.user.uid + '.jpg'); //image name

        //to upload an Profileimage to the storage above
        await ref.putFile(profileImage);

        //will give a link to the profileImage from the fb storage
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('user')
            .doc(authResult.user.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': url, //saving the link of that profileImage url
        });
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials';
      if (err.message != null) {
        message = err.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err); //to see any error at the development
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
