import 'package:dio/dio.dart';
import 'package:doc_app_sw/core/constants/api_constants.dart';
import 'package:doc_app_sw/core/network/api_error.dart';
import 'package:doc_app_sw/core/network/api_exceptions.dart';
import 'package:doc_app_sw/core/network/api_services.dart';
import 'package:doc_app_sw/logic/models/appointment.dart';

class AppointmentRepository {
  final ApiServices _apiServices = ApiServices();

  /// Get all appointments for the current user
  Future<List<Appointment>> getAppointments() async {
    try {
      final response = await _apiServices.get(ApiConstants.appointments);
      
      if (response is ApiError) {
        throw response;
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Appointment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }

  /// Create a new appointment
  Future<Appointment> createAppointment({
    required int doctorId,
    required String date,
    required String time,
    String? notes,
    String? appointmentType,
  }) async {
    try {
      final body = {
        'doctor_id': doctorId,
        'appointment_date': date,
        'appointment_time': time,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (appointmentType != null) 'appointment_type': appointmentType,
      };

      final response = await _apiServices.post(
        ApiConstants.createAppointment,
        body,
      );
      
      if (response is ApiError) {
        throw response;
      }

      return Appointment.fromJson(response['data']);
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }

  /// Get appointment details by ID
  Future<Appointment> getAppointmentById(String id) async {
    try {
      final response = await _apiServices.get(
        '${ApiConstants.appointmentDetails}/$id',
      );
      
      if (response is ApiError) {
        throw response;
      }

      return Appointment.fromJson(response['data']);
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }

  /// Cancel an appointment
  Future<void> cancelAppointment(String id) async {
    try {
      final response = await _apiServices.post(
        '${ApiConstants.cancelAppointment}/$id',
        {},
      );
      
      if (response is ApiError) {
        throw response;
      }
    } on DioException catch (e) {
      throw ApiExceptions.handleError(e);
    } catch (e) {
      throw ApiError(massage: e.toString());
    }
  }

  /// Get upcoming appointments
  Future<List<Appointment>> getUpcomingAppointments() async {
    try {
      final appointments = await getAppointments();
      final now = DateTime.now();
      
      return appointments.where((apt) {
        return apt.status == AppointmentStatus.upcoming &&
               (apt.date.isAfter(now) || 
                (apt.date.year == now.year &&
                 apt.date.month == now.month &&
                 apt.date.day == now.day));
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      rethrow;
    }
  }

  /// Get past appointments
  Future<List<Appointment>> getPastAppointments() async {
    try {
      final appointments = await getAppointments();
      final now = DateTime.now();
      
      return appointments.where((apt) {
        return apt.status == AppointmentStatus.past ||
               apt.status == AppointmentStatus.cancelled ||
               (apt.status == AppointmentStatus.upcoming && apt.date.isBefore(now));
      }).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      rethrow;
    }
  }
}
