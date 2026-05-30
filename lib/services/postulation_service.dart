import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/postulation_model.dart';

class PostulationService {
  final CollectionReference<Map<String, dynamic>> _postulationsRef;

  PostulationService({FirebaseFirestore? firestore})
      : _postulationsRef = (firestore ?? FirebaseFirestore.instance)
            .collection('postulations');

  Future<List<PostulationModel>> getPostulations() async {
    final snapshot = await _postulationsRef.get();
    return snapshot.docs
        .map((doc) => PostulationModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<List<PostulationModel>> getPostulationsByUser(String userId) async {
    final snapshot = await _postulationsRef
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => PostulationModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<List<PostulationModel>> getPostulationsByOffer(String offerId) async {
    final snapshot = await _postulationsRef
        .where('offerId', isEqualTo: offerId)
        .get();
    return snapshot.docs
        .map((doc) => PostulationModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<PostulationModel?> getPostulationById(String id) async {
    final doc = await _postulationsRef.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return PostulationModel.fromFirestore(doc.data()!);
  }

  Future<void> createPostulation(PostulationModel postulation) async {
    if (postulation.id.trim().isEmpty) {
      throw ArgumentError('Postulation id must not be empty');
    }
    await _postulationsRef.doc(postulation.id).set(postulation.toFirestore());
  }

  Future<void> updatePostulation(PostulationModel postulation) async {
    if (postulation.id.trim().isEmpty) {
      throw ArgumentError('Postulation id must not be empty');
    }
    await _postulationsRef
        .doc(postulation.id)
        .update(postulation.toFirestore());
  }

  Future<void> deletePostulation(String id) async {
    await _postulationsRef.doc(id).delete();
  }
}
