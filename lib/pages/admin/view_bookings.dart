import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:services/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomeServiceApp());
} 

class ViewBookings extends StatelessWidget {
  const ViewBookings({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Service App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BookingScreen(),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String selectedService = "Plumbing"; // Default selected service
  late Stream<QuerySnapshot> bookingsStream;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  void fetchBookings() {
    setState(() {
      bookingsStream = FirebaseFirestore.instance
          .collection('user_bookings')
          .where('serviceName', isEqualTo: selectedService)
          .snapshots();
    });
  }

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
              items: ["Plumbing", "Electrical", "Cleaning", "Painting"]
                  .map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedService = newValue;
                  });
                  fetchBookings();
                }
              },
            ),
          ),

          // Booking List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: bookingsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No bookings found.'));
                }

                var bookings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    var booking = bookings[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(booking['serviceName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Address: ${booking['address']}'),
                            Text('Date: ${booking['date']}'),
                            Text('Time: ${booking['time']}'),
                            Text('Status: ${booking['status']}'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
