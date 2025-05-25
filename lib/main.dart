import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'register.dart';
import 'event_list_page.dart';
import 'map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // precisa disso antes do Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // aqui ele usa o arquivo gerado
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6A8A99)),
      ),
      home: const MyHomePage(title: 'EventSearch'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _obscurePassword = true;
  int _selectedIndex = 0;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _senha = TextEditingController();
  void _onItemTapped(int index) {
  if (index == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventListPage()),
    );
  } else {
    setState(() {
      _selectedIndex = index;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A8A99),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.title),
            const Divider(
              color: Colors.black,
              thickness: 1, // Espessura do divisor
              height: 1, // Altura do divisor
            ),
          ],
        ),
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
                    keyboardType: TextInputType.emailAddress,
                    controller:_email,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Color(0xFFE3C8A8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    obscureText: _obscurePassword,
                    controller:_senha,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Color(0xFFE3C8A8),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A8A99),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      final email = _email.text.trim();
                      final senha = _senha.text.trim();

                      if (email.isEmpty || senha.isEmpty) {
                        _showError("Preencha Email e Senha.");
                        return;
                      }
                      _showLoading(context);

                      try {
                        // Login com Firebase
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: senha,
                        );

                        _hideLoading(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login realizado com sucesso!')),
                        );

                        // Navegar para a tela principal:
                        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));

                      } on FirebaseAuthException catch (e) {
                        _hideLoading(context);
                        String mensagem = '';

                        switch (e.code) {
                          case 'invalid-email':
                            mensagem = 'Email inválido.';
                            break;
                          case 'user-not-found':
                            mensagem = 'Usuário não encontrado.';
                            break;
                          case 'wrong-password':
                            mensagem = 'Senha incorreta.';
                            break;
                          default:
                            mensagem = 'Erro de login: ${e.message}';
                            break;
                        }

                        _showError(mensagem);
                      } catch (e) {
                        _hideLoading(context);
                        _showError('Erro inesperado: $e');
                      }
                    },
                    child: const Text('Logar'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3C8A8),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text('Registrar'),
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Lógica do botão Esqueci minha senha
                      },
                      child: const Text(
                        'Esqueci minha senha',
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFFE3C8A8),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Login',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Eventos',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF6A8A99),
          onTap: _onItemTapped,
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
      barrierDismissible: false, // Impede que o modal seja fechado ao clicar fora
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(), // Indicador de progresso circular
        );
    },
  );
}
void _hideLoading(BuildContext context) {
  Navigator.pop(context); // Fecha o modal de loading
}
}
