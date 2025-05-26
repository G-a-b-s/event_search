import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_list_page.dart';
import 'main.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EventListPage()),
      );
    } else if (index == 1) {

    } else if (index == 2) {

      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage(title: 'EventSearch')),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF385661), Color(0xFFC0AF96)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Digite o nome do evento...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.clear),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFC0AF96),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Sair',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}