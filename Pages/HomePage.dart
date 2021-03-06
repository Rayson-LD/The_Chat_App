import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:meme_organization/Pages/ChattingPage.dart';
import 'package:meme_organization/main.dart';
import 'package:meme_organization/models/user.dart';
import 'package:meme_organization/Pages/AccountSettingsPage.dart';
import 'package:meme_organization/Widgets/ProgressWidget.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);
  @override
  State createState() => HomeScreenState(currentUserId : currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  final String currentUserId;
  HomeScreenState({Key key, @required this.currentUserId});
  TextEditingController searchText = TextEditingController();
  Future<QuerySnapshot> futureSearchResult;
  HomePageHeader()
  {
    return AppBar(
      automaticallyImplyLeading: false,  //back button removal
        title : TextFormField(
          style: TextStyle(fontSize: 18.0, color: Colors.white),
          controller: searchText,
          decoration: InputDecoration(
            hintText: "Searchy Here ...",
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
              focusedBorder : UnderlineInputBorder(
  borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
  prefixIcon: Icon(Icons.person_pin,color : Colors.white,size: 30.0),
  suffixIcon: IconButton(onPressed: emptyTextFormField, icon: Icon(Icons.clear,color:Colors.white,))
        ),
          onFieldSubmitted: controlSearching,
        ),

      backgroundColor: Colors.lightBlue,

    );
  }
  controlSearching(String username)
  {
    Future<QuerySnapshot> allFoundUsers = Firestore.instance.collection("users").where("nickname", isGreaterThanOrEqualTo: username).getDocuments();
    setState(() {

      futureSearchResult = allFoundUsers;
    });
  }
  emptyTextFormField()
  {
    searchText.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomePageHeader(),
      body: futureSearchResult == null ? nouser()  : userpresent(),
    );
  }
  userpresent()
  {
    return FutureBuilder(
      future: futureSearchResult,
    builder: (context,dataSnapshot)
      {
        if(!dataSnapshot.hasData){
          return circularProgress();
        }
        List<UserResult> searchResult = [];
        dataSnapshot.data.documents.forEach((document)
        {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);

          if(currentUserId != document["id"])
            {
            searchResult.add(userResult);
            }
        });
          return ListView(children: searchResult,);
      },
    );
  }
  nouser()
  {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(Icons.group,color: Colors.lightBlueAccent,size: 200,),
            Text("Users",style: TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,),

          ],
        ),
      )
    );

  }
}


class UserResult extends StatelessWidget
{
  final User eachUser;
  UserResult(this.eachUser);
  @override
  Widget build(BuildContext context) {
      return Padding(padding: EdgeInsets.all(4.0),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              GestureDetector(
                onTap: (){sendUserToChatPage(context);},
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: CachedNetworkImageProvider(
                      eachUser.photoUrl
                    ),
                  ),
                  title: Text(
                    eachUser.nickname,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text("Joined : " + DateFormat("dd MMMM - hh:mm:aa").format(DateTime.fromMicrosecondsSinceEpoch(int.parse(eachUser.createdAt))),
                    style: TextStyle(color: Colors.grey,fontSize: 14.0,fontStyle: FontStyle.italic),
                  ),
                ),
              )
            ],
          ),
        ),
      );

  }
  sendUserToChatPage(BuildContext context)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(
        receiverid : eachUser.id,
        receiverAvatar : eachUser.photoUrl,
        receiverName : eachUser.nickname
    ))
    );
  }
}
