class ChatModel {
  ChatModel({
    required this.image,
    required this.isActive,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.lastActive,
    required this.id,
    required this.email,
    required this.pushToken,
  });
  late  String image;
  late  bool isActive;
  late  String about;
  late  String name;
  late  String createdAt;
  late  String lastActive;
  late  String id;
  late  String email;
  late  String pushToken;

  ChatModel.fromJson(Map<String, dynamic> json){
    image = json['image'];
    isActive = json['is_active'];
    about = json['about'];
    name = json['name'];
    createdAt = json['created_at'];
    lastActive = json['last_active'];
    id = json['id'];
    email = json['email'];
    pushToken = json['push_token'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['is_active'] = isActive;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['last_active'] = lastActive;
    data['id'] = id;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}
