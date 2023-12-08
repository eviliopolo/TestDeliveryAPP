// To parse this JSON data, do
//
//     final edficio = edficioFromJson(jsonString);

import 'dart:convert';

Edificio edficioFromJson(String str) => Edificio.fromJson(json.decode(str));

String edficioToJson(Edificio data) => json.encode(data.toJson());

class Edificio {
  int? id;
  String imagenPath;
  String edificio;
  String direccion;
  String telefono;
  String correo;
  String lat;
  String lng;

  Edificio({
    this.id,
    this.imagenPath = "",
    this.edificio = "",
    this.direccion = "1",
    this.telefono = "1111111111",
    this.correo = "",
    this.lat = "4.0",
    this.lng = "-72.0",
  });

  factory Edificio.fromJson(Map<String, dynamic> json) => Edificio(
        id: json["id"],
        imagenPath: json["imagenPath"],
        edificio: json["edificio"],
        direccion: json["direccion"],
        telefono: json["telefono"],
        correo: json["correo"],
        lat: json["lat"],
        lng: json["lng"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "imagenPath": imagenPath,
        "edificio": edificio,
        "direccion": direccion,
        "telefono": telefono,
        "correo": correo,
        "lat": lat,
        "lng": lng,
      };
}
