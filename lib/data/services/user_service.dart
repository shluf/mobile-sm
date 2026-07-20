import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class UserService {
  static const String _usersEndpoint = '/users';

  Future<UserListResponse> getUsers({
    required int page,
    int perPage = AppConstants.perPage,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}$_usersEndpoint?page=$page&per_page=$perPage',
    );

    final response = await http.get(
      uri,
      headers: {
        'x-api-key': AppConstants.apiKey,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UserListResponse.fromJson(json);
    } else {
      throw Exception(
        'Failed to load users: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }
}

class UserListResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<User> data;

  const UserListResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.data,
  });

  bool get hasMore => page < totalPages;

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>;
    return UserListResponse(
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      data: rawData.map((e) => User.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
