import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trace_model.dart';

class TraceService {
  final FirebaseFirestore _firestore;

  TraceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tracesRef(String postulationId) =>
      _firestore
          .collection('postulations')
          .doc(postulationId)
          .collection('traces');

  Future<List<TraceModel>> getTraces(String postulationId) async {
    final snapshot = await _tracesRef(postulationId).get();
    return snapshot.docs
        .map((doc) => TraceModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<TraceModel?> getTraceById(String postulationId, String id) async {
    final doc = await _tracesRef(postulationId).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return TraceModel.fromFirestore(doc.data()!);
  }

  Future<void> createTrace(TraceModel trace) async {
    if (trace.id.trim().isEmpty) {
      throw ArgumentError('Trace id must not be empty');
    }
    await _tracesRef(trace.postulationId)
        .doc(trace.id)
        .set(trace.toFirestore());
  }

  Future<void> updateTrace(TraceModel trace) async {
    if (trace.id.trim().isEmpty) {
      throw ArgumentError('Trace id must not be empty');
    }
    await _tracesRef(trace.postulationId)
        .doc(trace.id)
        .update(trace.toFirestore());
  }

  Future<void> deleteTrace(String postulationId, String id) async {
    await _tracesRef(postulationId).doc(id).delete();
  }
}
