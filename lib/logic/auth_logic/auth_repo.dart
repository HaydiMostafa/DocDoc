import 'package:dio/dio.dart';
import 'package:doc_app_sw/core/constants/api_constants.dart';
import 'package:doc_app_sw/core/network/api_error.dart';
import 'package:doc_app_sw/core/network/api_exceptions.dart';
import 'package:doc_app_sw/core/network/api_services.dart';
import 'package:doc_app_sw/core/utils/pref_helper.dart';
import 'package:doc_app_sw/logic/models/user_model.dart';

class AuthRepo {
  final ApiServices apiServices = ApiServices();
  UserModel _currentUser = UserModel();
  UserModel get currentUser => _currentUser;


  /// Login user
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await apiServices.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });
      if (response is ApiError) {
        throw response;
      }

      final user = UserModel.fromJson(response['data']);
      if (user.token != null) {
        await PrefHelper.saveToken(user.token!);
      }
      _currentUser = user;
      return user;
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    }
  }

  /// Register new user
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? gender,
  }) async {
    try {
      final response = await apiServices.post(ApiConstants.register, {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
      });

      if (response is ApiError) {
        throw response;
      }

      final user = UserModel.fromJson(response['data']);
      if (user.token != null) {
        await PrefHelper.saveToken(user.token!);
      }
      _currentUser = user;
      return user;
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    }
  }

  /// Get user profile
  Future<UserModel?> getProfile() async {
    try {
      final response = await apiServices.get(ApiConstants.profile);

      if (response is ApiError) {
        throw response;
      }
      final data = response['data'];
      final userJson = (data is List && data.isNotEmpty) ? data.first : data;
      final user = UserModel.fromJson(userJson);
      _currentUser = user;
      return user;
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }

  /// Update user profile
  Future<UserModel?> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? gender,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (gender != null) body['gender'] = gender;

      final response = await apiServices.update(ApiConstants.updateProfile, body);

      if (response is ApiError) {
        throw response;
      }

      final user = UserModel.fromJson(response['data']);
      _currentUser = user;
      return user;
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await apiServices.post(ApiConstants.logout, {});
      await PrefHelper.clearToken();
      _currentUser = UserModel();
    } on DioException catch (e) {
      // Even if logout fails on server, clear local data
      await PrefHelper.clearToken();
      _currentUser = UserModel();
      throw ApiExceptions.handleError(e);
    }
  }
  
}
