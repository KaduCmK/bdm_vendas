import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class SolicitacoesScreen extends StatefulWidget {
  const SolicitacoesScreen({super.key});

  @override
  State<SolicitacoesScreen> createState() => _SolicitacoesScreenState();
}

class _SolicitacoesScreenState extends State<SolicitacoesScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR');
    _setupFCM();
  }

  void _setupFCM() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();

    final user = FirebaseAuth.instance.currentUser;
    if (token != null && user != null) {
      await FirebaseFirestore.instance
          .collection('dispositivos')
          .doc(user.uid)
          .set({'token': token});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitações de Pagamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('solicitacoes')
            .where('status', isEqualTo: 'pendente')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma solicitação no momento.'));
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final formattedTime = timestamp != null
                  ? DateFormat.Hm('pt_BR').format(timestamp)
                  : '--:--';

              return Card(
                color: Colors.amber.shade50,
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: Text(
                      formattedTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    data['clienteNome'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Nota: ${data['notaId']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
                    tooltip: 'Marcar como atendido',
                    onPressed: () {
                      doc.reference.update({'status': 'concluido'});
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
