class MessageModel {
  MessageModel({
    required this.meId,
    required this.msg,
    required this.read,
    required this.youId,
    required this.type,
    required this.sent,
  });
  late final String meId;
  late final String msg;
  late final String read;
  late final String youId;
  late final dataType type;
  late final String sent;

  MessageModel.fromJson(Map<String, dynamic> json){
    meId = json['meId'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    youId = json['youId'].toString();
    type = json['type'].toString() == 'text' ? dataType.text : json['type'].toString() == 'image' ? dataType.image : dataType.doc;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['meId'] = meId;
    data['msg'] = msg;
    data['read'] = read;
    data['youId'] = youId;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}
enum dataType{text , image, doc}