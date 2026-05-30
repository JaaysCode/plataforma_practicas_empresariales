import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/company_model.dart';

class CompanyService {
  final CollectionReference<Map<String, dynamic>> _companiesRef;

  CompanyService({FirebaseFirestore? firestore})
      : _companiesRef =
            (firestore ?? FirebaseFirestore.instance).collection('companies');

  Future<List<CompanyModel>> getCompanies() async {
    final snapshot = await _companiesRef.get();
    return snapshot.docs
        .map((doc) => CompanyModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<CompanyModel?> getCompanyByNit(String nit) async {
    final doc = await _companiesRef.doc(nit).get();
    if (!doc.exists || doc.data() == null) return null;
    return CompanyModel.fromFirestore(doc.data()!);
  }

  Future<void> createCompany(CompanyModel company) async {
    if (company.nit.trim().isEmpty) {
      throw ArgumentError('Company nit must not be empty');
    }
    await _companiesRef.doc(company.nit).set(company.toFirestore());
  }

  Future<void> updateCompany(CompanyModel company) async {
    if (company.nit.trim().isEmpty) {
      throw ArgumentError('Company nit must not be empty');
    }
    await _companiesRef.doc(company.nit).update(company.toFirestore());
  }

  Future<void> deleteCompany(String nit) async {
    await _companiesRef.doc(nit).delete();
  }
}
