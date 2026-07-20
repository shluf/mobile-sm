import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  final List<User> _users = [];
  List<User> get users => _users;

  User? _selectedUser;
  User? get selectedUser => _selectedUser;

  int _currentPage = 1;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFirstLoad = true;
  bool get isFirstLoad => _isFirstLoad;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void selectUser(User user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    if (!_isFirstLoad) notifyListeners();

    try {
      final response = await _userService.getUsers(page: _currentPage);
      
      _users.addAll(response.data);
      _hasMore = response.hasMore;
      _currentPage++;
      _isLoading = false;
      _isFirstLoad = false;
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isFirstLoad = false;
      _errorMessage = 'Failed to load users. Please try again.';
      notifyListeners();
    }
  }

  Future<void> refreshUsers() async {
    _users.clear();
    _currentPage = 1;
    _hasMore = true;
    _isFirstLoad = true;
    _errorMessage = null;
    notifyListeners();
    
    await fetchUsers();
  }
}
