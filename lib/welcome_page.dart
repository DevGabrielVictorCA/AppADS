import 'package:flutter/material.dart';
import 'main.dart';
import 'gestor_entregas.dart';
import 'package:provider/provider.dart';
import 'entregas_provider.dart';
import 'contatos.dart';


// ================= PÁGINA DE BOAS-VINDAS =================
class WelcomePage extends StatelessWidget {
  final String nomeDoUsuario;
  final String tipoUsuario;

  const WelcomePage({
    super.key,
    required this.nomeDoUsuario,
    required this.tipoUsuario,
  });

  @override
  Widget build(BuildContext context) {
    if (tipoUsuario == "Gestor") {
      return GestorPage(nomeDoUsuario: nomeDoUsuario);
    } else {
      return EntregadorPage(nomeDoUsuario: nomeDoUsuario);
    }
  }
}

// ================= GESTOR =================
class GestorPage extends StatelessWidget {
  final String nomeDoUsuario;

  const GestorPage({super.key, required this.nomeDoUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Olá, $nomeDoUsuario!", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF005050),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumo do dia",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF005050)),
            ),
            const SizedBox(height: 16),
            // Cards com dados importantes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _ResumoCard(title: "Total Entregas", value: "15"),
                _ResumoCard(title: "Entregas Concluídas", value: "9"),
                _ResumoCard(title: "Pendentes", value: "6"),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Alertas recentes",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF005050)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.notification_important, color: Colors.red),
                    title: Text("Entrega atrasada: Rua C, 789"),
                  ),
                  ListTile(
                    leading: Icon(Icons.notification_important, color: Colors.orange),
                    title: Text("Nova entrega adicionada: Av. D, 101"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Botões principais
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MenuButton(
                    icon: Icons.local_shipping,
                    label: "Entregas",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GestorEntregasPage()),
                      );
                    },
                  ),
                  _MenuButton(icon: Icons.people, label: "Entregadores"),
                  _MenuButton(icon: Icons.bar_chart, label: "Relatórios"),
                  _MenuButton(icon: Icons.notifications, label: "Notificações"),
                  _MenuButton(icon: Icons.settings, label: "Configuração"),

                  _MenuButton(
                    icon: Icons.contact_page,
                    label: "Contatos",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ContatosPage()),
                      );
                    },
                  ),

                  _MenuButton(
                    icon: Icons.logout,
                    label: "Sair",
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ENTREGADOR =================
class EntregadorPage extends StatelessWidget {
  final String nomeDoUsuario;

  const EntregadorPage({super.key, required this.nomeDoUsuario});

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
        title: Text("Olá, $nomeDoUsuario!", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF005050),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Text(
                  "Pronto para as entregas de hoje?",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF005050))),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Total: ${provider.entregas.length}"),
                    Text("Concluídas: ${provider.entregas.where((e) => e['status'] == "Concluída").length}"),
                    Text("Pendentes: ${provider.entregas.where((e) => e['status'] == "Pendente").length}"),
                  ],
                ),
              ),
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
                                      style: const TextStyle(fontWeight: FontWeight.bold))),
                              Text(e['status']!,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: cor)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Destinatário: ${e['destinatario']}"),
                          Text("Horário: ${e['horario']}"),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(onPressed: () {}, child: const Text("Detalhes")),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                  onPressed: () {
                                    provider.atualizarStatus(index, "Concluída");
                                  },
                                  child: const Text("Concluir")),
                              const SizedBox(width: 8),
                              ElevatedButton(onPressed: () {}, child: const Text("Problemas")),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sair"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= WIDGET AUXILIAR =================
class _ResumoCard extends StatelessWidget {
  final String title;
  final String value;

  const _ResumoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[100],
      child: SizedBox(
        width: 120,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.teal),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
