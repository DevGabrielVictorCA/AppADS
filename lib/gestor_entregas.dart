import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'entregas_provider.dart';
import 'criar_entrega.dart';

class GestorEntregasPage extends StatelessWidget {
  const GestorEntregasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EntregasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Entregas", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF005050),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Criar Nova Entrega"),
              onPressed: () async {
                final novaEntrega =
                await Navigator.push<Map<String, String>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CriarEntregaPage(),
                  ),
                );

                if (novaEntrega != null) {
                  provider.adicionarEntrega(novaEntrega);
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.entregas.length,
                itemBuilder: (context, index) {
                  final e = provider.entregas[index];
                  Color cor;
                  switch (e['status']) {
                    case "Concluída":
                      cor = Colors.green;
                      break;
                    case "Pendente":
                      cor = Colors.yellow[700]!;
                      break;
                    default:
                      cor = Colors.red;
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: cor),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(e['endereco']!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Text(e['status']!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, color: cor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Destinatário: ${e['destinatario']}"),
                          Text("Horário: ${e['horario']}"),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Detalhes")),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                  onPressed: () {
                                    provider.atualizarStatus(index, "Concluída");
                                  },
                                  child: const Text("Concluir")),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Problemas")),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
