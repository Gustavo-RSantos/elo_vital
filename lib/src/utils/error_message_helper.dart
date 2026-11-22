import 'dart:async';
import 'dart:io';

import 'package:elo_vital/src/services/auth_exception.dart';
import 'package:flutter/foundation.dart';

/// Transforma erros técnicos em mensagens claras e respeitosas.
class ErrorMessageHelper {
  ErrorMessageHelper._();

  static String fromException(Object error) {
    if (error is AuthException) return error.message;
    if (error is TimeoutException) {
      return 'O servidor demorou para responder. Tente novamente.';
    }
    if (error is SocketException) {
      return 'Sem conexão com a internet. Verifique a sua rede e tente de novo.';
    }
    if (error is HttpException) {
      return 'Não foi possível falar com o servidor. Tente de novo mais tarde.';
    }

    debugPrint('Erro inesperado: $error');
    return 'Algo deu errado. Tente novamente.';
  }
}
