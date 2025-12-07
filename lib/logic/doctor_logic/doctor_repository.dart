import 'package:dio/dio.dart';
import 'package:doc_app_sw/core/constants/api_constants.dart';
import 'package:doc_app_sw/core/network/api_error.dart';
import 'package:doc_app_sw/core/network/api_exceptions.dart';
import 'package:doc_app_sw/core/network/api_services.dart';
import 'package:doc_app_sw/logic/models/doctor.dart';
import 'package:doc_app_sw/logic/models/specialization.dart';

class DoctorRepository {
  final ApiServices _apiServices = ApiServices();

  /// Get all doctors
  Future<List<Doctor>> getDoctors() async {
    try {
      final response = await _apiServices.get(ApiConstants.doctors);
      
      if (response is ApiError) {
        throw response;
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Doctor.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }

  /// Get doctor by ID
  Future<Doctor> getDoctorById(int id) async {
    try {
      final response = await _apiServices.get('${ApiConstants.doctorDetails}/$id');
      
      if (response is ApiError) {
        throw response;
      }

      return Doctor.fromJson(response['data']);
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }

  /// Search doctors by name or specialty
  Future<List<Doctor>> searchDoctors(String query) async {
    try {
      final response = await _apiServices.get(
        '${ApiConstants.searchDoctors}?name=$query',
      );
      
      if (response is ApiError) {
        throw response;
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Doctor.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }

  /// Get doctors by specialization
  Future<List<Doctor>> getDoctorsBySpecialization(int specializationId) async {
    try {
      final response = await _apiServices.get(
        '${ApiConstants.doctors}?specialization_id=$specializationId',
      );
      
      if (response is ApiError) {
        throw response;
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Doctor.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }

  /// Get all specializations
  Future<List<Specialization>> getSpecializations() async {
    try {
      final response = await _apiServices.get(ApiConstants.specializations);
      
      if (response is ApiError) {
        throw response;
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Specialization.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }
}
