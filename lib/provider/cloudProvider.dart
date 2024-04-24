import 'package:flutter/material.dart';

class CloudProvider extends ChangeNotifier {
  bool _isSyncToCloud = false;

  bool get isSync => _isSyncToCloud;

  void setIsSync(bool newData) {
    _isSyncToCloud = newData;
    notifyListeners();
  }
}