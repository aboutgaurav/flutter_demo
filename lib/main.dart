import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/*
* This is entry point for the app.
* */
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
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
    googleSignIn.signOut();
  }

  //Function to Open Wallpaper screen
  void _openWallpaperScreen() {
    Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => SuperHeroListScreen()));
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
              onPressed: () => _signIn()
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
            new Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(
              onPressed: _openWallpaperScreen,
              child: new Text(
                'Super Heroes',
                style: new TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
//endregion

//region :WallpaperScreen
class SuperHeroListScreen extends StatefulWidget {
  @override
  _SuperHeroListScreenState createState() => _SuperHeroListScreenState();
}

class _SuperHeroListScreenState extends State<SuperHeroListScreen> {
  //SuperHeroes list
  List<DocumentSnapshot> superHeroList;

  //Obtain collectionReference
  final CollectionReference collectionReference =
      Firestore.instance.collection("images");

  StreamSubscription<QuerySnapshot> subscription;

  @override
  void initState() {
    super.initState();
    subscription = collectionReference.snapshots().listen((data) {
      //Code to update list data
      setState(() {
        superHeroList = data.documents;
      });
    });
  }

  @override
  void dispose() {
    //Remove subscription here
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Suminilist"),
        ),
        body: superHeroList != null
            ? new StaggeredGridView.countBuilder(
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 4,
                itemCount: superHeroList.length,
                itemBuilder: (context, i) {
                  String imgPath = superHeroList[i].data['url'];
                  return new Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.all(new Radius.circular(8.0)),
                    child: new InkWell(
                      onTap: () => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  new SuperHeroDetailsScreen(imgPath))),
                      child: new Hero(
                        tag: imgPath,
                        child: new FadeInImage(
                            placeholder: new AssetImage("assets/iron_man.png"),
                            fit: BoxFit.cover,
                            image: new NetworkImage(imgPath)),
                      ),
                    ),
                  );
                },
                staggeredTileBuilder: (i) =>
                    new StaggeredTile.count(2, i.isEven ? 2 : 3),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              )
            : new Center(
                child: new CircularProgressIndicator(),
              ));
  }
}

//endregion

//region :WallpaperDetailsScreen
class SuperHeroDetailsScreen extends StatelessWidget {
  //Flag to store image path
  String imgPath;

  SuperHeroDetailsScreen(this.imgPath);

  LinearGradient bgGradient = new LinearGradient(
    colors: [new Color(0x00000000), new Color(0x30000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SizedBox.expand(
        child: new Container(
          decoration: new BoxDecoration(gradient: bgGradient),
          child: Stack(
            children: <Widget>[
              new Align(
                alignment: Alignment.center,
                child: new Hero(tag: imgPath, child: Image.network(imgPath)),
              ),
              new Align(
                alignment: Alignment.topCenter,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new AppBar(
                      elevation: 0.0,
                      backgroundColor: Colors.transparent,
                      leading: new IconButton(
                          icon: new Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.of(context).pop()),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//endregion
