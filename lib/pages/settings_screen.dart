import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Ensures back button is visible
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dark Mode Switch
            FadeInLeft(
              duration: const Duration(milliseconds: 500),
              child: settingsCard(
                icon: Icons.dark_mode_rounded,
                title: "Dark Mode",
                switchValue: isDarkMode,
                onChanged: (value) {
                  toggleTheme();
                },
              ),
            ),
            
            // Notifications Switch
            FadeInRight(
              duration: const Duration(milliseconds: 500),
              child: settingsCard(
                icon: Icons.notifications_active_rounded,
                title: "Enable Notifications",
                switchValue: notificationsEnabled,
                onChanged: (value) {
                  setState(() => notificationsEnabled = value);
                },
              ),
            ),

            // Privacy Settings Button
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 5, spreadRadius: 2)
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.privacy_tip_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 15),
                          Text(
                            "Privacy Settings",
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsCard({
    required IconData icon,
    required String title,
    required bool switchValue,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 15),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ],
          ),
          Switch(
            value: switchValue,
            onChanged: onChanged,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}

// Privacy Settings Screen
class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Settings"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text("Privacy settings will be displayed here.", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
