import 'dart:io';
import 'package:Meet_me/helper/my_data_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/dialog.dart';
import '../model/chat_model.dart';
import '../widget/button.dart';


class UserProfileScreen extends StatefulWidget {
  final ChatModel user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _image;
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9e6f9),
      appBar: AppBar(
        backgroundColor: const Color(0xfff9e6f9),
        title: Text(widget.user.name),
        iconTheme: IconThemeData(color: Colors.black, size: 26),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //for profile image
              Center(
                child: Stack(
                  children: [
                    _image != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                          MediaQuery.sizeOf(context).height * 0.15),
                      child: Image.file(
                          width: MediaQuery.sizeOf(context).height * 0.3,
                          height: MediaQuery.sizeOf(context).height * 0.3,
                          _image!.absolute,
                          fit: BoxFit.contain
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(
                          MediaQuery.sizeOf(context).height * 0.2),
                      child: CachedNetworkImage(
                        height: MediaQuery.sizeOf(context).height * 0.25,
                        width: MediaQuery.sizeOf(context).height * 0.25,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error),
                      ),
                    ),
                  ],
                ),
              ),

              //for space
              SizedBox(
                height: 15,
              ),

              //for Email id of user
              Text(
                widget.user.email,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
              ),

              //for space
              SizedBox(
                height: 15,
              ),

              //about
              RichText(text: TextSpan(
                  children: [
                    TextSpan(text: "About  ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontSize: 18)),
                    TextSpan(text: widget.user.about,style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w600,fontSize: 16)),
                  ]
              ),),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: RichText(text: TextSpan(
              children: [
                TextSpan(text: "Joined at  ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontSize: 18)),
                TextSpan(text: MyDateUtils.getLastMessageTime(context: context, time: widget.user.createdAt),style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w600,fontSize: 16)),
              ]
          ),)),
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
}
