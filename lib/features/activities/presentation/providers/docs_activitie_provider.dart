import 'package:crm_app/features/activities/domain/domain.dart';
import 'package:crm_app/features/activities/domain/entities/activitie_document.dart';
import 'package:crm_app/features/activities/domain/repositories/doc_activitie_repository.dart';
import 'package:crm_app/features/activities/infrastructure/mappers/activitie_create_document_response.dart';
import 'package:crm_app/features/activities/infrastructure/mappers/activitie_delete_document_mapper.dart';
import 'package:crm_app/features/activities/presentation/providers/doc_activitie_repository_provider.dart';
import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TypeFileOp { photo, archive }

final selectedAC = StateProvider<Activity?>((ref) => null);

final docActivitieProvider =
    StateNotifierProvider<DocumentsNotifier, DocumentsState>(
  (ref) {
    final docAcRepository = ref.watch(docActivitieRepositoryProvider);
    final user = ref.watch(authProvider).user;
    final activitie = ref.watch(selectedAC);
    return DocumentsNotifier(
      docOpRepository: docAcRepository,
      user: user!,
      opportunity: activitie,
    );
  },
);

class DocumentsNotifier extends StateNotifier<DocumentsState> {
  final DocActivitieRepository docOpRepository;
  final Activity? opportunity;
  User user;

  DocumentsNotifier({
    required this.docOpRepository,
    required this.user,
    this.opportunity,
  }) : super(DocumentsState()) {
    // loadNextPage();
  }

  Future loadNextPage({required TypeFileOp type}) async {
    print('Se esta ejecutando');
    if (state.isLoading || state.isLastPage) return;
    state = state.copyWith(isLoading: true, documents: []);
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

  Future<ACCreateDocumentResponse> createDocument(
      String path, String filename, TypeFileOp typeFileOp) async {
    try {
      Map<String, dynamic> documentLike = {
        'path': path,
        'filename': filename,
        'ID_USUARIO_REGISTRO': user.code,
        'ACDJ_ID_ACTIVIDAD': (opportunity?.id) ?? '',
        'ACDJ_ID_TIPO_ADJUNTO': typeFileOp == TypeFileOp.photo ? '03' : '01',
      };
      print(documentLike.toString());

      final documentResponse = await docOpRepository.createDocument(
        documentLike,
      );
      final message = documentResponse.message;

      if (documentResponse.status) {
        final document = documentResponse.document as ACDocument;
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
        return ACCreateDocumentResponse(response: true, message: message);
      }

      return ACCreateDocumentResponse(response: false, message: message);
    } catch (e) {
      print(e.toString());
      return ACCreateDocumentResponse(
        response: false,
        message: 'Error, revisar con su administrador.',
      );
    }
  }

  Future<ACDeleteDocumentResponse> deleteDocument(String idAdjunto) async {
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
        return ACDeleteDocumentResponse(response: true, message: message);
      }

      return ACDeleteDocumentResponse(response: false, message: message);
    } catch (e) {
      return ACDeleteDocumentResponse(
          response: false, message: 'Error, revisar con su administrador.');
    }
  }
}

class DocumentsState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<ACDocument> documents;
  final List<ACDocument> listDocuments;
  final List<ACDocument> listLinks;

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
    List<ACDocument>? documents,
    List<ACDocument>? listDocuments,
    List<ACDocument>? listLinks,
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
