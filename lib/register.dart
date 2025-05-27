import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  final TextEditingController _confirmarSenha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A8A99),
        title: const Text('Cadastro'),
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
                  TextField(
                    keyboardType: TextInputType.name,
                    controller: _nome,
                    decoration: InputDecoration(
                      labelText: 'Nome',
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
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _email,
                    decoration: InputDecoration(
                      labelText: 'Email',
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
                  TextField(
                    obscureText: _obscurePassword,
                    controller: _senha,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: const Color(0xFFE3C8A8),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLength: 16,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    obscureText: _obscureConfirmPassword,
                    controller: _confirmarSenha,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Senha',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: const Color(0xFFE3C8A8),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLength: 16,
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
                      final nome = _nome.text.trim();
                      final email = _email.text.trim();
                      final senha = _senha.text.trim();
                      final confirmarSenha = _confirmarSenha.text.trim();

                      if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
                        _showError('Preencha todos os campos.');
                        return;
                      }
                      if (senha != confirmarSenha) {
                        _showError('As senhas não coincidem.');
                        return;
                      }
                      _showLoading(context);
                      try {
                        final cred = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(email: email, password: senha);

                        await FirebaseFirestore.instance
                            .collection('cadastro')
                            .doc(cred.user!.uid)
                            .set({
                              'nome': nome,
                              'email': email,
                              'dataCadastro': Timestamp.now(),
                            });

                        _hideLoading(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
                        );

                        Navigator.pop(context);
                      } on FirebaseAuthException catch (e) {
                        _hideLoading(context);
                        _showError('Erro de autenticação: ${e.message}');
                      } catch (e) {
                        _hideLoading(context);
                        _showError('Erro inesperado: $e');
                      }
                    },
                    child: const Text('Cadastrar'),
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

  void _showError(String mensage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensage)),
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
