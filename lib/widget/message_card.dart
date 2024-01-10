import 'package:Meet_me/api/apis.dart';
import 'package:Meet_me/helper/my_data_utils.dart';
import 'package:Meet_me/model/MessageModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
class MessageCard extends StatefulWidget {
  final MessageModel message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe =APIs.user.uid == widget.message.meId;
    return InkWell(
      onLongPress: (){
        _showBottomSheetClipboard(isMe);
      },
      child: isMe ? greenBox() : blueBox(),
    );
  }

  Widget greenBox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              constraints: BoxConstraints(
                  minWidth: MediaQuery.sizeOf(context).width * 0.25,
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                  minHeight: MediaQuery.sizeOf(context).height * 0.06),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 1.5),
                  color: Color(0xff85ee8c),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15))),
              child: Stack(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 2, left: 3, right: 3, bottom: 15),
                      child: renderMessage()),
                  SizedBox(
                    height: 10,
                  ),
                  Positioned(
                    right: 25,
                    bottom: 1,
                    child: Text(
                      MyDateUtils.formattedTime(
                          context: context, time: widget.message.sent),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Positioned(
                      right: 1,
                      bottom: 1,
                      child: widget.message.read.isEmpty
                          ? Icon(
                              Icons.done_all,
                              size: 20,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.done_all,
                              size: 20,
                              color: Colors.blue,
                            ))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget blueBox() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              constraints: BoxConstraints(
                  minWidth: MediaQuery.sizeOf(context).width * 0.25,
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                  minHeight: MediaQuery.sizeOf(context).height * 0.06),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1.5),
                  color: Color(0xff85e9ee),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              child: Stack(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 2, left: 3, right: 3, bottom: 15),
                      child: renderMessage()),
                  Positioned(
                    left: 1,
                    bottom: 1,
                    child: Text(
                      MyDateUtils.getLastMessageTime(
                          context: context, time: widget.message.sent),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  showDocument(String url) async {
    await launchUrl(Uri.parse(url));
  }

  Widget renderMessage() {
    switch (widget.message.type.name) {
      case 'text':
        return Text(
          widget.message.msg,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        );

      case 'doc':
        return ElevatedButton.icon(
            onPressed: () {
              showDocument(widget.message.msg);
            },
            icon: Icon(Icons.file_download),
            label: Text('Download Document'));
      case 'image':
        return Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(13)),
            child: CachedNetworkImage(
                imageUrl: widget.message.msg, fit: BoxFit.cover),
          ),
        );
      default:
        return Text('Unknown message type');
    }
  }

  void _showBottomSheetClipboard(isMe) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,

          children:[
            Column(
              children: [

                //toggle bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.005,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),



                //copy button
            if(widget.message.type == dataType.text)
                ListTile(
                  leading: Icon(
                    Icons.copy,
                    color: Colors.blue,
                  ),
                  title: Text('Copy'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value) {
                      Navigator.pop(context);

                    });

                    // APIs.copyToClipboard(widget.message.msg);
                  },
                ),

                //divider
                Divider(
                  color: CupertinoColors.systemGrey3,
                  thickness: 1,
                  height: MediaQuery.sizeOf(context).height * 0.02,
                  indent: MediaQuery.sizeOf(context).width * 0.03,
                  endIndent: MediaQuery.sizeOf(context).width * 0.03,
                ),


                //delete button
                if(isMe)
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: Text('Delete'),
                    onTap: () {
                      _delete();
                      // APIs.deleteMessage(widget.message);
                    },
                  ),


                if(widget.message.type.name == 'text' &&isMe )
                //edit button
                  ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    title: Text('Edit'),
                    onTap: () {
                      _edit();
                      // APIs.deleteMessage(widget.message);
                    },
                  ),

                //divider
                if(isMe)
                Divider(
                  color: CupertinoColors.systemGrey3,
                  thickness: 1,
                  height: MediaQuery.sizeOf(context).height * 0.02,
                  indent: MediaQuery.sizeOf(context).width * 0.02,
                  endIndent: MediaQuery.sizeOf(context).width * 0.03,
                ),

                //sent time
                ListTile(
                  leading: Icon(
                    Icons.visibility,
                    color: Colors.blue,
                  ),
                  title: Text('Sent'),
                  trailing: Text(
                    MyDateUtils.getSentTime(
                      context: context,
                      lastActiveTime: widget.message.read,
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                //read time
                ListTile(
                  leading: Icon(
                    Icons.visibility,
                    color: Colors.green,
                  ),
                  title: Text('Read'),
                  trailing: Text(
                    widget.message.read.isNotEmpty
                        ? MyDateUtils.getReadTime(
                      context: context,
                      lastActiveTime: widget.message.read,
                    )
                        : 'Not Read',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ]
        );
      },
    );
  }

  void _delete() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Message'),
            content: Text('Are you sure you want to delete this message?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    APIs.deleteMessage(widget.message).then((value) {
                     //for alert box
                      Navigator.pop(context);
                      //for bottom sheet
                      Navigator.pop(context);
                    });

                  },
                  child: Text('Delete')),
            ],
          );
        });
  }



  void _edit() {
    String updateMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Message'),
            content: TextFormField(
              initialValue: updateMsg,
              onChanged: (value) {
                  updateMsg = value;
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    APIs.updateMessage(widget.message, updateMsg).then((value){
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                    
                  },
                  child: Text('Update')),
            ],
          );
        });
  }
}
