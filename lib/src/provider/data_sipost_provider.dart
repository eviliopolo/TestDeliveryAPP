//import 'package:flutter/foundation.dart';
import 'package:prueba_de_entrega/src/models/data_sipost_model.dart';
import 'package:prueba_de_entrega/src/models/sipost_response.dart';
import 'package:flutter/material.dart';
export 'package:prueba_de_entrega/src/models/data_sipost_model.dart';

class DataSipostProvider with ChangeNotifier {
  SipostResponse _sipostResponse = SipostResponse();
  DataSipost _dataSipost = DataSipost();
  String _guiaBarcode = "";
  int _codigo = 0;

  // CODIGO DE COMPROBACIÓN DE FIRMA

  int get codigo => _codigo;

  set codigo(int codigo) {
    _codigo = codigo;
    notifyListeners();
  }

  // CODIGO DE BARRA DE LA GUIA

  String get barcode => _guiaBarcode;

  set barcode(String data) {
    _guiaBarcode = data;
    notifyListeners();
  }

  // RESPUESTA DE SIPOST VERSION 3

  SipostResponse get sipostResponse {
    return _sipostResponse;
  }

  set sipostResponse(SipostResponse sipostResponse) {
    _sipostResponse = sipostResponse;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // RESPUESTA DE SIPOST VERSION 2
  DataSipost get dataSipost {
    return _dataSipost;
  }

  set dataSipost(DataSipost dataSipost) {
    _dataSipost = dataSipost;
    notifyListeners();
  }
}
