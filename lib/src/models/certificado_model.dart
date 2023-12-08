// To parse this JSON data, do
//
//     final guia = guiaFromJson(jsonString);

import 'dart:convert';

Certificado guiaFromJson(String str) => Certificado.fromJson(json.decode(str));

String guiaToJson(Certificado data) => json.encode(data.toJson());

/*
 * Modelo de los datos para 
 * guardar en sqlite
 */
class Certificado {
  int? id;
  int? idEdificio;
  int? hasFoto;
  int? cargada;
  String? imagenPath;
  String? fecha;
  String? guia;
  String? nombres;
  String? cedula;
  String? telefono;
  String? latitud;
  String? longitud;
  String? urlImagen;
  int? isPorteria;
  String? observaciones;
  int? isMultiple;
  String? cedulaMensajero;

  Certificado({
    this.id,
    this.idEdificio,
    this.hasFoto,
    this.imagenPath,
    this.fecha,
    this.cargada,
    this.guia,
    this.nombres,
    this.cedula,
    this.telefono,
    this.latitud,
    this.longitud,
    this.urlImagen,
    this.isPorteria,
    this.observaciones,
    this.cedulaMensajero,
    this.isMultiple,
  });

  factory Certificado.fromJson(Map<String, dynamic> json) => Certificado(
        id: json["id"],
        idEdificio: json["id_edificio"],
        hasFoto: json["hasFoto"],
        imagenPath: json["imagenPath"],
        fecha: json["fecha"],
        cargada: json["cargada"],
        guia: json["guia"],
        nombres: json["nombres"],
        cedula: json["cedula"],
        telefono: json["telefono"],
        latitud: json["latitud"],
        longitud: json["longitud"],
        urlImagen: json["urlImagen"],
        isPorteria: json["isPorteria"],
        observaciones: json["observaciones"],
        cedulaMensajero: json["cedulaMensajero"],
        isMultiple: json["isMultiple"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_edificio": idEdificio,
        "hasFoto": hasFoto,
        "imagenPath": imagenPath,
        "fecha": fecha,
        "cargada": cargada,
        "guia": guia,
        "nombres": nombres,
        "cedula": cedula,
        "telefono": telefono,
        "latitud": latitud,
        "longitud": longitud,
        "urlImagen": urlImagen,
        "isPorteria": isPorteria,
        "observaciones": observaciones,
        "cedulaMensajero": cedulaMensajero,
        "isMultiple": isMultiple,
      };
}
