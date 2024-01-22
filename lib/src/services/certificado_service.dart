import 'dart:io';
import 'dart:convert';
import 'package:LIQYAPP/src/services/database.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class CertificadoService extends Database {
  Future<dynamic> generarCertificado(
    String guia,
    String nombre,
    String cedula,
    String telefono,
    String latitud,
    String longitud,
    String urlImagen,
    bool isPorteria,
    String observaciones,
    String cedulaMensajero,
    bool isMultiple,
  ) async {
    final uri = Uri.https(url, 'api/soporte/SoporteEntregaSinFoto');
    final resp = await http.post(uri,
        body: {
          'Guia': guia.toUpperCase(),
          'Nombres': nombre,
          'Cedula': cedula.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
          'Telefono': telefono.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
          'Latitud': latitud,
          'Longitud': longitud,
          'UrlImagen': urlImagen,
          'IsPorteria': isPorteria.toString(),
          'Observaciones': observaciones,
          'CedulaMensajero': cedulaMensajero,
          'IsMultiple': isMultiple.toString(),
        },
        headers: headers);

    final decodedData = json.decode(resp.body);
    return decodedData;
  }

  Future<Map<String, dynamic>> generarCertificadoConImagen(
    File? foto,
    String guia,
    String nombre,
    String cedula,
    String telefono,
    String latitud,
    String longitud,
    String urlImagen,
    bool isPorteria,
    String observaciones,
    String cedulaMensajero,
    bool isMultiple,
  ) async {
    final uri = Uri.https(url, 'api/soporte/SoporteEntregaConFotov2');
    var soporte = await foto!.readAsBytes();
    img.Image imgTemp = img.decodeImage(soporte)!;
    img.Image resizedImg = img.copyResize(imgTemp, width: 300);
    final resp = await http.post(uri,
        body: {
          'Guia': guia.toUpperCase(),
          'Nombres': nombre,
          'Telefono': telefono.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
          'Latitud': latitud,
          'Longitud': longitud,
          'Cedula': cedula.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
          'IsPorteria': isPorteria.toString(),
          'IsMultiple': isMultiple.toString(),
          'SMS': "",
          'Observaciones': observaciones,
          'CedulaMensajero': cedulaMensajero,
          'UrlImagen': urlImagen,
          'ImagenSoporte':
              base64.encode(img.encodeJpg(resizedImg, quality: 100)),
        },
        headers: headers);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    return decodedData;
  }
}
