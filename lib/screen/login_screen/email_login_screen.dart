import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';


import '../../api/apis.dart';
import '../../helper/dialog.dart';
import '../../widget/button.dart';
import '../homeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [

          Positioned(child: LottieBuilder.asset(
            'images/lottieAnimatiob.json',
            fit: BoxFit.fill,
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,),
          ),
          Positioned(
            left: width*0.1,
            right: width*0.1,
            top: height*0.05,
            child:  Text('Welcome to Meet me',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 30),),),

          Positioned(
           bottom: height *0.1,
            left: width * 0.03,
            right: width * 0.03,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffffffff),
                minimumSize: Size(width * 0.9, height * 0.07),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                APIs.handleGoogleAuth(context);
              },
              icon: Image(
                height: height * 0.045,
                image: const AssetImage('images/google.png'),
              ),
              label: RichText(
                  text: const TextSpan(
                    text: 'Login in with ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    children: [
                      TextSpan(
                        text: 'Google',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}