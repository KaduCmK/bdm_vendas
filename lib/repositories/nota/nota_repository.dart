import 'package:bdm_vendas/models/nota.dart';

abstract class NotaRepository {
  Future<List<Nota>> getNotas();
  Future<Nota> getNota(String id);
  Stream<Nota> watchNota(String id);
  Future<void> addNota(Nota nota);
  Future<void> updateNota(Nota nota);
}