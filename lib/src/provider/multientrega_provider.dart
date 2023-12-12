import 'package:flutter/foundation.dart';
import 'package:LIQYAPP/src/models/certificado_model.dart';
import 'package:LIQYAPP/src/models/edificio_model.dart';

class MultiEntregaProvider with ChangeNotifier {
  Edificio _edificio = Edificio();
  Certificado _certificado = Certificado();
  List<Certificado> _listNoCertificado = [];

  Edificio get edificioData => _edificio;

  set edificioData(Edificio edif) {
    _edificio = edif;
    notifyListeners();
  }

  Certificado get certificadoData => _certificado;

  set certificadoData(Certificado cert) {
    _certificado = cert;
    notifyListeners();
  }

  List<Certificado> get listaNoCertificado {
    return _listNoCertificado;
  }

  set listaNoCertificado(List<Certificado> lista) {
    _listNoCertificado = lista;
    notifyListeners();
  }
}
