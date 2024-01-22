//import 'dart:html' as html;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;

class DigitalImageSipost {
  Future<dynamic> liquidation(
    String barcode,
    String receiverName,
    String observation,
    DateTime date,
    String username,
    String machine,
    String ip,
    String mac,
  ) async {
    //String url = "https://svc1.sipost.co/AppSingle/api/Liquidation";
    String url = "https://appcer.4-72.com.co/AppSingle/api/Liquidation";

    late String token = "Y2FybG9zLmdhbWJvYTpTYW50aWFnbzIwMjArKys=";
    late Map<String, String> headers;

    headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Token': token
    };

    final uri = Uri.parse(url);
    final resp = await http.post(uri,
        body: {
          'Barcode': barcode,
          'ReceiverName': receiverName,
          'Observation': observation,
          'Date': date.toString(),
          'Username': username,
          'Machine': machine,
          'IP': ip,
          'MAC': mac,
        },
        headers: headers);
    final decodedData = json.decode(resp.body);
    return decodedData;
  }

  Future<dynamic> file_sipost(
      String barcode, String? file, double lat, double lon) async {
    //String url = "https://svc1.sipost.co/AppSingle/api/ImageToPdf";
    String url = "https://appcer.4-72.com.co/AppSingle/api/ImageToPdf";

    late String token = "Y2FybG9zLmdhbWJvYTpTYW50aWFnbzIwMjArKys=";
    late Map<String, String> headers;

    headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Token': token
    };

    final bytes = File(file!).readAsBytesSync();

// Comprimir la imagen antes de convertirla a base64
    final compressedBytes =
        image.encodeJpg(image.decodeImage(bytes)!, quality: 85);

    Future<String> obtenerBase64Image() async {
      final String base64Image = base64Encode(compressedBytes);
      return base64Image;
    }

    final String base64Image = await obtenerBase64Image();
    final uri = Uri.parse(url);
    final resp = await http.post(uri,
        body: {
          'Barcode': barcode,
          'File': base64Image,
          'Longitude': lon.toString(),
          'Latitude': lat.toString(),
        },
        headers: headers);
    final decodedData = json.decode(resp.body);
    return decodedData;
  }
}
