import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'auth_page.dart';
import 'my_bookings_screen.dart';
import 'service_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Color> bgColors = [
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.tealAccent,
    Colors.greenAccent,
  ];
  int colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _startColorChange();
  }

  void _startColorChange() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        colorIndex = (colorIndex + 1) % bgColors.length;
      });
    });
  }

  final List<Map<String, dynamic>> services = const [
    {'name': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.blueAccent},
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'color': Colors.greenAccent},
    {'name': 'Electrical', 'icon': Icons.electrical_services, 'color': Colors.orangeAccent},
    {'name': 'Painting', 'icon': Icons.format_paint, 'color': Colors.purpleAccent},
    {'name': 'Carpentry', 'icon': Icons.handyman, 'color': Colors.redAccent},
    {'name': 'Gardening', 'icon': Icons.grass, 'color': Colors.tealAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Home Services',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgColors[colorIndex], Colors.black.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(service);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicePage(serviceName: service['name']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [service['color'], Colors.black.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: service['color'].withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(service['icon'], size: 70, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              service['name'],
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text("Nurendra", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            accountEmail: Text("nurendra@example.com", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/profile.jpeg"),
            ),
          ),
          _buildDrawerItem(Icons.home, 'Home', () => Navigator.pop(context)),
          _buildDrawerItem(Icons.person, 'Profile', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))),
          _buildDrawerItem(Icons.settings, 'Settings', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
          _buildDrawerItem(Icons.history, 'My Bookings', () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsScreen()))),
          _buildDrawerItem(Icons.logout, 'Logout', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthPage()))),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
      onTap: onTap,
    );
  }
}
