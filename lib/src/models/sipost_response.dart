class SipostResponse {
  SipostResponse({
    this.id,
    this.code,
    this.names,
    this.phone,
    this.address,
    this.identification,
    this.cityId,
    this.cityName,
    this.departamentId,
    this.departamentName,
    this.countryId,
    this.countryName,
    this.operativeCode,
    this.response,
    this.message,
    this.isCertificado,
    this.codigoSeguridad,
    this.isOtp,
    this.isFirma,
    this.isEntregaTercero,
    this.isPorteria,
    this.isOtpComprobado,
    this.isFirmaComprobada,
    this.isFotoObligatoria,
  });

  String? id;
  String? code;
  String? names;
  String? phone;
  String? address;
  String? identification;
  String? cityId;
  String? cityName;
  String? departamentId;
  String? departamentName;
  String? countryId;
  String? countryName;
  String? operativeCode;
  bool? response;
  String? message;
  bool? isCertificado;
  int? codigoSeguridad;
  bool? isOtp;
  bool? isFirma;
  bool? isEntregaTercero;
  bool? isPorteria;
  bool? isOtpComprobado;
  bool? isFirmaComprobada;
  bool? isFotoObligatoria;

  factory SipostResponse.fromJson(Map<String, dynamic> json) => SipostResponse(
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
        operativeCode: json["OperativeCode"],
        response: json["Response"],
        message: json["Message"],
        isCertificado: json["IsCertificado"],
        codigoSeguridad: json["CodigoSeguridad"],
        isOtp: json["IsOtp"],
        isFirma: json["IsFirma"],
        isEntregaTercero: json["IsEntregaTercero"],
        isPorteria: json["IsPorteria"],
        isOtpComprobado: json["IsOtpComprobado"],
        isFirmaComprobada: json["IsFirmaComprobada"],
        isFotoObligatoria: json["IsFotoObligatoria"],
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
        "Response": response,
        "Message": message,
        "IsCertificado": isCertificado,
        "CodigoSeguridad": codigoSeguridad,
        "IsOtp": isOtp,
        "IsFirma": isFirma,
        "IsEntregaTercero": isEntregaTercero,
        "IsPorteria": isPorteria,
        "IsOtpComprobado": isOtpComprobado,
        "IsFirmaComprobada": isFirmaComprobada,
        "IsFotoObligatoria": isFotoObligatoria,
      };
}
