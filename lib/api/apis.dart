import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_settings/app_settings.dart';
import 'package:Meet_me/model/MessageModel.dart';
import 'package:Meet_me/model/chat_model.dart';
import 'package:Meet_me/screen/homeScreen.dart';
import 'package:Meet_me/screen/login_screen/email_login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import '../helper/dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class APIs {
  //for authentication
  static final auth = FirebaseAuth.instance;

  //for accessing the firestore
  static final store = FirebaseFirestore.instance;

  //for accessing the firestorage
  static final storage = FirebaseStorage.instance;

  //for accessing the firebase messaging
  static final fMessaging = FirebaseMessaging.instance;

  //to return  current user
  static User get user => auth.currentUser!;

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //for storing self info
  static late ChatModel me;

  //for google signing
  static handleGoogleAuth(BuildContext context) {
    Dialogs.progressButton(context);
    signInWithGoogle(context).then((user) async {
      //for hiding the navigator bar
      Navigator.pop(context);

      if (await APIs.userExist()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login success")));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        await APIs.createUser().then(
          (value) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login success"),
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    });
  }

  static Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      Dialogs.showSnackBar(context, e.toString());
      return null;
    }
  }

  //for google sign out
  static googleSignOut(BuildContext context) async {
    await auth.signOut();
    await GoogleSignIn().signOut().then(
          (value) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          ),
        );
  }

  //to check if user exist
  static Future<bool> userExist() async {
    return (await store.collection('users').doc(user.uid).get()).exists;
  }

  //for storing the current user information
  static Future<void> getSelfInfo(BuildContext context) async {
    await store.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatModel.fromJson(user.data()!);
        APIs.userActiveStatus(true);
        await getTokenp(context);
      } else {
        createUser().then((value) => getSelfInfo(context));
      }
    });
  }

  //getting user info update of profile
  static Future<void> updateUserInfo() async {
    await store
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  //to create the user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final userChat = ChatModel(
      image: user.photoURL.toString(),
      isActive: false,
      about: "Hey I am using the Meet me",
      name: user.displayName.toString(),
      createdAt: time,
      lastActive: time,
      id: user.uid,
      email: user.email.toString(),
      pushToken: "",
    );
    return await store.collection('users').doc(user.uid).set(userChat.toJson());
  }

  //update the profile user image
  static Future<void> uploadImage(File file) async {
    final ref = storage.ref('profile_image${user.uid}');
    await ref.putFile(file);

    //updating image in firebase database
    me.image = await ref.getDownloadURL();
    await store.collection('users').doc(user.uid).update({'image': me.image});
  }

  //get all users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return store
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //get chatting user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatModel chatu) {
    return store
        .collection('users')
        .where('id', isEqualTo: chatu.id)
        .snapshots();
  }

  //see if user is online or not
  static Future<void> userActiveStatus(bool isOnline) async {
    store.collection('users').doc(user.uid).update({
      'is_active': isOnline,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }
//update message
  static Future<void> updateMessage(MessageModel message, String updatedMsg) async {
    await store
        .collection('chats/${getConversationId(message.youId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  static Future<void> deleteMessage(MessageModel message) async {
    await store
        .collection('chats/${getConversationId(message.youId)}/messages/')
        .doc(message.sent)
        .delete();
    if(message.type == dataType.image || message.type == dataType.doc) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> getTokenp(BuildContext context) async {
    //requesting the for first time for allowing the notification in mobiles
    final NotificationSettings settings = await fMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }

    //to get token
    await fMessaging.getToken().then((value) async {
      log("token: $value");
      if (value != null) {
        me.pushToken = value;
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatModel chatModel, String message) async {
    try {
      final body = {
        "to": chatModel.pushToken,
        'notification': {
          "title": chatModel.name,
          "body": message,
          "android_channel_id": "chats",
        }
      };
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var response = await post(url, body: jsonEncode(body), headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            "key=AAAAx0KeTpk:APA91bE-isBf8N1GAcoXxGfSl7hA0aDZzJFOD_TdvcM2EGzqm1DXd9AvNISdPkPaaDN3yVb_9I_7y8w4PSWSkyaSLEeMcD8G46lDoePNPHJp6pUD8uLJNQTnHXd2CgahbxPbrIQvjW1K"
      });
    } catch (e) {
      log("send Notification $e");
    }
  }

  ///***********Chat screen api**********

  //get conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? "${user.uid}_$id"
      : "${id}_${user.uid}";

  //get all the user chat message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatModel chatModel) {
    return store
        .collection('chats/${getConversationId(chatModel.id)}/messages/')
        .orderBy("sent", descending: true)
        .snapshots();
  }

  // sending message to user
  static Future<void> sendMessage(
      ChatModel chatModel, String msgs, dataType type) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    MessageModel message = MessageModel(
        meId: user.uid,
        msg: msgs,
        read: "",
        youId: chatModel.id,
        type: type,
        sent: time);
    await APIs.store
        .collection('chats/${getConversationId(chatModel.id)}/messages/')
        .doc(time)
        .set(message.toJson())
        .then((value) => sendPushNotification(chatModel, message.msg));
  }

  //update the status of user of message read or not
  static Future<void> updateMessageReadStatus(MessageModel message) async {
    await store
        .collection('chats/${getConversationId(message.meId)}/messages/')
        .doc(message.sent)
        .update({"read": DateTime.now().microsecondsSinceEpoch.toString()});
  }

  //get last message of user for showing in user card
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatModel chatModel) {
    return store
        .collection('chats/${getConversationId(chatModel.id)}/messages/')
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  //get Image for message chat
  static Future<void> uploadImageInMessage(
      ChatModel chatUser, File file) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final ref = storage.ref('images/${getConversationId(chatUser.id)}/$time');
    await ref.putFile(file);
    final downloadImage = await ref.getDownloadURL();
    await sendMessage(chatUser, downloadImage, dataType.image);
  }

  static Future<void> uploadDocInMessage(ChatModel chatUser, File file) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final ref = storage.ref('docs/${getConversationId(chatUser.id)}/$time');
    await ref.putFile(file);
    final downloadDoc = await ref.getDownloadURL();
    await sendMessage(chatUser, downloadDoc, dataType.doc);
  }
}
