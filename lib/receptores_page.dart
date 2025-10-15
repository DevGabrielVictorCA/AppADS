import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models.dart';
import 'contact_form_generic.dart';

class ReceptoresPage extends StatefulWidget {
  const ReceptoresPage({super.key});

  @override
  State<ReceptoresPage> createState() => _ReceptoresPageState();
}

class _ReceptoresPageState extends State<ReceptoresPage> {
  final DBHelper dbHelper = DBHelper();
  List<Receptor> receptores = [];

  @override
  void initState() {
    super.initState();
    _carregarReceptores();
  }

  Future<void> _carregarReceptores() async {
    final lista = await dbHelper.getReceptores();
    setState(() => receptores = lista);
  }

  Future<void> _abrirFormulario({Receptor? receptor}) async {
    final resultado = await showDialog<Receptor>(
      context: context,
      builder: (_) => ContactFormReceptor(
        receptor: receptor,
        dbHelper: dbHelper,
        onSave: (r) async => r,
      ),
    );

    if (resultado != null) _carregarReceptores();
  }

  Future<void> _deletarReceptor(int id) async {
    await dbHelper.deleteUsuario(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Receptor deletado!")));
    _carregarReceptores();
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
        itemCount: receptores.length,
        itemBuilder: (context, index) {
          final r = receptores[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(r.name),
              subtitle: Text(r.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF005050)),
                    onPressed: () => _abrirFormulario(receptor: r),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletarReceptor(r.id!),
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
