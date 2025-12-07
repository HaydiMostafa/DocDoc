# API Integration Examples

This file provides practical examples of how to integrate the new API layer with existing screens in the DocDoc app.

## Integration Steps

### 1. Update Home Screen to Load Doctors from API

**File:** `lib/screens/home_screen.dart`

Add these imports:
```dart
import 'package:doc_app_sw/logic/doctor_logic/doctor_repository.dart';
import 'package:doc_app_sw/logic/models/doctor.dart';
```

In your State class:
```dart
class _HomeScreenState extends State<HomeScreen> {
  final DoctorRepository _doctorRepo = DoctorRepository();
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final doctors = await _doctorRepo.getDoctors();
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadDoctors,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doctor = _doctors[index];
        return DoctorCard(doctor: doctor);
      },
    );
  }
}
```

### 2. Update Search Screen for Doctor Search

**File:** `lib/screens/search_screen.dart`

```dart
import 'package:doc_app_sw/logic/doctor_logic/doctor_repository.dart';
import 'package:doc_app_sw/logic/models/doctor.dart';

class _SearchScreenState extends State<SearchScreen> {
  final DoctorRepository _doctorRepo = DoctorRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> _searchResults = [];
  bool _isSearching = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _doctorRepo.searchDoctors(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: _performSearch,
          decoration: const InputDecoration(
            hintText: 'Search doctors...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        if (_isSearching)
          const CircularProgressIndicator()
        else
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return DoctorCard(doctor: _searchResults[index]);
              },
            ),
          ),
      ],
    );
  }
}
```

### 3. Update Appointment Form to Use API

**File:** `lib/screens/appointment_form_screen.dart`

```dart
import 'package:doc_app_sw/logic/appointment_logic/appointment_repository.dart';

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  final _formKey = GlobalKey<FormState>();
  
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _notes;
  bool _isBooking = false;

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isBooking = true);

    try {
      final appointment = await _appointmentRepo.createAppointment(
        doctorId: widget.doctor.id!,
        date: _selectedDate!.toIso8601String().split('T')[0],
        time: _selectedTime!,
        notes: _notes,
        appointmentType: 'in-person', // or get from user selection
      );

      setState(() => _isBooking = false);

      // Navigate to confirmation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AppointmentConfirmationScreen(
            appointment: appointment,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isBooking = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Date picker
          // Time picker
          // Notes field
          
          ElevatedButton(
            onPressed: _isBooking ? null : _bookAppointment,
            child: _isBooking
                ? const CircularProgressIndicator()
                : const Text('Book Appointment'),
          ),
        ],
      ),
    );
  }
}
```

### 4. Update My Appointments Screen

**File:** `lib/screens/my_appointments_screen.dart`

```dart
import 'package:doc_app_sw/logic/appointment_logic/appointment_repository.dart';
import 'package:doc_app_sw/logic/models/appointment.dart';

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pastAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final upcoming = await _appointmentRepo.getUpcomingAppointments();
      final past = await _appointmentRepo.getPastAppointments();
      
      setState(() {
        _upcomingAppointments = upcoming;
        _pastAppointments = past;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments: $e')),
      );
    }
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    try {
      await _appointmentRepo.cancelAppointment(appointment.id!);
      // Reload appointments
      await _loadAppointments();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cancellation failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentList(_upcomingAppointments, true),
                _buildAppointmentList(_pastAppointments, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments, bool showCancel) {
    if (appointments.isEmpty) {
      return const Center(child: Text('No appointments'));
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return ListTile(
          title: Text(appointment.doctor.name),
          subtitle: Text('${appointment.date} at ${appointment.time}'),
          trailing: showCancel
              ? IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () => _cancelAppointment(appointment),
                )
              : null,
        );
      },
    );
  }
}
```

### 5. Update Profile Screen with API

**File:** `lib/screens/profile_screen.dart`

```dart
import 'package:doc_app_sw/logic/auth_logic/auth_repo.dart';
import 'package:doc_app_sw/logic/models/user_model.dart';

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepo _authRepo = AuthRepo();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authRepo.getProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _authRepo.logout();
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  Future<void> _updateProfile() async {
    try {
      final updatedUser = await _authRepo.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      
      setState(() => _user = updatedUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Text(_user?.name ?? 'Unknown'),
        Text(_user?.email ?? ''),
        ElevatedButton(
          onPressed: _logout,
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
```

### 6. Doctor Details Screen

**File:** `lib/screens/doctor_details_screen.dart`

```dart
import 'package:doc_app_sw/logic/doctor_logic/doctor_repository.dart';
import 'package:doc_app_sw/logic/models/doctor.dart';

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  final DoctorRepository _doctorRepo = DoctorRepository();
  Doctor? _doctor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorDetails();
  }

  Future<void> _loadDoctorDetails() async {
    setState(() => _isLoading = true);

    try {
      final doctor = await _doctorRepo.getDoctorById(widget.doctorId);
      setState(() {
        _doctor = doctor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load doctor details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_doctor == null) {
      return const Scaffold(
        body: Center(child: Text('Doctor not found')),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Doctor image
            Image.network(_doctor!.image),
            Text(_doctor!.name),
            Text(_doctor!.specialty),
            Text('Rating: ${_doctor!.rating}'),
            Text('Hospital: ${_doctor!.hospital}'),
            Text(_doctor!.biography),
            if (_doctor!.price != null)
              Text('Price: \$${_doctor!.price}'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentFormScreen(doctor: _doctor!),
                  ),
                );
              },
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Testing the API Integration

### Test Authentication Flow
1. Login with credentials
2. Check if token is saved
3. Make authenticated request to get profile
4. Update profile
5. Logout and verify token is cleared

### Test Doctor Features
1. Load all doctors on home screen
2. Search for specific doctors
3. View doctor details
4. Filter doctors by specialization

### Test Appointment Features
1. Create a new appointment
2. View upcoming appointments
3. View past appointments
4. Cancel an appointment

## Error Handling Best Practices

1. **Always use try-catch blocks**
```dart
try {
  final result = await repository.someMethod();
  // Handle success
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

2. **Show user-friendly error messages**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Operation failed. Please try again.')),
);
```

3. **Add loading indicators**
```dart
if (_isLoading) {
  return const CircularProgressIndicator();
}
```

4. **Add retry functionality**
```dart
ElevatedButton(
  onPressed: _loadData,
  child: const Text('Retry'),
)
```

## Migration Tips

1. **Gradual Migration**: Replace local data sources with API calls one screen at a time
2. **Backward Compatibility**: Keep the old `AppointmentService` as fallback if needed
3. **Testing**: Test each screen individually after API integration
4. **Error Handling**: Implement proper error handling for network failures
5. **Loading States**: Add loading indicators for better UX
6. **Caching**: Consider implementing caching for frequently accessed data

## Additional Resources

- See `API_DOCUMENTATION.md` for complete API reference
- Check `lib/core/network/` for network configuration
- Review model classes in `lib/logic/models/` for data structures
