import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/company_model.dart';
import '../models/document_model.dart';
import '../models/offer_model.dart';
import '../models/postulation_model.dart';
import '../models/trace_model.dart';
import '../models/user_model.dart';


part 'app_database.g.dart';

class Companies extends Table {
  TextColumn get nit => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get sector => text()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {nit};
}

class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get postulationId => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get url => text()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Offers extends Table {
  TextColumn get id => text()();
  TextColumn get companyNit => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get position => text()();
  TextColumn get salary => text()();
  TextColumn get requirements => text()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Postulations extends Table {
  TextColumn get id => text()();
  TextColumn get offerId => text()();
  TextColumn get userId => text()();
  TextColumn get status => text()();
  DateTimeColumn get appliedAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Traces extends Table {
  TextColumn get id => text()();
  TextColumn get postulationId => text()();
  TextColumn get description => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get createdBy => text()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Users extends Table {
  TextColumn get cc => text()();
  TextColumn get name => text()();
  TextColumn get lastName => text()();
  TextColumn get email => text()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {cc};
}

@DriftDatabase(tables: [Companies, Documents, Offers, Postulations, Traces, Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'practitioners_app.db',
    native: const DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift.worker.dart.js'),
    ));
  }

  CompanyModel _mapCompanyToModel(Company row) {
    return CompanyModel(
      nit: row.nit,
      name: row.name,
      address: row.address,
      sector: row.sector,
      pendingSync: row.pendingSync,
    );
  }

  DocumentModel _mapDocumentToModel(Document row) {
    return DocumentModel(
      id: row.id,
      postulationId: row.postulationId,
      type: row.type,
      name: row.name,
      url: row.url,
      pendingSync: row.pendingSync,
    );
  }

  OfferModel _mapOfferToModel(Offer row) {
    return OfferModel(
      id: row.id,
      companyNit: row.companyNit,
      title: row.title,
      description: row.description,
      position: row.position,
      salary: row.salary,
      requirements: row.requirements,
      status: row.status,
      pendingSync: row.pendingSync,
    );
  }

  PostulationModel _mapPostulationToModel(Postulation row) {
    return PostulationModel(
      id: row.id,
      offerId: row.offerId,
      userId: row.userId,
      status: row.status,
      appliedAt: row.appliedAt,
      pendingSync: row.pendingSync,
    );
  }

  TraceModel _mapTraceToModel(Trace row) {
    return TraceModel(
      id: row.id,
      postulationId: row.postulationId,
      description: row.description,
      timestamp: row.timestamp,
      createdBy: row.createdBy,
      pendingSync: row.pendingSync,
    );
  }

  UserModel _mapUserToModel(User row) {
    return UserModel(
      cc: row.cc,
      name: row.name,
      lastName: row.lastName,
      email: row.email,
      pendingSync: row.pendingSync,
    );
  }

  Stream<List<CompanyModel>> watchCompanies() {
    final query = select(companies)
      ..orderBy([(c) => OrderingTerm.desc(c.name)]);

    return query.watch().map((rows) => rows.map(_mapCompanyToModel).toList());
  }

  Stream<List<OfferModel>> watchOffers() {
    final query = select(offers)
      ..orderBy([(o) => OrderingTerm.desc(o.title)]);

    return query.watch().map((rows) => rows.map(_mapOfferToModel).toList());
  }

   Stream<List<PostulationModel>> watchPostulations() {
    final query = select(postulations)
      ..orderBy([(p) => OrderingTerm.desc(p.appliedAt)]);

    return query.watch().map((rows) => rows.map(_mapPostulationToModel).toList());
  }

  Future<PostulationModel> insertPostulation(PostulationModel postulation) async{
    await into(postulations).insert(PostulationsCompanion.insert(
      id: postulation.id,
      offerId: postulation.offerId,
      userId: postulation.userId,
      status: postulation.status,
      appliedAt: postulation.appliedAt,
      pendingSync: Value(postulation.pendingSync),
    ));
    return postulation;
  }

  Future<List<PostulationModel>> getPendingPostulations() async {
    final rows = await (select(postulations)
          ..where((p) => p.pendingSync.equals(true)))
        .get();
    return rows.map(_mapPostulationToModel).toList();
  }

  Future<void> markPostulationAsSynced(String postulationId) async {
    await (update(postulations)..where((p) => p.id.equals(postulationId))).write(const PostulationsCompanion(
      pendingSync: const Value(false),
    ));
  }

  Future<void> upsertCompanyFromRemote(CompanyModel company) async {
    await into(companies).insertOnConflictUpdate(CompaniesCompanion.insert(
      nit: company.nit,
      name: company.name,
      address: company.address,
      sector: company.sector,
      pendingSync: Value(false),
    ));
  }

}