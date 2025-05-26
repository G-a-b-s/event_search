import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditEvent extends StatefulWidget {
  final Map<String, dynamic> eventData;
  const EditEvent({
    super.key,
    required this.eventData,
  });

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  late final TextEditingController _nome;
  late final TextEditingController _endereco;
  late final TextEditingController _data;
  late final TextEditingController _hora;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _didDeps = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the incoming event data:
    _nome = TextEditingController(text: widget.eventData['nome'] as String? ?? '');
    _endereco   = TextEditingController(text: widget.eventData['endereco']   as String? ?? '');

    final rawDate = widget.eventData['data'];
    if (rawDate is Timestamp) {
      _selectedDate = rawDate.toDate();
      _data = TextEditingController(text: DateFormat('dd/MM/yyyy').format(_selectedDate!));
    } else {
      _data = TextEditingController(text: widget.eventData['data'] as String? ?? '');
    }

    final rawTime = widget.eventData['hora'] as String? ?? '';
    _hora = TextEditingController(text: rawTime);

  if (rawTime.contains(':')) {
    final parts = rawTime.split(':');
    _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_selectedTime != null) {
      _hora.text = _selectedTime!.format(context);
    }
  });

    // _email            = TextEditingController(text: widget.eventData['email'] as String? ?? '');
    // _senha            = TextEditingController();
    // _confirmarSenha   = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didDeps && _selectedTime != null) {
      _hora.text = _selectedTime!.format(context);
    }
    _didDeps = true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _data.text   = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _hora.text    = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A8A99),
        title: const Text('Edição de Evento'),
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
                    controller: _nome,
                    decoration: _inputDecoration('Nome do Evento'),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16.0),
                  // Endereço
                  TextField(
                    controller: _endereco,
                    decoration: _inputDecoration('Endereço'),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16.0),
                  // Data
                  TextField(
                    controller: _data,
                    readOnly: true,
                    decoration: _inputDecoration('Data do Evento').copyWith(
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
                    decoration: _inputDecoration('Hora do Evento').copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time, color: Colors.black),
                        onPressed: () => _selectTime(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A8A99),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: _saveEvent,
                    child: const Text('Salvar Alterações'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: const Color(0xFFE3C8A8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }

  Future<void> _saveEvent() async {
    final nome = _nome.text.trim();
    final endereco   = _endereco.text.trim();
    final data       = _data.text.trim();
    final hora       = _hora.text.trim();
    if (nome.isEmpty || endereco.isEmpty || data.isEmpty || hora.isEmpty) {
      _showError('Preencha todos os campos.');
      return;
    }

    _showLoading(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Usuário não autenticado';

      await FirebaseFirestore.instance
          .collection('eventos')
          .doc(user.uid)
          .update({
        'nomeEvento': nome,
        'endereco'  : endereco,
        'data'      : data,
        'hora'      : hora,
        'dataAtualizacao': Timestamp.now(),
      });

      Navigator.pop(context); // hide loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento atualizado com sucesso!')),
      );
      Navigator.pop(context); // close edit modal
    } catch (e) {
      Navigator.pop(context);
      _showError('Erro ao salvar evento: $e');
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    _endereco.dispose();
    _data.dispose();
    _hora.dispose();
    super.dispose();
  }
}