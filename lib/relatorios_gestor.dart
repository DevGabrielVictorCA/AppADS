import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'db_helper.dart';
import 'models.dart';
import 'gestor_entregas.dart';

class RelatoriosGestorPage extends StatefulWidget {
  final bool scrollParaAlertas;

  const RelatoriosGestorPage({super.key, this.scrollParaAlertas = false});

  @override
  State<RelatoriosGestorPage> createState() => _RelatoriosGestorPageState();
}

class _RelatoriosGestorPageState extends State<RelatoriosGestorPage> {
  final DBHelper dbHelper = DBHelper();
  List<Entrega> entregas = [];
  List<Entregador> entregadores = [];
  List<Receptor> receptores = [];

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _alertasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _carregarDados();

    // rolar para alertas se solicitado
    if (widget.scrollParaAlertas) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAlertas());
    }
  }

  Future<void> _carregarDados() async {
    final listaEntregas = await dbHelper.getEntregas();
    final listaEntregadores = await dbHelper.getEntregadores();
    final listaReceptores = await dbHelper.getReceptores();
    setState(() {
      entregas = listaEntregas;
      entregadores = listaEntregadores;
      receptores = listaReceptores;
    });
  }

  void _scrollToAlertas() {
    final context = _alertasKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = entregas.length;
    int concluidas = entregas.where((e) => e.status == "Concluída").length;
    int pendentes = entregas.where((e) => e.status == "Pendente").length;
    int atrasadas = entregas.where((e) => e.status == "Atrasada").length;

    List<_ChartData> chartData = [
      _ChartData('Concluídas', concluidas, Colors.green),
      _ChartData('Pendentes', pendentes, Colors.orange),
      _ChartData('Atrasadas', atrasadas, Colors.red),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text("Relatórios", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF005050),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumo do dia",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005050),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ResumoCard(title: "Total Entregas", value: "$total"),
                  _ResumoCard(title: "Concluídas", value: "$concluidas"),
                  _ResumoCard(title: "Pendentes", value: "$pendentes"),
                  _ResumoCard(title: "Atrasadas", value: "$atrasadas"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Distribuição das entregas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005050),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: <PieSeries<_ChartData, String>>[
                  PieSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.status,
                    yValueMapper: (_ChartData data, _) => data.count,
                    pointColorMapper: (_ChartData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ALERTAS RECENTES
            Container(
              key: _alertasKey,
              child: const Text(
                "Alertas recentes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005050),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entregas.length,
              itemBuilder: (context, index) {
                final e = entregas[index];

                final entregador = entregadores.firstWhere(
                      (en) => en.name == e.entregador,
                  orElse: () => Entregador(
                    id: null,
                    name: e.entregador,
                    phone: '',
                    email: '',
                    address: '',
                  ),
                );

                final receptor = receptores.firstWhere(
                      (r) => r.name == e.receptor,
                  orElse: () => Receptor(
                    id: null,
                    name: e.receptor,
                    phone: '',
                    email: '',
                    address: '',
                  ),
                );

                Color cor;
                String subtitleText;

                if (e.status == "Problema reportado") {
                  cor = Colors.redAccent;
                  subtitleText =
                  "Produto: ${e.produto}\nEntregador: ${entregador.name}\nReceptor: ${receptor.name}\n\n🚨 Motivo: ${e.motivos ?? 'Não informado'}\nDescrição: ${e.descricao ?? 'Não informada'}";
                } else {
                  switch (e.status) {
                    case "Concluída":
                      cor = Colors.green;
                      break;
                    case "Pendente":
                      cor = Colors.orange;
                      break;
                    case "Atrasada":
                      cor = Colors.red;
                      break;
                    default:
                      cor = Colors.grey;
                  }
                  subtitleText =
                  "Produto: ${e.produto}\nEntregador: ${entregador.name}\nReceptor: ${receptor.name}";
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.assignment, color: cor),
                    title: Text("${e.status}: ${e.destino}"),
                    subtitle: Text(subtitleText),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GestorEntregasPage(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  final String status;
  final int count;
  final Color color;

  _ChartData(this.status, this.count, this.color);
}
