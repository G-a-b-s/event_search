import 'package:flutter/material.dart';
<<<<<<< HEAD

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Corpo com gradiente
=======
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
>>>>>>> main
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
<<<<<<< HEAD
            // Simulação de mapa como fundo (ex: imagem de mapa estático ou container)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.3), // transparência para simular mapa
              ),
            ),

            // Campo de busca
=======
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
>>>>>>> main
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
<<<<<<< HEAD

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFC0AF96),
=======
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFC0AF96),
        currentIndex: _selectedIndex,
>>>>>>> main
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
<<<<<<< HEAD
            icon: Icon(Icons.map),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '',
          ),
        ],
      ),
    );
  }
}
=======
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
>>>>>>> main
