import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'entregas_provider.dart';
import 'main.dart';
import 'gestor_entregas.dart';
import 'entregadores_page.dart';
import 'receptores_page.dart';
import 'relatorios_gestor.dart';

class WelcomePage extends StatefulWidget {
  final String nomeDoUsuario;
  final String tipoUsuario;
  final String emailUsuario;

  const WelcomePage({
    super.key,
    required this.nomeDoUsuario,
    required this.tipoUsuario,
    required this.emailUsuario,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<EntregasProvider>(context, listen: false);

    if (widget.tipoUsuario == "Gestor") {
      provider.carregarEntregas();
    } else if (widget.tipoUsuario == "Entregador") {
      provider.carregarEntregasDoEntregador(widget.emailUsuario);
    } else {
      provider.carregarEntregasDoReceptor(widget.emailUsuario);
    }
  }

  String _primeiroNome(String nomeCompleto) => nomeCompleto.split(' ').first;

  @override
  Widget build(BuildContext context) {
    final primeiroNome = _primeiroNome(widget.nomeDoUsuario);

    if (widget.tipoUsuario == "Gestor") {
      return GestorPage(nomeDoUsuario: primeiroNome);
    } else if (widget.tipoUsuario == "Entregador") {
      return EntregadorPage(nomeDoUsuario: primeiroNome, email: widget.emailUsuario);
    } else {
      return ReceptorPage(nomeDoUsuario: primeiroNome, email: widget.emailUsuario);
    }
  }
}

// ================= GESTOR =================
class GestorPage extends StatelessWidget {
  final String nomeDoUsuario;

  const GestorPage({super.key, required this.nomeDoUsuario});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EntregasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Olá, $nomeDoUsuario!", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF005050),
        centerTitle: true,
        actions: [
          // Botão de notificações direcionando para alertas recentes
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            tooltip: "Ver alertas recentes",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RelatoriosGestorPage(scrollParaAlertas: true),
                ),
              );
            },
          ),
        ],
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GestorEntregasPage()),
                ),
              ),
              _MenuButton(
                icon: Icons.people,
                label: "Entregadores",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EntregadoresPage()),
                ),
              ),
              _MenuButton(
                icon: Icons.person,
                label: "Receptores",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReceptoresPage()),
                ),
              ),
              _MenuButton(
                icon: Icons.bar_chart,
                label: "Relatórios",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RelatoriosGestorPage()),
                ),
              ),
              _MenuButton(icon: Icons.settings, label: "Configuração"),
              _MenuButton(
                icon: Icons.logout,
                label: "Sair",
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                ),
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
  final String email;

  const EntregadorPage({super.key, required this.nomeDoUsuario, required this.email});

  @override
  Widget build(BuildContext context) {
    return Consumer<EntregasProvider>(
      builder: (context, provider, _) {
        final entregasUsuario =
        provider.entregas.where((e) => e.entregadorEmail == email).toList();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("Olá, $nomeDoUsuario!", style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF005050),
            centerTitle: true,
          ),
          body: _EntregasListView(
            provider: provider,
            entregas: entregasUsuario,
            titulo: "Pronto para as entregas de hoje?",
            podeConcluir: true,
          ),
        );
      },
    );
  }
}

// ================= RECEPTOR =================
class ReceptorPage extends StatelessWidget {
  final String nomeDoUsuario;
  final String email;

  const ReceptorPage({super.key, required this.nomeDoUsuario, required this.email});

  @override
  Widget build(BuildContext context) {
    return Consumer<EntregasProvider>(
      builder: (context, provider, _) {
        final entregasUsuario =
        provider.entregas.where((e) => e.receptorEmail == email).toList();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("Olá, $nomeDoUsuario!", style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF005050),
            centerTitle: true,
          ),
          body: _EntregasListView(
            provider: provider,
            entregas: entregasUsuario,
            titulo: "Aqui estão as suas entregas agendadas:",
            podeConcluir: false,
          ),
        );
      },
    );
  }
}

// ================= COMPONENTE COMPARTILHADO =================
class _EntregasListView extends StatelessWidget {
  final EntregasProvider provider;
  final List<Entrega> entregas;
  final String titulo;
  final bool podeConcluir;

  const _EntregasListView({
    required this.provider,
    required this.entregas,
    required this.titulo,
    required this.podeConcluir,
  });

  void _mostrarDetalhes(BuildContext context, Entrega e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Detalhes da Entrega #${e.id}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Produto: ${e.produto}"),
            Text("Destino: ${e.destino}"),
            Text("Entregador: ${e.entregador}"),
            Text("Receptor: ${e.receptor}"),
            Text("Data/Hora: ${e.dataEntrega}"),
            Text("Status: ${e.status}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fechar"))
        ],
      ),
    );
  }

  void _abrirModalProblema(BuildContext context, Entrega e) {
    final motivos = {
      "Destinatário ausente": false,
      "Endereço incorreto": false,
      "Destinatário mudou-se": false,
      "Outro": false,
    };
    final descricaoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.87,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 24,
                  left: 16,
                  right: 16,
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reportar Problema",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...motivos.keys.map((m) => CheckboxListTile(
                        title: Text(m),
                        value: motivos[m],
                        onChanged: (v) => setState(() => motivos[m] = v!),
                      )),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descricaoController,
                        decoration: const InputDecoration(
                          labelText: "Descreva o problema",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text("Enviar Relato"),
                        onPressed: () async {
                          final motivosSelecionados = motivos.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toList();

                          if (descricaoController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Por favor, descreva o problema.")),
                            );
                            return;
                          }

                          if (motivosSelecionados.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Selecione pelo menos um motivo.")),
                            );
                            return;
                          }

                          await provider.reportarProblema(
                            entrega: e,
                            motivos: motivosSelecionados,
                            descricao: descricaoController.text.trim(),
                          );

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Problema reportado com sucesso!")),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: Text(
              titulo,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF005050)),
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
                  Text("Total: ${entregas.length}"),
                  Text("Concluídas: ${entregas.where((e) => e.status == "Concluída").length}"),
                  Text("Pendentes: ${entregas.where((e) => e.status == "Pendente").length}"),
                  Text("Atrasadas: ${entregas.where((e) => e.status == "Atrasada").length}"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: entregas.length,
              itemBuilder: (context, index) {
                final e = entregas[index];
                Color cor;
                switch (e.status) {
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
                              child: Text(e.destino,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Text(e.status,
                                style: TextStyle(fontWeight: FontWeight.bold, color: cor)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Produto: ${e.produto}"),
                        Text("Entregador: ${e.entregador}"),
                        Text("Receptor: ${e.receptor}"),
                        Text("Data/Hora: ${e.dataEntrega}"),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => _mostrarDetalhes(context, e),
                              child: const Text("Detalhes"),
                            ),
                            if (podeConcluir) ...[
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => provider.atualizarStatus(e, "Concluída"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text("Concluir", style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _abrirModalProblema(context, e),
                                child: const Text("Problemas", style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
            ),
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
