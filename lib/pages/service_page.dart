import 'package:flutter/material.dart';
import 'package:blur/blur.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_page.dart';

class ServicePage extends StatefulWidget {
  final String serviceName;

  const ServicePage({super.key, required this.serviceName});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final Map<String, int> selectedRooms = {};
  final Map<String, bool> selectedOptions = {};

  final List<String> cleaningRooms = ['Living Room', 'Bedroom', 'Bathroom', 'Kitchen', 'Office'];
  final List<String> plumbingIssues = ['Pipe Leakage', 'Tap Issue', 'Blocked Drain', 'Other'];
  final List<String> electricalIssues = ['Fan Repair', 'Light Issue', 'Switchboard Fix', 'Wiring Problem'];
  final List<String> paintingOptions = ['Full House', 'Single Room', 'Wall Painting', 'Exterior'];
  final List<String> carpentryOptions = ['Furniture Repair', 'Custom Work', 'Door Fixing', 'Cabinet Work'];
  final List<String> gardeningOptions = ['Lawn Mowing', 'Planting', 'Tree Trimming', 'Garden Cleaning'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false, // Prevents overlap
      appBar: AppBar(
        title: Text(
          widget.serviceName,
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        backgroundColor: getServiceColor().withOpacity(0.85),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: getServiceGradient(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ).blurred(blur: 5, colorOpacity: 0.1),
            ),
            Column(
              children: [
                Expanded(child: getServiceOptions()),

                // Proceed Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getServiceColor(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            serviceName: widget.serviceName,
                            selectedRooms: selectedRooms,
                            selectedOptions: selectedOptions,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Proceed to Booking",
                      style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getServiceOptions() {
    switch (widget.serviceName) {
      case 'Cleaning':
        return buildCleaningOptions();
      case 'Plumbing':
        return buildSelectionList(plumbingIssues);
      case 'Electrical':
        return buildSelectionList(electricalIssues);
      case 'Painting':
        return buildSelectionList(paintingOptions);
      case 'Carpentry':
        return buildSelectionList(carpentryOptions);
      case 'Gardening':
        return buildSelectionList(gardeningOptions);
      default:
        return const Center(child: Text('Service options coming soon!'));
    }
  }

  Widget buildCleaningOptions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 80), // Ensures first item is fully visible
        ...cleaningRooms.map((room) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: getServiceColor().withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                room,
                style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              subtitle: Text(
                'Rooms selected: ${selectedRooms[room] ?? 0}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 28),
                    onPressed: () {
                      setState(() {
                        if (selectedRooms.containsKey(room) && selectedRooms[room]! > 0) {
                          selectedRooms[room] = selectedRooms[room]! - 1;
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 28),
                    onPressed: () {
                      setState(() {
                        selectedRooms[room] = (selectedRooms[room] ?? 0) + 1;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildSelectionList(List<String> options) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: options.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.95),
            boxShadow: [
              BoxShadow(
                color: getServiceColor().withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: CheckboxListTile(
            activeColor: getServiceColor(),
            title: Text(
              option,
              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            value: selectedOptions[option] ?? false,
            onChanged: (bool? value) {
              setState(() {
                selectedOptions[option] = value!;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Color getServiceColor() {
    switch (widget.serviceName) {
      case 'Cleaning':
        return Colors.teal;
      case 'Plumbing':
        return Colors.blue;
      case 'Electrical':
        return Colors.orange;
      case 'Painting':
        return Colors.purple;
      case 'Carpentry':
        return Colors.brown;
      case 'Gardening':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  List<Color> getServiceGradient() {
    switch (widget.serviceName) {
      case 'Cleaning':
        return [Colors.teal.shade300, Colors.teal.shade900];
      case 'Plumbing':
        return [Colors.blue.shade300, Colors.blue.shade900];
      case 'Electrical':
        return [Colors.orange.shade300, Colors.orange.shade900];
      case 'Painting':
        return [Colors.purple.shade300, Colors.purple.shade900];
      case 'Carpentry':
        return [Colors.brown.shade400, Colors.brown.shade900];
      case 'Gardening':
        return [Colors.green.shade300, Colors.green.shade900];
      default:
        return [Colors.blueGrey.shade300, Colors.blueGrey.shade900];
    }
  }
}
