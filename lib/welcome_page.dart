import 'package:flutter/material.dart';
import 'main.dart';
import 'gestor_entregas.dart';
import 'package:provider/provider.dart';
import 'entregas_provider.dart';
import 'entregadores_page.dart';
import 'relatorios_gestor.dart';
import 'receptores_page.dart';

// ================= PÁGINA DE BOAS-VINDAS =================
class WelcomePage extends StatelessWidget {
  final String nomeDoUsuario;
  final String tipoUsuario;

  const WelcomePage({
    super.key,
    required this.nomeDoUsuario,
    required this.tipoUsuario,
  });

  String _primeiroNome(String nomeCompleto) {
    return nomeCompleto.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final primeiroNome = _primeiroNome(nomeDoUsuario);

    if (tipoUsuario == "Gestor") {
      return GestorPage(nomeDoUsuario: primeiroNome);
    } else if (tipoUsuario == "Entregador") {
      return EntregadorPage(nomeDoUsuario: primeiroNome);
    } else {
      return ReceptorPage(nomeDoUsuario: primeiroNome);
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
        child: Center(
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
              _MenuButton(
                icon: Icons.people,
                label: "Entregadores",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EntregadoresPage()),
                  );
                },
              ),
              _MenuButton(
                icon: Icons.person,
                label: "Receptores",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReceptoresPage()),
                  );
                },
              ),
              _MenuButton(
                icon: Icons.bar_chart,
                label: "Relatórios",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RelatoriosGestorPage()),
                  );
                },
              ),
              _MenuButton(icon: Icons.settings, label: "Configuração"),
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
        title: Text("Olá, $nomeDoUsuario!", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF005050),
        centerTitle: true,
      ),
      body: _EntregasListView(
        provider: provider,
        titulo: "Pronto para as entregas de hoje?",
        podeConcluir: true,
      ),
    );
  }
}

// ================= RECEPTOR =================
class ReceptorPage extends StatelessWidget {
  final String nomeDoUsuario;

  const ReceptorPage({super.key, required this.nomeDoUsuario});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EntregasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Olá, $nomeDoUsuario!", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF005050),
        centerTitle: true,
      ),
      body: _EntregasListView(
        provider: provider,
        titulo: "Aqui estão as suas entregas agendadas:",
        podeConcluir: false,
      ),
    );
  }
}

// ================= COMPONENTE COMPARTILHADO =================
class _EntregasListView extends StatelessWidget {
  final EntregasProvider provider;
  final String titulo;
  final bool podeConcluir;

  const _EntregasListView({
    required this.provider,
    required this.titulo,
    required this.podeConcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF005050)),
            ),
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
                              child: Text(e['endereco'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Text(e['status'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold, color: cor)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Entregador: ${e['entregador'] ?? 'N/A'}"),
                        Text("Horário: ${e['horario'] ?? '---'}"),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(onPressed: () {}, child: const Text("Detalhes")),
                            if (podeConcluir) ...[
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  provider.atualizarStatus(index, "Concluída");
                                },
                                child: const Text("Concluir"),
                              ),
                            ],
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
    );
  }
}

// ================= BOTÃO DE MENU =================
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
