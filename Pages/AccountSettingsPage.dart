import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_organization/Widgets/ProgressWidget.dart';
import 'package:meme_organization/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController namecontroller;
  TextEditingController aboutcontroller;
  SharedPreferences preferences;
  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photoUrl = "";
  File imageAvatar;
  bool isLoading = false;
  final FocusNode namefocusNode = FocusNode();
  final FocusNode aboutfocusNode = FocusNode();
  @override
  void initstate()
  {
    super.initState();
    readDataFromLocal();
  }
  void  readDataFromLocal() async
  {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id");
    print(id);
    nickname = preferences.getString("nickname");
    aboutMe = preferences.getString("aboutMe");
    photoUrl = preferences.getString("photoUrl");
    namecontroller = TextEditingController(text: nickname);
    aboutcontroller = TextEditingController(text: aboutMe);
    setState(() {

    });
  }
  Future getImage() async{
    File  newimageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(newimageFile != null)
    {
      setState(() {

        this.imageAvatar = newimageFile;
        isLoading = true;
      });
    }
    ImageToFirestore();
  }
  Future ImageToFirestore() async {
    String mFilename = id;
    StorageReference reference = FirebaseStorage.instance.ref().child(mFilename);
    StorageUploadTask storageUploadTask = reference.putFile(imageAvatar);
    StorageTaskSnapshot snapshot;
    storageUploadTask.onComplete.then((value)
    {
      if(value.error == null)
      {
        snapshot = value;
        snapshot.ref.getDownloadURL().then((newImageUrl)
        {
          photoUrl = newImageUrl;
          Firestore.instance.collection("users").document(id).updateData({
            "photoUrl": photoUrl,
            "nickname": nickname,
            "aboutMe" : aboutMe,
          }).then((data)async{
            await preferences.setString("photoUrl", photoUrl);
            await preferences.setString("nickname", nickname);
            await preferences.setString("aboutMe", aboutMe);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Update Successfully");
          });
        },onError: (errorMsg)
        {

          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: errorMsg.toString());
        }
        );
      }
    },onError: (errorMsg)
    {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
    }
    );
  }
  updateData()
  {
    namefocusNode.unfocus();
    setState(() {
      isLoading = false;
    });
    Firestore.instance.collection("users").document(id).updateData({
      "nickname" : nickname,
      "photoUrl" : photoUrl,
      "aboutMe" : aboutMe,
    }).then((data) async{
      await preferences.setString("photoUrl", photoUrl);
      await preferences.setString("nickname", nickname);
      await preferences.setString("aboutMe", aboutMe);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Update Successfully");
    });
  }
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async
  {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    this.setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()),(Route<dynamic> route) => false);
  }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          iconTheme : IconThemeData(
            color : Colors.white,
          ),
          backgroundColor: Colors.lightBlueAccent,
          title: Text(
            "Account Settings",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(onPressed: readDataFromLocal, icon: Icon(Icons.refresh),color: Colors.white,)
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: Center(
                      child: Stack(
                        children: [
                          (imageAvatar == null)
                              ? (photoUrl != "")
                              ? Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(20.0),
                              ),
                              imageUrl: photoUrl,
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(125.0)),
                            clipBehavior: Clip.hardEdge,
                          )
                              : Icon(Icons.account_circle,size:100.0,color:Colors.grey)
                              : Material(
                            child: Image.file(
                              imageAvatar,
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(125.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          IconButton(onPressed: getImage, icon: Icon(Icons.camera_alt,size: 100.0,color: Colors.white.withOpacity(0.3),),padding: EdgeInsets.all(0.0),splashColor: Colors.transparent,highlightColor: Colors.grey,iconSize: 200.0,)
                        ],
                      ),
                    ),
                    width:double.infinity,
                    margin: EdgeInsets.all(20.0),
                  ),
                  //input fields
                  Column(
                    children: [
                      Padding(padding: EdgeInsets.all(1.0),child: isLoading? circularProgress():Container(),),
                      //username
                      Container(
                        child: Text(
                          "Profile Name",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 10.0,bottom: 5.0,top: 10.0),
                      ),
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Rayson",
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: namecontroller,
                            onChanged: (value){
                              nickname = value;
                            },
                            focusNode: namefocusNode,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0,right: 30.0),
                      ),
                      Container(
                        child: Text(
                          "About Me",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 10.0,bottom: 5.0,top: 10.0),
                      ),
                      Container(
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "About me .. ",
                              contentPadding: EdgeInsets.all(5.0),
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            controller: aboutcontroller,
                            onChanged: (value){
                              aboutMe = value;
                            },
                            focusNode: aboutfocusNode,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30.0,right: 30.0),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  //Update
                  Container(
                    child: FlatButton(
                      onPressed: updateData,
                      child: Text(
                        "Update",
                        style: TextStyle(fontSize: 10.0),
                      ),
                      color: Colors.lightBlueAccent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                    ),
                    margin: EdgeInsets.only(top: 15.0,bottom: 1.0),
                  ),
                  //logout
                  Padding(padding: EdgeInsets.only(left: 50.0,right: 50.0),
                    child: RaisedButton(
                      color: Colors.red,
                      onPressed: logoutUser ,
                      child: Text(
                        "Logout",
                        style: TextStyle(
                            color: Colors.white,fontSize: 14.0
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              padding: EdgeInsets.only(left: 15.0,right: 15.0),
            )
          ],
        ),
      );
    }

}

