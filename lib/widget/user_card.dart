import 'package:Meet_me/api/apis.dart';
import 'package:Meet_me/model/MessageModel.dart';
import 'package:Meet_me/screen/user_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Meet_me/model/chat_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helper/my_data_utils.dart';
import '../screen/chat_screen.dart';

class UserCard extends StatefulWidget {
  final ChatModel user;
  const UserCard({super.key, required this.user});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  List userList = [];
  MessageModel? message;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Card(
          color: Color(0xffffc9fd),
          margin: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list = data
                        ?.map((e) => MessageModel.fromJson(e.data()))
                        .toList() ??
                    [];
                if (list.isNotEmpty) message = list[0];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                  user: widget.user,
                                )));
                  },
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.sizeOf(context).height * 0.3),
                          border:
                              Border.all(color: Color(0xffd534c9), width: 2)),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            MediaQuery.sizeOf(context).height *
                                                0.15),
                                        child: CachedNetworkImage(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.3,
                                          width: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.3,
                                          fit: BoxFit.fill,
                                          imageUrl: widget.user.image,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: Icon(
                                            CupertinoIcons.info,
                                            color: Colors.white,
                                            size: 34,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserProfileScreen(
                                                          user: widget.user,
                                                        )));
                                          },
                                        ),
                                      ),
                                      Positioned(
                                          // bottom: 10,
                                          top: 9,
                                          left: 0,
                                          child: Text(
                                            widget.user.name,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18),
                                          ))
                                    ],
                                  ),
                                );
                              });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.sizeOf(context).height * 0.3),
                          child: CachedNetworkImage(
                            width: MediaQuery.sizeOf(context).height * 0.055,
                            height: MediaQuery.sizeOf(context).height * 0.055,
                            fit: BoxFit.cover,
                            imageUrl: widget.user.image,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    title: Text(widget.user.name),
                    subtitle: renderMessage(),
                    trailing: message == null
                        ? null
                        : message!.read.isEmpty &&
                                APIs.user.uid != message!.meId
                            ? cardContainer(context)
                            : Text(MyDateUtils.getLastMessageTime(
                                context: context, time: message!.sent)),
                  ),
                );
              }),
        ));
  }

  Container cardContainer(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.02,
      width: MediaQuery.sizeOf(context).height * 0.02,
      decoration: BoxDecoration(
          color: Color(0xFFD404E5),
          borderRadius:
              BorderRadius.circular(MediaQuery.sizeOf(context).height * 0.01)),
    );
  }
  Widget renderMessage() {
    switch (message?.type.name) {
      case 'text':
        return Text(
          message!.msg,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        );

      case 'doc':
        return Text('Document');
      case 'image':
        return Text('image');
      default:
        return Text(widget.user.about);
    }
  }
}
