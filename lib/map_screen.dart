import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_list_page.dart';
import 'register_event.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:intl/intl.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 1;
  List<Marker> _markers = [];
  List<Map<String, dynamic>> _eventData = [];
  // String _searchText = '';
  LatLng? _currentPosition;
  final PopupController _popupController = PopupController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final query = await FirebaseFirestore.instance.collection('eventos').get();
    final markers = <Marker>[];
    final eventData = <Map<String, dynamic>>[];

    // Adiciona marcador da localização atual do usuário
    if (_currentPosition != null) {
      markers.add(
        Marker(
          key: const ValueKey('user'),
          point: _currentPosition!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    // Adiciona todos os eventos do banco (sem filtro de proximidade)
    for (var doc in query.docs) {
      final data = doc.data();
      if (data['localizacao'] != null && data['nomeEvento'] != null) {
        final geo = data['localizacao'];
        final eventLatLng = LatLng(geo.latitude, geo.longitude);

        // if (_searchText.isEmpty ||
        //     (data['nomeEvento']?.toLowerCase() ?? '').contains(
        //       _searchText.toLowerCase(),
        //     )) {
        markers.add(
          Marker(
            key: ValueKey(doc.id),
            point: eventLatLng,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
        eventData.add({
          'id': doc.id,
          'nomeEvento': data['nomeEvento'],
          'endereco': data['endereco'],
          'dataHora': data['dataHora'],
          'localizacao': eventLatLng,
        });
        // }
      }
    }

    setState(() {
      _markers = markers;
      _eventData = eventData;
    });
  }

  // void _onSearch(String value) {
  //   setState(() {
  //     _searchText = value;
  //   });
  //   _loadMarkers();
  // }

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
        MaterialPageRoute(
          builder: (_) => const MyHomePage(title: 'EventSearch'),
        ),
        (route) => false,
      );
    }
  }

  String _formatarDataHora(dynamic dataHora) {
    DateTime? dt;
    if (dataHora is String) {
      try {
        dt = DateTime.parse(dataHora);
      } catch (_) {
        return dataHora;
      }
    } else if (dataHora is Timestamp) {
      dt = dataHora.toDate();
    } else if (dataHora is DateTime) {
      dt = dataHora;
    }
    if (dt == null) return '-';
    return 'Data: ${DateFormat('dd/MM/yyyy').format(dt)}  Hora: ${DateFormat('HH:mm').format(dt)}';
  }

  Map<String, dynamic>? _getEventDataByMarker(Marker marker) {
    if (marker.key == const ValueKey('user')) return null;
    return _eventData.firstWhere(
      (e) => e['id'] == (marker.key as ValueKey).value,
      orElse: () => {},
    );
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
            _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                  options: MapOptions(
                    center: _currentPosition,
                    zoom: 14,
                    onTap: (_, __) => _popupController.hideAllPopups(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers:
                          _markers
                              .where((m) => m.key == const ValueKey('user'))
                              .toList(),
                    ),
                    PopupMarkerLayer(
                      options: PopupMarkerLayerOptions(
                        markers:
                            _markers
                                .where((m) => m.key != const ValueKey('user'))
                                .toList(),
                        popupController: _popupController,
                        popupDisplayOptions: PopupDisplayOptions(
                          builder: (BuildContext context, Marker marker) {
                            final event = _getEventDataByMarker(marker);
                            if (event == null) return const SizedBox.shrink();
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['nomeEvento'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (event['endereco'] != null)
                                      Text(event['endereco']),
                                    if (event['dataHora'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          _formatarDataHora(event['dataHora']),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            // Positioned(
            //   top: 60,
            //   left: 16,
            //   right: 16,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 12),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(24),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Color.fromARGB((0.1 * 255).toInt(), 0, 0, 0),
            //           blurRadius: 4,
            //           offset: const Offset(0, 2),
            //         ),
            //       ],
            //     ),
            //     child: TextField(
            //       decoration: const InputDecoration(
            //         hintText: 'Pesquisar evento pelo nome...',
            //         border: InputBorder.none,
            //         icon: Icon(Icons.search),
            //       ),
            //       onChanged: _onSearch,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Color(0xFFE3C8A8)),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF6A8A99),
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Eventos'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Mapa'),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Cadastrar Evento',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Sair'),
          ],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
