import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models.dart';
import 'contact_form_generic.dart';

class EntregadoresPage extends StatefulWidget {
  const EntregadoresPage({super.key});

  @override
  State<EntregadoresPage> createState() => _EntregadoresPageState();
}

class _EntregadoresPageState extends State<EntregadoresPage> {
  final DBHelper dbHelper = DBHelper();
  List<Entregador> entregadores = [];

  @override
  void initState() {
    super.initState();
    _carregarEntregadores();
  }

  Future<void> _carregarEntregadores() async {
    final lista = await dbHelper.getEntregadores();
    setState(() => entregadores = lista);
  }

  Future<void> _abrirFormulario({Entregador? entregador}) async {
    final resultado = await showDialog<Entregador>(
      context: context,
      builder: (_) => ContactFormEntregador(
        entregador: entregador,
        dbHelper: dbHelper,
        onSave: (e) async => e,
      ),
    );

    if (resultado != null) _carregarEntregadores();
  }

  Future<void> _deletarEntregador(int id) async {
    await dbHelper.deleteUsuario(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Entregador deletado!")));
    _carregarEntregadores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0xFF005050),
          title: const Text("Entregadores", style: TextStyle(color: Colors.white),)
      ),
      body: ListView.builder(
        itemCount: entregadores.length,
        itemBuilder: (context, index) {
          final e = entregadores[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(e.name),
              subtitle: Text(e.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF005050)),
                    onPressed: () => _abrirFormulario(entregador: e),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletarEntregador(e.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF005050),
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
