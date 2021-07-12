import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meme_organization/Widgets/FullImageWidget.dart';
import 'package:meme_organization/Widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';

class Chat extends StatelessWidget {
  final String receiverid;
  final String receiverAvatar;
  final String receiverName;
  Chat({

    Key key,
    @required this.receiverid,
    @required this.receiverAvatar,
    @required this.receiverName,
});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              backgroundImage: CachedNetworkImageProvider(receiverAvatar),
            ),
          )
        ],
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text(
          receiverName,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(receiverid : receiverid, receiverAvatar : receiverAvatar,receiverName: receiverName),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverid;
  final String receiverAvatar;
  final String receiverName;

  ChatScreen({
  Key key,
  @required  this.receiverid,
    @required this.receiverAvatar,
    @required this.receiverName,
}) : super(key : key);
  @override
  State createState() => ChatScreenState(receiverid : receiverid, receiverAvatar : receiverAvatar, receiverName: receiverName);
}




class ChatScreenState extends State<ChatScreen> {
  final String receiverid;
  final String receiverAvatar;
  final String receiverName;
  final TextEditingController textController = TextEditingController();
  final ScrollController listController = ScrollController();
  final FocusNode focusnode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;
  File newimageFile;
  String imageUrl;
  SharedPreferences Preferences;
  String chatId;
  String id;
  var ListMessages;

  ChatScreenState({
    Key key,
    @required this.receiverid,
    @required this.receiverAvatar,
    @required this.receiverName,
  });

  @override
  void initState() {
    super.initState();
    focusnode.addListener(onFocusChange);
    isDisplaySticker = false;
    isLoading = false;
    chatId = "";
    readLocal();
  }

  readLocal() async {
    Preferences = await SharedPreferences.getInstance();
    id = Preferences.getString("id") ?? "";
    if (id.hashCode <= receiverid.hashCode) {
      chatId = '$id-$receiverid';
    }
    else {
      chatId = '$receiverid-$id';
      Firestore.instance.collection("users").document(id).updateData({

        'chattingWith': receiverid
      });
      setState(() {

      });
    }
  }

