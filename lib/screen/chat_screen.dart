import 'dart:io';
import 'package:Meet_me/api/apis.dart';
import 'package:Meet_me/helper/my_data_utils.dart';
import 'package:Meet_me/model/chat_model.dart';
import 'package:Meet_me/screen/user_profile_screen.dart';
import 'package:Meet_me/widget/message_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/MessageModel.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textController = TextEditingController();
  List<MessageModel> userMessageList = [];
  bool isEmoji = false;
  File? _image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getUserInfo(widget.user);
    APIs.userActiveStatus(true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (isEmoji) {
            setState(() {
              isEmoji = !isEmoji;
            });
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Scaffold(
          backgroundColor: const Color(0xfff9e6f9),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessage(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        if (data != null) {
                          userMessageList = data
                              .map((e) => MessageModel.fromJson(e.data()))
                              .toList();
                        }

                        if (userMessageList.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.zero,
                            itemCount: userMessageList.length,
                            itemBuilder: (context, index) {
                              return MessageCard(
                                message: userMessageList[index],
                              );
                            },
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error: ${snapshot.error}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              "Say hi 😸",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w700),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
              textBar(),
              if (isEmoji)
                SizedBox(
                  height:
                      isEmoji ? MediaQuery.sizeOf(context).height * 0.35 : null,
                  child: EmojiPicker(
                    textEditingController: textController,
                    config: Config(
                      bgColor: const Color(0xfff9e6f9),
                      columns: 8,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  //for appbar
  Widget _appBar() {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffb12ca1),
              Color(0xfff067f9),
              Color(0xfffc31f2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UserProfileScreen(user: widget.user)));
          },
          child: StreamBuilder(
              stream: APIs.getUserInfo(widget.user),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                final data = snapshot.data?.docs;
                final listp =
                    data?.map((e) => ChatModel.fromJson(e.data())).toList() ??
                        [];
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 29,
                        color: Colors.white,
                      ),
                    ),

                    //for space
                    const SizedBox(width: 5),

                    //for image in the profile
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(
                            MediaQuery.sizeOf(context).height * 0.3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.sizeOf(context).height * 0.3),
                        child: CachedNetworkImage(
                          width: MediaQuery.sizeOf(context).height * 0.065,
                          height: MediaQuery.sizeOf(context).height * 0.065,
                          fit: BoxFit.cover,
                          imageUrl: listp.isNotEmpty
                              ? listp[0].image
                              : widget.user.image,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),

                    //for space
                    const SizedBox(width: 15),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          listp.isNotEmpty ? listp[0].name : widget.user.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                        Text(
                          listp.isNotEmpty
                              ? listp[0].isActive
                                  ? "online"
                                  : MyDateUtils.getLastActiveTime(
                                      context: context,
                                      lastActiveTime: listp[0].lastActive)
                              : MyDateUtils.getLastActiveTime(
                                  context: context,
                                  lastActiveTime: widget.user.lastActive),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ],
                    )
                  ],
                );
              }),
        ),
      ),
    );
  }

  //for input text field
  Widget textBar() {
    return SafeArea(
      bottom: isEmoji ? false : true,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height * 0.075,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 2,
                  bottom: 2,
                  left: 2,
                  right: 1,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purpleAccent, width: 1.9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  height: MediaQuery.sizeOf(context).height,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.smiley, size: 29),
                        onPressed: () {
                          setState(() {
                            isEmoji = !isEmoji;
                            FocusScope.of(context).unfocus();
                          });
                        },
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: TextField(
                          onTap: () {
                            setState(() {
                              isEmoji = false;
                              FocusScope.of(context).unfocus();
                            });
                          },
                          controller: textController,
                          decoration: const InputDecoration(
                            hintText: "Type a message",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          getDocument();
                        },
                        icon: const Icon(Icons.attach_file, size: 29),
                      ),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: "camera",
                            child: Row(
                              children: [
                                Icon(Icons.camera),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Take a Photo"),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: "gallery",
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.folder),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Choose from Gallery"),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == "camera") {
                            getImage(ImageSource.camera).then((value) {
                              APIs.uploadImageInMessage(widget.user, _image!);
                            });
                          } else if (value == "gallery") {
                            getMultipleImage(ImageSource.gallery);
                          }
                        },
                        child: const Icon(Icons.camera_alt, size: 29),
                      ),
                      const SizedBox(
                        width: 9,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //sending message button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2, top: 2),
                child: Container(
                  width: MediaQuery.sizeOf(context).height * 0.5,
                  height: MediaQuery.sizeOf(context).height * 0.45,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purpleAccent, width: 2),
                  ),
                  child: IconButton(
                    color: Colors.purpleAccent,
                    disabledColor: Colors.purpleAccent,
                    focusColor: Colors.purpleAccent,
                    onPressed: () {
                      APIs.sendMessage(
                          widget.user, textController.text, dataType.text);
                      textController.clear();
                    },
                    icon: const Icon(
                      Icons.send,
                      size: 45,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      if (kDebugMode) {
        print("No Image Selected");
      }
    }
  }

  Future<void> getMultipleImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 40);
    if (images.isNotEmpty) {
      for (var image in images) {
        APIs.uploadImageInMessage(widget.user, File(image.path));
      }
    }
  }

  Future<void> getDocument() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      APIs.uploadDocInMessage(widget.user, file);
    }
  }
}
