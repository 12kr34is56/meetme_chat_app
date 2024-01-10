import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;


  final void Function()? onPressed;

   Button({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.9,
      height: MediaQuery.of(context).size.height*0.08,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        color: Colors.deepPurple.shade400,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
