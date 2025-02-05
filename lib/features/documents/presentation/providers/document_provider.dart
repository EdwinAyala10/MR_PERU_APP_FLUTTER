import 'package:crm_app/features/documents/domain/domain.dart';
import 'package:crm_app/features/documents/presentation/providers/documents_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final documentProvider = StateNotifierProvider.autoDispose.family<DocumentNotifier, DocumentState, String>(
  (ref, documentId ) {
    
    final documentsRepository = ref.watch(documentsRepositoryProvider );
  
    return DocumentNotifier(
      documentsRepository: documentsRepository, 
      documentId: documentId
    );
});



class DocumentNotifier extends StateNotifier<DocumentState> {

  final DocumentsRepository documentsRepository;


  DocumentNotifier({
    required this.documentsRepository,
    required String documentId,
  }): super(DocumentState(id: documentId )) {
    loadDocument();
  }

  Document newEmptyDocument() {
    return Document(
      adjtIdAdjunto: 'new',
      adjtEstado: '0',
      adjtNombreArchivo: '',
      adjtNombreOriginal: '',
      adjtRutalRelativa: '',
      adjtTipoArchivo: '',
      adjtTipoRegistro: '',
      document: '',
      documents: [], 
      adjtIdTipoRegistro: '',
    );
  }


  Future<void> loadDocument() async {

    try {

      if ( state.id == 'new' ) {
        state = state.copyWith(
          isLoading: false,
          document: newEmptyDocument(),
        );  
        return;
      }

      final document = await documentsRepository.getDocumentById(state.id);

      state = state.copyWith(
        isLoading: false,
        document: document
      );

    } catch (e) {
      // 404 product not found
      print(e);
    }

  }

}


class DocumentState {

  final String id;
  final Document? document;
  final bool isLoading;
  final bool isSaving;

  DocumentState({
    required this.id, 
    this.document, 
    this.isLoading = true, 
    this.isSaving = false,
  });

  DocumentState copyWith({
    String? id,
    Document? document,
    bool? isLoading,
    bool? isSaving,
  }) => DocumentState(
    id: id ?? this.id,
    document: document ?? this.document,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
  );
  
}

