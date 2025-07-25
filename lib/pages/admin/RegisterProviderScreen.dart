import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterProviderScreen extends StatefulWidget {
  const RegisterProviderScreen({super.key});

  @override
  _RegisterProviderScreenState createState() => _RegisterProviderScreenState();
}

class _RegisterProviderScreenState extends State<RegisterProviderScreen> {
  List<String> services = ["Plumbing", "Electrical", "Cleaning", "Painting", "Carpentry", "Gardening"];
  String? selectedService;
  bool isLoading = false; // Show loading indicator

  void registerAsProvider() async {
    if (selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a service")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('service_providers').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'service': selectedService,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registered as $selectedService Provider")),
      );

      Navigator.pop(context, true); // Return true to refresh dashboard
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Service")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select a service to provide", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: services.map((service) {
                  return ListTile(
                    title: Text(service),
                    leading: Radio<String>(
                      value: service,
                      groupValue: selectedService,
                      onChanged: (String? value) {
                        setState(() {
                          selectedService = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : registerAsProvider, // Disable when loading
                child: isLoading ? CircularProgressIndicator() : Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
