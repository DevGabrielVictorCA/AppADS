import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'entrega.dart';
import 'add_entrega.dart';

class GestorEntregasPage extends StatefulWidget {
  const GestorEntregasPage({super.key});

  @override
  State<GestorEntregasPage> createState() => _GestorEntregasPageState();
}

class _GestorEntregasPageState extends State<GestorEntregasPage> {
  final DBHelper dbHelper = DBHelper();
  List<Entrega> entregas = [];

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {
    final lista = await dbHelper.getEntregas();
    setState(() {
      entregas = lista;
    });
  }

  Future<void> _abrirEntrega({Entrega? entrega}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEntregaPage(entrega: entrega),
      ),
    );
    if (resultado == true) {
      _carregarEntregas();
    }
  }

  Future<void> _deletarEntrega(int id) async {
    await dbHelper.deleteEntrega(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Entrega deletada!")));
    _carregarEntregas();
  }

  Future<void> _atualizarConcluida(Entrega entrega, bool valor) async {
    entrega.concluida = valor;
    if (valor) {
      entrega.status = "Concluída";
    } else {
      final agora = DateTime.now();
      final dataEntrega = DateTime.tryParse(entrega.dataEntrega);
      if (dataEntrega != null && dataEntrega.isBefore(agora)) {
        entrega.status = "Atrasada";
      } else {
        entrega.status = "Pendente";
      }
    }
    await dbHelper.updateEntrega(entrega);
    _carregarEntregas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestor de Entregas")),
      body: ListView.builder(
        itemCount: entregas.length,
        itemBuilder: (context, index) {
          final e = entregas[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(e.produto),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Destino: ${e.destino}"),
                  Text("Entregador: ${e.entregador}"),
                  Text("Status: ${e.status}"),
                ],
              ),
              isThreeLine: true,
              leading: Checkbox(
                value: e.concluida,
                onChanged: (valor) => _atualizarConcluida(e, valor!),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _abrirEntrega(entrega: e),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletarEntrega(e.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirEntrega(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
