import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


/*
* This is entry point for the app.
* */
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: new AuthScreen(),
    );
  }
}

//region :AuthScreen

/*
* Class for Auth screen which has option of 'Sign In' and 'Sign Out'
* */
class AuthScreen extends StatefulWidget {
  @override
  AuthScreenState createState() {
    return new AuthScreenState();
  }
}

class AuthScreenState extends State<AuthScreen> {
  //Obtain FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Obtain GoogleSignIn instance
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  //Function to provide sign in functionality and return instance of Firebase user.
  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    FirebaseUser user = await _auth.signInWithGoogle(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    print('User name: ${user.displayName}');
    return user;
  }

  //Function to provide sign out functionality
  void _signOut() {
    googleSignIn
        .signOut();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Firebase Authentication'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(24.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new RaisedButton(
              onPressed: () =>
                  _signIn()
                      .then((FirebaseUser user) => print(user))
                      .catchError((onError) => print(onError)),
              child: new Text(
                'Sign In',
                style: new TextStyle(color: Colors.white),
              ),
              color: Colors.green,
            ),
            new Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(
              onPressed: _signOut,
              child: new Text(
                'Sign Out',
                style: new TextStyle(color: Colors.white),
              ),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
//endregion