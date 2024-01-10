
import 'package:flutter/material.dart';

class MyDateUtils{


  //get formatted time for message sending
  static String formattedTime({required BuildContext context ,required String time}){
    final date = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final formattedTime = TimeOfDay.fromDateTime(date).format(context);

    // Determine AM or PM

    return formattedTime;
  }

  //get formatted time for last message
  static String getLastMessageTime({required BuildContext context ,required String time}){
    final sent = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final now = DateTime.now();
    if(sent.day == now.day && sent.month == now.month && sent.year == now.year){
      final formattedTime = TimeOfDay.fromDateTime(sent).format(context);

      return formattedTime;
    }
    return "${sent.day} ${_getMonth(sent)}";
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActiveTime}) {
    final i = int.tryParse(lastActiveTime) ?? -1;
    if (i == -1) {
      return "Last time not available";
    }
    DateTime time = DateTime.fromMicrosecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      return "Last seen today at $formattedTime";
    }
    if ((now.difference(time).inHours / 24).round() == 1) {
      return "Last seen yesterday at $formattedTime";
    }

    String month = _getMonth(time);
    return "Last seen on ${time.day} $month at $formattedTime";
  }

  //for seen and read time
   static String getSentTime(
      {required BuildContext context, required String lastActiveTime}) {
    final i = int.tryParse(lastActiveTime) ?? -1;
    if (i == -1) {
      return "Not time available";
    }
    DateTime time = DateTime.fromMicrosecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      return "today sent at $formattedTime";
    }
    if ((now.difference(time).inHours / 24).round() == 1) {
      return "sent yesterday at $formattedTime";
    }

    String month = _getMonth(time);
    return "sent on ${time.day} $month at $formattedTime";
  }

  // for read time

  static String getReadTime(
      {required BuildContext context, required String lastActiveTime}) {
    final i = int.tryParse(lastActiveTime) ?? -1;
    if (i == -1) {
      return "Not time available";
    }
    DateTime time = DateTime.fromMicrosecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      return "today read at $formattedTime";
    }
    if ((now.difference(time).inHours / 24).round() == 1) {
      return "read yesterday at $formattedTime";
    }

    String month = _getMonth(time);
    return "read on ${time.day} $month at $formattedTime";
  }

  //for making the time in months
  static _getMonth(DateTime sent){
    switch (sent.month){
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
    }
    return "NA";
  }

}