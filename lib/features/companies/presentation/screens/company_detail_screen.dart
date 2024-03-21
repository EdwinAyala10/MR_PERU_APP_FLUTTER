import 'package:crm_app/features/companies/domain/domain.dart';
import 'package:crm_app/features/companies/presentation/providers/company_provider.dart';
import 'package:crm_app/features/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyDetailScreen extends ConsumerWidget {
  final String companyId;

  const CompanyDetailScreen({Key? key, required this.companyId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyState = ref.watch(companyProvider(companyId));

    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Crear Empresa'),
        leading: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.push('/company/${companyState.company!.ruc}');
          },
        ),
      ),*/
      // 01 : CHECK-IN     06: CHECK-OUT
      floatingActionButton: FloatingActionButton.extended(
        label: Text(companyState.company?.cchkIdEstadoCheck == '06' ? 'CHECK-IN' : (companyState.company?.cchkIdEstadoCheck == null ? 'CHECK-IN' : 'CHECK-OUT')),
        icon: const Icon(Icons.arrow_circle_right_outlined),
        onPressed: () {
          String idCheck = companyState.company!.cchkIdEstadoCheck == '06' ? '01' : (companyState.company!.cchkIdEstadoCheck == null ? '01' : '06');
          String ruc = companyState.company!.ruc;
          String ids = '${idCheck}*${ruc}';
          context.push('/company_check_in/${ids}');
        },
      ),
      body: companyState.isLoading
          ? const FullScreenLoader()
          : _CompanyDetailView(company: companyState.company!),
    );
    //return _CompanyDetailView();
  }
}

class _CompanyDetailView extends StatelessWidget {
  final Company company;

  const _CompanyDetailView({required this.company});

  @override
  Widget build(BuildContext context) {
    TextStyle styleTitle =
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);
    TextStyle styleLabel = const TextStyle(
        fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black54);
    TextStyle styleContent =
        const TextStyle(fontWeight: FontWeight.w300, fontSize: 16);
    SizedBox spacingHeight = SizedBox(
      height: 14,
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text(
            company.razon,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          pinned: true,
          expandedHeight: 48,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/company/${company.ruc}');
              },
            ),
          ],
        ),
        SliverFillRemaining(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(company.cchkIdEstadoCheck ?? ''),
                  Text(company?.cchkIdEstadoCheck == '06' ? 'CHECK-IN' : (company?.cchkIdEstadoCheck == null ? 'CHECK-IN' : 'CHECK-OUT')),

                  Text('GENERAL', style: styleTitle),
                  spacingHeight,
                  FieldCompany('Nombre de la empresa', company.razon, styleLabel, styleContent),
                  FieldCompany('RUC', company.ruc, styleLabel, styleContent),
                  FieldCompany('Tipo', '', styleLabel, styleContent),
                  FieldCompany('Estado', company.estado ?? '', styleLabel, styleContent),
                  FieldCompany('Calificación', company.calificacion ?? '', styleLabel, styleContent),
                  FieldCompany('Responsable', '', styleLabel, styleContent),
                  FieldCompany('Empresa visible para todos', company.visibleTodos == "1" ? 'SI' : 'NO', styleLabel, styleContent),
                  FieldCompanyTextArea('Comentarios', company.seguimientoComentario ?? '', styleLabel, styleContent),
                  FieldCompanyTextArea('Recomendación', company.observaciones ?? '', styleLabel, styleContent),
                  spacingHeight,
                  Text('DATOS DE CONTACTO', style: styleTitle),
                  spacingHeight,
                  FieldCompany('Teléfono', company.telefono ?? '', styleLabel, styleContent),
                  FieldCompany('Email', company.email ?? '', styleLabel, styleContent),
                  FieldCompany('Web', company.website ?? '', styleLabel, styleContent),
                  spacingHeight,
                  Text('DIRECCION', style: styleTitle),
                  spacingHeight,
                  Text(company.direccion ?? '', overflow: TextOverflow.ellipsis, style: styleContent),
                  spacingHeight,
                  FieldCompanyTextArea('Detalle de la dirección', '', styleLabel, styleContent),
                  FieldCompanyTextArea('Población', '', styleLabel, styleContent),
                  FieldCompanyTextArea('Prov. / Reg.', '', styleLabel, styleContent),
                  FieldCompanyTextArea('Código postal', company.codigoPostal ?? '', styleLabel, styleContent),
                  spacingHeight,
                  spacingHeight,
                  spacingHeight,
                  spacingHeight,
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Column FieldCompany(String label, String text, TextStyle styleLabel, TextStyle styleContent) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: styleLabel),
            Spacer(),
            Text(text, overflow: TextOverflow.ellipsis, style: styleContent),
          ],
        ),
        Divider(),
      ],
    );
  }
  Column FieldCompanyTextArea(String label, String text, TextStyle styleLabel, TextStyle styleContent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: styleLabel),
        Text(text, overflow: TextOverflow.ellipsis, style: styleContent),
        Divider(),
      ],
    );
  }
}
