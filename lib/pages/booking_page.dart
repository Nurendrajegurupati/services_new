import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blur/blur.dart';
import 'booking_success_page.dart';

class BookingPage extends StatefulWidget {
  final String serviceName;
  final Map<String, int> selectedRooms;
  final Map<String, bool> selectedOptions;

  const BookingPage({
    super.key,
    required this.serviceName,
    required this.selectedRooms,
    required this.selectedOptions,
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter all details", style: GoogleFonts.lato(fontSize: 16)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to log in first.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(user.uid)
          .collection("user_bookings")
          .add({
        "serviceName": widget.serviceName,
        "date": DateFormat('yyyy-MM-dd').format(_selectedDate!),
        "time": _selectedTime!.format(context),
        "address": _addressController.text,
        "phoneNumber": _phoneController.text,
        "status": "Pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookingSuccessPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Booking - ${widget.serviceName}',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.deepPurple.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Blur Effect
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.1),
            ).blurred(blur: 10, colorOpacity: 0.1),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Address Input Field
                  _buildTextField(
                    controller: _addressController,
                    label: "Enter Address",
                    icon: Icons.location_on,
                    keyboardType: TextInputType.streetAddress,
                  ),
                  const SizedBox(height: 15),
                  // Phone Number Input Field
                  _buildTextField(
                    controller: _phoneController,
                    label: "Enter Phone Number",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),
                  // Date Picker
                  _buildPickerField(
                    onTap: _pickDate,
                    label: _selectedDate != null
                        ? "Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}"
                        : "Select Date",
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 15),
                  // Time Picker
                  _buildPickerField(
                    onTap: _pickTime,
                    label: _selectedTime != null
                        ? "Time: ${_selectedTime!.format(context)}"
                        : "Select Time",
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 30),
                  // Confirm Booking Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        elevation: 5,
                      ),
                      onPressed: _isLoading ? null : _confirmBooking,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.deepPurple)
                          : Text(
                              "Confirm Booking",
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
          border: InputBorder.none,
          suffixIcon: Icon(icon, color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            Icon(icon, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
