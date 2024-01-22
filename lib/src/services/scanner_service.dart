import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class ScanService with ChangeNotifier {
  String _scanResult = "";
  String? _exception;
  Timer? _timer;
  int? value;

  static final StreamController _timeController =
      StreamController<int>.broadcast();

  Stream<dynamic> get timer => _timeController.stream;

  get exception => _exception;
  get scanResult => _scanResult;

  Future<void> scanBarcode() async {
    try {
      ScanResult barcode = await BarcodeScanner.scan();
      _scanResult = barcode.rawContent;
      notifyListeners();
    } on PlatformException catch (error) {
      if (error.code == BarcodeScanner.cameraAccessDenied) {
        _scanResult = 'El usuario no concedió permiso para usar la cámara!';
      } else {
        _exception = 'Error desconocido: $error';
      }
    } on FormatException {
      //print('No se pudo obtener el código de barras)');
    } catch (e) {
      //print('Error desconocido: $e');
    }
  }

  startTimer() {
    int countDown = 600;
    const int seg = 600;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      countDown = seg - timer.tick;
      if (countDown < 1) {
        cancel();
      } else {
        _timeController.sink.add(countDown);
      }
    });
  }

  close() {
    _timeController.close();
  }

  cancel() {
    _timer?.cancel();
  }
}
