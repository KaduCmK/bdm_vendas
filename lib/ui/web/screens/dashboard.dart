import 'package:bdm_vendas/ui/web/screens/clientes_screen.dart';
import 'package:bdm_vendas/ui/web/screens/notas_arquivadas_screen.dart';
import 'package:bdm_vendas/ui/web/screens/notas_screen.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  static const List<Widget> _destinations = <Widget>[
    NotasScreen(),
    NotasArquivadasScreen(),
    ClientesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bar do Malhado | Vendas")),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description),
                label: Text("Notas"),
                padding: const EdgeInsets.symmetric(vertical: 4)
              ),
              NavigationRailDestination(
                icon: Icon(Icons.archive_outlined),
                selectedIcon: Icon(Icons.archive),
                label: Text("Arquivadas"),
                padding: const EdgeInsets.symmetric(vertical: 4)
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_2_outlined),
                selectedIcon: Icon(Icons.person_2),
                label: Text("Clientes"),
                padding: const EdgeInsets.symmetric(vertical: 4)
              ),
            ],
          ),
          const VerticalDivider(),
          Expanded(child: _destinations[_selectedIndex]),
        ],
      ),
    );
  }
}
