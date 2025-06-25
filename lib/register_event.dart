import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'event_list_page.dart';
import 'map_screen.dart';
import 'main.dart';
import 'package:geocoding/geocoding.dart';

class RegisterEvent extends StatefulWidget {
  const RegisterEvent({super.key});

  @override
  State<RegisterEvent> createState() => _RegisterEventState();
}

class _RegisterEventState extends State<RegisterEvent> {
  final TextEditingController _nomeEvento = TextEditingController();
  final TextEditingController _endereco = TextEditingController();
  final TextEditingController _cep = TextEditingController();
  final TextEditingController _data = TextEditingController();
  final TextEditingController _hora = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedIndex = 2;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _data.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        // Sempre salva no formato 24h
        _hora.text = picked.hour.toString().padLeft(2, '0') + ':' + picked.minute.toString().padLeft(2, '0');
      });
    }
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      );
    } else if (index == 2) {
      // já está na tela de cadastro
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A8A99),
        title: const Text('Cadastro de Evento'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A8A99), Color(0xFFE3C8A8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            heightFactor: 0.9,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: <Widget>[
                  // Nome do Evento
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _nomeEvento,
                    decoration: InputDecoration(
                      labelText: 'Nome do Evento',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: const Color(0xFFE3C8A8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16.0),
                  // Endereço
                  TextField(
                    keyboardType: TextInputType.streetAddress,
                    controller: _endereco,
                    decoration: InputDecoration(
                      labelText: 'Endereço',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: const Color(0xFFE3C8A8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16.0),
                  // Cep
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _cep,
                    decoration: InputDecoration(
                      labelText: 'CEP',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: const Color(0xFFE3C8A8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLength: 20,
                  ),
                  const SizedBox(height: 16.0),
                  // Data
                  TextField(
                    controller: _data,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data do Evento',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: const Color(0xFFE3C8A8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.black),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Hora
                  TextField(
                    controller: _hora,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Hora do Evento',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: const Color(0xFFE3C8A8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time, color: Colors.black),
                        onPressed: () => _selectTime(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A8A99),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      final nomeEvento = _nomeEvento.text.trim();
                      final endereco = _endereco.text.trim();
                      final cepText = _cep.text.trim();
                      final dataText = _data.text.trim();
                      final horaText = _hora.text.trim();

                      if (nomeEvento.isEmpty ||
                          endereco.isEmpty ||
                          cepText.isEmpty ||
                          dataText.isEmpty ||
                          horaText.isEmpty) {
                        _showError('Preencha todos os campos.');
                        return;
                      }

                      int? cep = int.tryParse(cepText.replaceAll(RegExp(r'[^0-9]'), ''));
                      if (cep == null) {
                        _showError('CEP inválido.');
                        return;
                      }

                      try {
                        final dataParts = dataText.split('/');
                        final horaParts = horaText.split(':');
                        if (dataParts.length != 3 || horaParts.length != 2) {
                          _showError('Data ou hora inválida.');
                          return;
                        }
                        final eventDateTime = DateTime(
                          int.parse(dataParts[2]),
                          int.parse(dataParts[1]),
                          int.parse(dataParts[0]),
                          int.parse(horaParts[0]),
                          int.parse(horaParts[1]),
                        );
                        final Timestamp dataHora = Timestamp.fromDate(eventDateTime);

                        _showLoading(context);

                        try {
                          // Geocoding: busca latitude/longitude pelo endereço ou CEP
                          List<Location> locations = [];
                          try {
                            locations = await locationFromAddress('$endereco, $cepText');
                          } catch (_) {
                            // Tenta só pelo CEP se falhar
                            locations = await locationFromAddress(cepText);
                          }

                          double? latitude;
                          double? longitude;
                          if (locations.isNotEmpty) {
                            latitude = locations.first.latitude;
                            longitude = locations.first.longitude;
                          }

                          if (latitude == null || longitude == null) {
                            _hideLoading(context);
                            _showError('Não foi possível localizar o endereço.');
                            return;
                          }

                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            _hideLoading(context);
                            _showError('Usuário não autenticado.');
                            return;
                          }

                          await FirebaseFirestore.instance.collection('eventos').add({
                            'nomeEvento': nomeEvento,
                            'endereco': endereco,
                            'cep': cep,
                            'dataHora': dataHora,
                            'dataCadastro': Timestamp.now(),
                            'userId': user.uid,
                            'localizacao': GeoPoint(latitude, longitude),
                          });

                          _hideLoading(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Evento cadastrado com sucesso!')),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const EventListPage()),
                            (route) => false,
                          );
                        } catch (e) {
                          _hideLoading(context);
                          _showError('Erro ao salvar evento: $e');
                        }
                      } catch (e) {
                        _showError('Data ou hora inválida. $e');
                      }
                    },
                    child: const Text('Salvar Evento'),
                  ),
                ],
              ),
            ),
          ),
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _hideLoading(BuildContext context) {
    Navigator.pop(context);
  }
}