import 'package:crm_app/features/documents/domain/domain.dart';
import 'package:crm_app/features/documents/infrastructure/mapers/create_document_response.dart';
import 'package:crm_app/features/documents/presentation/providers/documents_repository_provider.dart';

import '../../../auth/domain/domain.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sendEnlaceProvider =
    StateNotifierProvider<SendEnlaceNotifier, SendEnlaceState>((ref) {
  //final authRepository = AuthRepositoryImpl();
  final documentsRepository = ref.watch(documentsRepositoryProvider);
  final user = ref.watch(authProvider).user;

  return SendEnlaceNotifier(
    documentsRepository: documentsRepository,
    user: user!,
  );
});

class SendEnlaceNotifier extends StateNotifier<SendEnlaceState> {
  final DocumentsRepository documentsRepository;
  final User user;

  SendEnlaceNotifier({
    //required this.authRepository,
    required this.documentsRepository,
    required this.user,
  }) : super(SendEnlaceState());

  Future<CreateDocumentResponse> sendEnlace() async {
    try {

      final enlaceLike = {
        'ID_USUARIO_REGISTRO': user.code,
        'ADJT_ENLACE': state.message,
      };

      final enlaceResponse =
          await documentsRepository.createEnlace(enlaceLike);

      final message = enlaceResponse.message;

      if (enlaceResponse.status) {
        
        state = state.copyWith(isSend: true, isViewText: false, message: '');
        return CreateDocumentResponse(response: true, message: message);
      }
        return CreateDocumentResponse(response: false, message: message);
    } catch (e) {
      return CreateDocumentResponse(response: false, message: 'Error, revisar con su administrador.');
    }
  }


  void onChangeMessage(String value) {
    state = state.copyWith(
      message: value,
    );
  }
}

class SendEnlaceState {
  final bool isSend;
  final bool isViewText;
  final String? idUsuarioRegistro;
  final String? message;

  SendEnlaceState(
      {this.isSend = false,
      this.isViewText = false,
      this.idUsuarioRegistro = '',
      this.message = ''});

  SendEnlaceState copyWith({
    bool? isSend,
    bool? isViewText,
    String? idUsuarioRegistro,
    String? message,
  }) =>
      SendEnlaceState(
        isSend: isSend ?? this.isSend,
        isViewText: isViewText ?? this.isViewText,
        idUsuarioRegistro: idUsuarioRegistro ?? this.idUsuarioRegistro,
        message: message ?? this.message,
      );
}
