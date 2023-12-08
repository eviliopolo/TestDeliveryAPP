// To parse this JSON data, do
//
//     final guia = guiaFromJson(jsonString);

import 'dart:convert';

DataSipost guiaFromJson(String str) => DataSipost.fromJson(json.decode(str));

String guiaToJson(DataSipost data) => json.encode(data.toJson());

/*
 * Modelo de los datos de 
 * sipost al consultar la guía
 * despues de escanear el codigo de barras
 */

class DataSipost {
    String barcode;
    String id;
    String code;
    String names;
    String phone;
    String address;
    String identification;
    String cityId;
    String cityName;
    String departamentId;
    String departamentName;
    String countryId;
    String countryName;
    String operativeCode;
    int codigoSeguridad;
    String response;
    String message;
    bool isCertificado;
    bool isTelefonica;

    DataSipost({
        this.barcode = "",
        this.id = "",
        this.code = "",
        this.names = "SERVICIOS POSTALES NACIONALES",
        this.phone = "123456",
        this.address = "",
        this.identification = "9504033920",
        this.cityId = "",
        this.cityName = "",
        this.departamentId = "",
        this.departamentName = "",
        this.countryId = "",
        this.countryName = "",
        this.operativeCode = "",
        this.codigoSeguridad = 000000,
        this.response = "",
        this.message = "",
        this.isCertificado = false,
        this.isTelefonica = false,
    });

    factory DataSipost.fromJson(Map<String, dynamic> json) => DataSipost(
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
        codigoSeguridad: json["CodigoSeguridad"],
        operativeCode: json["OperativeCode"],
        response: json["Response"],
        message: json["Message"],
        isCertificado: json["IsCertificado"],
        isTelefonica: json["IsTelefonica"],
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
        "OperativeCode": operativeCode,
        "CodigoSeguridad": codigoSeguridad,
        "Response": response,
        "Message": message,
        "IsCertificado": isCertificado,
        "IsTelefonica": isTelefonica,
    };
}
