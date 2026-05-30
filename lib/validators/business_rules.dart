import '../models/offer_model.dart';
import '../models/postulation_model.dart';

// Status constants
const String kStatusPostulado = 'postulado';
const String kStatusPreseleccionado = 'preseleccionado';
const String kStatusAprobado = 'aprobado';
const String kStatusRechazado = 'rechazado';
const String kStatusPublicada = 'publicada';

// Role constants
const String kRoleEstudiante = 'estudiante';
const String kRoleEmpresa = 'empresa';
const String kRoleCoordinador = 'coordinador';

/// Rule 1: Estudiante no puede postularse dos veces a la misma oferta.
bool canApplyToOffer({
  required String offerId,
  required String userId,
  required List<PostulationModel> existingPostulations,
}) {
  return !existingPostulations.any(
    (p) => p.offerId == offerId && p.userId == userId,
  );
}

/// Rule 2: Oferta cerrada no recibe postulaciones.
bool isOfferOpenForApplications(OfferModel offer) {
  return offer.status == kStatusPublicada;
}

/// Rule 3: Postulación debe tener estado inicial.
String initialPostulationStatus() => kStatusPostulado;

/// Rule 4: Solo coordinador puede aprobar o rechazar.
bool canApproveOrReject(String userRole) => userRole == kRoleCoordinador;

/// Rule 5: Solo empresa puede preseleccionar candidatos.
bool canPreselect(String userRole) => userRole == kRoleEmpresa;

/// Rule 6: Postulación rechazada debe tener motivo.
bool hasValidRejectionReason(PostulationModel postulation) {
  if (postulation.status != kStatusRechazado) return true;
  final reason = postulation.rejectionReason;
  return reason != null && reason.trim().isNotEmpty;
}

/// Terminal states — aprobado y rechazado no tienen transiciones de salida.
bool isTerminalStatus(String status) {
  return status == kStatusAprobado || status == kStatusRechazado;
}

/// Valid transition guard combining all rules for a status change.
bool canTransitionStatus({
  required PostulationModel postulation,
  required String newStatus,
  required String userRole,
  String? rejectionReason,
}) {
  if (isTerminalStatus(postulation.status)) return false;

  if (newStatus == kStatusPreseleccionado) {
    return canPreselect(userRole);
  }

  if (newStatus == kStatusAprobado) {
    return canApproveOrReject(userRole);
  }

  if (newStatus == kStatusRechazado) {
    if (!canApproveOrReject(userRole)) return false;
    final reason = rejectionReason ?? '';
    return reason.trim().isNotEmpty;
  }

  return false;
}
