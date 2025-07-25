import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String serviceName;

  const BookingPage({super.key, required this.serviceName});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void _confirmBooking() {
    if (selectedDate == null || selectedTime == null || 
        phoneController.text.isEmpty || addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all details!")),
      );
      return;
    }

    if (phoneController.text.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 10-digit phone number!")),
      );
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String formattedTime = selectedTime!.format(context);
    String phoneNumber = phoneController.text;
    String address = addressController.text;

    // Save booking to Firebase
    _saveBooking(widget.serviceName, address, formattedDate, formattedTime, phoneNumber);

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Booking Confirmed"),
        content: Text("Service: ${widget.serviceName}\nDate: $formattedDate\nTime: $formattedTime\nAddress: $address\nPhone: $phoneNumber"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _saveBooking(String serviceName, String address, String date, String time, String phone) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection("bookings")
        .doc(user.uid)
        .collection("user_bookings")
        .add({
          "serviceName": serviceName,
          "address": address,
          "date": date,
          "time": time,
          "phone": phone,
          "status": "Pending", // New bookings start as "Pending"
          "createdAt": Timestamp.now(),
        }).then((_) {
          print("Booking Confirmed!");
        }).catchError((error) {
          print("Failed to book: $error");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book a Service")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Booking for: ${widget.serviceName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Address Input Field
            const Text("Enter Your Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.location_on),
                hintText: "Enter your full address",
              ),
            ),

            const SizedBox(height: 20),

            // Phone Number Input Field
            const Text("Enter Your Phone Number", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.phone),
                hintText: "Enter 10-digit phone number",
              ),
            ),

            const SizedBox(height: 10),

            const Text("Select Date & Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Date Picker Button
            ElevatedButton(
              onPressed: _pickDate,
              child: Text(selectedDate == null
                  ? "Select Date"
                  : DateFormat('EEEE, MMM d, yyyy').format(selectedDate!)),
            ),

            const SizedBox(height: 10),

            // Time Picker Button
            ElevatedButton(
              onPressed: _pickTime,
              child: Text(selectedTime == null
                  ? "Select Time"
                  : selectedTime!.format(context)),
            ),

            const SizedBox(height: 20),

            // Confirm Booking Button
            Center(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                child: const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
