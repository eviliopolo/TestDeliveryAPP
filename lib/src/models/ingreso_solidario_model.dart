// To parse this JSON data, do
//
//     final ingresoSolidarioModel = ingresoSolidarioModelFromJson(jsonString);

import 'dart:convert';

IngresoSolidarioModel ingresoSolidarioModelFromJson(String str) =>
    IngresoSolidarioModel.fromJson(json.decode(str));

String ingresoSolidarioModelToJson(IngresoSolidarioModel data) =>
    json.encode(data.toJson());

class IngresoSolidarioModel {
  String barcode;
  String id;
  String code;
  String names;
  String phone;
  String email;
  String address;
  String identification;
  String cityId;
  String cityName;
  String departamentId;
  String departamentName;
  String countryId;
  String countryName;
  String response;
  String message;
  bool isCertificado;
  int codigoSeguridad;
  bool isColombian;

  IngresoSolidarioModel({
    this.barcode = "",
    this.id = "",
    this.code = "",
    this.names = "",
    this.phone = "",
    this.email = "",
    this.address = "",
    this.identification = "",
    this.cityId = "",
    this.cityName = "",
    this.departamentId = "",
    this.departamentName = "",
    this.countryId = "",
    this.countryName = "",
    this.response = "",
    this.message = "",
    this.isCertificado = false,
    this.codigoSeguridad = 000000,
    this.isColombian = false,
  });

  factory IngresoSolidarioModel.fromJson(Map<String, dynamic> json) =>
      IngresoSolidarioModel(
        id: json["\u0024id"],
        code: json["Code"],
        names: json["Names"],
        phone: json["Phone"],
        address: json["Address"],
        identification: json["Identification"],
        cityId: json["CityId"],
        cityName: json["CityName"],
        departamentId: json["DepartamentId"],
        departamentName: json["DepartamentName"],
        countryId: json["CountryId"],
        countryName: json["CountryName"],
        response: json["Response"],
        message: json["Message"],
        isCertificado: json["IsCertificado"],
        codigoSeguridad: json["CodigoSeguridad"],
        isColombian: json["IsColombian"],
      );

  Map<String, dynamic> toJson() => {
        "\u0024id": id,
        "Code": code,
        "Names": names,
        "Phone": phone,
        "Address": address,
        "Identification": identification,
        "CityId": cityId,
        "CityName": cityName,
        "DepartamentId": departamentId,
        "DepartamentName": departamentName,
        "CountryId": countryId,
        "CountryName": countryName,
        "Response": response,
        "Message": message,
        "IsCertificado": isCertificado,
        "CodigoSeguridad": codigoSeguridad,
        "IsColombian": isColombian,
      };
}
