import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegisterEvent extends StatefulWidget {
  const RegisterEvent({super.key});

  @override
  State<RegisterEvent> createState() => _RegisterEventState();
}

class _RegisterEventState extends State<RegisterEvent> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _nomeEvento = TextEditingController();
  final TextEditingController _endereco = TextEditingController();
  final TextEditingController _data = TextEditingController();
  final TextEditingController _hora = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _confirmarSenha = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
                  // Event Name
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
                  // Address
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
                  // Date
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
                  // Time
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
                  // Save Event Button
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
                      final email = _email.text.trim();
                      final senha = _senha.text.trim();
                      final confirmarSenha = _confirmarSenha.text.trim();

                      if (nomeEvento.isEmpty ||
                          endereco.isEmpty ||
                          data.isEmpty ||
                          hora.isEmpty ||
                          email.isEmpty ||
                          senha.isEmpty ||
                          confirmarSenha.isEmpty) {
                        _showError('Preencha todos os campos.');
                        return;
                      }

                      if (senha != confirmarSenha) {
                        _showError('As senhas não coincidem.');
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
                          'email': email,
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
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Voltar para o Login',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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