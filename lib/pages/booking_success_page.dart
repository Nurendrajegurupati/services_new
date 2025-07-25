import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/success.json', width: 200, height: 200), // Success Animation
            const SizedBox(height: 20),
            const Text(
              "🎉 Congratulations!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your booking is confirmed!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("HomePage"),
            ),
          ],
        ),
      ),
    );
  }
}
