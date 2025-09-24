import 'package:flutter/material.dart';

class CriarEntregaPage extends StatefulWidget {
  const CriarEntregaPage({super.key});

  @override
  State<CriarEntregaPage> createState() => _CriarEntregaPageState();
}

class _CriarEntregaPageState extends State<CriarEntregaPage> {
  final TextEditingController enderecoController = TextEditingController();
  final TextEditingController destinatarioController = TextEditingController();
  final TextEditingController horarioController = TextEditingController();
  String statusSelecionado = "Pendente";
  final List<String> opcoesStatus = ["Pendente", "Concluída", "Atrasada"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Nova Entrega"),
        backgroundColor: const Color(0xFF005050),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: enderecoController,
              decoration: const InputDecoration(labelText: "Endereço"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: destinatarioController,
              decoration: const InputDecoration(labelText: "Destinatário"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: horarioController,
              decoration: const InputDecoration(labelText: "Horário"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: statusSelecionado,
              isExpanded: true,
              items: opcoesStatus.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (novo) {
                setState(() {
                  statusSelecionado = novo!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (enderecoController.text.isEmpty ||
                    destinatarioController.text.isEmpty ||
                    horarioController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Preencha todos os campos")),
                  );
                  return;
                }

                Navigator.pop(context, {
                  "endereco": enderecoController.text,
                  "destinatario": destinatarioController.text,
                  "horario": horarioController.text,
                  "status": statusSelecionado,
                });
              },
              child: const Text("Criar"),
            ),
          ],
        ),
      ),
    );
  }
}
