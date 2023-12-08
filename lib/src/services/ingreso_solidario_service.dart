import 'package:prueba_de_entrega/src/services/database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngresoSolidarioService extends Database {
  Future<Map<String, dynamic>> obtenerDatosGuiaIS(
    String guia,
    String cedulaMensajero,
  ) async {
    final uri = Uri.https(url, 'api/soporte/ValidarGuiaIngresoSolidiario');
    final resp = await http.post(uri,
        body: {'Guia': guia, 'CedulaMensajero': cedulaMensajero},
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }

  Future<Map<String, dynamic>> emailIngresoSolidario(
    String guia,
    String cedulaMensajero,
    String cedulaDestinatario,
    String email,
    bool iscarta,
  ) async {
    final uri = Uri.https(url, 'api/soporte/EmailIngresoSolidario');
    final resp = await http.post(uri,
        body: {
          'Guia': guia,
          'CedulaMensajero': cedulaMensajero,
          'CedulaDestinatario': cedulaDestinatario,
          'Email': email,
          'Iscarta': iscarta.toString(),
        },
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }
}
