import 'package:bdm_vendas/models/nota.dart';

abstract class NotaRepository {
  Future<List<Nota>> getNotas();
  Future<void> addNota(Nota nota);
  Future<void> updateNota(Nota nota);
}