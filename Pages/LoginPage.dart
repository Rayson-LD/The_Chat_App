import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_organization/Pages/HomePage.dart';
import 'package:meme_organization/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key : key);
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googlesigin = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;
  bool isLoggedIn = false;
  bool isLoading = false;
  FirebaseUser currentUser;
  void initState()
  {
    super.initState();
    isSignedIn();
  }
  void isSignedIn() async
  {
    this.setState(() {
      isLoggedIn = true;
    });
    preferences = await SharedPreferences.getInstance();

    isLoggedIn = await googlesigin.isSignedIn();
    if(isLoggedIn)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId : preferences.getString("id"))));
      }
    this.setState(() {
      isLoading = false;
    });

    this.setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors : [Colors.lightBlueAccent,Colors.purpleAccent],
            )
          ),
          alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Meme Organization",style: TextStyle(fontSize: 40.0,color: Colors.white,fontFamily: "Signatra"),
                ),
                GestureDetector(
                  onTap : SigninAuth,
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height :80.0),
                        Container(
                          width: 270.0,
                            height: 65.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/signin_button.png"),
                              fit: BoxFit.cover,
                            ),

                          ),
                        ),
                        Padding(padding: EdgeInsets.all(1.0),
                        child: isLoading ? circularProgress() : Container(),)
                      ],
                    ),
                  ),
                )
              ],
            ),
        ),
      );
  }
Future<Null> SigninAuth() async{
    preferences = await SharedPreferences.getInstance();
    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googlesigin.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credentials = GoogleAuthProvider.getCredential(idToken: googleAuth.idToken,accessToken: googleAuth.accessToken);
    FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credentials)).user;
    if(firebaseUser != null)
      {
          final QuerySnapshot resultQuery = await Firestore.instance.collection("users").where("id",isEqualTo: firebaseUser.uid).getDocuments();
          final List<DocumentSnapshot> documentSnapshot = resultQuery.documents;

          if(documentSnapshot.length == 0)
            {
              Firestore.instance.collection("users").document(firebaseUser.uid).setData({
                "nickname" : firebaseUser.displayName,
                "photoUrl" : firebaseUser.photoUrl,
                "aboutMe" : "This is Me !!",
                "id": firebaseUser.uid,
                "createdAt" : DateTime.now().millisecondsSinceEpoch.toString(),
                "chattingWith" : null,
              });
              currentUser = firebaseUser;
              await preferences.setString("id", currentUser.uid);
              await preferences.setString("nickname", currentUser.displayName);
              await preferences.setString("photoUrl", currentUser.photoUrl);
            }
          else
            {
              currentUser = firebaseUser;
              await preferences.setString("id", documentSnapshot[0]["id"]);
              await preferences.setString("nickname", documentSnapshot[0]["nickname"]);
              await preferences.setString("aboutMe", documentSnapshot[0]["aboutMe"]);
              await preferences.setString("photoUrl", documentSnapshot[0]["photoUrl"]);
            }
          Fluttertoast.showToast(msg: "Sign in Successfull");
          this.setState(() {
            isLoading = false;
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
      }
    else
    {
      Fluttertoast.showToast(msg: "Sign in Failed");
      this.setState(() {
        isLoading = false;
      });
    }
      }

}
