import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'welcome_page.dart';
import 'entregas_provider.dart';
import 'cadastro_page.dart';
import 'db_helper.dart';

void main() {
  // Inicialização do sqflite para desktop (Windows, Linux, macOS)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => EntregasProvider(),
      child: const MyApp(),
    ),
  );
}

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

// ================= LOGIN PAGE =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? tipoUsuarioSelecionado;
  final List<String> opcoes = ['Gestor', 'Entregador', 'Receptor'];
  bool _obscureSenha = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();
    final tipo = tipoUsuarioSelecionado;

    if (email.isEmpty || senha.isEmpty || tipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos!')),
      );
      return;
    }

    final db = DBHelper();
    final usuario = await db.autenticarUsuario(email, senha);

    if (usuario != null && usuario['tipoUsuario'] == tipo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomePage(
            nomeDoUsuario: usuario['nome']?.toString() ?? '',
            tipoUsuario: usuario['tipoUsuario']?.toString() ?? '',
          ),
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário ou senha incorretos!')),
      );
    }
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-Vindo!',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            // Botão Limpar Dados
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final db = DBHelper();
                await db.limparTudo();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todos os usuários foram apagados!')),
                );
              },
              child: const Text('Limpar usuários (teste)'),
            ),


            const SizedBox(height: 10),
            LoginCard(
              emailController: _emailController,
              passwordController: _passwordController,
              valorSelecionado: tipoUsuarioSelecionado,
              opcoes: opcoes,
              onChanged: (novo) {
                setState(() {
                  tipoUsuarioSelecionado = novo;
                });
              },
              onLoginPressed: _fazerLogin,
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

// ================= CARD DE LOGIN =================
class LoginCard extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? valorSelecionado;
  final List<String> opcoes;
  final void Function(String?) onChanged;
  final VoidCallback onLoginPressed;

  const LoginCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.valorSelecionado,
    required this.opcoes,
    required this.onChanged,
    required this.onLoginPressed,
  });

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  bool _obscureSenha = true;
  bool _isUnderlined = false;

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
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: widget.passwordController,
                obscureText: _obscureSenha,
                decoration: InputDecoration(
                  labelText: "Senha",
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureSenha ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() => _obscureSenha = !_obscureSenha);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: widget.valorSelecionado,
                hint: const Text("Selecione o usuário"),
                isExpanded: true,
                items: widget.opcoes.map((valor) {
                  return DropdownMenuItem(
                    value: valor,
                    child: Text(valor),
                  );
                }).toList(),
                onChanged: widget.onChanged,
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
                  onPressed: widget.onLoginPressed,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 35),
              GestureDetector(
                onTapDown: (_) => setState(() => _isUnderlined = true),
                onTapUp: (_) async {
                  await Future.delayed(const Duration(milliseconds: 150));
                  setState(() => _isUnderlined = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastroPage()),
                  );
                },
                onTapCancel: () => setState(() => _isUnderlined = false),
                child: Text.rich(
                  TextSpan(
                    text: "Ainda não tem registro? ",
                    style: const TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: "Cadastrar",
                        style: TextStyle(
                          color: const Color(0xFF005050),
                          fontWeight: FontWeight.bold,
                          decoration: _isUnderlined
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
