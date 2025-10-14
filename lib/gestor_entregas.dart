import 'package:flutter/material.dart';
import 'add_entrega.dart';
import 'db_helper.dart';
import 'models.dart';

class GestorEntregasPage extends StatefulWidget {
  final int? entregaSelecionadaId; // id da entrega que queremos focar

  const GestorEntregasPage({super.key, this.entregaSelecionadaId});

  @override
  State<GestorEntregasPage> createState() => _GestorEntregasPageState();
}

class _GestorEntregasPageState extends State<GestorEntregasPage> {
  final DBHelper dbHelper = DBHelper();
  List<Entrega> entregas = [];
  bool carregando = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {
    setState(() => carregando = true);
    final lista = await dbHelper.getEntregas();

    final agora = DateTime.now();
    for (var e in lista) {
      if (e.concluida) {
        e.status = 'Concluída';
      } else {
        try {
          final dataEntrega = DateTime.parse(e.dataEntrega);
          e.status = dataEntrega.isBefore(agora) ? 'Atrasada' : 'Pendente';
        } catch (_) {
          e.status = 'Pendente';
        }
      }
      await dbHelper.updateEntrega(e);
    }

    setState(() {
      entregas = lista;
      carregando = false;
    });

    // Scroll para entrega selecionada
    if (widget.entregaSelecionadaId != null) {
      final index = entregas.indexWhere((e) => e.id == widget.entregaSelecionadaId);
      if (index != -1) {
        await Future.delayed(const Duration(milliseconds: 300));
        _scrollController.animateTo(
          index * 100.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _deletarEntrega(int id) async {
    await dbHelper.deleteEntrega(id);
    _carregarEntregas();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Entrega removida!")));
    }
  }

  Future<void> _editarEntrega(Entrega entrega) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEntregaPage(entrega: entrega),
      ),
    );
    if (result == true) {
      _carregarEntregas();
    }
  }

  Widget _buildItemEntrega(Entrega e) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: Checkbox(
          value: e.concluida,
          onChanged: (val) async {
            e.concluida = val ?? false;
            if (e.concluida) {
              e.status = 'Concluída';
            } else {
              try {
                final dataEntrega = DateTime.parse(e.dataEntrega);
                e.status = dataEntrega.isBefore(DateTime.now())
                    ? 'Atrasada'
                    : 'Pendente';
              } catch (_) {
                e.status = 'Pendente';
              }
            }
            await dbHelper.updateEntrega(e);
            if (mounted) setState(() {});
          },
        ),
        title: Text(e.produto),
        subtitle: Text(
          "Destino: ${e.destino}\nEntregador: ${e.entregador}\nReceptor: ${e.receptor}\nData: ${e.dataEntrega}\nStatus: ${e.status}",
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (valor) {
            if (valor == 'Editar') _editarEntrega(e);
            if (valor == 'Excluir') _deletarEntrega(e.id!);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'Editar', child: Text('Editar')),
            PopupMenuItem(value: 'Excluir', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestor de Entregas")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : entregas.isEmpty
          ? const Center(child: Text("Nenhuma entrega cadastrada"))
          : RefreshIndicator(
        onRefresh: _carregarEntregas,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: entregas.length,
          itemBuilder: (_, index) => _buildItemEntrega(entregas[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEntregaPage()),
          );
          if (result == true) _carregarEntregas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
