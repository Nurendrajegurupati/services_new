import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserBookingsScreen extends StatefulWidget {
  const UserBookingsScreen({super.key});

  @override
  _UserBookingsScreenState createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen> {
  String selectedService = 'Plumbing'; // Default service
  final List<String> services = ['Plumbing', 'Electrical', 'Cleaning', 'Painting', 'Carpentry', 'Gardening'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Bookings')),
      body: Column(
        children: [
          // Dropdown to select service
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: DropdownButton<String>(
              value: selectedService,
              onChanged: (String? newValue) {
                setState(() {
                  selectedService = newValue!;
                });
              },
              items: services.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
            ),
          ),

          // Display Bookings
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user_bookings')
                  .where('service', isEqualTo: selectedService) // Ensure correct field name
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No bookings found."));
                }

                // Debug: Print bookings in console
                for (var doc in snapshot.data!.docs) {
                  print("Booking: ${doc.data()}");
                }

                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(data['userName'] ?? 'Unknown User'),
                        subtitle: Text("Time: ${data['time'] ?? 'N/A'}"),
                        trailing: Text("Status: ${data['status'] ?? 'Pending'}"),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
