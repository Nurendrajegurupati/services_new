import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String selectedService = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          SizedBox(height: 10),
          _buildServiceFilter(),
          Expanded(child: _buildBookingsList()),
        ],
      ),
    );
  }

  Widget _buildServiceFilter() {
    List<String> services = [
      "All",
      "Plumbing",
      "Cleaning",
      "Painting",
      "Carpentry",
      "Electrical"
    ];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: services.map((service) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ChoiceChip(
                label: Text(service,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                selected: selectedService == service,
                selectedColor: Colors.deepPurple,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                    color: selectedService == service ? Colors.white : Colors.black),
                onSelected: (selected) {
                  setState(() {
                    selectedService = service;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('user_bookings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text("No bookings found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)));
        }

        var bookings = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return selectedService == "All" || data['serviceName'] == selectedService;
        }).toList();

        return ListView.builder(
          itemCount: bookings.length,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          itemBuilder: (context, index) {
            var booking = bookings[index].data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                title: Text("Service: ${booking['serviceName']}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text("Status: ${booking['status']}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                onTap: () {
                  _showBookingDetails(context, bookings[index]);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showBookingDetails(BuildContext context, QueryDocumentSnapshot booking) {
    var data = booking.data() as Map<String, dynamic>;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Booking Details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              Divider(),
              _detailRow("Service", data['serviceName']),
              _detailRow("Status", data['status']),
              _detailRow("Date", data['date']),
              _detailRow("Time", data['time']),
              _detailRow("Address", data['address']),
              GestureDetector(
                onTap: () => _callUser(data['phoneNumber']),
                child: _detailRow("Phone", data['phoneNumber'], isPhone: true),
              ),
              SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [ 
                  _actionButton("Confirm", Icons.check, Colors.green,
                      () => _updateBookingStatus(booking.reference, "Confirmed")),
                  _actionButton("Reject", Icons.close, Colors.red,
                      () => _updateBookingStatus(booking.reference, "Rejected")),
                  _actionButton("Call", Icons.call, Colors.blue,
                      () => _callUser(data['phoneNumber'])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }

  Widget _detailRow(String title, String value, {bool isPhone = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
          GestureDetector(
            onTap: isPhone ? () => _callUser(value) : null,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isPhone ? Colors.blue : Colors.black,
                decoration: isPhone ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callUser(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch phone call"), backgroundColor: Colors.red));
    }
  }

  void _updateBookingStatus(DocumentReference bookingRef, String status) {
    bookingRef.update({'status': status}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking $status successfully!"),
          backgroundColor: status == "Confirmed" ? Colors.green : Colors.red,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $error"), backgroundColor: Colors.red),
      );
    });
  }
}
