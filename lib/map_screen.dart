import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_list_page.dart';
import 'register_event.dart';
import 'main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 1;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final query = await FirebaseFirestore.instance.collection('eventos').get();
    final markers = <Marker>{};
    for (var doc in query.docs) {
      final data = doc.data();
      if (data['localizacao'] != null && data['nomeEvento'] != null) {
        final geo = data['localizacao'];
        if (_searchText.isEmpty ||
            (data['nomeEvento']?.toLowerCase() ?? '').contains(_searchText.toLowerCase())) {
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(geo.latitude, geo.longitude),
              infoWindow: InfoWindow(
                title: data['nomeEvento'],
                snippet: data['endereco'],
              ),
            ),
          );
        }
      }
    }
    setState(() {
      _markers = markers;
    });
  }

  void _onSearch(String value) {
    setState(() {
      _searchText = value;
    });
    _loadMarkers();
  }

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
      // já está na tela de mapa
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterEvent()),
      );
    } else if (index == 3) {
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
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-19.975, -44.005),
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
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
                      color: Color.fromARGB((0.1 * 255).toInt(), 0, 0, 0),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar evento pelo nome...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                  onChanged: _onSearch,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE3C8A8),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF6A8A99),
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Eventos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Cadastrar Evento',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Sair',
            ),
          ],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}