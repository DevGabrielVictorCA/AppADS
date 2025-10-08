import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'entrega.dart';
import 'contact.dart';

class AddEntregaPage extends StatefulWidget {
  final Entrega? entrega;

  const AddEntregaPage({super.key, this.entrega});

  @override
  State<AddEntregaPage> createState() => _AddEntregaPageState();
}

class _AddEntregaPageState extends State<AddEntregaPage> {
  final _formKey = GlobalKey<FormState>();
  final produtoController = TextEditingController();
  final destinoController = TextEditingController();
  final receptorController = TextEditingController();
  DateTime? dataEntrega;
  String statusEntrega = "Pendente";
  String? entregadorSelecionado;

  final DBHelper dbHelper = DBHelper();
  List<Contact> contatos = [];

  @override
  void initState() {
    super.initState();
    _carregarContatos();

    // Se estiver editando, preencher campos
    if (widget.entrega != null) {
      final e = widget.entrega!;
      produtoController.text = e.produto;
      destinoController.text = e.destino;
      receptorController.text = e.receptor;
      entregadorSelecionado = e.entregador;
      dataEntrega = DateTime.tryParse(e.dataEntrega);
      statusEntrega = e.status;
    }
  }

  Future<void> _carregarContatos() async {
    final lista = await dbHelper.getContacts();
    setState(() {
      contatos = lista;
    });
  }

  Future<void> _selecionarData(BuildContext context) async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataEntrega ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (dataSelecionada != null) {
      final horaSelecionada = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dataEntrega ?? DateTime.now()),
      );
      if (horaSelecionada != null) {
        setState(() {
          dataEntrega = DateTime(
            dataSelecionada.year,
            dataSelecionada.month,
            dataSelecionada.day,
            horaSelecionada.hour,
            horaSelecionada.minute,
          );
          _atualizarStatusAutomatico();
        });
      }
    }
  }

  void _atualizarStatusAutomatico() {
    if (dataEntrega == null) return;
    final agora = DateTime.now();
    if (dataEntrega!.isBefore(agora)) {
      statusEntrega = "Atrasada";
    } else {
      statusEntrega = "Pendente";
    }
  }

  Future<void> _salvarEntrega() async {
    if (_formKey.currentState!.validate()) {
      final entrega = Entrega(
        id: widget.entrega?.id,
        produto: produtoController.text,
        destino: destinoController.text,
        receptor: receptorController.text,
        entregador: entregadorSelecionado ?? "Não definido",
        dataEntrega: dataEntrega?.toIso8601String() ?? "",
        status: statusEntrega,
        concluida: statusEntrega == "Concluída",
      );

      if (widget.entrega == null) {
        await dbHelper.insertEntrega(entrega);
      } else {
        await dbHelper.updateEntrega(entrega);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Entrega salva com sucesso!")),
        );
        Navigator.pop(context, true); // Retorna true para recarregar lista
      }
    }
  }

  @override
  void dispose() {
    produtoController.dispose();
    destinoController.dispose();
    receptorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entrega == null ? "Nova Entrega" : "Editar Entrega"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: produtoController,
                decoration: const InputDecoration(labelText: "Produto"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o produto" : null,
              ),
              TextFormField(
                controller: destinoController,
                decoration: const InputDecoration(labelText: "Destino"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o destino" : null,
              ),
              TextFormField(
                controller: receptorController,
                decoration: const InputDecoration(labelText: "Receptor"),
                validator: (v) =>
                v == null || v.isEmpty ? "Informe o receptor" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: entregadorSelecionado,
                decoration:
                const InputDecoration(labelText: "Selecione o Entregador"),
                items: contatos
                    .map((c) => DropdownMenuItem(
                  value: c.name,
                  child: Text(c.name),
                ))
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    entregadorSelecionado = valor!;
                  });
                },
                validator: (v) => v == null ? "Selecione um entregador" : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                  dataEntrega == null
                      ? "Selecione a data e hora da entrega"
                      : "Entrega: ${dataEntrega!.day}/${dataEntrega!.month}/${dataEntrega!.year} às ${dataEntrega!.hour.toString().padLeft(2, '0')}:${dataEntrega!.minute.toString().padLeft(2, '0')}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selecionarData(context),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: statusEntrega,
                decoration:
                const InputDecoration(labelText: "Status da Entrega"),
                items: const [
                  DropdownMenuItem(value: "Pendente", child: Text("Pendente")),
                  DropdownMenuItem(value: "Atrasada", child: Text("Atrasada")),
                  DropdownMenuItem(value: "Concluída", child: Text("Concluída")),
                ],
                onChanged: (valor) {
                  setState(() {
                    statusEntrega = valor!;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _salvarEntrega,
                icon: const Icon(Icons.save),
                label: const Text("Salvar Entrega"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
