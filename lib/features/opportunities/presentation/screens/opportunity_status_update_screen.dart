import 'dart:async';

import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/opportunities/domain/domain.dart';
import 'package:crm_app/features/opportunities/presentation/providers/docs_opportunitie_provider.dart';
import 'package:crm_app/features/opportunities/presentation/providers/opportunities_repository_provider.dart';
import 'package:crm_app/features/opportunities/presentation/providers/opportunities_provider.dart';
import 'package:crm_app/features/opportunities/presentation/providers/opportunity_provider.dart';
import 'package:crm_app/features/resource-detail/presentation/providers/resource_details_provider.dart';
import 'package:crm_app/features/shared/domain/entities/dropdown_option.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/select_custom_form.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OpportunityStatusUpdateScreen extends ConsumerStatefulWidget {
  final String opportunityId;

  const OpportunityStatusUpdateScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  ConsumerState<OpportunityStatusUpdateScreen> createState() =>
      _OpportunityStatusUpdateScreenState();
}

class _OpportunityStatusUpdateScreenState
    extends ConsumerState<OpportunityStatusUpdateScreen> {
  List<DropdownOption> _estadoOptions = [
    DropdownOption(id: '', name: 'Cargando...'),
  ];
  List<DropdownOption> _motivoOptions = [
    DropdownOption(id: '', name: 'Cargando...'),
  ];
  final Set<String> _selectedOpportunityIds = {};

  String _selectedEstadoId = '';
  String _selectedMotivoId = '';
  bool _isLoadingEstados = true;
  bool _isLoadingMotivos = false;
  bool _didInitSelection = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEstados();
    });
  }

  Future<void> _loadEstados() async {
    final estados =
        await ref.read(resourceDetailsProvider.notifier).loadCatalogById(
              groupId: '05',
            );
    if (!mounted) return;
    setState(() {
      _estadoOptions = estados;
      _isLoadingEstados = false;
    });
  }

  Future<void> _loadMotivos() async {
    setState(() {
      _isLoadingMotivos = true;
    });
    final motivos =
        await ref.read(resourceDetailsProvider.notifier).loadCatalogById(
              groupId: '22',
            );
    if (!mounted) return;
    setState(() {
      _motivoOptions = motivos;
      _isLoadingMotivos = false;
    });
  }

  List<Opportunity> _resolveOpportunityOptions(Opportunity current) {
    final siblings = ref.read(currentOpportunityGroupProvider);
    // El grupo ya viene filtrado por bandeja desde backend (parámetro ESTADO),
    // por eso solo se toma la misma empresa y se normaliza; no se vuelve a
    // filtrar por estado en frontend.
    final sameCompany = normalizeOpportunityGroup(
      siblings
          .where((opportunity) => opportunity.empresaKey == current.empresaKey)
          .toList(),
    );
    if (sameCompany.isNotEmpty) return sameCompany;
    return [current];
  }

  String _selectedOpportunitySummary(List<Opportunity> options) {
    final selected = options
        .where(
            (opportunity) => _selectedOpportunityIds.contains(opportunity.id))
        .map((opportunity) => opportunity.oprtNombre)
        .toList();

    if (selected.isEmpty) return 'Seleccione oportunidad(es)';
    return selected.join(', ');
  }

  Future<void> _openOpportunitySelector(List<Opportunity> options) async {
    final tempSelectedIds = Set<String>.from(_selectedOpportunityIds);

    final selected = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seleccione oportunidad(es)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(dialogContext).size.height * 0.38,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: options.map((opportunity) {
                          final checked =
                              tempSelectedIds.contains(opportunity.id);
                          return CheckboxListTile(
                            value: checked,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: const Color(0xFF1F8FBF),
                            title: Text(
                              opportunity.oprtNombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onChanged: (value) {
                              setStateDialog(() {
                                if (value ?? false) {
                                  tempSelectedIds.add(opportunity.id);
                                } else {
                                  tempSelectedIds.remove(opportunity.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1F8FBF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(
                              tempSelectedIds.toList(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F8FBF),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                                side:
                                    const BorderSide(color: Color(0xFFE3E6EA)),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Aceptar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == null || !mounted) return;
    setState(() {
      _selectedOpportunityIds
        ..clear()
        ..addAll(selected);
    });
  }

  String _statusTabLabel(String estadoId) {
    switch (estadoId) {
      case '01':
      case '02':
      case '03':
      case '04':
        return 'Activos';
      case '05':
        return 'En pausa';
      case '06':
        return 'Cerrado/Ganado';
      case '07':
        return 'Perdidas';
      default:
        return 'otro estado';
    }
  }

  Future<Map<String, dynamic>> _refreshAfterStatusUpdate(
    Opportunity current,
    Opportunity? selected,
    String type,
  ) async {
    final opportunitiesNotifier = ref.read(opportunitiesProvider.notifier);
    final opportunitiesRepository = ref.read(opportunitiesRepositoryProvider);
    final selectedIds = _selectedOpportunityIds.toSet();
    Opportunity? targetOpportunity;
    List<Opportunity> destinationGroup = [];

    final siblings = ref.read(currentOpportunityGroupProvider);
    final ruc = selected?.oprtRuc ?? current.oprtRuc ?? '';
    final currentSectionType = resolveOpportunitySectionType(
      preferredType: type,
      reference: current,
    );
    if (ruc.isNotEmpty && siblings.isNotEmpty) {
      final user = ref.read(authProvider).user;
      final refreshedGroups =
          await opportunitiesRepository.getListOpportunities(
        ruc: ruc,
        search: '',
        limit: 100,
        offset: 1,
        idUsuario: (user?.isAdmin ?? false) ? '' : (user?.code ?? ''),
        estado: opportunitySectionTypeFromStatus(_selectedEstadoId).isNotEmpty
            ? opportunitySectionTypeFromStatus(_selectedEstadoId)
            : currentSectionType,
      );
      final refreshed = refreshedGroups
          .expand((opportunity) =>
              opportunity.oportunidadesDelGrupo ?? [opportunity])
          .toList();

      final movedOpportunities = refreshed
          .where((opportunity) => selectedIds.contains(opportunity.id))
          .toList();

      final currentMoved = movedOpportunities
          .where((opportunity) => opportunity.id == current.id)
          .toList();
      if (currentMoved.isNotEmpty) {
        targetOpportunity = currentMoved.first;
      } else if (movedOpportunities.isNotEmpty) {
        targetOpportunity = movedOpportunities.first;
      }

      // El grupo destino se toma completo desde backend (ya viene filtrado por
      // la bandeja destino con el parámetro ESTADO). Así, al mover una o varias
      // oportunidades, el detalle muestra TODAS las de esa empresa que quedan en
      // la bandeja destino (las que ya estaban + las recién movidas), no solo
      // las movidas.
      destinationGroup = normalizeOpportunityGroup(
        refreshed.where((opportunity) {
          return opportunity.empresaKey == current.empresaKey;
        }).toList(),
      );

      if (destinationGroup.isNotEmpty) {
        final movedInsideDestination = destinationGroup
            .where((opportunity) => selectedIds.contains(opportunity.id))
            .toList();
        targetOpportunity = movedInsideDestination.isNotEmpty
            ? movedInsideDestination.first
            : destinationGroup.first;
        ref.read(currentOpportunityGroupProvider.notifier).state =
            normalizeOpportunityGroup(destinationGroup);
        ref.read(selectedOp.notifier).state = targetOpportunity;
        ref.read(currentOpportunityShowAllProvider.notifier).state = false;
      }
    }

    if (targetOpportunity != null) {
      final updated = await opportunitiesRepository
          .getOpportunityById(targetOpportunity.id);
      ref.read(selectedOp.notifier).state = updated;
      targetOpportunity = updated;
    }

    if (type.isEmpty) {
      unawaited(opportunitiesNotifier.loadNextPage(isRefresh: true));
    } else {
      unawaited(opportunitiesNotifier.loadNextPageByType(isRefresh: true));
    }

    return {
      'targetOpportunityId': targetOpportunity?.id ?? current.id,
      'targetOpportunityName':
          targetOpportunity?.oprtNombre ?? current.oprtNombre,
      'tabLabel': _statusTabLabel(_selectedEstadoId),
      'routeChanged':
          (targetOpportunity?.id ?? current.id) != widget.opportunityId,
    };
  }

  Future<void> _save(Opportunity current, List<Opportunity> options) async {
    if (_selectedEstadoId.isEmpty) {
      showSnackbar(context, 'Debe seleccionar un estado');
      return;
    }
    if (_selectedOpportunityIds.isEmpty) {
      showSnackbar(context, 'Debe seleccionar al menos una oportunidad');
      return;
    }
    if (_selectedEstadoId == '07' && _selectedMotivoId.isEmpty) {
      showSnackbar(context, 'Debe seleccionar un motivo');
      return;
    }

    showLoadingMessage(context);
    final response = await ref
        .read(opportunitiesProvider.notifier)
        .updateOpportunitiesStatus(
          opportunityIds: _selectedOpportunityIds.toList(),
          estadoId: _selectedEstadoId,
          motivoId: _selectedEstadoId == '07' ? _selectedMotivoId : '',
        );

    if (!mounted) return;

    if (!response.response) {
      Navigator.of(context).pop();
      showSnackbar(context, response.message);
      return;
    }
    final selected = ref.read(selectedOp);
    final type = ref.read(opportunitiesProvider).typeOpportunity;

    final result = await _refreshAfterStatusUpdate(current, selected, type);

    if (!mounted) return;
    Navigator.of(context).pop();
    context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedOp);
    final loaded =
        ref.watch(opportunityProvider(widget.opportunityId)).opportunity;
    final current =
        selected?.id == widget.opportunityId ? selected : (loaded ?? selected);

    if (current == null) {
      return const Scaffold(body: FullScreenLoader());
    }

    final options = _resolveOpportunityOptions(current);
    if (!_didInitSelection) {
      _didInitSelection = true;
      _selectedEstadoId = current.oprtIdEstadoOportunidad ?? '';
      _selectedOpportunityIds
        ..clear()
        ..add(current.id);
      if (_selectedEstadoId == '07') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadMotivos();
        });
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Actualizar estado',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _isLoadingEstados
                  ? PlaceholderInput(text: 'Cargando Estado...')
                  : SelectCustomForm(
                      label: 'Estado',
                      value: _selectedEstadoId,
                      callbackChange: (String? newValue) {
                        if (newValue == null) return;
                        setState(() {
                          _selectedEstadoId = newValue;
                          _selectedMotivoId = '';
                        });
                        if (newValue == '07') {
                          _loadMotivos();
                        }
                      },
                      items: _estadoOptions,
                    ),
              if (_selectedEstadoId == '07') ...[
                const SizedBox(height: 12),
                _isLoadingMotivos
                    ? PlaceholderInput(text: 'Cargando Motivo...')
                    : SelectCustomForm(
                        label: 'Motivo',
                        value: _selectedMotivoId,
                        callbackChange: (String? newValue) {
                          setState(() {
                            _selectedMotivoId = newValue ?? '';
                          });
                        },
                        items: _motivoOptions,
                      ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Oportunidad',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _openOpportunitySelector(options),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedOpportunitySummary(options),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButtonCustom(
          iconData: Icons.save,
          callOnPressed: () => _save(current, options),
        ),
      ),
    );
  }
}
