
import 'package:flutter/material.dart';

class Dialogs{
  static  showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.up,
        elevation: 5,
        backgroundColor: Colors.deepPurple.shade200,
        content: Text(message,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18),),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  static  progressButton(BuildContext context){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}