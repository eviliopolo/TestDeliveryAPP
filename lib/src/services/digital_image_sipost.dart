//import 'dart:html' as html;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    String barcode, File? file, double lat, double lon) async {
    String url = "https://appcer.4-72.com.co/AppSingle/api/ImageToPdf";

    late String token = "Y2FybG9zLmdhbWJvYTpTYW50aWFnbzIwMjArKys=";
    late Map<String, String> headers;

    headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Token': token
    };

    List<int> imageBytes = await file!.readAsBytes();
    String base64Image = base64Encode(imageBytes);

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
