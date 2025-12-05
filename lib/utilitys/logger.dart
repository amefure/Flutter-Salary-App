import 'package:flutter/foundation.dart';

void logger(Object? message) {
  if (kDebugMode) {
    print(message);
  }
}
