import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'contact.dart';

class ContactFormPage extends StatefulWidget {
  final Contact? contact;
  const ContactFormPage({super.key, this.contact});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  late DBHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    if (widget.contact != null) {
      nameController.text = widget.contact!.name;
      phoneController.text = widget.contact!.phone;
      emailController.text = widget.contact!.email;
    }
  }

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final contact = Contact(
        id: widget.contact?.id,
        name: nameController.text,
        phone: phoneController.text,
        email: emailController.text,
      );

      if (widget.contact == null) {
        await dbHelper.insertContact(contact);
      } else {
        await dbHelper.updateContact(contact);
      }

      Navigator.pop(context, true); // retorna true p/ recarregar lista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? "Novo Contato" : "Editar Contato"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nome"),
                validator: (value) => value!.isEmpty ? "Informe o nome" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Telefone"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? "Informe o telefone" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "E-mail"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value!.isEmpty ? "Informe o e-mail" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
