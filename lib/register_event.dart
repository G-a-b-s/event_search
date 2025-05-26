import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'event_list_page.dart';
import 'map_screen.dart';
import 'main.dart';

class RegisterEvent extends StatefulWidget {
  const RegisterEvent({super.key});

  @override
  State<RegisterEvent> createState() => _RegisterEventState();
}

class _RegisterEventState extends State<RegisterEvent> {
  final TextEditingController _nomeEvento = TextEditingController();
  final TextEditingController _endereco = TextEditingController();
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
        _hora.text = picked.format(context);
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
      // Já está na tela de cadastro de evento
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
                      final data = _data.text.trim();
                      final hora = _hora.text.trim();

                      if (nomeEvento.isEmpty ||
                          endereco.isEmpty ||
                          data.isEmpty ||
                          hora.isEmpty) {
                        _showError('Preencha todos os campos.');
                        return;
                      }

                      _showLoading(context);

                      try {
                        // Fetch the current authenticated user
                        final User? user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          _hideLoading(context);
                          _showError('Nenhum usuário autenticado encontrado.');
                          return;
                        }

                        // Save event data to Firestore using the current user's UID
                        await FirebaseFirestore.instance
                            .collection('eventos')
                            .doc(user.uid)
                            .set({
                          'nomeEvento': nomeEvento,
                          'endereco': endereco,
                          'data': data,
                          'hora': hora,
                          'dataCadastro': Timestamp.now(),
                        });

                        _hideLoading(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Evento cadastrado com sucesso!')),
                        );

                        Navigator.pop(context);
                      } catch (e) {
                        _hideLoading(context);
                        _showError('Erro ao salvar evento: $e');
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFE3C8A8),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6A8A99),
        unselectedItemColor: Colors.black,
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