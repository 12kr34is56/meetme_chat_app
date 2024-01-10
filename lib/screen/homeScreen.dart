import 'dart:developer';
import 'package:Meet_me/api/apis.dart';
import 'package:Meet_me/screen/profile_screen.dart';
import 'package:Meet_me/widget/user_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../model/chat_model.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  List<ChatModel> user = [];
  List<ChatModel> searchUser = [];
  bool isSearching = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo(context);
    SystemChannels.lifecycle.setMessageHandler((message){
      log("System \n ${message}");
      if (APIs.auth.currentUser != null) {   if (message.toString().contains('resume')) APIs.userActiveStatus(true);
          if (message.toString().contains('inactive')) {
            APIs.userActiveStatus(false);
          }

      }

      return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
          onWillPop: () {
            if(isSearching ){
              setState(() {
                isSearching = !isSearching;
              });
              return Future.value(false);
            }else{//if user exist show the dialog box
              return showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Are you sure?'),
                    content: Text('Do you want to exit an App'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Yes'),
                      ),
                    ],
                  )).then((value) => value as bool);
            }

          },
          child: Scaffold(
            backgroundColor: const Color(0xfff9e6f9),
            drawerEnableOpenDragGesture: true,

            //appBar is used to create a appbar in the app
            appBar: AppBar(
              toolbarHeight: MediaQuery.sizeOf(context).height*0.058,
              backgroundColor: const Color(0xff8c34e3),
              automaticallyImplyLeading: false,
              title: isSearching ? SizedBox(
                width:  MediaQuery.sizeOf(context).width*0.6,
                height: MediaQuery.sizeOf(context).height*0.055,
                child: TextField(
                  scrollPadding: EdgeInsets.zero,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search,color: Colors.deepPurple,size: 26,),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    fillColor: Colors.white,
                    enabled: true,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val){
                    searchUser.clear();

                    for(var i in user){
                      if(i.name.toLowerCase().contains(val.toLowerCase())){
                        searchUser.add(i);
                        setState(() {
                          searchUser;
                        });
                      }
                    }
                  },
                ),
              ): Text('Meet Me',style: TextStyle(color: Colors.white),),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  },
                  icon: isSearching ? Icon(Icons.close,size: 29,) : Icon(Icons.search),
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(user: APIs.me,)));
                  },
                ),
              ],
            ),

            //body is used to create a body in the app
            body: StreamBuilder(
              stream: APIs.getAllUser(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    user  = data?.map((e) => ChatModel.fromJson(e.data())).toList() ??[];
                    if(user.isNotEmpty){
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: isSearching ? searchUser.length : user.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return  UserCard(user: isSearching ? searchUser [index]:user[index]);

                        },
                      );
                    }else{
                      return Center(child: Text("No connection found"),);
                    }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
