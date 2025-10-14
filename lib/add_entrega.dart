import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models.dart';
import 'package:intl/intl.dart';

class AddEntregaPage extends StatefulWidget {
  final Entrega? entrega;

  const AddEntregaPage({Key? key, this.entrega}) : super(key: key);

  @override
  _AddEntregaPageState createState() => _AddEntregaPageState();
}

class _AddEntregaPageState extends State<AddEntregaPage> {
  final DBHelper dbHelper = DBHelper();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _produtoController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _dataEntregaController = TextEditingController();

  List<Entregador> entregadores = [];
  Entregador? entregadorSelecionado;

  List<Receptor> receptores = [];
  Receptor? receptorSelecionado;

  bool concluida = false;

  String? statusSelecionado;
  final List<String> opcoesStatus = ['Pendente', 'Atrasada', 'Concluída'];

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
    if (widget.entrega != null) {
      _produtoController.text = widget.entrega!.produto;
      _destinoController.text = widget.entrega!.destino;
      _dataEntregaController.text = widget.entrega!.dataEntrega;
      statusSelecionado = widget.entrega!.status;
      concluida = widget.entrega!.concluida;
    }
  }

  Future<void> _loadUsuarios() async {
    entregadores = await dbHelper.getEntregadores();
    receptores = await dbHelper.getReceptores();

    if (widget.entrega != null) {
      if (entregadores.isNotEmpty) {
        entregadorSelecionado = entregadores.firstWhere(
              (e) => e.name == widget.entrega!.entregador,
          orElse: () => entregadores.first,
        );
      }

      if (receptores.isNotEmpty) {
        receptorSelecionado = receptores.firstWhere(
              (r) => r.name == widget.entrega!.receptor,
          orElse: () => receptores.first,
        );
      }
    }

    setState(() {});
  }

  Future<void> _pickDateTime() async {
    DateTime initialDate = DateTime.now();
    if (_dataEntregaController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd HH:mm').parse(_dataEntregaController.text);
      } catch (_) {}
    }

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) return;

    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    _dataEntregaController.text = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

    final now = DateTime.now();
    if (concluida) {
      statusSelecionado = 'Concluída';
    } else if (dateTime.isBefore(now)) {
      statusSelecionado = 'Atrasada';
    } else {
      statusSelecionado = 'Pendente';
    }
    setState(() {});
  }

  Future<void> _saveEntrega() async {
    if (!_formKey.currentState!.validate()) return;
    if (entregadorSelecionado == null || receptorSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione entregador e receptor')),
      );
      return;
    }

    final entrega = Entrega(
      id: widget.entrega?.id,
      produto: _produtoController.text,
      destino: _destinoController.text,
      entregador: entregadorSelecionado!.name,
      receptor: receptorSelecionado!.name,
      dataEntrega: _dataEntregaController.text,
      status: statusSelecionado ?? 'Pendente',
      concluida: concluida,
    );

    if (widget.entrega == null) {
      await dbHelper.insertEntrega(entrega);
    } else {
      await dbHelper.updateEntrega(entrega);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entrega == null ? 'Adicionar Entrega' : 'Editar Entrega'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _produtoController,
                decoration: const InputDecoration(labelText: 'Produto'),
                validator: (v) => v == null || v.isEmpty ? 'Preencha o produto' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _destinoController,
                decoration: const InputDecoration(labelText: 'Destino'),
                validator: (v) => v == null || v.isEmpty ? 'Preencha o destino' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Entregador>(
                value: entregadorSelecionado,
                items: entregadores.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.name),
                  );
                }).toList(),
                onChanged: (e) => setState(() => entregadorSelecionado = e),
                decoration: const InputDecoration(labelText: 'Entregador'),
                validator: (v) => v == null ? 'Selecione um entregador' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Receptor>(
                value: receptorSelecionado,
                items: receptores.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r.name),
                  );
                }).toList(),
                onChanged: (r) => setState(() => receptorSelecionado = r),
                decoration: const InputDecoration(labelText: 'Receptor'),
                validator: (v) => v == null ? 'Selecione um receptor' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dataEntregaController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data de Entrega',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickDateTime,
                validator: (v) => v == null || v.isEmpty ? 'Preencha a data' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: statusSelecionado,
                items: opcoesStatus.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (s) => setState(() => statusSelecionado = s),
                decoration: const InputDecoration(labelText: 'Status'),
                validator: (v) => v == null || v.isEmpty ? 'Selecione um status' : null,
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: _saveEntrega,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
