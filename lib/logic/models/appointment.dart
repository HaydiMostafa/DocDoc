import 'doctor.dart';

class Appointment {
  final String? id;
  final Doctor doctor;
  final DateTime date;
  final String time;
  final String? notes;
  final AppointmentStatus status;
  final DateTime? createdAt;
  final int? doctorId;
  final String? appointmentType;

  Appointment({
    this.id,
    required this.doctor,
    required this.date,
    required this.time,
    this.notes,
    this.status = AppointmentStatus.upcoming,
    this.createdAt,
    this.doctorId,
    this.appointmentType,
  });

  bool get isUpcoming => status == AppointmentStatus.upcoming;
  bool get isPast => status == AppointmentStatus.past;
  bool get isCancelled => status == AppointmentStatus.cancelled;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString(),
      doctor: json['doctor'] != null 
          ? Doctor.fromJson(json['doctor']) 
          : Doctor(
              name: json['doctor_name'] ?? 'Unknown Doctor',
              specialty: json['specialty'] ?? '',
              rating: 4.5,
              image: '',
              biography: '',
              hospital: '',
              contact: '',
            ),
      date: json['appointment_date'] != null 
          ? DateTime.parse(json['appointment_date'])
          : DateTime.now(),
      time: json['appointment_time'] ?? json['time'] ?? '',
      notes: json['notes'] ?? json['note'] ?? '',
      status: _statusFromString(json['status']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      doctorId: json['doctor_id'] as int?,
      appointmentType: json['appointment_type'] ?? json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId ?? doctor.id,
      'appointment_date': date.toIso8601String().split('T')[0],
      'appointment_time': time,
      'notes': notes,
      'status': status.name,
      'appointment_type': appointmentType,
    };
  }

  static AppointmentStatus _statusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'upcoming':
      case 'scheduled':
      case 'confirmed':
        return AppointmentStatus.upcoming;
      case 'past':
      case 'completed':
        return AppointmentStatus.past;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.upcoming;
    }
  }

  Appointment copyWith({
    String? id,
    Doctor? doctor,
    DateTime? date,
    String? time,
    String? notes,
    AppointmentStatus? status,
    DateTime? createdAt,
    int? doctorId,
    String? appointmentType,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      doctorId: doctorId ?? this.doctorId,
      appointmentType: appointmentType ?? this.appointmentType,
    );
  }
}

enum AppointmentStatus { upcoming, past, cancelled }
