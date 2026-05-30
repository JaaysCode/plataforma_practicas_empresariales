import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/offer_model.dart';

class OfferService {
  final CollectionReference<Map<String, dynamic>> _offerCollection;

  OfferService({FirebaseFirestore? firestore})
      : _offerCollection =
            (firestore ?? FirebaseFirestore.instance).collection('offers');

  Future<List<OfferModel>> getOffers() async {
    final snapshot = await _offerCollection.get();
    return snapshot.docs
        .map((doc) => OfferModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<List<OfferModel>> getOffersByCompany(String companyNit) async {
    final snapshot = await _offerCollection
        .where('companyNit', isEqualTo: companyNit)
        .get();
    return snapshot.docs
        .map((doc) => OfferModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<OfferModel?> getOfferById(String id) async {
    final doc = await _offerCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return OfferModel.fromFirestore(doc.data()!);
  }

  Future<void> addOffer(OfferModel offer) async {
    if (offer.id.trim().isEmpty) {
      throw ArgumentError('Offer id must not be empty');
    }
    await _offerCollection.doc(offer.id).set(offer.toFirestore());
  }

  Future<void> updateOffer(OfferModel offer) async {
    if (offer.id.trim().isEmpty) {
      throw ArgumentError('Offer id must not be empty');
    }
    await _offerCollection.doc(offer.id).update(offer.toFirestore());
  }

  Future<void> deleteOffer(String id) async {
    await _offerCollection.doc(id).delete();
  }
}