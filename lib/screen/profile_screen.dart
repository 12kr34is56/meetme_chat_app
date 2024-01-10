import 'dart:io';
import 'package:Meet_me/helper/dialog.dart';
import 'package:Meet_me/widget/button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../model/chat_model.dart';

class ProfileScreen extends StatefulWidget {
  final ChatModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9e6f9),
      appBar: AppBar(
        backgroundColor: const Color(0xfff9e6f9),
        title: Text("Profile Screen"),
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
                                fit: BoxFit.cover),
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: MaterialButton(
                        onPressed: () {
                          showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0),
                              ),
                            ),
                            context: context,
                            builder: (context) {
                              return ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0),
                                ),
                                child: buildBottomNavigationBar(),
                              );
                            },
                          );
                        },
                        child: Icon(
                          Icons.camera_alt,
                          size: 35,
                        ),
                        color: Colors.white,
                        shape: CircleBorder(),
                        height: MediaQuery.sizeOf(context).height * 0.065,
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

              //for updating the name of user
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: TextFormField(
                  initialValue: widget.user.name,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  // controller: emailController,
                  onSaved: (val) => APIs.me.name = val!,
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : "Required Name",
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        CupertinoIcons.person,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(width: 2.0))),
                ),
              ),

              //for updating the about of user
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: TextFormField(
                  initialValue: widget.user.about,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  // controller: emailController,
                  onSaved: (val) => APIs.me.about = val!,
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : "Required about",
                  decoration: InputDecoration(
                      prefixIcon: Icon(CupertinoIcons.quote_bubble),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(width: 2.0))),
                ),
              ),

              //for space
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.05,
              ),

              //for updating the data in fields
              Button(text: "Update",onPressed: (){
                if(_formkey.currentState!.validate()){
                  _formkey.currentState!.save();
                  APIs.updateUserInfo().then((value) {
                    Dialogs.showSnackBar(context, "Data update");
                  });
                }
              },),

              SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

              //logout button
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                          MediaQuery.sizeOf(context).width * 0.25,
                          MediaQuery.sizeOf(context).height * 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                     await  APIs.userActiveStatus(false);

                      APIs.googleSignOut(context);
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 25,
                    ),
                    label: Text(
                      "Logout",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.deepPurple,
      items: [
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () async {
              getImage(ImageSource.camera).then((value) {
                APIs.uploadImage(File(_image!.path));
                Navigator.pop(context);
              });
            },
            icon: Icon(
              Icons.cameraswitch_sharp,
              size: 40,
            ),
          ),
          label: "Camera",
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () async {
              getImage(ImageSource.gallery).then((value) {
                APIs.uploadImage(File(_image!.path));
                Navigator.pop(context);
              });
            },
            icon: Icon(
              Icons.cameraswitch_sharp,
              size: 40,
            ),
          ),
          label: "Folder",
        ),
      ],
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
