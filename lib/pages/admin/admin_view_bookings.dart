import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminViewBookings extends StatefulWidget {
  const AdminViewBookings({super.key});

  @override
  _AdminViewBookingsState createState() => _AdminViewBookingsState();
}

class _AdminViewBookingsState extends State<AdminViewBookings> {
  Future<List<QueryDocumentSnapshot>> fetchBookings() async {
    List<QueryDocumentSnapshot> allBookings = [];

    // Fetch all users
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('bookings').get();
    print("Fetched ${usersSnapshot.docs.length} users"); // ✅ Debug print

    for (var userDoc in usersSnapshot.docs) {
      // Fetch user_bookings subcollection for each user
      QuerySnapshot bookingsSnapshot =
          await userDoc.reference.collection('user_bookings').get();
      print(
        "User ${userDoc.id} has ${bookingsSnapshot.docs.length} bookings",
      ); // ✅ Debug print

      // Add each booking document to the list
      allBookings.addAll(bookingsSnapshot.docs);
    }

    return allBookings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin - View Bookings")),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No bookings found"));
          }

          var bookings = snapshot.data!;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Service: ${booking['serviceName']}"),
                  subtitle: Text("Status: ${booking['status']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
