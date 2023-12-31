import 'package:flutter/foundation.dart';
import 'package:LIQYAPP/src/models/ingreso_solidario_model.dart';

class IngresoSolidarioProvider with ChangeNotifier {
  IngresoSolidarioModel _ingresoSolidarioData = new IngresoSolidarioModel();

  IngresoSolidarioModel get ingresoSolidarioData {
    return _ingresoSolidarioData;
  }

  set ingresoSolidarioData(IngresoSolidarioModel ingresoSolidarioData) {
    _ingresoSolidarioData = ingresoSolidarioData;
    notifyListeners();
  }
}
