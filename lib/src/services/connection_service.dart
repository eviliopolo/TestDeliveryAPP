import 'dart:io';

////import 'package:data_connection_checker/data_connection_checker.dart';
//export 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionService {
  Stream<InternetConnectionStatus> get connection {
    return InternetConnectionChecker().onStatusChange;
  }

  Future<bool> checkConnectivity() async {
    bool connect = true;
    try {
      final result = await InternetAddress.lookup(
          'https://appsinglessdev.azurewebsites.net');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connect = true;
      }
    } on SocketException catch (_) {
      connect = false;
    }
    return connect;
  }
}