  onFocusChange() {
    //hide stickers
    if (focusnode.hasFocus) {
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: [
          Column(
            children: [
              createListMessages(),
              createInput(),

              //show stickers
              (isDisplaySticker ? showStickers() : Container()),
            ],
          ),

          createLoading(),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  createLoading() {
    return Positioned(
        child: isLoading ? circularProgress() : Container()
    );
  }

  Future<bool> onBackPress() {
    if (isDisplaySticker) {
      setState(() {
        isDisplaySticker = false;
      });
    }
    else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  Future uploadimageFile() async {
    newimageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (newimageFile != null) {
      isLoading = true;
    }
    String filename = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(
        "Chat Images").child(filename);
    StorageUploadTask storageUploadTask = reference.putFile(newimageFile);
    StorageTaskSnapshot snapshot = await storageUploadTask.onComplete;
    snapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Empty Message.Cannot be sent");
    }
    );
  }
  showStickers() {
    focusnode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
    return Container(
      child: Column(
        children: [
          //emojis
          Row(
            children: [
              FlatButton(onPressed: () => onSendMessage("mimi1", 2),
                  child: Image.asset("assets/images/mimi1.gif", width: 50,
                    height: 50,
                    fit: BoxFit.cover,)),
              FlatButton(onPressed: () => onSendMessage("mimi2", 2),
                  child: Image.asset("assets/images/mimi2.gif", width: 50,
                    height: 50,
                    fit: BoxFit.cover,)),
              FlatButton(onPressed: () => onSendMessage("mimi3", 2),
                  child: Image.asset("assets/images/mimi3.gif", width: 50,
                    height: 50,
                    fit: BoxFit.cover,)),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: [
              FlatButton(onPressed: () => onSendMessage("mimi4", 2),
                  child: Image.asset("assets/images/mimi4.gif", width: 50,
                    height: 50,
                    fit: BoxFit.cover,)),
              FlatButton(onPressed: () => onSendMessage("mimi5", 2),
                  child: Image.asset("assets/images/mimi5.gif", width: 50,
                    height: 50,
                    fit: BoxFit.cover,)),
              FlatButton(onPressed: () => onSendMessage("mimi6", 2),
                  child: Image.asset("assets/images/mimi6.gif", width: 50,
                    height: 50,
                    fit: BoxFit.cover,)),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: [
              FlatButton(onPressed: () => onSendMessage("mimi7", 2),
                  child: Image.asset("assets/images/mimi7.gif", width: 50,
                    height: 50,
                    fit: BoxFit.cover,)),
              FlatButton(onPressed: () => onSendMessage("mimi8", 2),
                  child: Image.asset("assets/images/mimi8.gif", width: 50,
                    height: 50,
                    fit: BoxFit.cover,)),
              FlatButton(onPressed: () => onSendMessage("mimi9", 2),
                  child: Image.asset("assets/images/mimi9.gif", width: 50,
                    height: 50,
                    fit: BoxFit.cover,)),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white
      ),
      padding: EdgeInsets.all(5.0),
      height: 180,
    );
  }
  void onSendMessage(String Msg, int type) {
    //0 for msg
    //1 for image
    //2 for sticker

    if (Msg != "") {
      textController.clear();
      var docRef = Firestore.instance.collection("messages")
          .document(chatId)
          .collection(chatId)
          .document(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString());
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(docRef, {
          "idFrom": id,
          "idTo": receiverid,
          "timestamp": DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          "content": Msg,
          "type": type,
        },);
      });
      listController.animateTo(
          0.0, duration: Duration(milliseconds: 30), curve: Curves.easeOut);
    }
    else {
      Fluttertoast.showToast(msg: "Empty Message.Cannot be sent");
    }
  }


  createListMessages() {
    return Flexible(child: chatId == "" ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),)
    )
        : StreamBuilder(stream:
    Firestore.instance.collection("messages")
        .document(chatId).collection(chatId)
        .orderBy("timestamp", descending: true)
        .limit(20).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
                )
            );
          }
          else {
            ListMessages = snapshot.data.documents;
            return ListView.builder(padding:
            EdgeInsets.all(10.0),
                itemBuilder: (context, index) =>
                    createItem(index, snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
                reverse: true,
                controller: listController);
          }
        })
    );
  }

  bool isLastMsgLeft(int index) {
    if ((index > 0 && ListMessages != null &&
        ListMessages[index - 1]["idFrom"] == id) || index == 0) {
      return true;
    }
    else {
      return false;
    }
  }

  bool isLastMsgRight(int index) {
    if ((index > 0 && ListMessages != null &&
        ListMessages[index - 1]["idFrom"] != id) || index == 0) {
      return true;
    }
    else {
      return false;
    }
  }

  Widget createItem(int index, DocumentSnapshot document)
  {
    //messages - right side
    if(document["idFrom"] == id)
      {
        return Row(
          children: [
            document["type"] == 0
            ?Container(
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(right: 75.0),
                 child: Text(
                    document["content"],
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  ),
                    Padding(padding: EdgeInsets.only(left: 100.0),
                  child :Text(
                    DateFormat("hh:mm:aa").format(DateTime.fromMillisecondsSinceEpoch(int.parse(document["timestamp"])),
                    ),
                    style: TextStyle(
                      color: Colors.white,fontStyle: FontStyle.italic,fontWeight: FontWeight.w400,
                    ),
                  ),
              ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              width: 200,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20 : 10,right: 10),
            )
            //for image
                : document["type"] == 1
            ?Container(
              child: FlatButton(
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context,url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
                      ),
                      width: 200,
                      height: 200,
                      padding: EdgeInsets.all(70),
                      decoration: BoxDecoration(
                        color: Colors.grey,borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    errorWidget: (context,url,error) => Material(
                      child: Image.asset("assets/images/img_not_available.jpeg",width: 200,height: 200,fit: BoxFit.cover,),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: document["content"],
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhoto(url: document["content"])));
                },
              ),
              margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20 : 10,right: 10),
            )
            //stickers
                :Container(
                    child: Image.asset("assets/images/${document["content"]}.gif",
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,),
              margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20 : 10,right: 10),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      }
    //Receiver Messages
    else
      {
            return Container(
              child: Column(
                children: [
                  Row(
                          children: [
                            //receiver prof image
                            (document["idFrom"] != id) ? Material(
                            child: CachedNetworkImage(
                              placeholder: (context,url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
                                ),
                                width: 35,
                                height: 35,
                                padding: EdgeInsets.all(10),
                              ),
                              imageUrl: receiverAvatar,
                              fit: BoxFit.cover,
                              imageBuilder: (context, imageProvider) => Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            ) :
                            Container(width: 35),

                            //display messages
                             document["type"] == 0
                                ?Container(
                              child: Column(
                               children: [
                                 Padding(padding: EdgeInsets.only(right: 75.0),
                                   child: Text(
                                     document["content"],
                                     style: TextStyle(
                                       color: Colors.black,
                                       fontWeight: FontWeight.w400,
                                     ),
                                   ),
                                 ),
                                 Padding(padding: EdgeInsets.only(left: 100.0),
                                   child :Text(
                                     DateFormat("hh:mm:aa").format(DateTime.fromMillisecondsSinceEpoch(int.parse(document["timestamp"])),
                                     ),
                                     style: TextStyle(
                                       color: Colors.white,fontStyle: FontStyle.italic,fontWeight: FontWeight.w400,
                                     ),
                                   ),
                                 ),
                               ],
                              ),
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.green,borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.only(left: 10),
                            )
                              //Image Msg
                              : document["type"] == 1
                            ?Container(
                              child: FlatButton(
                                child: Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context,url) => Container(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),
                                      ),
                                      width: 200,
                                      height: 200,
                                      padding: EdgeInsets.all(70),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    errorWidget: (context,url,error) => Material(
                                      child: Image.asset("",width: 200,height: 200,fit: BoxFit.cover,),
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    imageUrl: document["content"],
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: (){
                                 Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhoto(url: document["content"])));
                                },
                              ),
                              margin: EdgeInsets.only(left: 10),
                            )
                             //gif
                              :Container(
                                child: Image.asset("assets/images/${document["content"]}.gif",
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,),
                                  margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20 : 10,right: 10),
                                  )

                          ],

                  ),
                  //time
                  isLastMsgLeft(index) ?
                      Container(
                        width: 150,
                        height: 25,
                        child: Text(
                          DateFormat("dd MMMM - hh:mm:aa").format(DateTime.fromMillisecondsSinceEpoch(int.parse(document["timestamp"])),
                        ),
                          style: TextStyle(
                            color: Colors.white,fontSize: 14.0,fontStyle: FontStyle.italic
                          ),
                          textAlign: TextAlign.center,
                      ),
                        margin: EdgeInsets.only(left:100,top:50,bottom:50),
                        
                        decoration: BoxDecoration(
                            color: Colors.black,
                          borderRadius: BorderRadius.circular(8)
                        ),
                      )
                      :Container(

                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
                      ),
              margin: EdgeInsets.only(bottom: 10),
            );
      }
  }
  createInput()
  {
  return Container(
    child: Row(
      children: [
        Material(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            child: IconButton(onPressed:uploadimageFile, icon: Icon(Icons.image),color: Colors.lightBlueAccent,),
          ),
          color: Colors.white,
        ),
        //emoji button
        Material(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            child: IconButton(onPressed:showStickers, icon: Icon(Icons.face),color: Colors.lightBlueAccent,),
          ),
          color: Colors.white,
        ),
        //message
        Flexible(
          child: Container(
            child: TextField(
              style: TextStyle(
                color: Colors.black,fontSize: 15.0
              ),
              controller: textController,
              focusNode: focusnode,
              decoration: InputDecoration.collapsed(hintText: "Type a message ...",hintStyle: TextStyle(color: Colors.grey)),

            ),
          ),
        ),
        //send button
        Material(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            child: IconButton(onPressed:() => onSendMessage(textController.text,0), icon: Icon(Icons.send),color: Colors.lightBlueAccent,),
          ),
          color: Colors.white,
        ),
      ],
    ),
    width: double.infinity,
    height: 50.0,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Colors.grey,
          width: 0.5
        )
      ),
          color: Colors.white
    ),

  );
  }

}
