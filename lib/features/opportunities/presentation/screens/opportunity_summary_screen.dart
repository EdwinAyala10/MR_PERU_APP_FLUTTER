import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/opportunity_summary_provider.dart';

class OpportunitySummaryScreen extends ConsumerStatefulWidget {
  final String opportunityId;

  const OpportunitySummaryScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  ConsumerState<OpportunitySummaryScreen> createState() => _OpportunitySummaryScreenState();
}

class _OpportunitySummaryScreenState extends ConsumerState<OpportunitySummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(opportunitySummaryProvider(widget.opportunityId).notifier).generateSummary(widget.opportunityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(opportunitySummaryProvider(widget.opportunityId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00607D)),
          onPressed: () {
            // Pop dos veces: primero cierra summary, luego activation, quedando en detail
            context.pop();
            context.pop();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00A8DD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'FORCE ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'MR',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00607D),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(summaryState),
      ),
    );
  }

  Widget _buildBody(OpportunitySummaryState state) {
    if (state.isLoading) {
      return _buildLoading();
    }

    if (state.errorMessage != null) {
      return _buildError(state.errorMessage!);
    }

    if (state.summary != null && state.summary!.hasData) {
      return _buildSummary(state.summary!);
    }

    return _buildEmpty();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00A8DD).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A8DD)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Generando resumen con IA...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00607D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esto puede tomar unos segundos',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No se pudo generar el resumen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00607D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(opportunitySummaryProvider(widget.opportunityId).notifier).generateSummary(widget.opportunityId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A8DD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Intentar nuevamente',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00A8DD).withOpacity(0.1),
                  const Color(0xFF00607D).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00A8DD).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A8DD).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF00A8DD),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Resumen generado con IA',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00607D),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              summary.data,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF374151),
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00A8DD).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 48,
                color: Color(0xFF00A8DD),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay resumen disponible',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00607D),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudo obtener información de esta oportunidad',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
