# API Documentation

This document describes the API layer implementation for the DocDoc application.

## Overview

The API layer provides comprehensive backend integration for the DocDoc doctor appointment application. It includes repositories for authentication, doctors, appointments, and specializations.

## Architecture

### Core Components

1. **ApiServices** (`lib/core/network/api_services.dart`)
   - Base service for making HTTP requests
   - Methods: `get()`, `post()`, `update()`, `delete()`
   - Handles error management and Dio exceptions

2. **ApiConstants** (`lib/core/constants/api_constants.dart`)
   - Centralized API endpoint definitions
   - Makes endpoint management easier

3. **DioClient** (`lib/core/network/dio_client.dart`)
   - Configured with base URL: `https://vcare.integration25.com/api/`
   - Automatic token injection for authenticated requests
   - Request/response interceptors

## API Endpoints

### Authentication (`AuthRepo`)

**Location:** `lib/logic/auth_logic/auth_repo.dart`

#### Login
```dart
Future<UserModel?> login(String email, String password)
```
- Endpoint: `POST /auth/login`
- Parameters: email, password
- Returns: UserModel with authentication token
- Automatically saves token to local storage

#### Register
```dart
Future<UserModel?> register({
  required String name,
  required String email,
  required String password,
  required String passwordConfirmation,
  String? phone,
  String? gender,
})
```
- Endpoint: `POST /auth/register`
- Parameters: name, email, password, password_confirmation, phone (optional), gender (optional)
- Returns: UserModel with authentication token

#### Get Profile
```dart
Future<UserModel?> getProfile()
```
- Endpoint: `GET /user/profile`
- Requires: Authentication token
- Returns: Current user's profile information

#### Update Profile
```dart
Future<UserModel?> updateProfile({
  String? name,
  String? email,
  String? phone,
  String? gender,
})
```
- Endpoint: `PUT /user/profile`
- Parameters: name, email, phone, gender (all optional)
- Returns: Updated UserModel

#### Logout
```dart
Future<void> logout()
```
- Endpoint: `POST /auth/logout`
- Clears local authentication token

### Doctors (`DoctorRepository`)

**Location:** `lib/logic/doctor_logic/doctor_repository.dart`

#### Get All Doctors
```dart
Future<List<Doctor>> getDoctors()
```
- Endpoint: `GET /doctor/index`
- Returns: List of all doctors

#### Get Doctor by ID
```dart
Future<Doctor> getDoctorById(int id)
```
- Endpoint: `GET /doctor/show/{id}`
- Parameters: doctor ID
- Returns: Detailed doctor information

#### Search Doctors
```dart
Future<List<Doctor>> searchDoctors(String query)
```
- Endpoint: `GET /doctor/doctor-search?name={query}`
- Parameters: search query (name or specialty)
- Returns: List of matching doctors

#### Get Doctors by Specialization
```dart
Future<List<Doctor>> getDoctorsBySpecialization(int specializationId)
```
- Endpoint: `GET /doctor/index?specialization_id={id}`
- Parameters: specialization ID
- Returns: List of doctors in that specialization

#### Get Specializations
```dart
Future<List<Specialization>> getSpecializations()
```
- Endpoint: `GET /specialization/index`
- Returns: List of all medical specializations

### Appointments (`AppointmentRepository`)

**Location:** `lib/logic/appointment_logic/appointment_repository.dart`

#### Get All Appointments
```dart
Future<List<Appointment>> getAppointments()
```
- Endpoint: `GET /appointment/index`
- Requires: Authentication
- Returns: All appointments for the current user

#### Create Appointment
```dart
Future<Appointment> createAppointment({
  required int doctorId,
  required String date,
  required String time,
  String? notes,
  String? appointmentType,
})
```
- Endpoint: `POST /appointment/store`
- Parameters:
  - doctorId: ID of the doctor
  - date: Appointment date (format: YYYY-MM-DD)
  - time: Appointment time
  - notes: Optional notes
  - appointmentType: Optional type (e.g., "in-person", "virtual")
- Returns: Created appointment

#### Get Appointment by ID
```dart
Future<Appointment> getAppointmentById(String id)
```
- Endpoint: `GET /appointment/show/{id}`
- Parameters: appointment ID
- Returns: Appointment details

#### Cancel Appointment
```dart
Future<void> cancelAppointment(String id)
```
- Endpoint: `POST /appointment/cancel/{id}`
- Parameters: appointment ID
- Cancels the specified appointment

#### Get Upcoming Appointments
```dart
Future<List<Appointment>> getUpcomingAppointments()
```
- Filters appointments to show only upcoming ones
- Sorted by date (earliest first)

