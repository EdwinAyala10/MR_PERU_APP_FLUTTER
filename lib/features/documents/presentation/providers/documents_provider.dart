import 'package:crm_app/features/auth/domain/domain.dart';
import 'package:crm_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crm_app/features/documents/domain/domain.dart';
import 'package:crm_app/features/documents/infrastructure/infrastructure.dart';
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
       
        state = state.copyWith(
          documents: [document, ...state.documents],
          listDocuments: document.adjtIdTipoRegistro == '01' ? [ document, ...state.listDocuments ] : state.listDocuments,
          listLinks: document.adjtIdTipoRegistro == '02' ? [ document, ...state.listLinks ] : state.listLinks,
        );
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
      //offset: state.offset + 10,
      //documents: [...state.documents, ...documents ]
      documents: documents,
      listDocuments: documents.where((doc) => doc.adjtIdTipoRegistro == '01').toList(),
      listLinks: documents.where((doc) => doc.adjtIdTipoRegistro == '02').toList()
    );

  }

  Future<DeleteDocumentResponse> deleteDocument( String idAdjunto ) async {
    try {

      final documentResponse = await documentsRepository.deleteDocumentLink(idAdjunto);
      
      final message = documentResponse.message;

      if (documentResponse.status) {

        final documents = state.documents.where((doc) => doc.adjtIdAdjunto != idAdjunto).toList();
      
        state = state.copyWith(
          documents: documents,
          listDocuments: documents.where((doc) => doc.adjtIdTipoRegistro == '01').toList(),
          listLinks: documents.where((doc) => doc.adjtIdTipoRegistro == '02').toList()
        );

        return DeleteDocumentResponse(response: true, message: message);
      }

      return DeleteDocumentResponse(response: false, message: message);

    } catch (e) {
      return DeleteDocumentResponse(response: false, message: 'Error, revisar con su administrador.');
    }

  }

}





class DocumentsState {

  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Document> documents;
  final List<Document> listDocuments;
  final List<Document> listLinks;

  DocumentsState({
    this.isLastPage = false, 
    this.limit = 10, 
    this.offset = 0, 
    this.isLoading = false, 
    this.documents = const[],
    this.listDocuments = const[],
    this.listLinks = const[],
  });

  DocumentsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Document>? documents,
    List<Document>? listDocuments,
    List<Document>? listLinks,
  }) => DocumentsState(
    isLastPage: isLastPage ?? this.isLastPage,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    isLoading: isLoading ?? this.isLoading,
    documents: documents ?? this.documents,
    listDocuments: listDocuments ?? this.listDocuments,
    listLinks: listLinks ?? this.listLinks,
  );

}
