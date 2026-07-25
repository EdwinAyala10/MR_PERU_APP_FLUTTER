import 'dart:async';
import 'dart:developer';

import 'package:crm_app/config/constants/environment.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/domain/repositories/activities_repository.dart';
import 'package:crm_app/features/activities/presentation/providers/activities_provider.dart';
import 'package:crm_app/features/activities/presentation/providers/activities_repository_provider.dart';
import 'package:crm_app/features/activities/presentation/providers/activity_provider.dart';
import 'package:crm_app/features/activities/presentation/providers/forms/activity_form_provider.dart';
import 'package:crm_app/features/activities/presentation/widgets/item_activity.dart';
import 'package:crm_app/features/agenda/domain/entities/event.dart';
import 'package:crm_app/features/agenda/domain/repositories/events_repository.dart';
import 'package:crm_app/features/agenda/presentation/providers/events_provider.dart';
import 'package:crm_app/features/agenda/presentation/providers/events_repository_provider.dart';
import 'package:crm_app/features/agenda/presentation/widgets/item_event.dart';
import 'package:crm_app/features/opportunities/domain/entities/op_document.dart';
import 'package:crm_app/features/opportunities/domain/repositories/doc_opportunitie_repository.dart';
import 'package:crm_app/features/companies/presentation/widgets/show_loading_message.dart';
import 'package:crm_app/features/documents/presentation/screens/documents_screen.dart';
import 'package:crm_app/features/opportunities/domain/entities/opportunity.dart';
import 'package:crm_app/features/opportunities/infrastructure/mappers/op_delete_document_mapper.dart';
import 'package:crm_app/features/opportunities/presentation/widgets/opportunity_force_mr_summary_card.dart';
import 'package:crm_app/features/opportunities/presentation/widgets/op_document_card.dart';
import 'package:crm_app/features/opportunities/presentation/providers/force_mr_preferences_provider.dart';
import 'package:crm_app/features/shared/presentation/providers/ui_provider.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:crm_app/features/shared/widgets/loading_modal.dart';
import 'package:crm_app/features/shared/widgets/no_exist_listview.dart';
import 'package:crm_app/features/shared/widgets/show_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:crm_app/features/opportunities/presentation/providers/doc_opportunitie_repository_provider.dart';
import '../providers/providers.dart';
import '../../../shared/shared.dart';
import 'package:intl/intl.dart';

/// Cachés en memoria (stale-while-revalidate) del contenido de cada tab del
/// detalle, indexados por una clave que combina showAll + oportunidad + ruc.
/// Permiten mostrar al instante lo ya visto al cambiar de oportunidad o al
/// poner "Todos", mientras se refresca en segundo plano.
final _eventsTabCacheProvider =
    StateProvider<Map<String, List<Event>>>((ref) => {});
final _activitiesTabCacheProvider =
    StateProvider<Map<String, List<Activity>>>((ref) => {});
final _photosTabCacheProvider =
    StateProvider<Map<String, List<OpDocument>>>((ref) => {});
final _documentsTabCacheProvider =
    StateProvider<Map<String, List<OpDocument>>>((ref) => {});

class OpportunityDetailScreen extends ConsumerWidget {
  final String opportunityId;

  const OpportunityDetailScreen({Key? key, required this.opportunityId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final companyState = ref.watch(companyProvider(companyId));
    // return Scaffold(
    //   body: companyState.isLoading
    //       ? const FullScreenLoader()
    //       : (companyState.company != null
    //           ? _CompanyDetailView(
    //               company: companyState.company!,
    //               /*contacts: companySecundaryState.contacts,
    //               opportunities: companyState.opportunities,
    //               activities: companyState.activities,
    //               events: companyState.events,
    //               companyLocales: companyState.companyLocales,*/
    //             )
    //           : Center(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   const Text('No se encontro datos de la empresa'),
    //                   const SizedBox(
    //                     height: 10,
    //                   ),
    //                   ElevatedButton(
    //                     onPressed: () {
    //                       // Acción cuando se presiona el botón
    //                       context.pop();
    //                     },
    //                     child: const Text('Regresar'),
    //                   ),
    //                 ],
    //               ),
    //             ),
    // ),
    // );
    return _CompanyDetailView(opportunityId);
  }
}

class _CompanyDetailView extends ConsumerStatefulWidget {
  final String opportunityId;

  const _CompanyDetailView(this.opportunityId);

  @override
  _CompanyDetailViewState createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends ConsumerState<_CompanyDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentIndex = 0;
  // Inicia en false: si el grupo ya viene sembrado desde el punto de entrada
  // no se muestra el LinearProgressIndicator inicial. Solo se pone en true
  // dentro de _refreshOpportunityGroupFull() cuando realmente se recarga.
  bool _isLoadingCompanyGroup = false;

  final LayerLink _opportunitySwitcherLink = LayerLink();
  final GlobalKey _opportunitySwitcherKey = GlobalKey();
  OverlayEntry? _opportunitySwitcherOverlay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: ref.read(currentOpportunityDetailTabProvider),
    );
    currentIndex = _tabController.index;
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final group = ref.read(currentOpportunityGroupProvider);
      final selected = ref.read(selectedOp);
      final opportunity =
          ref.read(opportunityProvider(widget.opportunityId)).opportunity;

      // Caso 1: No hay contexto inicial (deep link, URL directa).
      // Aquí sí se muestra el loader porque no hay nada que mostrar.
      if (group.isEmpty || selected == null) {
        _refreshOpportunityGroupFull();
        return;
      }

      // Caso 2: Inconsistencia entre widget.opportunityId y selectedOp.
      if (selected.id != widget.opportunityId && opportunity == null) {
        _refreshOpportunityGroupFull();
        return;
      }

      // Caso 3 (normal): Ya hay contexto sembrado. La navegación fue
      // instantánea. Se completa el grupo en SEGUNDO PLANO para traer todas
      // las oportunidades de la empresa (todos los estados) sin bloquear la
      // UI ni recargar las tabs (actividades, fotos, eventos).
      _refreshOpportunityGroupSilent();

