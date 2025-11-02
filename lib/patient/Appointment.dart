import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Home.dart';           // Replace with your actual Home file name
import 'Medication.dart';     // Replace with your Medication file
import 'Caregiver.dart';      // Replace with your Caregiver file

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDepartment;
  String? _selectedDoctor;
  String _appointmentType = 'General Consultation';

  final List<String> _departments = [
    'Cardiology', 'Dermatology', 'Neurology', 'Orthopedics', 'Pediatrics', 'Psychiatry', 'Radiology',
  ];

  final Map<String, List<String>> _doctors = {
    'Cardiology': ['Dr. Sarah Johnson', 'Dr. Michael Chen'],
    'Dermatology': ['Dr. Emily Brown', 'Dr. James Wilson'],
    'Neurology': ['Dr. Lisa Anderson', 'Dr. Robert Taylor'],
    'Orthopedics': ['Dr. David Martinez', 'Dr. Jennifer Lee'],
    'Pediatrics': ['Dr. Amanda White', 'Dr. Christopher Davis'],
    'Psychiatry': ['Dr. Michelle Garcia', 'Dr. Daniel Rodriguez'],
    'Radiology': ['Dr. Karen Thomas', 'Dr. Steven Moore'],
  };

  final List<String> _appointmentTypes = [
    'General Consultation', 'Follow-up', 'Urgent Care', 'Routine Checkup', 'Vaccination',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF6B6B),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF6B6B),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submitAppointment() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) return _showSnackBar('Please select a date', Colors.red);
    if (_selectedTime == null) return _showSnackBar('Please select a time', Colors.red);
    if (_selectedDepartment == null) return _showSnackBar('Please select a department', Colors.red);
    if (_selectedDoctor == null) return _showSnackBar('Please select a doctor', Colors.red);

    _showSnackBar('Appointment booked successfully!', Colors.green);

    _formKey.currentState!.reset();
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _notesController.clear();
      _selectedDate = null;
      _selectedTime = null;
      _selectedDepartment = null;
      _selectedDoctor = null;
      _appointmentType = 'General Consultation';
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Bottom Navigation Item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required int index,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (isActive) return;
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PatientHomePage()),
              );
              break;
            case 1:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PatientMedicationScreen()),
              );
              break;
            case 2:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const PatientCaregiverScreen()),
              );
              break;
            case 3:
              break; // Already here
            case 4:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const Placeholder()),
              );
              break;
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFFFF6B6B) : Colors.grey[400],
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? const Color(0xFFFF6B6B) : Colors.grey[400],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // PINK GRADIENT HEADER
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9B9B), Color(0xFFFFB5B5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                children: [
                  Row(
                    children: [
                      // BACK ARROW → HOME
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const PatientHomePage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Book Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.calendar_today_rounded, size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    'Schedule Your Visit',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // FORM CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Personal Information'),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter your email';
                          if (!value!.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
                      ),
                      const SizedBox(height: 30),
                      _buildSectionTitle('Appointment Details'),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        label: 'Department',
                        icon: Icons.local_hospital_outlined,
                        value: _selectedDepartment,
                        items: _departments,
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value;
                            _selectedDoctor = null;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        label: 'Doctor',
                        icon: Icons.medical_services_outlined,
                        value: _selectedDoctor,
                        items: _selectedDepartment != null ? _doctors[_selectedDepartment!]! : [],
                        onChanged: (value) => setState(() => _selectedDoctor = value),
                        enabled: _selectedDepartment != null,
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        label: 'Appointment Type',
                        icon: Icons.assignment_outlined,
                        value: _appointmentType,
                        items: _appointmentTypes,
                        onChanged: (value) => setState(() => _appointmentType = value!),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateTimeCard(
                              label: 'Date',
                              value: _selectedDate != null
                                  ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                                  : 'Select Date',
                              icon: Icons.calendar_today_outlined,
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildDateTimeCard(
                              label: 'Time',
                              value: _selectedTime != null ? _selectedTime!.format(context) : 'Select Time',
                              icon: Icons.access_time_outlined,
                              onTap: () => _selectTime(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildSectionTitle('Additional Information'),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _notesController,
                        label: 'Notes (Optional)',
                        icon: Icons.note_outlined,
                        maxLines: 4,
                        validator: null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _submitAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                            'Book Appointment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(icon: Icons.home, label: 'Home', isActive: false, index: 0),
                _buildNavItem(icon: Icons.medication, label: 'Medication', isActive: false, index: 1),
                _buildNavItem(icon: Icons.local_hospital, label: 'Caregiver', isActive: false, index: 2),
                _buildNavItem(icon: Icons.calendar_month, label: 'Appointment', isActive: true, index: 3),
                _buildNavItem(icon: Icons.settings, label: 'Settings', isActive: false, index: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Widgets (unchanged from your original)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFFF6B6B)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFFF6B6B)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: enabled ? onChanged : null,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildDateTimeCard({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFF6B6B), size: 20),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}