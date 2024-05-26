class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;

//  Default contructor
  UserModel({this.uid, this.fullname, this.email, this.profilepic});

//Named Constructor
// map->object
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
  }
  //function obj->map
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic
    };
  }
}
