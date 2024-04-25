import 'package:flutter/material.dart';
import 'package:notes/database/syncCloud.dart';

class CloudProvider extends ChangeNotifier {
  bool _isSyncToCloud = true;

  bool get isSync => _isSyncToCloud;

  Future<void> setIsSync(bool newData) async {
    _isSyncToCloud = newData;
    notifyListeners();
  }
}
