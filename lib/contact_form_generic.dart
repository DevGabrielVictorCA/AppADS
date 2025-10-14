import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'models.dart';


typedef SaveCallback<T> = Future<T> Function(T item);

// --------------------- PasswordFormField ---------------------
class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;

  const PasswordFormField({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = true,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
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
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: _toggleVisibility,
        ),
      ),
      validator: (v) {
        if (widget.isRequired && (v == null || v.isEmpty)) {
          return "Informe a senha";
        }
        return null;
      },
    );
  }
}

// --------------------- ContactFormReceptor ---------------------
class ContactFormReceptor extends StatefulWidget {
  final Receptor? receptor;
  final String? senhaExistente;
  final DBHelper dbHelper;
  final SaveCallback<Receptor>? onSave;

  const ContactFormReceptor({
    super.key,
    this.receptor,
    this.senhaExistente,
    required this.dbHelper,
    this.onSave,
  });

  @override
  State<ContactFormReceptor> createState() => _ContactFormReceptorState();
}

class _ContactFormReceptorState extends State<ContactFormReceptor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.receptor?.name ?? "");
    phoneController = TextEditingController(text: widget.receptor?.phone ?? "");
    emailController = TextEditingController(text: widget.receptor?.email ?? "");
    addressController = TextEditingController(text: widget.receptor?.address ?? "");
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.receptor != null;
      String senhaParaSalvar = passwordController.text;

      // 🔸 Mantém senha antiga se o campo estiver vazio
      if (isEditing && senhaParaSalvar.isEmpty) {
        final usuarioExistente =
        await widget.dbHelper.getUsuarioById(widget.receptor!.id!);
        senhaParaSalvar = usuarioExistente?['senha']?.toString() ?? '';
      }

      final novoReceptor = Receptor(
        id: widget.receptor?.id,
        name: nameController.text,
        phone: phoneController.text,
        email: emailController.text,
        address: addressController.text,
      );

      if (!isEditing) {
        await widget.dbHelper.inserirUsuario(
          nameController.text,
          emailController.text,
          senhaParaSalvar,
          "Receptor", // ✅ corrigido
          telefone: phoneController.text,
          endereco: addressController.text,
        );
      } else {
        await widget.dbHelper.updateUsuario(
          widget.receptor!.id!,
          nameController.text,
          emailController.text,
          senhaParaSalvar,
          "Receptor", // ✅ corrigido
          telefone: phoneController.text,
          endereco: addressController.text,
        );
      }

      if (widget.onSave != null) await widget.onSave!(novoReceptor);
      if (mounted) Navigator.pop(context, novoReceptor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.receptor != null;

    return AlertDialog(
      title: Text(isEditing ? "Editar Receptor" : "Novo Receptor"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nome Completo"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o nome completo" : null,
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: "Telefone"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o telefone" : null,
              ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Informe o email";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return "Email inválido";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: addressController,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(labelText: "Endereço"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o endereço" : null,
              ),
              const SizedBox(height: 12),
              PasswordFormField(
                controller: passwordController,
                label: isEditing ? "Nova Senha (opcional)" : "Senha",
                isRequired: !isEditing,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --------------------- ContactFormEntregador ---------------------
class ContactFormEntregador extends StatefulWidget {
  final Entregador? entregador;
  final String? senhaExistente;
  final DBHelper dbHelper;
  final SaveCallback<Entregador>? onSave;

  const ContactFormEntregador({
    super.key,
    this.entregador,
    this.senhaExistente,
    required this.dbHelper,
    this.onSave,
  });

  @override
  State<ContactFormEntregador> createState() => _ContactFormEntregadorState();
}

class _ContactFormEntregadorState extends State<ContactFormEntregador> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.entregador?.name ?? "");
    phoneController = TextEditingController(text: widget.entregador?.phone ?? "");
    emailController = TextEditingController(text: widget.entregador?.email ?? "");
    addressController = TextEditingController(text: widget.entregador?.address ?? "");
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.entregador != null;
      String senhaParaSalvar = passwordController.text;

      // 🔸 Mantém senha antiga se o campo estiver vazio
      if (isEditing && senhaParaSalvar.isEmpty) {
        final usuarioExistente =
        await widget.dbHelper.getUsuarioById(widget.entregador!.id!);
        senhaParaSalvar = usuarioExistente?['senha']?.toString() ?? '';
      }

      final novoEntregador = Entregador(
        id: widget.entregador?.id,
        name: nameController.text,
        phone: phoneController.text,
        email: emailController.text,
        address: addressController.text,
      );

      if (!isEditing) {
        await widget.dbHelper.inserirUsuario(
          nameController.text,
          emailController.text,
          senhaParaSalvar,
          "Entregador",
          telefone: phoneController.text,
          endereco: addressController.text,
        );
      } else {
        await widget.dbHelper.updateUsuario(
          widget.entregador!.id!,
          nameController.text,
          emailController.text,
          senhaParaSalvar,
          "Entregador",
          telefone: phoneController.text,
          endereco: addressController.text,
        );
      }

      if (widget.onSave != null) await widget.onSave!(novoEntregador);
      if (mounted) Navigator.pop(context, novoEntregador);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entregador != null;

    return AlertDialog(
      title: Text(isEditing ? "Editar Entregador" : "Novo Entregador"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nome Completo"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o nome completo" : null,
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: "Telefone"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o telefone" : null,
              ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Informe o email";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return "Email inválido";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: addressController,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(labelText: "Endereço"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o endereço" : null,
              ),
              const SizedBox(height: 12),
              PasswordFormField(
                controller: passwordController,
                label: isEditing ? "Nova Senha (opcional)" : "Senha",
                isRequired: !isEditing,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
