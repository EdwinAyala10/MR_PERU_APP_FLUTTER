import 'dart:async';
import 'dart:developer' as developer;
import 'package:crm_app/config/config.dart';
import 'package:crm_app/features/resource-detail/domain/domain.dart';
import 'package:crm_app/features/resource-detail/presentation/providers/resource_details_provider.dart';
import 'package:crm_app/features/shared/widgets/custom_company_field.dart';
import 'package:crm_app/features/shared/widgets/floating_action_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class RubroScreen extends ConsumerStatefulWidget {
  const RubroScreen({super.key});

  @override
  ConsumerState<RubroScreen> createState() => _RubroScreenState();
}

class _RubroScreenState extends ConsumerState<RubroScreen> {
  late TextEditingController _rubroController;
  String _selectedRubroId = '';
  String _selectedRubroName = '';
  String _selectedRubroIdRecursos = '';
  String _screenTitle = 'Crear Rubro';
  String _initialRubroText = '';
  String _initialSelectedRubroId = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _rubroController = TextEditingController();
    _rubroController.addListener(() {
      // Actualizar el estado cuando cambia el texto para detectar cambios
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onRubroSelected(ResourceDetail? rubro) {
    if (rubro == null) {
      setState(() {
        _selectedRubroId = '';
        _selectedRubroName = '';
        _selectedRubroIdRecursos = '';
        _screenTitle = 'Crear Rubro';
        _rubroController.clear();
        _initialRubroText = '';
        _initialSelectedRubroId = '';
      });
      return;
    }

    setState(() {
      _selectedRubroId = rubro.recdCodigo;
      _selectedRubroName = rubro.recdNombre;
      _selectedRubroIdRecursos = rubro.recdIdRecursos;
      _screenTitle = 'Editar Rubro';
      _rubroController.text = rubro.recdNombre;
      _initialRubroText = rubro.recdNombre;
      _initialSelectedRubroId = rubro.recdCodigo;
    });
  }

  bool _hasUnsavedChanges() {
    return _rubroController.text.trim() != _initialRubroText ||
        _selectedRubroId != _initialSelectedRubroId;
  }

  Future<void> _showDiscardChangesDialog(Function onConfirm) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Descartar cambios'),
          content: const Text(
            'Tienes cambios sin guardar. ¿Estás seguro de que deseas descartarlos?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text(
                'Descartar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onNuevoPressed() {
    if (_hasUnsavedChanges()) {
      _showDiscardChangesDialog(() {
        _clearFields();
      });
    } else {
      _clearFields();
    }
  }

  void _clearFields() {
    setState(() {
      _selectedRubroId = '';
      _selectedRubroName = '';
      _selectedRubroIdRecursos = '';
      _screenTitle = 'Crear Rubro';
      _rubroController.clear();
      _initialRubroText = '';
      _initialSelectedRubroId = '';
    });
  }

  Future<void> _onGuardarPressed() async {
    if (_rubroController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El campo Rubro es requerido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      RubroResponse response;

      if (_selectedRubroIdRecursos.isNotEmpty) {
        // Editar rubro existente
        response = await ref
            .read(resourceDetailsProvider.notifier)
            .editRubro(_rubroController.text.trim(), _selectedRubroIdRecursos);
      } else {
        // Crear nuevo rubro
        response = await ref
            .read(resourceDetailsProvider.notifier)
            .createRubro(_rubroController.text.trim());
      }

      // Mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: response.status ? Colors.green : Colors.red,
        ),
      );

      // Si fue exitoso, limpiar campos y cerrar pantalla
      if (response.status) {
        // Cerrar la pantalla indicando que se guardó algo
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      String errorMessage = 'Error al guardar el rubro';

      if (e is DioException && e.response?.statusCode == 429) {
        errorMessage =
            'Demasiadas solicitudes. Por favor, espera unos segundos e intenta nuevamente.';
      } else if (e is DioException &&
          e.response?.data is Map &&
          e.response?.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      } else {
        errorMessage =
            'Ocurrió un error inesperado al guardar el rubro. Inténtalo nuevamente.';
      }

      // Log técnico para diagnóstico
      developer.log(
        e.toString(),
        name: 'RubroScreen._onGuardarPressed',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _rubroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        if (_hasUnsavedChanges()) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Descartar cambios'),
                content: const Text(
                  'Tienes cambios sin guardar. ¿Estás seguro de que deseas salir?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      'Salir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
          if (shouldPop == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              _screenTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomCompanyField(
                      label: 'Rubro',
                      controller: _rubroController,
                      onChanged: (value) {
                        // El campo se actualiza automáticamente con el controller
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: ElevatedButton(
                      onPressed: _screenTitle == 'Crear Rubro'
                          ? null
                          : _onNuevoPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Nuevo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Editar Rubro",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              _RubroSelector(
                selectedRubroId: _selectedRubroId,
                selectedRubroName: _selectedRubroName,
                onRubroChanged: _onRubroSelected,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButtonCustom(
            callOnPressed: _isSaving ? null : _onGuardarPressed,
            iconData: Icons.save,
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _RubroSelector extends ConsumerStatefulWidget {
  final String selectedRubroId;
  final String selectedRubroName;
  final ValueChanged<ResourceDetail?> onRubroChanged;

  const _RubroSelector({
    required this.selectedRubroId,
    required this.selectedRubroName,
    required this.onRubroChanged,
  });

  @override
  ConsumerState<_RubroSelector> createState() => _RubroSelectorState();
}

class _RubroSelectorState extends ConsumerState<_RubroSelector> {
  Future<void> _showSearchDialog() async {
    final searchController = TextEditingController();
    List<ResourceDetail> rubros = [];
    bool isLoading = true;
    Timer? debounceTimer;

    // Función para buscar rubros dentro del diálogo
    Future<void> searchRubros(
        String search, Function setDialogState, bool Function() isOpen,
        {bool skipDebounce = false}) async {
      if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();

      // Si skipDebounce es true, ejecutar inmediatamente (para carga inicial)
      if (skipDebounce) {
        if (!isOpen()) return;

        setDialogState(() {
          isLoading = true;
        });

        try {
          final result = await ref
              .read(resourceDetailsProvider.notifier)
              .searchResourceDetailsByGroup(groupId: '16', search: search);

          if (!isOpen()) return;

          setDialogState(() {
            rubros = result.where((r) => r.recdCodigo != '00').toList();
            isLoading = false;
          });
        } catch (e) {
          if (!isOpen()) return;

          setDialogState(() {
            isLoading = false;
          });
        }
        return;
      }

      // Para búsquedas con debounce (cuando el usuario escribe)
      debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        if (!isOpen()) return;

        setDialogState(() {
          isLoading = true;
        });

        try {
          final result = await ref
              .read(resourceDetailsProvider.notifier)
              .searchResourceDetailsByGroup(groupId: '16', search: search);

          if (!isOpen()) return;

          setDialogState(() {
            rubros = result.where((r) => r.recdCodigo != '00').toList();
            isLoading = false;
          });
        } catch (e) {
          if (!isOpen()) return;

          setDialogState(() {
            isLoading = false;
          });
        }
      });
    }

    final selected = await showDialog<ResourceDetail>(
      context: context,
      builder: (context) {
        bool isDialogOpen = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Cargar rubros al abrir el diálogo (sin debounce para carga inmediata)
            if (rubros.isEmpty && isLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (isDialogOpen) {
                  searchRubros('', setDialogState, () => isDialogOpen,
                      skipDebounce: true);
                }
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Título y campo de búsqueda
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Buscar rubro...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        searchController.clear();
                                        searchRubros('', setDialogState,
                                            () => isDialogOpen,
                                            skipDebounce: true);
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              setDialogState(() {});
                              searchRubros(
                                  value, setDialogState, () => isDialogOpen);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            debounceTimer?.cancel();
                            isDialogOpen = false;
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Lista de rubros
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : rubros.isEmpty
                              ? Center(
                                  child: Text(
                                    'No se encontraron rubros',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: rubros.length,
                                  itemBuilder: (context, index) {
                                    final rubro = rubros[index];
                                    final isSelected = rubro.recdCodigo ==
                                        widget.selectedRubroId;
                                    return ListTile(
                                      title: Text(
                                        rubro.recdNombre,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? const Icon(Icons.check,
                                              color: primaryColor)
                                          : null,
                                      onTap: () {
                                        Navigator.of(context).pop(rubro);
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      widget.onRubroChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSearchDialog(),
      child: InputDecorator(
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.selectedRubroName.isNotEmpty
                    ? widget.selectedRubroName
                    : 'Seleccionar rubro...',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.selectedRubroName.isNotEmpty
                      ? Colors.black
                      : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
