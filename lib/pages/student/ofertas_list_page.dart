import 'package:flutter/material.dart';

import '../../models/offer_model.dart';
import '../../services/offer_service.dart';
import 'oferta_detail_page.dart';

class OfertasListPage extends StatefulWidget {
  final String userId;

  const OfertasListPage({super.key, required this.userId});

  @override
  State<OfertasListPage> createState() => _OfertasListPageState();
}

class _OfertasListPageState extends State<OfertasListPage> {
  final _offerService = OfferService();
  late Future<List<OfferModel>> _offersFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _offersFuture = _offerService
          .getOffers()
          .then((all) => all.where((o) => o.status == 'publicada').toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas disponibles'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _load,
          ),
        ],
      ),
      body: FutureBuilder<List<OfferModel>>(
        future: _offersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar las ofertas',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: _load,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final offers = snapshot.data ?? [];

          if (offers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_off_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ofertas disponibles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final offer = offers[index];
                return _OfferCard(
                  offer: offer,
                  onTap: () => _openDetail(offer),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openDetail(OfferModel offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfertaDetailPage(
          offer: offer,
          userId: widget.userId,
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onTap;

  const _OfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      offer.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.4)),
                ],
              ),
              const SizedBox(height: 8),
              _InfoChip(
                icon: Icons.work_outline,
                label: offer.position,
              ),
              const SizedBox(height: 4),
              _InfoChip(
                icon: Icons.attach_money_rounded,
                label: offer.salary,
              ),
              const SizedBox(height: 8),
              Text(
                offer.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
