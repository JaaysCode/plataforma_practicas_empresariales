import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/offer_model.dart';

class OfferService {
  final CollectionReference<Map<String, dynamic>> _offerCollection =
      FirebaseFirestore.instance.collection('offers');

  Future<List<OfferModel>> getOffers() async {
    final snapshot = await _offerCollection
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs
        .map((doc) => OfferModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<void> addOffer(OfferModel offer) async {
    if (offer.id.trim().isEmpty) {
      throw ArgumentError('Offer id must not be empty');
    }

    await _offerCollection.doc(offer.id).set(offer.toFirestore());
  }
}