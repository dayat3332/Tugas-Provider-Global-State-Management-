import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String userName;

  UserModel({
    this.userName = "Default",
  });

  void changeUserName({required String newUserName}) {
    userName = newUserName;
    notifyListeners();
  }
}
