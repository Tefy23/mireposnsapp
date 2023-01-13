import 'package:flutter/material.dart';

class MyProvider with ChangeNotifier {
  String _url = "";
  String get myUrl => _url;

  set url(String newtest) {
    _url = newtest;
    //notifyListeners();
  }
}
