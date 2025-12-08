class ApiConstants {
  // Base URL is already configured in DioClient
  
  // Auth endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  
  // User/Profile endpoints
  static const String profile = 'user/profile';
  static const String updateProfile = 'user/profile';
  
  // Doctor endpoints
  static const String doctors = 'doctor/index';
  static const String doctorDetails = 'doctor/show';
  static const String searchDoctors = 'doctor/doctor-search';
  
  // Appointment endpoints
  static const String appointments = 'appointment/index';
  static const String createAppointment = 'appointment/store';
  static const String appointmentDetails = 'appointment/show';
  static const String cancelAppointment = 'appointment/cancel';
  
  // Specialization endpoints
  static const String specializations = 'specialization/index';
}
