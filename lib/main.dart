import 'package:flutter/material.dart';
import 'welcome_page.dart';

void main() {
  runApp(const MyApp());
}

// ================= LOGIN PAGE =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Educalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF005050)),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? valorSelecionado;
  final List<String> opcoes = ['Gestor', 'Entregador'];

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF005050),
        title: const Text(
          'Educalog',
          style: TextStyle(color: Colors.white, fontSize: 23.5),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF005050),
              Color(0xFF00837C),
              Color(0xFFD1FFFD),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-Vindo!',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            LoginCard(
              userController: _userController,
              passwordController: _passwordController,
              valorSelecionado: valorSelecionado,
              opcoes: opcoes,
              onChanged: (novo) {
                setState(() {
                  valorSelecionado = novo;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        height: 70,
        width: double.infinity,
        color: const Color(0xFF005050),
        alignment: Alignment.center,
        child: const Text(
          'Desenvolvido por Gabriel Cardoso © 2025',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  final TextEditingController userController;
  final TextEditingController passwordController;
  final String? valorSelecionado;
  final List<String> opcoes;
  final void Function(String?) onChanged;

  const LoginCard({
    super.key,
    required this.userController,
    required this.passwordController,
    required this.valorSelecionado,
    required this.opcoes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userController,
                decoration: const InputDecoration(
                  labelText: "Usuário:",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "Senha:",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: valorSelecionado,
                hint: const Text("Selecione o usuário"),
                isExpanded: true,
                items: opcoes.map((valor) {
                  return DropdownMenuItem(
                    value: valor,
                    child: Text(valor),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005050),
                    foregroundColor: Colors.white,
                    elevation: 5,
                  ),
                  onPressed: () {
                    final nomeDoUsuario = userController.text.trim();
                    final senhaDoUsuario = passwordController.text.trim();

                    if (nomeDoUsuario.isEmpty ||
                        senhaDoUsuario.isEmpty ||
                        valorSelecionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, preencha todos os campos!'),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WelcomePage(
                            nomeDoUsuario: nomeDoUsuario,
                            tipoUsuario: valorSelecionado!,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
