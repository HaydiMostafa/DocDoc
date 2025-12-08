# Complete Updated Files - API Migration

This document contains the complete content of the files updated to use the new API.

## File 1: lib/screens/my_appointments_screen.dart

**Complete file content (replace entire file with this):**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/color_theme.dart';
import '../logic/models/appointment.dart';
import '../logic/appointment_logic/appointment_repository.dart';
import 'cancel_appointment_dialog.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pastAppointments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh appointments when screen is shown
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    
    try {
      final upcoming = await _appointmentRepository.getUpcomingAppointments();
      final past = await _appointmentRepository.getPastAppointments();
      
      setState(() {
        _upcomingAppointments = upcoming;
        _pastAppointments = past;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load appointments: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CancelAppointmentDialog(appointment: appointment),
    );

    if (confirmed == true && appointment.id != null) {
      try {
        await _appointmentRepository.cancelAppointment(appointment.id!);
        await _loadAppointments(); // Reload appointments from API

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel appointment: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myWhite,
      appBar: AppBar(
        backgroundColor: MyColors.myWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors.myBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Appointments',
          style: TextStyle(
            color: MyColors.myBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: MyColors.myBlue,
          unselectedLabelColor: MyColors.myGrey,
          indicatorColor: MyColors.myBlue,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Upcoming', style: TextStyle(fontSize: 16.sp)),
                  if (_upcomingAppointments.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: MyColors.myBlue,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${_upcomingAppointments.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Past', style: TextStyle(fontSize: 16.sp)),
                  if (_pastAppointments.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: MyColors.myGrey,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${_pastAppointments.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(_upcomingAppointments, isUpcoming: true),
                _buildAppointmentsList(_pastAppointments, isUpcoming: false),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList(
    List<Appointment> appointments, {
    required bool isUpcoming,
  }) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80.sp, color: MyColors.myGrey),
            SizedBox(height: 20.h),
            Text(
              isUpcoming ? 'No upcoming appointments' : 'No past appointments',
              style: TextStyle(
                fontSize: 18.sp,
                color: MyColors.myGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isUpcoming
                  ? 'Book your first appointment to get started'
                  : 'Your past appointments will appear here',
              style: TextStyle(fontSize: 14.sp, color: MyColors.myGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointments[index], isUpcoming);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, bool isUpcoming) {
    String _formatDate(DateTime date) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Image
                CircleAvatar(
                  radius: 35.r,
                  backgroundImage: AssetImage(appointment.doctor.image),
                ),
                SizedBox(width: 16.w),
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctor.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: MyColors.myBlack,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        appointment.doctor.specialty,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: MyColors.myGrey,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital,
                            size: 16.sp,
                            color: MyColors.myGrey,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              appointment.doctor.hospital,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: MyColors.myGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isUpcoming ? 'Upcoming' : 'Past',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isUpcoming ? Colors.green : MyColors.myGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Date
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18.sp,
                        color: MyColors.myBlue,
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: MyColors.myGrey,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _formatDate(appointment.date),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: MyColors.myBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Time
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18.sp,
                        color: MyColors.myBlue,
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: MyColors.myGrey,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            appointment.time,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: MyColors.myBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Cancel Button (only for upcoming appointments)
          if (isUpcoming && !appointment.isCancelled)
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Cancel Appointment',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## File 2: lib/screens/appointment_form_screen.dart

**Complete file content (replace entire file with this):**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/color_theme.dart';
import '../logic/models/doctor.dart';
import '../logic/models/appointment.dart';
import '../widgets/app_text_button.dart';
import '../logic/appointment_logic/appointment_repository.dart';
import 'appointment_confirmation_screen.dart';

class AppointmentFormScreen extends StatefulWidget {
  final Doctor? selectedDoctor;

  const AppointmentFormScreen({super.key, this.selectedDoctor});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  bool _isSubmitting = false;
  final List<String> _availableTimes = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.selectedDoctor;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: MyColors.myBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time when date changes
      });
    }
  }

  void _selectTime(String time) {
    setState(() {
      _selectedTime = time;
    });
  }

  Future<void> _submitAppointment() async {
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a doctor')));
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a time')));
      return;
    }

    // Check if doctor has an ID for API call
    if (_selectedDoctor!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected doctor is not available for booking'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create appointment via API
      final appointment = await _appointmentRepository.createAppointment(
        doctorId: _selectedDoctor!.id!,
        date: _selectedDate!.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
        time: _selectedTime!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        appointmentType: 'in-person',
      );

      setState(() => _isSubmitting = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AppointmentConfirmationScreen(appointment: appointment),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myWhite,
      appBar: AppBar(
        backgroundColor: MyColors.myWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors.myBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Appointment',
          style: TextStyle(
            color: MyColors.myBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Selection Section
            Text(
              'Select Doctor',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: MyColors.myBlue,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                // Navigate to doctor selection screen
                // For now, we'll show a dialog or use the passed doctor
                if (widget.selectedDoctor == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Doctor selection feature coming soon'),
                    ),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: _selectedDoctor != null
                      ? MyColors.myBlue.withOpacity(0.1)
                      : MyColors.myLightGrey,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _selectedDoctor != null
                        ? MyColors.myBlue
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: _selectedDoctor != null
                    ? Row(
                        children: [
                          CircleAvatar(
                            radius: 30.r,
                            backgroundImage: AssetImage(_selectedDoctor!.image),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedDoctor!.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.myBlue,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _selectedDoctor!.specialty,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: MyColors.myGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: MyColors.myBlue,
                            size: 24.sp,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: MyColors.myGrey,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Tap to select a doctor',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: MyColors.myGrey,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 30.h),

            // Date Selection Section
            Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: MyColors.myBlue,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: _selectedDate != null
                      ? MyColors.myBlue.withOpacity(0.1)
                      : MyColors.myLightGrey,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _selectedDate != null
                        ? MyColors.myBlue
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: _selectedDate != null
                              ? MyColors.myBlue
                              : MyColors.myGrey,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Select appointment date',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _selectedDate != null
                                ? MyColors.myBlue
                                : MyColors.myGrey,
                            fontWeight: _selectedDate != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedDate != null)
                      Icon(
                        Icons.check_circle,
                        color: MyColors.myBlue,
                        size: 24.sp,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),

            // Time Selection Section
            if (_selectedDate != null) ...[
              Text(
                'Select Time',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: MyColors.myBlue,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: _availableTimes.map((time) {
                  final isSelected = _selectedTime == time;
                  return GestureDetector(
                    onTap: () => _selectTime(time),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MyColors.myBlue
                            : MyColors.myLightGrey,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? MyColors.myBlue
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected ? Colors.white : MyColors.myGrey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 30.h),
            ],

            // Notes Section
            Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: MyColors.myBlue,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: MyColors.myLightGrey,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Add any special requests or notes...',
                  hintStyle: TextStyle(color: MyColors.myGrey, fontSize: 14.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                ),
                style: TextStyle(fontSize: 14.sp, color: MyColors.myBlack),
              ),
            ),
            SizedBox(height: 40.h),

            // Submit Button
            AppTextButton(
              buttonText: _isSubmitting ? 'Booking...' : 'Confirm Appointment',
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              onPressed: _isSubmitting ? () {} : _submitAppointment,
              backgroundColor: _isSubmitting ? MyColors.myGrey : MyColors.myBlue,
              borderRadius: 16.r,
              buttonHeight: 56.h,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
```

---

## Summary of Changes

### Key Changes in Both Files:

1. **Import Change:**
   - Changed from: `import '../logic/appointment_logic/appointment_service.dart';`
   - Changed to: `import '../logic/appointment_logic/appointment_repository.dart';`

2. **Repository Instance:**
   - Changed from: `final AppointmentService _appointmentService = AppointmentService();`
   - Changed to: `final AppointmentRepository _appointmentRepository = AppointmentRepository();`

3. **API Integration:**
   - All methods now use API calls instead of local storage
   - Added proper error handling with try-catch blocks
   - Added loading states for better UX

### What to Do:

1. **Replace `lib/screens/my_appointments_screen.dart`** with the complete content above
2. **Replace `lib/screens/appointment_form_screen.dart`** with the complete content above
3. Done! The screens now use the new API

### Benefits:

- ✅ Real-time data from backend
- ✅ Proper error handling
- ✅ Loading indicators
- ✅ No more local storage dependency
- ✅ Production-ready API integration
