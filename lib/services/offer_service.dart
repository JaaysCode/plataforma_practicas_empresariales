import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/offer_model.dart';

class OfferService {
  final CollectionReference<Map<String, dynamic>> _offerCollection =
      FirebaseFirestore.instance.collection('offers');

  Future<List<OfferModel>> getOffers() async {
    final snapshot = await _offerCollection.get();
    final offers = <OfferModel>[];

    for (final doc in snapshot.docs) {
      if (doc.data().containsKey('status') && doc.data()['status'] == 'active') {
        offers.add(OfferModel.fromFirestore(doc.data()));
      }
    }

    return offers;
  }
}