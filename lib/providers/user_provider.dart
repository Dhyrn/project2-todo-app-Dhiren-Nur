import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  String? _currentUserId;
  List<Map<String, dynamic>> _otherUsers = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get otherUsers => _otherUsers;
  bool get isLoading => _isLoading;

  void updateCurrentUser(String? userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    if (userId != null) _listenToOtherUsers();
  }

  void _listenToOtherUsers() {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    _userService.getOtherUsers(_currentUserId!).listen((users) {
      _otherUsers = users;
      _isLoading = false;
      notifyListeners();
    });
  }
}
