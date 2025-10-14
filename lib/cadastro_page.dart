import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';

// --------------------- PasswordField ---------------------
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = true,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: _toggleVisibility,
        ),
      ),
      validator: (value) {
        if (widget.isRequired && (value == null || value.isEmpty)) {
          return "Informe a senha";
        }
        if (value != null && value.isNotEmpty && value.length < 6) {
          return "A senha deve ter pelo menos 6 caracteres";
        }
        return null;
      },
    );
  }
}

// --------------------- CadastroPage ---------------------
class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final enderecoController = TextEditingController();
  final senhaController = TextEditingController();

  String? tipoUsuario;
  bool _isLoading = false;

  final List<String> opcoesUsuario = ['Gestor', 'Entregador', 'Receptor'];

  void _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final db = DBHelper();
      await db.inserirUsuario(
        nomeController.text.trim(),
        emailController.text.trim(),
        senhaController.text.trim(),
        tipoUsuario!,
        telefone: telefoneController.text.trim(),
        endereco: enderecoController.text.trim(),
      );

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado com sucesso!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    enderecoController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome completo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Informe seu nome" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefoneController,
                decoration: const InputDecoration(
                  labelText: "Telefone",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                value == null || value.isEmpty ? "Informe seu telefone" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Informe seu e-mail";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "E-mail inválido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: enderecoController,
                decoration: const InputDecoration(
                  labelText: "Endereço",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Informe seu endereço" : null,
              ),
              const SizedBox(height: 16),
              PasswordField(controller: senhaController, label: "Senha"),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Tipo de usuário",
                  border: OutlineInputBorder(),
                ),
                value: tipoUsuario,
                items: opcoesUsuario
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                    .toList(),
                onChanged: (valor) => setState(() => tipoUsuario = valor),
                validator: (value) =>
                value == null ? "Selecione um tipo de usuário" : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _cadastrar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Cadastrar", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
