import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/document_model.dart';

class DocumentService {
  final FirebaseFirestore _firestore;

  DocumentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _documentsRef(
          String postulationId) =>
      _firestore
          .collection('postulations')
          .doc(postulationId)
          .collection('documents');

  Future<List<DocumentModel>> getDocuments(String postulationId) async {
    final snapshot = await _documentsRef(postulationId).get();
    return snapshot.docs
        .map((doc) => DocumentModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<DocumentModel?> getDocumentById(
      String postulationId, String id) async {
    final doc = await _documentsRef(postulationId).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return DocumentModel.fromFirestore(doc.data()!);
  }

  Future<void> createDocument(DocumentModel document) async {
    if (document.id.trim().isEmpty) {
      throw ArgumentError('Document id must not be empty');
    }
    await _documentsRef(document.postulationId)
        .doc(document.id)
        .set(document.toFirestore());
  }

  Future<void> updateDocument(DocumentModel document) async {
    if (document.id.trim().isEmpty) {
      throw ArgumentError('Document id must not be empty');
    }
    await _documentsRef(document.postulationId)
        .doc(document.id)
        .update(document.toFirestore());
  }

  Future<void> deleteDocument(String postulationId, String id) async {
    await _documentsRef(postulationId).doc(id).delete();
  }
}
