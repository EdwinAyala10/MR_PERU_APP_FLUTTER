import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/documents/domain/domain.dart';
import 'package:crm_app/features/documents/infrastructure/mapers/create_document_response.dart';
import 'package:crm_app/features/documents/presentation/providers/documents_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final documentsProvider = StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {

  final documentsRepository = ref.watch( documentsRepositoryProvider );
  final user = ref.watch(authProvider).user;

  return DocumentsNotifier(
    documentsRepository: documentsRepository,
    user: user!,
  );
  
});



class DocumentsNotifier extends StateNotifier<DocumentsState> {
  
  final DocumentsRepository documentsRepository;
  User user;

  DocumentsNotifier({
    required this.documentsRepository,
    required this.user,
  }): super( DocumentsState() ) {
    loadNextPage();
  }

  Future<CreateDocumentResponse> createDocument( String path, String filename,  ) async {
    try {

      Map<String,dynamic> documentLike = {
        'path': path,
        'filename': filename,
        'id_usuario_registro': user.code
      };

      final documentResponse = await documentsRepository.createDocument(documentLike);
      
      final message = documentResponse.message;

      if (documentResponse.status) {
        final document = documentResponse.document as Document;
        final isDocumentInList =
            state.documents.any((element) => element.adjtIdAdjunto == document.adjtIdAdjunto);

        if (!isDocumentInList) {
          state = state.copyWith(documents: [document, ...state.documents]);
          return CreateDocumentResponse(response: true, message: message);
        }

        state = state.copyWith(
            documents: state.documents
                .map(
                  (element) => (element.adjtIdAdjunto == document.adjtIdAdjunto) ? document : element,
                )
                .toList());

        return CreateDocumentResponse(response: true, message: message);
      }

      return CreateDocumentResponse(response: false, message: message);

    } catch (e) {
      return CreateDocumentResponse(response: false, message: 'Error, revisar con su administrador.');
    }

  }

  Future loadNextPage() async {

    if ( state.isLoading || state.isLastPage ) return;

    state = state.copyWith( isLoading: true );

    final documents = await documentsRepository.getDocuments();

    if ( documents.isEmpty ) {
      state = state.copyWith(
        isLoading: false,
        isLastPage: true
      );
      return;
    }

    state = state.copyWith(
      isLastPage: false,
      isLoading: false,
      offset: state.offset + 10,
      documents: [...state.documents, ...documents ]
    );


  }

}





class DocumentsState {

  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Document> documents;

  DocumentsState({
    this.isLastPage = false, 
    this.limit = 10, 
    this.offset = 0, 
    this.isLoading = false, 
    this.documents = const[]
  });

  DocumentsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Document>? documents,
  }) => DocumentsState(
    isLastPage: isLastPage ?? this.isLastPage,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    isLoading: isLoading ?? this.isLoading,
    documents: documents ?? this.documents,
  );

}
