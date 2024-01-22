import 'package:LIQYAPP/src/models/guide.dart';
import 'package:LIQYAPP/src/services/database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsultaService extends Database {
  //final _baseUrl = 'https://svc1.sipost.co/AppSingle';
  final _baseUrl = 'https://appcer.4-72.com.co/AppSingle';
  Future<Map<String, dynamic>> consultarGuia(String guia,
      String cedulaMensajero, bool isMultiple, bool isPorteria) async {
    final uri = Uri.https(url, "api/soporte/ValidarGuia");
    var resp = await http.post(uri,
        body: {
          "Guia": guia,
          "CedulaMensajero": cedulaMensajero,
          "IsMultiple": isMultiple.toString(),
          "IsPorteria": isPorteria.toString()
        },
        headers: headers);

    var decodedData = jsonDecode(resp.body);

    return decodedData;
  }

  Future<Map<String, dynamic>> obtenerDatosGuia(
      String guia, String cedulaMensajero) async {
    final uri = Uri.https(url, 'api/soporte/ValidarGuia');
    final resp = await http.post(uri,
        body: {'Guia': guia, 'CedulaMensajero': cedulaMensajero},
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }

  Future<Map<String, dynamic>> obtenerDatosGuiaTelefonica(
      String guia, String cedulaMensajero) async {
    final uri = Uri.https(url, 'api/soporte/ValidarGuiaTelefonica');
    final resp = await http.post(uri,
        body: {'Guia': guia, 'CedulaMensajero': cedulaMensajero},
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }

////////////////////////////////
  Future<Guide?> searchGuideSipost(String guide) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/Shipping?barcode=$guide'), headers: {
        'Content-Type': 'application/json',
        'Token': 'Y2FybG9zLmdhbWJvYTpTYW50aWFnbzIwMjArKys='
      });

      switch (response.statusCode) {
        case 200:
          final json = Map<String, dynamic>.from(
            jsonDecode(response.body),
          );
          Guide guide = Guide.fromJson(json['Shipping']);
          return guide;
        default:
          return null;
      }
    } catch (e) {
      rethrow;
      // if (e is SocketException){
      //   return Either.left(SignInFailure.network);
      // }
      // return Either.left(SignInFailure.unknown);
    }
  }

  ///

  Future<Map<String, dynamic>> obtenerDatosGuiaMailAmericas(
      String guia, String cedulaMensajero) async {
    final uri = Uri.https(url, 'api/soporte/ClasificacionMailAmericas');
    final resp = await http.post(uri,
        body: {'Guia': guia, 'CedulaMensajero': cedulaMensajero},
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }

  Future<Map<String, dynamic>> enviarOTP(
    String guia,
    String cedulaMensajero,
    String celularDestinatario,
  ) async {
    final uri = Uri.https(url, 'api/soporte/EnviarOtp');
    final resp = await http.post(uri,
        body: {
          'Guia': guia,
          'CedulaMensajero': cedulaMensajero,
          'CelularDestinatario':
              celularDestinatario.replaceAll(new RegExp(r"\s+\b|\b\s"), "")
        },
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }

  Future<Map<String, dynamic>> comprobarGuiaOtp(
    String guia,
    String cedulaMensajero,
    String codigo,
  ) async {
    final uri = Uri.https(url, 'api/soporte/ComprobarGuiaOtp');
    final resp = await http.post(uri,
        body: {
          'Guia': guia,
          'CedulaMensajero': cedulaMensajero,
          'Codigo': codigo
        },
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }

  /*
  Future<Map<String, dynamic>> validarVersion(
    String cedulaMensajero,
    String version,
  ) async {
    final uri = Uri.https(url, 'api/soporte/VerificarVersionAndroid');
    final resp = await http.post(uri,
        body: {
          'CedulaMensajero': cedulaMensajero,
          'VersionAndroid': version.toString()
        },
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }
  */

  Future<Map<String, dynamic>> obtenerGuiasCertificadas(
    String cedulaMensajero,
  ) async {
    final uri =
        Uri.https(url, 'api/soporte/ObtenerGuiasCertificadasPorMensajero');
    final resp = await http.post(uri,
        body: {
          'CedulaMensajero': cedulaMensajero,
        },
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }

  Future<Map<String, dynamic>> enviarLinkFirma(
    String guia,
    String cedulaMensajero,
    String celularDestinatario,
  ) async {
    final uri = Uri.https(url, 'api/soporte/EnviarLinkFirma');
    final resp = await http.post(uri,
        body: {
          'Guia': guia,
          'CedulaMensajero': cedulaMensajero,
          'CelularDestinatario': celularDestinatario,
        },
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }

  Future<Map<String, dynamic>> comprobarGuiaFirma(
    String guia,
    String cedulaMensajero,
    String codigo,
  ) async {
    final uri = Uri.https(url, 'api/soporte/ComprobarEsGuiaFirmada');
    final resp = await http.post(uri,
        body: {
          'Guia': guia,
          'CedulaMensajero': cedulaMensajero,
          'Codigo': codigo,
        },
        headers: headers);
    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }
}