      // Se prearman en segundo plano los datos COMPLETOS (con responsable) de
      // todas las oportunidades del grupo, para que al cambiar de oportunidad
      // ya esté todo listo y el responsable no aparezca con retraso.
      _prefetchGroupFullDetails();
    });
  }

  /// Precarga los datos completos (getOpportunityById, que incluye el
  /// responsable) de cada oportunidad del grupo y los guarda en el caché
  /// persistente [fullOpportunityCacheProvider].
  void _prefetchGroupFullDetails() {
    final group = ref.read(currentOpportunityGroupProvider);
    for (final op in group) {
      unawaited(_prefetchFullOpportunity(op.id));
    }
  }

  Future<void> _prefetchFullOpportunity(String id) async {
    if (id.isEmpty) return;
    if (ref.read(fullOpportunityCacheProvider).containsKey(id)) return;
    try {
      final full = await ref
          .read(opportunitiesRepositoryProvider)
          .getOpportunityById(id);
      final cache =
          Map<String, Opportunity>.from(ref.read(fullOpportunityCacheProvider));
      cache[id] = full;
      ref.read(fullOpportunityCacheProvider.notifier).state = cache;
    } catch (_) {
      // Prefetch best-effort: si falla, la vista igual cargará por demanda.
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _closeOpportunitySwitcher();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      currentIndex = _tabController.index;
    });
    ref.read(currentOpportunityDetailTabProvider.notifier).state =
        _tabController.index;
  }

  Future<void> _refreshCurrentOpportunity() async {
    final currentId = ref.read(selectedOp)?.id ?? widget.opportunityId;
    await ref.read(opportunityProvider(currentId).notifier).loadOpportunity();

    final updated = ref.read(opportunityProvider(currentId)).opportunity;
    if (updated == null) return;

    final group = ref.read(currentOpportunityGroupProvider);
    if (group.isNotEmpty) {
      final updatedGroup = group.map((opportunity) {
        return opportunity.id == currentId ? updated : opportunity;
      }).toList();
      ref.read(currentOpportunityGroupProvider.notifier).state = updatedGroup;
    }

    // Se refresca el caché de datos completos con la versión actualizada.
    final cache =
        Map<String, Opportunity>.from(ref.read(fullOpportunityCacheProvider));
    cache[currentId] = updated;
    ref.read(fullOpportunityCacheProvider.notifier).state = cache;

    ref.read(selectedOp.notifier).state = updated;
    ref.read(selectOpportunity.notifier).state = updated;
  }

  /// Completa el grupo de la empresa en segundo plano SIN mostrar loader y
  /// SIN recargar las tabs. Solo actualiza la lista del switcher para que
  /// muestre todas las oportunidades de la empresa (todos los estados).
  /// No toca selectedOp para evitar que las tabs se reconstruyan/recarguen.
  Future<void> _refreshOpportunityGroupSilent() async {
    final currentId = ref.read(selectedOp)?.id ?? widget.opportunityId;

    // Se carga la oportunidad completa para obtener un empresaKey confiable
    // (el objeto que viene de la lista filtrada a veces no trae el
    // oprtLocalCodigo, y sin él el filtro por empresaKey queda vacío y el
    // grupo no se actualiza en el primer intento).
    await ref.read(opportunityProvider(currentId).notifier).loadOpportunity();

    final loaded = ref.read(opportunityProvider(currentId)).opportunity;
    final base = loaded ?? ref.read(selectedOp);
    final ruc = base?.oprtRuc ?? '';
    if (ruc.isEmpty) return;

    final user = ref.read(authProvider).user;
    final refreshedGroups =
        await ref.read(opportunitiesRepositoryProvider).getListOpportunities(
              ruc: ruc,
              search: '',
              limit: 100,
              offset: 1,
              idUsuario: (user?.isAdmin ?? false) ? '' : (user?.code ?? ''),
              estado: '',
            );
    final refreshed = refreshedGroups
        .expand(
            (opportunity) => opportunity.oportunidadesDelGrupo ?? [opportunity])
        .toList();

    // Todas las oportunidades de la empresa (mismo RUC), sin importar estado.
    final byRuc = refreshed
        .where((opportunity) => (opportunity.oprtRuc ?? '') == ruc)
        .toList();

    // Se actualiza el caché por RUC para que próximas entradas sean instantáneas.
    if (byRuc.isNotEmpty) {
      final newCache = Map<String, List<Opportunity>>.from(
          ref.read(companyGroupCacheProvider));
      newCache[ruc] = byRuc;
      ref.read(companyGroupCacheProvider.notifier).state = newCache;
    }

    // Se muestran TODAS las oportunidades de la misma empresa (mismo RUC), sin
    // importar el estado (activo, pausa, ganado, perdida) ni el local.
    final result = byRuc;

    if (result.isEmpty) return;
    if (!mounted) return;

    // Solo se actualiza el grupo (para el switcher). No se toca selectedOp
    // ni se recargan las tabs.
    ref.read(currentOpportunityGroupProvider.notifier).state = result;

    // Al conocerse el grupo completo, se prearman los datos completos (con
    // responsable) de todas sus oportunidades para que el cambio sea instantáneo.
    _prefetchGroupFullDetails();
  }

  Future<void> _refreshOpportunityGroupFull() async {
    final currentId = ref.read(selectedOp)?.id ?? widget.opportunityId;

    if (mounted) {
      setState(() {
        _isLoadingCompanyGroup = true;
      });
    }

    await ref.read(opportunityProvider(currentId).notifier).loadOpportunity();

    final current = ref.read(selectedOp);
    final loadedOpportunity =
        ref.read(opportunityProvider(currentId)).opportunity;
    final baseOpportunity = current ?? loadedOpportunity;
    final ruc = baseOpportunity?.oprtRuc ?? '';

    if (ruc.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingCompanyGroup = false;
        });
      }
      return;
    }

    final user = ref.read(authProvider).user;
    final refreshedGroups =
        await ref.read(opportunitiesRepositoryProvider).getListOpportunities(
              ruc: ruc,
              search: '',
              limit: 100,
              offset: 1,
              idUsuario: (user?.isAdmin ?? false) ? '' : (user?.code ?? ''),
              estado: '',
            );
    final refreshed = refreshedGroups
        .expand(
            (opportunity) => opportunity.oportunidadesDelGrupo ?? [opportunity])
        .toList();
    // Todas las oportunidades de la misma empresa (mismo RUC), sin importar
    // estado ni local.
    final filtered = refreshed
        .where((opportunity) => (opportunity.oprtRuc ?? '') == ruc)
        .toList();

    if (filtered.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingCompanyGroup = false;
        });
      }
      return;
    }

    ref.read(currentOpportunityGroupProvider.notifier).state = filtered;

    final selectedId =
        ref.read(selectedOp)?.id ?? baseOpportunity?.id ?? currentId;
    final updatedSelected = filtered.where((o) => o.id == selectedId).toList();
    if (updatedSelected.isNotEmpty) {
      ref.read(selectedOp.notifier).state = updatedSelected.first;
      ref.read(selectOpportunity.notifier).state = updatedSelected.first;
    } else if (baseOpportunity != null) {
      ref.read(selectedOp.notifier).state = filtered.first;
      ref.read(selectOpportunity.notifier).state = filtered.first;
    }

    if (!mounted) return;
    setState(() {
      _isLoadingCompanyGroup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final opportunityGroup = ref.watch(currentOpportunityGroupProvider);
    final showAll = ref.watch(currentOpportunityShowAllProvider);
    final currentOpportunityId =
        ref.watch(selectedOp)?.id ?? widget.opportunityId;
    final siblings =
        opportunityGroup.length > 1 ? opportunityGroup : const <Opportunity>[];

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          centerTitle: true,
          title: const Text(
            "Detalle de la oportunidad",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(
                  Icons.info,
                  size: 30,
                ),
                text: 'Informacion',
              ),
              Tab(
                icon: Icon(
                  Icons.event,
                  size: 30,
                ),
                text: 'Eventos',
              ),
              Tab(
                icon: Icon(
                  Icons.local_activity,
                  size: 30,
                ),
                text: 'Actividad',
              ),
              Tab(
                icon: Icon(
                  Icons.camera_enhance_sharp,
                  size: 30,
                ),
                text: 'Fotos',
              ),
              Tab(
                icon: Icon(
                  Icons.file_copy_sharp,
                  size: 30,
                ),
                text: 'Archivos',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.autorenew_rounded),
              onPressed: () async {
                final targetId =
                    ref.read(selectedOp)?.id ?? widget.opportunityId;
                final result =
                    await context.push('/opportunity_status/$targetId');
                if (!mounted) return;
                if (result is Map<String, dynamic>) {
                  final nextId = result['targetOpportunityId'] as String?;
                  final routeChanged = result['routeChanged'] == true;
                  if (routeChanged && nextId != null && nextId.isNotEmpty) {
                    ref.read(currentOpportunityShowAllProvider.notifier).state =
                        false;
                    ref
                        .read(currentOpportunityDetailTabProvider.notifier)
                        .state = 0;
                    final nextOpportunity = ref
                        .read(currentOpportunityGroupProvider)
                        .where((opportunity) => opportunity.id == nextId)
                        .toList();
                    if (nextOpportunity.isNotEmpty) {
                      ref.read(selectedOp.notifier).state =
                          nextOpportunity.first;
                      ref.read(selectOpportunity.notifier).state =
                          nextOpportunity.first;
                    }
                    _reloadCurrentTabForOpportunity(nextId);
                    setState(() {});
                    // Se cargan los datos completos (con responsable) del nuevo
                    // objetivo y se refresca el caché, para que el responsable
                    // no quede en blanco tras cambiar de estado.
                    await _refreshCurrentOpportunity();
                    return;
                  }

                  await _refreshCurrentOpportunity();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Si ya hay una oportunidad específica seleccionada (no
                // "Todos"), se edita directamente sin preguntar. Solo se
                // muestra el selector cuando el switcher está en "Todos".
                final target = await resolveTargetOpportunity(context, ref);
                if (target == null) return;
                final didEdit = await context.push('/opportunity/${target.id}');
                if (!mounted) return;
                if (didEdit == true) {
                  await _refreshCurrentOpportunity();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoadingCompanyGroup)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: LinearProgressIndicator(minHeight: 3),
              )
            else if (siblings.isNotEmpty)
              _buildOpportunitySwitcher(siblings, showAll),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics:
                    const NeverScrollableScrollPhysics(), // Desactiva el scroll
                children: [
                  buildInformation(),
                  buildEventsOportunity(currentOpportunityId),
                  buildActivity(currentOpportunityId),
                  buildPhotos(currentOpportunityId),
                  buildDocuments(currentOpportunityId)
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _itFloatingButton(currentIndex),
      ),
    );
  }

  Widget _buildOpportunitySwitcher(List<Opportunity> siblings, bool showAll) {
    final selected = ref.read(selectedOp);
    final current = siblings.firstWhere(
      (o) => o.id == selected?.id,
      orElse: () => siblings.first,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: CompositedTransformTarget(
        link: _opportunitySwitcherLink,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _toggleOpportunitySwitcher(siblings, current),
          child: Container(
            key: _opportunitySwitcherKey,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    showAll && currentIndex != 0 ? 'Todos' : current.oprtNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleOpportunitySwitcher(
    List<Opportunity> siblings,
    Opportunity current,
  ) {
    final showAll = ref.read(currentOpportunityShowAllProvider);
    if (_opportunitySwitcherOverlay != null) {
      _closeOpportunitySwitcher();
      return;
    }

    final renderBox =
        _opportunitySwitcherKey.currentContext!.findRenderObject() as RenderBox;
    final buttonWidth = renderBox.size.width;
    final buttonHeight = renderBox.size.height;

    _opportunitySwitcherOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeOpportunitySwitcher,
              ),
            ),
            CompositedTransformFollower(
              link: _opportunitySwitcherLink,
              showWhenUnlinked: false,
              offset: Offset(0, buttonHeight),
              child: Material(
                elevation: 4,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: buttonWidth,
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: currentIndex == 0
                        ? siblings.length
                        : siblings.length + 1,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (currentIndex != 0 && index == 0) {
                        return InkWell(
                          onTap: () => _onShowAllSelected(siblings),
                          child: Container(
                            color: showAll
                                ? const Color(0xFFE8F0FE)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Todos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (showAll)
                                  const Icon(
                                    Icons.check,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      final opportunity =
                          siblings[currentIndex == 0 ? index : index - 1];
                      final isSelected =
                          !showAll && opportunity.id == current.id;

                      return InkWell(
                        onTap: () => _onOpportunitySelected(
                            opportunity, current, siblings),
                        child: Container(
                          color: isSelected
                              ? const Color(0xFFE8F0FE)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  opportunity.oprtNombre,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_opportunitySwitcherOverlay!);
  }

  void _closeOpportunitySwitcher() {
    _opportunitySwitcherOverlay?.remove();
    _opportunitySwitcherOverlay = null;
  }

  void _onOpportunitySelected(
    Opportunity opportunity,
    Opportunity current,
    List<Opportunity> siblings,
  ) {
    final wasShowingAll = ref.read(currentOpportunityShowAllProvider);
    _closeOpportunitySwitcher();
    if (opportunity.id == current.id && !wasShowingAll) return;
    ref.read(currentOpportunityShowAllProvider.notifier).state = false;
    if (opportunity.id == current.id && wasShowingAll) {
      _reloadCurrentTabForOpportunity(opportunity.id);
      setState(() {});
      return;
    }
    ref.read(selectOpportunity.notifier).state = opportunity;
    ref.read(selectedOp.notifier).state = opportunity;
    ref.read(currentOpportunityGroupProvider.notifier).state = siblings;
    setState(() {});
  }

  void _onShowAllSelected(List<Opportunity> siblings) {
    _closeOpportunitySwitcher();
    ref.read(currentOpportunityShowAllProvider.notifier).state = true;
    ref.read(currentOpportunityGroupProvider.notifier).state = siblings;
    setState(() {});
  }

  void _reloadCurrentTabForOpportunity(String opportunityId) {
    switch (currentIndex) {
      case 1:
        ref.read(eventsProvider.notifier).loadNextPageByObtetivo(opportunityId);
        break;
      case 2:
        ref
            .read(activitiesProvider.notifier)
            .loadNextPageActivitiesByOpportunities(
              isRefresh: true,
              opportunityId: opportunityId,
            );
        break;
      case 3:
        ref.read(docOpportunitieProvider.notifier).loadNextPage(
              type: TypeFileOp.photo,
            );
        break;
      case 4:
        ref.read(docOpportunitieProvider.notifier).loadNextPage(
              type: TypeFileOp.archive,
            );
        break;
    }
  }

  /// Al crear un evento nuevo desde esta pantalla, si la empresa tiene más
  /// de una oportunidad (equipo), se pregunta antes a cuál de ellas queda
  /// asociado el evento en lugar de asumir la que está abierta.
  Future<void> _handleNewEvent() async {
    final target = await resolveTargetOpportunity(context, ref);
    if (target == null) return;

    ref.read(selectOpportunity.notifier).state = target;
    ref.read(selectedOp.notifier).state = target;
    ref
        .read(uiProvider.notifier)
        .onCompanyActivity(target.oprtRuc ?? '', target.razon ?? '');

    if (!mounted) return;
    context.push('/event/new');
  }

  Widget _itFloatingButton(int currentIndex) {
    switch (currentIndex) {
      case 1:
        return FloatingActionButtonCustom(
          iconData: Icons.add,
          callOnPressed: _handleNewEvent,
        );
      case 2:
        return FloatingActionButtonCustom(
          callOnPressed: () {
            final opportunity = ref.watch(selectedOp);
            log("This is the opportunitye ${opportunity?.id}");
            log("This is the opportunitye ${opportunity?.oprtRuc}");
            log("This is the opportunitye ${opportunity?.razon}");
            ref.read(rucOpportunitieProvider.notifier).state =
                opportunity?.oprtRuc ?? '';
            ref.read(idOportunidadMotivo.notifier).state = opportunity?.id;
            ref.read(razonOportunityProvider.notifier).state =
                opportunity?.razon ?? '';
            ref.read(fromOpportunity.notifier).state = true;
            ref.read(uiProvider.notifier).deleteCompanyActivity();
            context.push('/activity/new').then((value) {
              ref
                  .read(activitiesProvider.notifier)
                  .loadNextPageActivitiesByOpportunities(
                    isRefresh: true,
                    opportunityId:
                        ref.read(selectedOp.notifier).state?.id ?? '',
                  );
            });
          },
          iconData: Icons.add,
        );
      default:
        return Container();
    }
  }

  Widget buildEventsOportunity(String currentOpportunityId) {
    return EventsDetailView(
      key: ValueKey(
          'events-${ref.watch(currentOpportunityShowAllProvider)}-$currentOpportunityId'),
      opportunityId: currentOpportunityId,
      companyRuc: ref.watch(selectedOp)?.oprtRuc ?? '',
      groupIds:
          ref.watch(currentOpportunityGroupProvider).map((o) => o.id).toList(),
      showAll: ref.watch(currentOpportunityShowAllProvider),
    );
  }

  Widget buildActivity(String currentOpportunityId) {
    return _ActivitiesView(
      key: ValueKey(
          'activities-${ref.watch(currentOpportunityShowAllProvider)}-$currentOpportunityId'),
      opportunityId: currentOpportunityId,
      companyRuc: ref.watch(selectedOp)?.oprtRuc ?? '',
      groupIds:
          ref.watch(currentOpportunityGroupProvider).map((o) => o.id).toList(),
      showAll: ref.watch(currentOpportunityShowAllProvider),
    );
  }

  Widget buildInformation() {
    return OpportunityDetailView(
      opportunityId: ref.watch(selectedOp)?.id ?? widget.opportunityId,
      onGenerateSummary: () async {
        final prefsNotifier = ref.read(forceMrPreferencesProvider.notifier);
        final hasAccepted = await prefsNotifier.hasAccepted();

        if (!mounted) return;

        if (hasAccepted) {
          // Ya aceptó Force MR, ir directo al resumen
          context.push(
              '/opportunity_summary/${ref.read(selectedOp)?.id ?? widget.opportunityId}');
        } else {
          // Primera vez, mostrar activación
          context.push(
              '/force_mr_activation/${ref.read(selectedOp)?.id ?? widget.opportunityId}');
        }
      },
    );
  }

  Widget buildPhotos(String currentOpportunityId) {
    return _PhotoView(
      _tabController,
      key: ValueKey(
          'photos-${ref.watch(currentOpportunityShowAllProvider)}-$currentOpportunityId'),
      opportunityId: currentOpportunityId,
      companyRuc: ref.watch(selectedOp)?.oprtRuc ?? '',
      groupIds:
          ref.watch(currentOpportunityGroupProvider).map((o) => o.id).toList(),
      showAll: ref.watch(currentOpportunityShowAllProvider),
    );
  }

  Widget buildDocuments(String currentOpportunityId) {
    return _DocumentsView(
      _tabController,
      key: ValueKey(
          'documents-${ref.watch(currentOpportunityShowAllProvider)}-$currentOpportunityId'),
      opportunityId: currentOpportunityId,
      companyRuc: ref.watch(selectedOp)?.oprtRuc ?? '',
      groupIds:
          ref.watch(currentOpportunityGroupProvider).map((o) => o.id).toList(),
      showAll: ref.watch(currentOpportunityShowAllProvider),
    );
  }
}

class OpportunityDetailView extends ConsumerWidget {
  final String opportunityId;
  final VoidCallback? onGenerateSummary;

  const OpportunityDetailView({
    super.key,
    required this.opportunityId,
    this.onGenerateSummary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityState = ref.watch(opportunityProvider(opportunityId));
    final selected = ref.watch(selectedOp);

    // Se prefiere el objeto COMPLETO (con responsable/arrayresponsables). El
    // orden de prioridad es:
    //   1) caché persistente prearmado (fullOpportunityCacheProvider): al
    //      entrar al detalle se precargan TODAS las oportunidades del grupo,
    //      así que normalmente ya está completo desde el primer render.
    //   2) el objeto cargado por opportunityProvider (getOpportunityById).
    //   3) selectedOp como respaldo instantáneo (viene de la lista/grupo y NO
    //      trae responsables), solo mientras el completo termina de cargar.
    final cached = ref.watch(fullOpportunityCacheProvider)[opportunityId];
    final loaded = opportunityState.opportunity;
    final opportunity = cached ??
        ((loaded != null && loaded.id == opportunityId)
            ? loaded
            : (selected?.id == opportunityId ? selected : loaded));

    if (opportunityState.isLoading && opportunity == null) {
      return const FullScreenLoader();
    }

    if (opportunity == null) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: double.infinity, // Ocupa todo el ancho disponible
                alignment: Alignment.center,
                child: const Text(
                  'No se encontro información de la oportunidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ))
          ],
        ),
      );
    }

    return Scaffold(
      // appBar: AppBar(
      //   // title: const Text('Detalles de oportunidad'),
      //   // actions: [
      //   //   IconButton(
      //   //     icon: const Icon(Icons.edit),
      //   //     onPressed: () {
      //   //       context.push('/opportunity/${opportunity.id}');
      //   //     },
      //   //   ),
      //   // ],
      // ),
      // floatingActionButton: FloatingActionButton(
      //   elevation: 0,
      //   backgroundColor: Colors.blueGrey,
      //   onPressed: () {},
      //   child: IconButton(
      //     icon: const Icon(
      //       Icons.edit,
      //       color: Colors.white,
      //     ),
      //     onPressed: () {
      //       context.push('/opportunity/${opportunity.id}');
      //     },
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OpportunityForceMrSummaryCard(
                onGenerateSummary: onGenerateSummary,
              ),
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  ContainerCustom(
                    label: 'Nombre de la oportunidad',
                    text: opportunity.oprtNombre,
                  ),
                  // Positioned(
                  //   right: 20,
                  //   top: 1,
                  //   child: SizedBox(
                  //     width: 50,
                  //     child: MaterialButton(
                  //       padding: EdgeInsets.zero,
                  //       shape: const RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.all(
                  //           Radius.circular(100),
                  //         ),
                  //       ),
                  //       color: Colors.blueGrey,
                  //       onPressed: () {},
                  //       child: IconButton(
                  //         icon: const Icon(
                  //           Icons.edit,
                  //           color: Colors.white,
                  //         ),
                  //         onPressed: () {
                  //           context.push('/opportunity/${opportunity.id}');
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              ContainerCustom(
                label: 'Estado',
                text: opportunity.oprtNobbreEstadoOportunidad ?? '',
              ),
              ContainerCustom(
                label: 'Probabilidad',
                text: '${opportunity.oprtProbabilidad}%',
              ),
              const ContainerCustom(
                label: 'Moneda',
                text: 'USD',
              ),
              ContainerCustom(
                label: 'Importe Total',
                text: opportunity.oprtValor.toString(),
              ),
              ContainerCustom(
                label: 'Fecha',
                text: DateFormat('dd-MM-yyyy').format(
                    opportunity.oprtFechaPrevistaVenta ?? DateTime.now()),
              ),
              ContainerCustom(
                label: 'Empresa',
                text: opportunity.oprtRazon ?? '',
              ),
              ContainerCustom(
                label: 'Local',
                text: opportunity.oprtLocalNombre ?? '',
              ),
              ContainerCustom(
                label: 'Contacto',
                text: opportunity.oprtNombreContacto ?? '',
              ),
              if (opportunity.arrayresponsables != null &&
                  opportunity.arrayresponsables!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Responsables',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 8),
                      Wrap(
                        runSpacing: 4,
                        spacing: 8,
                        children:
                            opportunity.arrayresponsables!.map((responsable) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              responsable.userreportName ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ContainerCustom(
                label: 'Comentario',
                text: opportunity.oprtComentario ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContainerCustom extends StatelessWidget {
  final String label;
  final String text;
  final IconData? icon;
  final Function()? callbackIcon;
  final Widget? icon2;
  final Function()? callbackIcon2;
  const ContainerCustom(
      {super.key,
      required this.label,
      required this.text,
      this.icon,
      this.callbackIcon,
      this.icon2,
      this.callbackIcon2});

  @override
  Widget build(BuildContext context) {
    if (text == "") {
      return const SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 247, 245, 245),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  maxLines: 10,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Expanded(child: SizedBox()),
                icon2 != null
                    ? IconButton(
                        icon: icon2!,
                        iconSize: 20, // Tamaño del icono
                        color: Colors.blue, // Color del icono
                        onPressed: callbackIcon2,
                      )
                    : const SizedBox(),
                icon != null
                    ? IconButton(
                        icon: Icon(icon),
                        iconSize: 30, // Tamaño del icono
                        color: Colors.blue, // Color del icono
                        onPressed: callbackIcon,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class EventsDetailView extends ConsumerStatefulWidget {
  final String opportunityId;
  final String companyRuc;
  final List<String> groupIds;
  final bool showAll;

  const EventsDetailView({
    super.key,
    required this.opportunityId,
    required this.companyRuc,
    required this.groupIds,
    required this.showAll,
  });

  @override
  ConsumerState<EventsDetailView> createState() => _EventsDetailViewState();
}

class _EventsDetailViewState extends ConsumerState<EventsDetailView> {
  bool _isLoading = true;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  String get _cacheKey =>
      '${widget.showAll}|${widget.opportunityId}|${widget.companyRuc}';

  Future<void> _loadEvents() async {
    // Si hay datos en caché, se muestran al instante (sin loader) y se
    // refresca en segundo plano. Si no, se muestra el loader.
    final cached = ref.read(_eventsTabCacheProvider)[_cacheKey];
    if (cached != null) {
      setState(() {
        _events = cached;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final EventsRepository repo = ref.read(eventsRepositoryProvider);
    final loaded = widget.showAll
        ? await repo.getEventsListByObjetive(
            '0',
            ruc: widget.companyRuc,
            offset: 0,
            top: 100,
          )
        : await repo.getEventsListByObjetive(widget.opportunityId);

    final filtered = widget.showAll
        ? loaded
            .where((event) => widget.groupIds.contains(event.evntIdOportunidad))
            .toList()
        : loaded;

    filtered.sort((a, b) => _eventDateTime(b).compareTo(_eventDateTime(a)));

    // Se actualiza el caché para próximas visitas.
    final newCache =
        Map<String, List<Event>>.from(ref.read(_eventsTabCacheProvider));
    newCache[_cacheKey] = filtered;
    ref.read(_eventsTabCacheProvider.notifier).state = newCache;

    if (!mounted) return;
    setState(() {
      _events = filtered;
      _isLoading = false;
    });
  }

  DateTime _eventDateTime(Event event) {
    final date =
        event.evntFechaInicioEvento ?? DateTime.fromMillisecondsSinceEpoch(0);
    final rawTime = event.evntHoraInicioEvento ?? '00:00:00';
    final time = rawTime.length >= 8 ? rawTime.substring(0, 8) : '00:00:00';
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final second = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FullScreenLoader();
    }

    if (_events.isEmpty) {
      return NoExistData(
        textCenter: 'No hay eventos registrados',
        onRefreshCallback: _loadEvents,
        icon: Icons.graphic_eq,
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: ListView.builder(
          itemCount: _events.length,
          itemBuilder: (context, index) {
            final event = _events[index];
            return ItemEvent(
              event: event,
              callbackOnTap: () {
                context.push('/event_detail/${event.id}');
              },
            );
          },
        ),
      ),
    );
  }
}

class _PhotoView extends ConsumerStatefulWidget {
  final TabController tabController;
  final String opportunityId;
  final String companyRuc;
  final List<String> groupIds;
  final bool showAll;

  const _PhotoView(
    this.tabController, {
    super.key,
    required this.opportunityId,
    required this.companyRuc,
    required this.groupIds,
    required this.showAll,
  });

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends ConsumerState<_PhotoView> {
  final ScrollController scrollController = ScrollController();
  bool _isLoading = true;
  List<OpDocument> _documents = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocuments());
    super.initState();
  }

  String get _cacheKey =>
      'photo|${widget.showAll}|${widget.opportunityId}|${widget.companyRuc}';

  Future<void> _loadDocuments() async {
    // Muestra caché al instante (sin loader) y refresca en segundo plano.
    final cached = ref.read(_photosTabCacheProvider)[_cacheKey];
    if (cached != null) {
      setState(() {
        _documents = cached;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final DocOpportunitieRepository repo =
        ref.read(docOpportunitieRepositoryProvider);
    final merged = <OpDocument>[];
    final seen = <String>{};

    final idOp = widget.showAll ? '0' : widget.opportunityId;
    final rucVal = widget.showAll ? widget.companyRuc : '';
    log('📸 _PhotoView._loadDocuments -> idOportunidad: $idOp, ruc: "$rucVal", showAll: ${widget.showAll}');

    final docs = await repo.getDocuments(
      idOportunidad: idOp,
      idTypeAdjunto: '03',
      ruc: rucVal,
    );
    for (final doc in docs) {
      if (!widget.showAll || widget.groupIds.contains(doc.oadjIdOportunidad)) {
        if (seen.add(doc.oadjIdOportunidadAdjunto)) {
          merged.add(doc);
        }
      }
    }

    merged.sort((a, b) => (int.tryParse(b.oadjIdOportunidadAdjunto) ?? 0)
        .compareTo(int.tryParse(a.oadjIdOportunidadAdjunto) ?? 0));

    // Actualiza el caché para próximas visitas.
    final newCache =
        Map<String, List<OpDocument>>.from(ref.read(_photosTabCacheProvider));
    newCache[_cacheKey] = merged;
    ref.read(_photosTabCacheProvider.notifier).state = newCache;

    if (!mounted) return;
    setState(() {
      _documents = merged;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleAddPressed() async {
    final target = await resolveTargetOpportunity(context, ref);
    if (target == null) return;
    if (!mounted) return;
    final uploaded = await showModalAdd(
      context,
      ref,
      widget.tabController,
      TypeFileOp.photo,
      opportunityIdOverride: target.id,
    );
    if (uploaded) {
      await _loadDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FullScreenLoader();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButtonCustom(
        callOnPressed: _handleAddPressed,
        iconData: Icons.add,
      ),
      body: _documents.isEmpty
          ? NoExistData(
              textCenter: 'No hay fotos registrados',
              onRefreshCallback: _loadDocuments,
              icon: Icons.graphic_eq,
            )
          : RefreshIndicator(
              onRefresh: _loadDocuments,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: MasonryGridView.count(
                  controller: scrollController,
                  // physics: const BouncingScrollPhysics(),
                  physics: const AlwaysScrollableScrollPhysics(),
                  crossAxisCount: 1,
                  itemCount: _documents.length,
                  itemBuilder: (_, index) {
                    final document = _documents[index];
                    return InkWell(
                      onTap: () async {
                        String fileUrl =
                            '${Environment.urlPublic}${document.oadjRutalRelativa}';
                        log(fileUrl.toString());
                        String fileName = document.oadjNombreOriginal;
                        log(fileName.toString());
                        await _requestStoragePermission(
                          context,
                          fileUrl,
                          fileName,
                        );
                      },
                      child: OPDocumentCard(
                        document: document,
                        callback: () {
                          showLoadingMessage(context);
                          ref
                              .read(docOpportunitieProvider.notifier)
                              .deleteDocument(document.oadjIdOportunidadAdjunto)
                              .then(
                            (OPDeleteDocumentResponse value) {
                              if (value.message != '') {
                                showSnackbar(context, value.message);
                                if (value.response) {}
                              }
                              _loadDocuments();
                            },
                          );
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _DocumentsView extends ConsumerStatefulWidget {
  final TabController tabController;
  final String opportunityId;
  final String companyRuc;
  final List<String> groupIds;
  final bool showAll;

  const _DocumentsView(
    this.tabController, {
    super.key,
    required this.opportunityId,
    required this.companyRuc,
    required this.groupIds,
    required this.showAll,
  });

  @override
  _DocumentsViewState createState() => _DocumentsViewState();
}

class _DocumentsViewState extends ConsumerState<_DocumentsView> {
  final ScrollController scrollController = ScrollController();
  bool _isLoading = true;
  List<OpDocument> _documents = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocuments());
    super.initState();
  }

  String get _cacheKey =>
      'archive|${widget.showAll}|${widget.opportunityId}|${widget.companyRuc}';

  Future<void> _loadDocuments() async {
    // Muestra caché al instante (sin loader) y refresca en segundo plano.
    final cached = ref.read(_documentsTabCacheProvider)[_cacheKey];
    if (cached != null) {
      setState(() {
        _documents = cached;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final DocOpportunitieRepository repo =
        ref.read(docOpportunitieRepositoryProvider);
    final merged = <OpDocument>[];
    final seen = <String>{};

    final idOp = widget.showAll ? '0' : widget.opportunityId;
    final rucVal = widget.showAll ? widget.companyRuc : '';
    log('📄 _DocumentsView._loadDocuments -> idOportunidad: $idOp, ruc: "$rucVal", showAll: ${widget.showAll}');

    final docs = await repo.getDocuments(
      idOportunidad: idOp,
      idTypeAdjunto: '01',
      ruc: rucVal,
    );
    for (final doc in docs) {
      if (!widget.showAll || widget.groupIds.contains(doc.oadjIdOportunidad)) {
        if (seen.add(doc.oadjIdOportunidadAdjunto)) {
          merged.add(doc);
        }
      }
    }

    merged.sort((a, b) => (int.tryParse(b.oadjIdOportunidadAdjunto) ?? 0)
        .compareTo(int.tryParse(a.oadjIdOportunidadAdjunto) ?? 0));

    // Actualiza el caché para próximas visitas.
    final newCache = Map<String, List<OpDocument>>.from(
        ref.read(_documentsTabCacheProvider));
    newCache[_cacheKey] = merged;
    ref.read(_documentsTabCacheProvider.notifier).state = newCache;

    if (!mounted) return;
    setState(() {
      _documents = merged;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleAddPressed() async {
    final target = await resolveTargetOpportunity(context, ref);
    if (target == null) return;
    if (!mounted) return;
    final uploaded = await showModalAdd(
      context,
      ref,
      widget.tabController,
      TypeFileOp.archive,
      opportunityIdOverride: target.id,
    );
    if (uploaded) {
      await _loadDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FullScreenLoader();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButtonCustom(
        callOnPressed: _handleAddPressed,
        iconData: Icons.add,
      ),
      body: _documents.isEmpty
          ? NoExistData(
              textCenter: 'No hay documentos registrados',
              onRefreshCallback: _loadDocuments,
              icon: Icons.graphic_eq,
            )
          : RefreshIndicator(
              onRefresh: _loadDocuments,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: MasonryGridView.count(
                  controller: scrollController,
                  // physics: const BouncingScrollPhysics(),
                  physics: const AlwaysScrollableScrollPhysics(),
                  crossAxisCount: 1,
                  itemCount: _documents.length,
                  itemBuilder: (_, index) {
                    final document = _documents[index];
                    return GestureDetector(
                      onTap: () async {
                        String fileUrl =
                            '${Environment.urlPublic}${document.oadjRutalRelativa}';
                        String fileName = document.oadjNombreOriginal;
                        await _requestStoragePermission(
                          context,
                          fileUrl,
                          fileName,
                        );
                      },
                      child: OPDocumentCard(
                        document: document,
                        callback: () {
                          showLoadingMessage(context);
                          ref
                              .read(docOpportunitieProvider.notifier)
                              .deleteDocument(document.oadjIdOportunidadAdjunto)
                              .then(
                            (OPDeleteDocumentResponse value) {
                              if (value.message != '') {
                                showSnackbar(context, value.message);
                                if (value.response) {}
                              }
                              _loadDocuments();
                            },
                          );
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

/// Si el selector superior está en una oportunidad específica, se usa esa
/// directamente. Si está en "Todos", se pide elegir una oportunidad para
/// guardar el nuevo registro.
Future<Opportunity?> resolveTargetOpportunity(
  BuildContext context,
  WidgetRef ref,
) async {
  if (!ref.read(currentOpportunityShowAllProvider)) {
    return ref.read(selectedOp);
  }

  final options = ref.read(currentOpportunityGroupProvider);
  if (options.isEmpty) return ref.read(selectedOp);

  Opportunity selected = ref.read(selectedOp) ?? options.first;

  return showDialog<Opportunity>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Seleccione oportunidad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            content: DropdownButton<Opportunity>(
              isExpanded: true,
              value: selected,
              items: options
                  .map(
                    (opportunity) => DropdownMenuItem<Opportunity>(
                      value: opportunity,
                      child: Text(
                        opportunity.oprtNombre,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setStateDialog(() => selected = value);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(selectedOp.notifier).state = selected;
                  Navigator.of(dialogContext).pop(selected);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Continuar'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _requestStoragePermission(context, fileUrl, fileName) async {
  var extStorageStatus = await Permission.manageExternalStorage.status;
  var storageStatus = await Permission.storage.request();
  if (!storageStatus.isGranted) {
    await Permission.storage.request();
  }
  if (!extStorageStatus.isGranted) {
    await Permission.manageExternalStorage.request();
  }
  if (extStorageStatus.isGranted || storageStatus.isGranted) {
    await downloadFile(fileUrl, fileName, context);
  } else if (extStorageStatus.isPermanentlyDenied ||
      storageStatus.isPermanentlyDenied) {
    // Permiso denegado permanentemente, mostrar diálogo para abrir la configuración
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Permiso de almacenamiento denegado permanentemente. Por favor habilítelo en la configuración.'),
        action: SnackBarAction(
          label: 'Abrir configuración',
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  } else {
    // Permiso denegado
    showSnackbar(context, 'Permiso de almacenamiento denegado');
  }
}

Future<void> downloadFile(
    String fileUrl, String fileName, BuildContext context) async {
  final dio = Dio();

  try {
    final dir = await getExternalStorageDirectory();
    final filePath = '${dir!.path}/$fileName';

    final response = await dio.download(fileUrl, filePath);

    if (response.statusCode == 200) {
      await showNotification(filePath, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Archivo descargado en: $filePath'),
          action: SnackBarAction(
            label: 'Abrir',
            onPressed: () {
              openFile(filePath);
            },
          ),
        ),
      );
    } else {
      print('Error al descargar el archivo: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al descargar el archivo: $e');
  }
}

String agregarPrefijoPeru(String numero) {
  // Verificar si el número ya tiene el prefijo de país "+51"
  if (!numero.startsWith('+51')) {
    // Si no tiene el prefijo, agregarlo al principio
    return '+51$numero';
  }
  // Si ya tiene el prefijo, devolver el número sin cambios
  return numero;
}

Future<bool> showModalAdd(
  BuildContext context,
  WidgetRef ref,
  TabController tabController,
  TypeFileOp typeFileOp, {
  String? opportunityIdOverride,
}) {
  final completer = Completer<bool>();

  showModalBottomSheet(
    context: context,
    builder: (BuildContext modalContext) {
      return Container(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              typeFileOp == TypeFileOp.archive ? 'Documentos' : "Fotos",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Visibility(
              visible: typeFileOp == TypeFileOp.archive,
              child: ListTile(
                title: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.file),
                    SizedBox(width: 10),
                    Center(child: Text('Subir Archivo')),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(modalContext);
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    String fileName = result.files.single.name;
                    String filePath = result.files.single.path!;

                    showLoadingMessage(context);
                    await ref
                        .read(docOpportunitieProvider.notifier)
                        .createDocument(
                          filePath,
                          fileName,
                          typeFileOp,
                          opportunityIdOverride: opportunityIdOverride,
                        );
                    Navigator.pop(context);
                  }
                  completer.complete(result != null);
                },
              ),
            ),
            Visibility(
              visible: typeFileOp == TypeFileOp.photo,
              child: ListTile(
                title: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.plus),
                    SizedBox(width: 10),
                    Center(child: Text('Agregar Foto')),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(modalContext);
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    String fileName = result.files.single.name;
                    String filePath = result.files.single.path!;
                    showLoadingMessage(context);
                    await ref
                        .read(docOpportunitieProvider.notifier)
                        .createDocument(
                          filePath,
                          fileName,
                          typeFileOp,
                          opportunityIdOverride: opportunityIdOverride,
                        );
                    Navigator.pop(context);
                  }
                  completer.complete(result != null);
                },
              ),
            ),
            const Divider(),
            Visibility(
              visible: typeFileOp == TypeFileOp.photo,
              child: ListTile(
                title: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.camera),
                    SizedBox(width: 10),
                    Center(
                      child: Text('Tomar Foto'),
                    ),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(modalContext);
                  final pickedFile =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    String fileName = pickedFile.name;
                    String filePath = pickedFile.path;
                    showLoadingMessage(context);
                    await ref
                        .read(docOpportunitieProvider.notifier)
                        .createDocument(
                          filePath,
                          fileName,
                          typeFileOp,
                          opportunityIdOverride: opportunityIdOverride,
                        );
                    Navigator.pop(context);
                  }
                  completer.complete(pickedFile != null);
                },
              ),
            ),
            const SizedBox(height: 6),
            ListTile(
              title: const Center(
                child: Text(
                  'CANCELAR',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              onTap: () {
                Navigator.pop(modalContext);
                completer.complete(false);
              },
            ),
          ],
        ),
      );
    },
  );

  return completer.future;
}

class _ActivitiesView extends ConsumerStatefulWidget {
  final String opportunityId;
  final String companyRuc;
  final List<String> groupIds;
  final bool showAll;

  const _ActivitiesView({
    super.key,
    required this.opportunityId,
    required this.companyRuc,
    required this.groupIds,
    required this.showAll,
  });

  @override
  _ActivitiesViewState createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends ConsumerState<_ActivitiesView> {
  final ScrollController scrollController = ScrollController();
  bool _isLoading = true;
  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadActivities());
  }

  String get _cacheKey =>
      '${widget.showAll}|${widget.opportunityId}|${widget.companyRuc}';

  Future<void> _loadActivities() async {
    // Muestra caché al instante (sin loader) y refresca en segundo plano.
    final cached = ref.read(_activitiesTabCacheProvider)[_cacheKey];
    if (cached != null) {
      setState(() {
        _activities = cached;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final ActivitiesRepository repo = ref.read(activitiesRepositoryProvider);
    final loaded = widget.showAll
        ? await repo.getActivitiesByOpportunitie(
            opportunityId: '0',
            ruc: widget.companyRuc,
            search: '',
            limit: 100,
            offset: 0,
          )
        : await repo.getActivitiesByOpportunitie(
            opportunityId: widget.opportunityId,
            ruc: '',
            search: '',
            limit: 100,
            offset: 0,
          );

    final filtered = widget.showAll
        ? loaded
            .where((activity) =>
                widget.groupIds.contains(activity.actiIdOportunidad))
            .toList()
        : loaded;

    filtered.sort((a, b) {
      final aDate = _activityDateTime(a);
      final bDate = _activityDateTime(b);
      return bDate.compareTo(aDate);
    });

    // Actualiza el caché para próximas visitas.
    final newCache =
        Map<String, List<Activity>>.from(ref.read(_activitiesTabCacheProvider));
    newCache[_cacheKey] = filtered;
    ref.read(_activitiesTabCacheProvider.notifier).state = newCache;

    if (!mounted) return;
    setState(() {
      _activities = filtered;
      _isLoading = false;
    });
  }

  DateTime _activityDateTime(Activity activity) {
    final date = activity.actiFechaActividad;
    final rawTime = activity.actiHoraActividad;
    final time = rawTime.length >= 8 ? rawTime.substring(0, 8) : '00:00:00';
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final second = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _loadActivities();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingModal();
    }

    return _activities.isNotEmpty
        ? _ListActivities(
            activities: _activities,
            onRefreshCallback: _refresh,
            scrollController: scrollController,
          )
        : NoExistData(
            textCenter: 'No hay actividades registradas',
            onRefreshCallback: _refresh,
            icon: Icons.graphic_eq,
          );
  }
}

class _ListActivities extends ConsumerStatefulWidget {
  final List<Activity> activities;
  final Future<void> Function() onRefreshCallback;
  final ScrollController scrollController;

  const _ListActivities(
      {required this.activities,
      required this.onRefreshCallback,
      required this.scrollController});

  @override
  _ListActivitiesState createState() => _ListActivitiesState();
}

class _ListActivitiesState extends ConsumerState<_ListActivities> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
        GlobalKey<RefreshIndicatorState>();
    return widget.activities.isEmpty
        ? Center(
            child: RefreshIndicator(
                onRefresh: widget.onRefreshCallback,
                key: refreshIndicatorKey,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: widget.onRefreshCallback,
                        child: const Text('Recargar'),
                      ),
                      const Center(
                        child: Text('No hay registros'),
                      ),
                    ],
                  ),
                )),
          )
        : NotificationListener(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels + 400 ==
                  scrollInfo.metrics.maxScrollExtent) {
                ref
                    .read(activitiesProvider.notifier)
                    .loadNextPageActivitiesByOpportunities(
                        isRefresh: false,
                        opportunityId:
                            ref.read(selectedOp.notifier).state?.id ?? '');
              }
              return false;
            },
            child: RefreshIndicator(
              notificationPredicate: defaultScrollNotificationPredicate,
              onRefresh: widget.onRefreshCallback,
              key: refreshIndicatorKey,
              child: ListView.separated(
                itemCount: widget.activities.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemBuilder: (context, index) {
                  final activity = widget.activities[index];

                  return ItemActivity(
                      activity: activity,
                      callbackOnTap: () {
                        context.push('/activity_detail/${activity.id}');
                      });
                },
              ),
            ),
          );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:go_router/go_router.dart';

// // import '../../../activities/domain/domain.dart';
// // import '../../../activities/presentation/widgets/item_activity.dart';
// // import '../../../agenda/domain/domain.dart';
// // import '../../../agenda/presentation/widgets/item_event.dart';
// // import '../../../contacts/domain/domain.dart';
// // import '../../../contacts/presentation/widgets/item_contact.dart';
// // import '../../../opportunities/domain/domain.dart';
// // import '../../../opportunities/presentation/widgets/item_opportunity.dart';
// // import '../../../shared/widgets/floating_action_button_custom.dart';
// // import '../../../shared/widgets/floating_action_button_icon_custom.dart';
// // import '../../../shared/shared.dart';

// class OpportunityDetailScreen extends ConsumerWidget {
//   final String opportunityId;

//   const OpportunityDetailScreen({Key? key, required this.opportunityId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // final companyState = ref.watch(companyProvider(companyId));

//     // return Scaffold(
//     //   body: companyState.isLoading
//     //       ? const FullScreenLoader()
//     //       : (companyState.company != null
//     //           ? _CompanyDetailView(
//     //               company: companyState.company!,
//     //               /*contacts: companySecundaryState.contacts,
//     //               opportunities: companyState.opportunities,
//     //               activities: companyState.activities,
//     //               events: companyState.events,
//     //               companyLocales: companyState.companyLocales,*/
//     //             )
//     //           : Center(
//     //               child: Column(
//     //                 mainAxisAlignment: MainAxisAlignment.center,
//     //                 children: [
//     //                   const Text('No se encontro datos de la empresa'),
//     //                   const SizedBox(
//     //                     height: 10,
//     //                   ),
//     //                   ElevatedButton(
//     //                     onPressed: () {
//     //                       // Acción cuando se presiona el botón
//     //                       context.pop();
//     //                     },
//     //                     child: const Text('Regresar'),
//     //                   ),
//     //                 ],
//     //               ),
//     //             )),
//     // );
//     return _CompanyDetailView();
//   }
// }

// class _CompanyDetailView extends ConsumerStatefulWidget {
//   // final Company company;
//   /*final List<Contact> contacts;
//   final List<Opportunity> opportunities;
//   final List<Activity> activities;
//   final List<Event> events;
//   final List<CompanyLocal> companyLocales;*/

//   const _CompanyDetailView(
//       // required this.company,
//       /*required this.contacts,
//       required this.opportunities,
//       required this.activities,
//       required this.events,
//       required this.companyLocales*/
//       );

//   @override
//   _CompanyDetailViewState createState() => _CompanyDetailViewState();
// }

// class _CompanyDetailViewState extends ConsumerState<_CompanyDetailView>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 6, vsync: this);
//     _tabController.addListener(_handleTabChange);

//     // WidgetsBinding.instance?.addPostFrameCallback((_) {
//     //   ref
//     //       .watch(companyProvider(widget.company.ruc).notifier)
//     //       .loadSecundaryDetails();
//     // });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _handleTabChange() {
//     setState(() {
//       _currentIndex = _tabController.index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TextStyle styleTitle =
//     //     const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);
//     // TextStyle styleLabel = const TextStyle(
//     //     fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87);
//     // TextStyle styleContent =
//     //     const TextStyle(fontWeight: FontWeight.w400, fontSize: 16);
//     // SizedBox spacingHeight = const SizedBox(height: 14);

//     return DefaultTabController(
//       length: 6, // Ahora tenemos 6 pestañas
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("",
//               style: TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w600,
//                   overflow: TextOverflow.ellipsis)),
//           bottom: TabBar(
//             controller: _tabController,
//             tabs: const [
//               Tab(
//                   icon: Icon(
//                     Icons.info,
//                     size: 30,
//                   ),
//                   text: 'Informacion'),
//               Tab(
//                   icon: Icon(
//                     Icons.local_activity,
//                     size: 30,
//                   ),
//                   text: 'Actividad'),
//               Tab(
//                 icon: Icon(
//                   Icons.camera_enhance_sharp,
//                   size: 30,
//                 ),
//                 text: 'Fotos',
//               ),
//               Tab(
//                 icon: Icon(
//                   Icons.file_copy_sharp,
//                   size: 30,
//                 ),
//                 text: 'Archivos',
//               ),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () {
//                 // context.push('/company/${widget.company.rucId}');
//               },
//             ),
//           ],
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: const [
//             SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                 child: Text('fwefwe'),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                 child: Text('Informacion'),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                 child: Text('Locales'),
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                 child: Text('Cantacto'),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
