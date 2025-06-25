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
  late final TextEditingController _nomeEvento;
  late final TextEditingController _endereco;
  late final TextEditingController _cep;
  late final TextEditingController _data;
  late final TextEditingController _hora;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    _nomeEvento = TextEditingController(text: widget.eventData['nomeEvento'] as String? ?? '');
    _endereco   = TextEditingController(text: widget.eventData['endereco']   as String? ?? '');
    _cep        = TextEditingController(text: widget.eventData['cep']?.toString() ?? '');

    // Data e hora
    final rawTimestamp = widget.eventData['dataHora'];
    if (rawTimestamp is Timestamp) {
      final dt = rawTimestamp.toDate();
      _selectedDate = dt;
      _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      _data = TextEditingController(text: DateFormat('dd/MM/yyyy').format(dt));
      _hora = TextEditingController(
        text: dt.hour.toString().padLeft(2, '0') + ':' + dt.minute.toString().padLeft(2, '0'),
      );
    } else {
      _data = TextEditingController();
      _hora = TextEditingController();
    }
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
        _data.text = DateFormat('dd/MM/yyyy').format(picked);
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
        _hora.text = picked.hour.toString().padLeft(2, '0') + ':' + picked.minute.toString().padLeft(2, '0');
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
                    controller: _nomeEvento,
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
                  // Cep
                  TextField(
                    controller: _cep,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('CEP'),
                    maxLength: 20,
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
    final nomeEvento = _nomeEvento.text.trim();
    final endereco = _endereco.text.trim();
    final cepText = _cep.text.trim();
    final dataText = _data.text.trim();
    final horaText = _hora.text.trim();

    if (nomeEvento.isEmpty || endereco.isEmpty || cepText.isEmpty || dataText.isEmpty || horaText.isEmpty) {
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
      final eventDateTime = DateTime(
        int.parse(dataParts[2]),
        int.parse(dataParts[1]),
        int.parse(dataParts[0]),
        int.parse(horaParts[0]),
        int.parse(horaParts[1]),
      );
      final Timestamp dataHora = Timestamp.fromDate(eventDateTime);

      _showLoading(context);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _hideLoading(context);
        _showError('Usuário não autenticado.');
        return;
      }

      final docId = widget.eventData['docId'];
      if (docId == null) {
        _hideLoading(context);
        _showError('ID do evento não encontrado.');
        return;
      }

      await FirebaseFirestore.instance.collection('eventos').doc(docId).update({
        'nomeEvento': nomeEvento,
        'endereco': endereco,
        'cep': cep,
        'dataHora': dataHora,
        'dataAtualizacao': Timestamp.now(),
        'userId': user.uid,
      });

      _hideLoading(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento atualizado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      _hideLoading(context);
      _showError('Erro ao salvar evento: $e');
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

  void _hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nomeEvento.dispose();
    _endereco.dispose();
    _cep.dispose();
    _data.dispose();
    _hora.dispose();
    super.dispose();
  }
}