#### Get Past Appointments
```dart
Future<List<Appointment>> getPastAppointments()
```
- Filters appointments to show past and cancelled ones
- Sorted by date (most recent first)

## Models

### Doctor Model
**Location:** `lib/logic/models/doctor.dart`

Properties:
- `id`: Doctor ID
- `name`: Doctor's name
- `specialty`: Medical specialty
- `rating`: Doctor's rating (0-5)
- `image`: Profile image URL
- `biography`: Doctor's biography
- `hospital`: Hospital/clinic name
- `contact`: Contact information
- `email`: Email address
- `phone`: Phone number
- `address`: Physical address
- `price`: Appointment price
- `specializationId`: ID of the specialization

Methods:
- `fromJson()`: Parse from API response
- `toJson()`: Convert to JSON

### Appointment Model
**Location:** `lib/logic/models/appointment.dart`

Properties:
- `id`: Appointment ID
- `doctor`: Associated Doctor object
- `date`: Appointment date
- `time`: Appointment time
- `notes`: Optional notes
- `status`: AppointmentStatus (upcoming, past, cancelled)
- `createdAt`: Creation timestamp
- `doctorId`: Doctor's ID
- `appointmentType`: Type of appointment

Methods:
- `fromJson()`: Parse from API response
- `toJson()`: Convert to JSON
- `copyWith()`: Create a copy with modified fields

### UserModel
**Location:** `lib/logic/models/user_model.dart`

Properties:
- `id`: User ID
- `name`: User's name
- `username`: Username
- `email`: Email address
- `phone`: Phone number
- `gender`: Gender
- `token`: Authentication token

Methods:
- `fromJson()`: Parse from API response
- `toJson()`: Convert to JSON

### Specialization Model
**Location:** `lib/logic/models/specialization.dart`

Properties:
- `id`: Specialization ID
- `name`: Specialization name
- `icon`: Icon URL
- `doctorsCount`: Number of doctors in this specialization

Methods:
- `fromJson()`: Parse from API response
- `toJson()`: Convert to JSON

## Usage Examples

### Example 1: Login and Get Profile
```dart
final authRepo = AuthRepo();

// Login
try {
  final user = await authRepo.login('user@example.com', 'password');
  print('Logged in as: ${user?.name}');
  
  // Get profile
  final profile = await authRepo.getProfile();
  print('Profile: ${profile?.email}');
} catch (e) {
  print('Error: $e');
}
```

### Example 2: Search and Book Appointment
```dart
final doctorRepo = DoctorRepository();
final appointmentRepo = AppointmentRepository();

// Search for doctors
try {
  final doctors = await doctorRepo.searchDoctors('cardiology');
  
  if (doctors.isNotEmpty) {
    final selectedDoctor = doctors.first;
    
    // Book an appointment
    final appointment = await appointmentRepo.createAppointment(
      doctorId: selectedDoctor.id!,
      date: '2024-01-15',
      time: '10:00 AM',
      notes: 'First visit',
      appointmentType: 'in-person',
    );
    
    print('Appointment booked: ${appointment.id}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Example 3: Get Upcoming Appointments
```dart
final appointmentRepo = AppointmentRepository();

try {
  final upcomingAppointments = await appointmentRepo.getUpcomingAppointments();
  
  for (var appointment in upcomingAppointments) {
    print('${appointment.doctor.name} on ${appointment.date}');
  }
} catch (e) {
  print('Error: $e');
}
```

## Error Handling

All API methods can throw the following exceptions:
- `ApiError`: Custom error with message and status code
- `DioException`: Network-related errors

It's recommended to wrap API calls in try-catch blocks:

```dart
try {
  final doctors = await doctorRepo.getDoctors();
  // Handle success
} on ApiError catch (e) {
  // Handle API error
  print('API Error: ${e.massage} (${e.statusCode})');
} on DioException catch (e) {
  // Handle network error
  print('Network Error: ${e.message}');
} catch (e) {
  // Handle other errors
  print('Unexpected Error: $e');
}
```

## Authentication

The API uses token-based authentication:
1. Login or register to receive a token
2. Token is automatically saved to local storage
3. Token is automatically included in subsequent API requests
4. Logout to clear the token

## Configuration

To change the base URL, modify `lib/core/network/dio_client.dart`:

```dart
BaseOptions(
  baseUrl: 'YOUR_API_BASE_URL',
  // ... other options
)
```

## Notes

- All dates should be in ISO 8601 format (YYYY-MM-DD)
- Authentication token is required for most endpoints
- The API automatically handles token injection and error responses
- Response data is wrapped in a `data` field: `{ "data": {...} }`
