import 'package:flutter/material.dart';
import 'add_entrega.dart';
import 'db_helper.dart';
import 'models.dart';

class GestorEntregasPage extends StatefulWidget {
  const GestorEntregasPage({super.key});

  @override
  State<GestorEntregasPage> createState() => _GestorEntregasPageState();
}

class _GestorEntregasPageState extends State<GestorEntregasPage> {
  final DBHelper dbHelper = DBHelper();
  List<Entrega> entregas = [];
  List<Entrega> entregasFiltradas = [];
  bool carregando = true;

  // Filtros
  Set<String> filtrosStatus = {};
  Set<String> filtrosEntregadores = {};
  Set<String> filtrosReceptores = {};
  Set<String> filtrosProdutos = {};
  Set<String> filtrosDestinos = {};

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
      if (!e.concluida) {
        try {
          final dt = DateTime.parse(e.dataEntrega);
          e.status = dt.isBefore(agora) ? 'Atrasada' : 'Pendente';
        } catch (_) {
          e.status = 'Pendente';
        }
      } else {
        e.status = 'Concluída';
      }
      await dbHelper.updateEntrega(e);
    }

    setState(() {
      entregas = lista;
      entregasFiltradas = List.from(entregas);
      carregando = false;
    });
  }

  void _aplicarFiltros() {
    setState(() {
      entregasFiltradas = entregas.where((e) {
        bool ok = true;
        if (filtrosStatus.isNotEmpty) ok &= filtrosStatus.contains(e.status);
        if (filtrosEntregadores.isNotEmpty) ok &= filtrosEntregadores.contains(e.entregador);
        if (filtrosReceptores.isNotEmpty) ok &= filtrosReceptores.contains(e.receptor);
        if (filtrosProdutos.isNotEmpty) ok &= filtrosProdutos.contains(e.produto);
        if (filtrosDestinos.isNotEmpty) ok &= filtrosDestinos.contains(e.destino);
        return ok;
      }).toList();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Concluída':
        return Colors.green;
      case 'Pendente':
        return Colors.orange;
      case 'Atrasada':
        return Colors.red;
      default:
        return Colors.grey;
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
            e.status = e.concluida
                ? 'Concluída'
                : (DateTime.parse(e.dataEntrega).isBefore(DateTime.now())
                ? 'Atrasada'
                : 'Pendente');
            await dbHelper.updateEntrega(e);
            _aplicarFiltros();
          },
        ),
        title: Text(e.produto),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Destino: ${e.destino}"),
            Text("Entregador: ${e.entregador}"),
            Text("Receptor: ${e.receptor}"),
            Text("Data: ${e.dataEntrega}"),
            Text(
              "Status: ${e.status}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _statusColor(e.status),
              ),
            ),
          ],
        ),
        isThreeLine: false,
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

  Future<void> _editarEntrega(Entrega e) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEntregaPage(entrega: e)),
    );
    if (result == true) _carregarEntregas();
  }

  Future<void> _deletarEntrega(int id) async {
    await dbHelper.deleteEntrega(id);
    _carregarEntregas();
  }

  Widget _buildFiltroIcon({
    required IconData icon,
    required String label,
    required List<String> options,
    required Set<String> selectedValues,
  }) {
    final ativo = selectedValues.isNotEmpty;
    return PopupMenuButton<String>(
      icon: Icon(
        icon,
        color: ativo ? Color(0xFF005050) : null,
      ),
      tooltip: label,
      onSelected: (value) {
        setState(() {
          if (selectedValues.contains(value)) {
            selectedValues.remove(value);
          } else {
            selectedValues.add(value);
          }
          _aplicarFiltros();
        });
      },
      itemBuilder: (_) => options.map((opt) {
        final checked = selectedValues.contains(opt);
        return CheckedPopupMenuItem(
          value: opt,
          checked: checked,
          child: Text(opt),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusOptions = ['Pendente', 'Atrasada', 'Concluída'];
    final entregadorOptions = entregas.map((e) => e.entregador).toSet().toList();
    final receptorOptions = entregas.map((e) => e.receptor).toSet().toList();
    final produtoOptions = entregas.map((e) => e.produto).toSet().toList();
    final destinoOptions = entregas.map((e) => e.destino).toSet().toList();

    return Scaffold(

      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0xFF005050),
          title: const Text("Gestor de Entregas", style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _buildFiltroIcon(
                  icon: Icons.info,
                  label: 'Status',
                  options: statusOptions,
                  selectedValues: filtrosStatus,
                ),
                _buildFiltroIcon(
                  icon: Icons.person,
                  label: 'Entregador',
                  options: entregadorOptions,
                  selectedValues: filtrosEntregadores,
                ),
                _buildFiltroIcon(
                  icon: Icons.person_outline,
                  label: 'Receptor',
                  options: receptorOptions,
                  selectedValues: filtrosReceptores,
                ),
                _buildFiltroIcon(
                  icon: Icons.shopping_cart,
                  label: 'Produto',
                  options: produtoOptions,
                  selectedValues: filtrosProdutos,
                ),
                _buildFiltroIcon(
                  icon: Icons.location_on,
                  label: 'Destino',
                  options: destinoOptions,
                  selectedValues: filtrosDestinos,
                ),
                // Botão para limpar filtros
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Limpar filtros',
                  onPressed: () {
                    setState(() {
                      filtrosStatus.clear();
                      filtrosEntregadores.clear();
                      filtrosReceptores.clear();
                      filtrosProdutos.clear();
                      filtrosDestinos.clear();
                      _aplicarFiltros();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : entregasFiltradas.isEmpty
                ? const Center(child: Text("Nenhuma entrega encontrada"))
                : RefreshIndicator(
              onRefresh: _carregarEntregas,
              child: ListView.builder(
                itemCount: entregasFiltradas.length,
                itemBuilder: (_, index) =>
                    _buildItemEntrega(entregasFiltradas[index]),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF005050),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEntregaPage()),
          );
          if (result == true) _carregarEntregas();
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
