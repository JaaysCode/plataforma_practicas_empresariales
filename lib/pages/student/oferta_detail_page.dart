import 'package:flutter/material.dart';

import '../../models/offer_model.dart';
import '../../models/postulation_model.dart';
import '../../services/postulation_service.dart';
import '../../validators/business_rules.dart';

class OfertaDetailPage extends StatefulWidget {
  final OfferModel offer;
  final String userId;

  const OfertaDetailPage({
    super.key,
    required this.offer,
    required this.userId,
  });

  @override
  State<OfertaDetailPage> createState() => _OfertaDetailPageState();
}

class _OfertaDetailPageState extends State<OfertaDetailPage> {
  final _postulationService = PostulationService();

  bool _isApplying = false;
  bool _alreadyApplied = false;
  bool _isLoadingCheck = true;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyApplied();
  }

  Future<void> _checkIfAlreadyApplied() async {
    try {
      final userPostulations = await _postulationService
          .getPostulationsByUser(widget.userId);
      final already = !canApplyToOffer(
        offerId: widget.offer.id,
        userId: widget.userId,
        existingPostulations: userPostulations,
      );
      if (mounted) setState(() => _alreadyApplied = already);
    } catch (_) {
      // On error, allow user to try applying — server will reject if needed
    } finally {
      if (mounted) setState(() => _isLoadingCheck = false);
    }
  }

  Future<void> _apply() async {
    // Business rule: offer must be open
    if (!isOfferOpenForApplications(widget.offer)) {
      _showError('Esta oferta ya no acepta postulaciones.');
      return;
    }

    // Business rule: no duplicate postulation
    if (_alreadyApplied) {
      _showError('Ya te has postulado a esta oferta.');
      return;
    }

    final confirm = await _showConfirmDialog();
    if (!confirm) return;

    setState(() => _isApplying = true);

    try {
      final postulation = PostulationModel(
        id: '${widget.userId}_${widget.offer.id}_${DateTime.now().millisecondsSinceEpoch}',
        userId: widget.userId,
        offerId: widget.offer.id,
        status: initialPostulationStatus(),
        appliedAt: DateTime.now(),
        pendingSync: false,
      );

      await _postulationService.createPostulation(postulation);

      if (!mounted) return;

      setState(() => _alreadyApplied = true);
      _showSuccess('¡Postulación enviada con éxito!');
    } catch (e) {
      if (!mounted) return;
      _showError('Error al postularse: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar postulación'),
        content: Text(
          '¿Deseas postularte a "${widget.offer.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Postularme'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final offer = widget.offer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de oferta'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              offer.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              offer.position,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Info chips row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailChip(
                  icon: Icons.attach_money_rounded,
                  label: offer.salary,
                  color: Colors.green,
                ),
                _DetailChip(
                  icon: Icons.business_rounded,
                  label: 'NIT: ${offer.companyNit}',
                  color: colorScheme.secondary,
                ),
                _DetailChip(
                  icon: offer.status == 'publicada'
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  label: offer.status == 'publicada' ? 'Disponible' : offer.status,
                  color: offer.status == 'publicada' ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            _SectionTitle(title: 'Descripción'),
            const SizedBox(height: 8),
            Text(
              offer.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Requirements
            _SectionTitle(title: 'Requisitos'),
            const SizedBox(height: 8),
            Text(
              offer.requirements,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // Apply button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: _isLoadingCheck
            ? const Center(child: CircularProgressIndicator())
            : _alreadyApplied
                ? _AlreadyAppliedBanner()
                : offer.status != 'publicada'
                    ? _ClosedOfferBanner()
                    : FilledButton.icon(
                        onPressed: _isApplying ? null : _apply,
                        icon: _isApplying
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _isApplying ? 'Enviando...' : 'Postularme',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _AlreadyAppliedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green),
          SizedBox(width: 8),
          Text(
            'Ya te postulaste a esta oferta',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosedOfferBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text(
            'Esta oferta no acepta postulaciones',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
