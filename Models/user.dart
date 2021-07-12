import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String nickname;
  final String aboutMe;
  final String photoUrl;
  final String createdAt;

  User({
    this.id,
    this.nickname,
    this.aboutMe,
    this.photoUrl,
    this.createdAt,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      photoUrl: doc['photoUrl'],
      nickname: doc['nickname'],
      aboutMe: doc['aboutMe'],
      createdAt: doc['createdAt'],
    );
  }
}