import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/opportunities/domain/entities/op_document.dart';
import 'package:crm_app/features/opportunities/domain/entities/opportunity.dart';
import 'package:crm_app/features/opportunities/domain/repositories/doc_opportunitie_repository.dart';
import 'package:crm_app/features/opportunities/infrastructure/mappers/op_create_document_response.dart';
import 'package:crm_app/features/opportunities/infrastructure/mappers/op_delete_document_mapper.dart';

import 'package:crm_app/features/opportunities/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TypeFileOp { photo, archive }

final selectedOp = StateProvider<Opportunity?>((ref) => null);

/// Oportunidades hermanas (mismo grupo/empresa) de la oportunidad
/// actualmente abierta en el detalle. Se setea al entrar desde [ItemOpportunity]
/// para poder pintar el selector "cambiar de oportunidad" en la parte
/// superior de la pantalla de detalle.
final currentOpportunityGroupProvider =
    StateProvider<List<Opportunity>>((ref) => []);

final currentOpportunityDetailTabProvider = StateProvider<int>((ref) => 0);

final currentOpportunityShowAllProvider = StateProvider<bool>((ref) => false);

/// Caché en memoria del grupo completo (todas las oportunidades, sin importar
/// su estado) de cada empresa, indexado por RUC. Se llena por prefetch al
/// dibujar las tarjetas de la lista, de modo que al entrar al detalle el
/// switcher muestre todas las oportunidades desde el PRIMER intento, sin
/// esperar una petición de red.
final companyGroupCacheProvider =
    StateProvider<Map<String, List<Opportunity>>>((ref) => {});

/// Caché persistente de oportunidades COMPLETAS (getOpportunityById), indexado
/// por id de oportunidad. A diferencia de [opportunityProvider] (autoDispose),
/// este caché no se destruye al cambiar de oportunidad, por lo que conserva
/// datos completos como el responsable (arrayresponsables). Se llena por
/// prefetch de todo el grupo al entrar al detalle, para que al cambiar de
/// oportunidad todo ya esté armado y no haya "parpadeo" del responsable.
final fullOpportunityCacheProvider =
    StateProvider<Map<String, Opportunity>>((ref) => {});

final docOpportunitieProvider =
    StateNotifierProvider<DocumentsNotifier, DocumentsState>(
  (ref) {
    final docOpRepository = ref.watch(docOpportunitieRepositoryProvider);
    final user = ref.watch(authProvider).user;
    final opportunity = ref.watch(selectedOp);
    return DocumentsNotifier(
      docOpRepository: docOpRepository,
      user: user!,
      opportunity: opportunity,
    );
  },
);

class DocumentsNotifier extends StateNotifier<DocumentsState> {
  final DocOpportunitieRepository docOpRepository;
  final Opportunity? opportunity;
  User user;

  DocumentsNotifier({
    required this.docOpRepository,
    required this.user,
    this.opportunity,
  }) : super(DocumentsState()) {
    // loadNextPage();
  }

  Future loadNextPage({
    required TypeFileOp type,
  }) async {
    print('Se esta ejecutando');
    if (state.isLoading || state.isLastPage) return;
    state = state.copyWith(isLoading: true);
    final documents = await docOpRepository.getDocuments(
      idOportunidad: (opportunity?.id) ?? '',
      idTypeAdjunto: type == TypeFileOp.photo ? "03" : "01",
    );
    print(opportunity?.id);
    print(TypeFileOp.photo);
    print(documents.length);
    if (documents.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isLastPage: false,
        documents: state.documents,
      );
      return;
    }

    state = state.copyWith(
      isLastPage: false,
      isLoading: false,
      // offset: state.offset + 10,
      // documents: [...state.documents, ...documents],
      documents: documents,
      listDocuments:
          documents.where((doc) => doc.oadjIdTipoAdjunto == '01').toList(),
      listLinks:
          documents.where((doc) => doc.oadjIdTipoAdjunto == '02').toList(),
    );
  }

  Future<OPCreateDocumentResponse> createDocument(
      String path, String filename, TypeFileOp typeFileOp,
      {String? opportunityIdOverride}) async {
    try {
      final targetOpportunityId =
          opportunityIdOverride ?? (opportunity?.id) ?? '';
      Map<String, dynamic> documentLike = {
        'path': path,
        'filename': filename,
        'ID_USUARIO_REGISTRO': user.code,
        'OADJ_ID_OPORTUNIDAD': targetOpportunityId,
        'OADJ_ID_TIPO_ADJUNTO': typeFileOp == TypeFileOp.photo ? '03' : '01',
      };

      final documentResponse = await docOpRepository.createDocument(
        documentLike,
      );
      final message = documentResponse.message;
      if (documentResponse.status) {
        final document = documentResponse.document as OpDocument;
        // Solo se refleja en la lista visible de esta pestaña si el adjunto
        // quedó asociado a la oportunidad que se está mostrando; si se
        // eligió otro equipo del grupo, no debe aparecer aquí.
        if (targetOpportunityId == ((opportunity?.id) ?? '')) {
          state = state.copyWith(
            documents: [
              document,
              ...state.documents,
            ],
            // listDocuments: document.oadjIdTipoAdjunto == '03'
            //     ? [document, ...state.listDocuments]
            //     : state.listDocuments,
            // listLinks: document.oadjIdTipoAdjunto == '01'
            //     ? [document, ...state.listLinks]
            //     : state.listLinks,
          );
        }
        return OPCreateDocumentResponse(response: true, message: message);
      }

      return OPCreateDocumentResponse(response: false, message: message);
    } catch (e) {
      return OPCreateDocumentResponse(
        response: false,
        message: 'Error, revisar con su administrador.',
      );
    }
  }

  Future<OPDeleteDocumentResponse> deleteDocument(String idAdjunto) async {
    try {
      final documentResponse = await docOpRepository.deleteDocumentLink(
        idAdjunto,
        user.id,
      );

      final message = documentResponse.message;
      if (documentResponse.status) {
        final documents = state.documents
            .where((doc) => doc.oadjIdOportunidadAdjunto != idAdjunto)
            .toList();
        state = state.copyWith(
          documents: documents,
          // listDocuments: documents
          //     .where((doc) => doc.oadjIdOportunidadAdjunto == '01')
          //     .toList(),
          // listLinks: documents
          //     .where((doc) => doc.oadjIdOportunidadAdjunto == '02')
          //     .toList()
          // );
        );
        return OPDeleteDocumentResponse(response: true, message: message);
      }

      return OPDeleteDocumentResponse(response: false, message: message);
    } catch (e) {
      return OPDeleteDocumentResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }
}

class DocumentsState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<OpDocument> documents;
  final List<OpDocument> listDocuments;
  final List<OpDocument> listLinks;

  DocumentsState({
    this.isLastPage = false,
    this.limit = 10,
    this.offset = 0,
    this.isLoading = false,
    this.documents = const [],
    this.listDocuments = const [],
    this.listLinks = const [],
  });

  DocumentsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<OpDocument>? documents,
    List<OpDocument>? listDocuments,
    List<OpDocument>? listLinks,
  }) =>
      DocumentsState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        documents: documents ?? this.documents,
        listDocuments: listDocuments ?? this.listDocuments,
        listLinks: listLinks ?? this.listLinks,
      );
}
