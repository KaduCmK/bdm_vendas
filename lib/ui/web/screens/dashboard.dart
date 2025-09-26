import 'package:bdm_vendas/ui/web/screens/cardapio/cardapio_management_screen.dart';
import 'package:bdm_vendas/ui/web/screens/clientes/clientes_screen.dart';
import 'package:bdm_vendas/ui/web/screens/notas/notas_screen.dart';
import 'package:bdm_vendas/ui/web/screens/notas_arquivadas_screen.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _destinations;

  @override
  void initState() {
    super.initState();
    _destinations = <Widget>[
      ClientesScreen(onNavigateToNotas: () => _navigateToIndex(1)),
      NotasScreen(),
      NotasArquivadasScreen(),
      CardapioManagementScreen(),
    ];
  }

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bar do Malhado | Vendas")),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _navigateToIndex,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.person_2_outlined),
                selectedIcon: Icon(Icons.person_2),
                label: Text("Clientes"),
                padding: EdgeInsets.symmetric(vertical: 4),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description),
                label: Text("Notas"),
                padding: EdgeInsets.symmetric(vertical: 4),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.archive_outlined),
                selectedIcon: Icon(Icons.archive),
                label: Text("Arquivadas"),
                padding: EdgeInsets.symmetric(vertical: 4),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: Text("Gerenciar Cardápio"),
                padding: EdgeInsets.symmetric(vertical: 4),
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
