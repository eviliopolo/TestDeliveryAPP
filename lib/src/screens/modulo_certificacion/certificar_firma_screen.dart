import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/loading_overlay.dart';
import 'package:LIQYAPP/src/components/modals.dart';
import 'package:LIQYAPP/src/models/sipost_response.dart';
import 'package:LIQYAPP/src/provider/data_sipost_provider.dart';
import 'package:LIQYAPP/src/services/certificado_service.dart';
//import 'package:LIQYAPP/src/services/connection_service.dart';
import 'package:LIQYAPP/src/services/consulta_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/services/scanner_service.dart';
import 'package:LIQYAPP/src/services/sqlite_db.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class CertificarFirmaScreen extends StatefulWidget {
  @override
  _CertificarFirmaScreenState createState() => _CertificarFirmaScreenState();
}

class _CertificarFirmaScreenState extends State<CertificarFirmaScreen> {
  File? _foto;
  final _scanService = ScanService();
  final _consultaService = ConsultaService();
  final _prefs = PreferenciasUsuario();
  final _certificadoService = CertificadoService();
  bool _internetConnection = true;
  bool _certificando = false;

  double _lat = 4;
  double _lng = -72;

  TextEditingController _observacionesController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    //_getCurrentPosition();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _scanService.cancel();
    if (!Provider.of<DataSipostProvider>(context, listen: false)
        .sipostResponse
        .isFirmaComprobada!) {
      _scanService.startTimer();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scanService.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DataSipostProvider sipostProvider =
        Provider.of<DataSipostProvider>(context, listen: false);
    final _connection =
        Provider.of<InternetConnectionStatus>(context, listen: false);

    if (_connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (_connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(6, 69, 147, 1),
        foregroundColor: Colors.white,
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "menu");
          },
        ),
        title: Wrap(
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              'Servicios Postales Nacionales',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '#OperadorPostalOficial',
              style: TextStyle(fontSize: 12.0, fontFamily: 'Light'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: background,
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Card(
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                child: Column(
                                  children: <Widget>[
                                    BarcodeWidget(
                                      data: sipostProvider.barcode,
                                      barcode: Barcode.code128(),
                                      height: 80.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      drawText: true,
                                      style: const TextStyle(
                                          fontFamily: "",
                                          height: 2.0,
                                          letterSpacing: 2.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12.0),
                                    const Divider(),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          height: 80.0,
                                          decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(12.0)),
                                          child: AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: _foto != null
                                                  ? _mostrarFoto()
                                                  : Icon(Icons.camera_alt)),
                                        ),
                                        SizedBox(width: 8.0),
                                        Expanded(
                                          child: MaterialButton(
                                            elevation: 0.0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            color: Color.fromRGBO(
                                                244, 244, 244, 1.0),
                                            child: Text("Toma una foto"),
                                            onPressed: () {
                                              //_tomarFoto();
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 12.0),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: double.infinity,
                                            child: const Text(
                                              'DATOS DE LA PERSONA QUE RECIBE',
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontFamily: "Custom"),
                                            ),
                                          ),
                                          SizedBox(height: 6.0),
                                          TextFormField(
                                            readOnly: !sipostProvider
                                                .sipostResponse
                                                .isEntregaTercero!,
                                            style: TextStyle(fontSize: 12.0),
                                            decoration: InputDecoration(
                                              labelText:
                                                  "Nombre completo de quíen recibe",
                                              isDense: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                            initialValue: sipostProvider
                                                .sipostResponse.names,
                                            onSaved: (value) => sipostProvider
                                                .sipostResponse.names = value,
                                            validator: (valor) {
                                              if (valor!.isEmpty) {
                                                return "Ingrese el nombre completo de quíen recibe.";
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 6.0),
                                          Visibility(
                                            visible: !sipostProvider
                                                .sipostResponse.isPorteria!,
                                            child: TextFormField(
                                              style: TextStyle(fontSize: 12.0),
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText:
                                                    "Número cedula de quien recibe",
                                                isDense: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                              ),
                                              initialValue: sipostProvider
                                                          .sipostResponse
                                                          .identification ==
                                                      null
                                                  ? ""
                                                  : sipostProvider
                                                      .sipostResponse
                                                      .identification
                                                      .toString(),
                                              onSaved: (value) => sipostProvider
                                                  .sipostResponse
                                                  .identification = value,
                                              validator: (valor) {
                                                if (valor!.isEmpty) {
                                                  return "Ingrese la cédula de quíen recibe.";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 6.0),
                                          Visibility(
                                            visible: !sipostProvider
                                                .sipostResponse.isPorteria!,
                                            child: TextFormField(
                                                readOnly: !sipostProvider
                                                    .sipostResponse
                                                    .isEntregaTercero!,
                                                style:
                                                    TextStyle(fontSize: 12.0),
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    labelText:
                                                        "Número celular de quíen recibe",
                                                    isDense: true,
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                12.0))),
                                                initialValue: sipostProvider
                                                    .sipostResponse.phone
                                                    .toString(),
                                                onSaved: (value) =>
                                                    sipostProvider
                                                        .sipostResponse
                                                        .phone = value,
                                                validator: (valor) {
                                                  if (valor!.isEmpty ||
                                                      valor.length != 10) {
                                                    return "Ingrese un número celular válido.";
                                                  }
                                                  return null;
                                                }),
                                          ),
                                          SizedBox(height: 6.0),
                                          TextFormField(
                                            maxLines: 3,
                                            controller:
                                                _observacionesController,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelText: "Observaciones",
                                              alignLabelWithHint: true,
                                              hintText: "Escriba aquí",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: TextButton.icon(
                                              icon: Icon(
                                                Icons.cloud_upload,
                                                size: 20.0,
                                              ),
                                              /*
                                              color: yellow,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),*/
                                              label: Text(
                                                "Certificar entrega",
                                              ),
                                              onPressed: () {
                                                certificar(sipostProvider);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )),
          ),
          Visibility(
            visible: !sipostProvider.sipostResponse.isFirmaComprobada!,
            child: StreamBuilder<dynamic>(
              stream: _scanService.timer,
              builder: (context, snapshot) {
                print("=======");
                print(sipostProvider.sipostResponse.isFirmaComprobada);
                print(sipostProvider.sipostResponse.isPorteria);
                print(sipostProvider.sipostResponse.isOtp);
                print(sipostProvider.sipostResponse.isFirma);
                print("=======");
                if (snapshot.hasData) {
                  if (sipostProvider.sipostResponse.isPorteria!) {
                    _scanService.cancel();
                    sipostProvider.sipostResponse.identification = "1";
                    sipostProvider.sipostResponse.phone = "1111111111";
                    sipostProvider.sipostResponse.isFirmaComprobada = true;
                    return SizedBox.shrink();
                  } else {
                    // CONSULTA CADA 10 SEGUNDOS SI LA GUÍA YA ESTÁ FIRMADA

                    if (snapshot.data! % 10 == 0) {
                      print("Multiplo de 10");

                      _consultaService
                          .comprobarGuiaFirma(
                              sipostProvider.barcode,
                              _prefs.cedulaMensajero,
                              sipostProvider.codigo.toString())
                          .then((resp) {
                        print("comprobación de guia: $resp");
                        if (resp["Response"]) {
                          _scanService.cancel();
                          sipostProvider.sipostResponse.isFirmaComprobada =
                              true;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Guia comprobada")));
                        }
                      }).catchError((error) {
                        showAlert(
                          context,
                          "Error",
                          "Error: $error",
                          TextButton(
                            child: Text("ENTENDIDO"),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, "menu");
                            },
                          ),
                          null,
                        );
                      });
                    }
                    return const LoadingOverlay(
                      title: "Comprobando la firma del cliente",
                      content: "Por favor espere",
                    );
                  }
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
          Visibility(
            visible: _certificando,
            child: const LoadingOverlay(
              title: "Certificando entrega",
              content: "Por favor espere",
            ),
          ),
        ],
      ),
    );
  }

/*
  void _tomarFoto() {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    // Procesar foto marbete
    final PickedFile filePicked = await ImagePicker().getImage(
      source: origen,
      imageQuality: 90,
      maxWidth: MediaQuery.of(context).size.height,
    );
    _foto = File(filePicked.path);
    if (_foto != null) {}
    setState(() {});
  }
  */

  // Capturar foto
  Widget _mostrarFoto() {
    // Mostrar la foto del marbete
    if (_foto != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          child: Image.file(
            _foto!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Icon(Icons.edit);
  }

  certificar(DataSipostProvider sipostProvider) async {
    setState(() => _certificando = true);
    if (_internetConnection) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        if (_foto != null) {
        } else {}

        /*
        if (_foto != null) {
          _certificadoService
              .generarCertificadoConImagen(
                  _foto,
                  sipostProvider.barcode,
                  sipostProvider.sipostResponse.names!,
                  sipostProvider.sipostResponse.identification ?? "1",
                  sipostProvider.sipostResponse.phone ?? "1111111111",
                  _lat.toString(),
                  _lng.toString(),
                  'https://maps.googleapis.com/maps/api/staticmap?center=$_lat,$_lng&zoom=17&scale=2&size=400x120&maptype=roadmap&markers=$_lat,$_lng',
                  sipostProvider.sipostResponse.isPorteria!,
                  _observacionesController.text,
                  _prefs.cedulaMensajero,
                  false)
              .then((resp) async {
            _scanService.cancel();
            if (resp['Message'] == 'Ingresado Correctamente') {
              setState(() => _certificando = false);

              Certificado _certificado = new Certificado()
                ..idEdificio = null
                ..hasFoto = 1
                ..cargada = 1
                ..imagenPath = _foto!.path
                ..fecha = DateTime.now().toLocal().toString()
                ..guia = sipostProvider.barcode
                ..nombres = sipostProvider.sipostResponse.names
                ..cedula = sipostProvider.sipostResponse.identification ?? "1"
                ..telefono = sipostProvider.sipostResponse.phone ?? "1111111111"
                ..latitud = _lat.toString()
                ..latitud = _lng.toString()
                ..urlImagen = 'https://maps.googleapis...'
                ..isPorteria = sipostProvider.sipostResponse.isPorteria! ? 1 : 0
                ..observaciones = _observacionesController.text
                ..cedulaMensajero = _prefs.cedulaMensajero
                ..isMultiple = 0;

              await SqliteDB.db.crearCertificado(_certificado);
              sipostProvider.sipostResponse = new SipostResponse();
              sipostProvider.barcode = "";
              mensajeSoporteEnviadoPopUp(context);
            } else if (resp["Message"] == "La guia ya fue entregada") {
              setState(() => _certificando = false);
              showAlert(
                context,
                'Error al certificar',
                "La guia ya fue entregada",
                TextButton(
                  child: Text('ENTENDIDO'),
                  onPressed: () {
                    sipostProvider.sipostResponse = new SipostResponse();
                    sipostProvider.barcode = "";
                    Navigator.popAndPushNamed(context, 'menu');
                  },
                ),
                null,
              );
            } else if (resp["Message"] == "Ingresado , pero sin liquidacion") {
              setState(() => _certificando = false);
              showAlert(
                context,
                'Error al certificar',
                "Ingresado , pero sin liquidacion",
                TextButton(
                  child: Text('ENTENDIDO'),
                  onPressed: () {
                    sipostProvider.sipostResponse = new SipostResponse();
                    sipostProvider.barcode = "";
                    Navigator.popAndPushNamed(context, 'menu');
                  },
                ),
                null,
              );
            } else if (resp["Message"] ==
                "No se encontro el cargue o el envío ya fue liquidado.") {
              setState(() => _certificando = false);
              showAlert(
                context,
                'Ha habido un error',
                "No se encontro el cargue o el envío ya fue liquidado.",
                TextButton(
                  child: Text('ENTENDIDO'),
                  onPressed: () {
                    sipostProvider.sipostResponse = new SipostResponse();
                    sipostProvider.barcode = "";
                    Navigator.popAndPushNamed(context, 'menu');
                  },
                ),
                null,
              );
            } else {
              setState(() => _certificando = false);
              showAlert(
                context,
                'Error al certificar',
                resp["Message"],
                TextButton(
                  child: Text('ENTENDIDO'),
                  onPressed: () {
                    sipostProvider.sipostResponse = new SipostResponse();
                    sipostProvider.barcode = "";
                    Navigator.popAndPushNamed(context, 'menu');
                  },
                ),
                null,
              );
            }
          }).catchError((error) {
            setState(() => _certificando = false);
          }).timeout(Duration(seconds: 180), onTimeout: () {
            timeoutPopUp(context);
          });
        } else {
          if (sipostProvider.sipostResponse.isFotoObligatoria!) {
            showAlert(context, "Foto Obligatoria",
                "Se requiere tomar una foto de evidencia", null, null);
            setState(() => _certificando = false);
            return;
          } else {
            _certificadoService
                .generarCertificado(
              sipostProvider.barcode,
              sipostProvider.sipostResponse.names!,
              sipostProvider.sipostResponse.identification ?? "1",
              sipostProvider.sipostResponse.phone ?? "1111111111",
              _lat.toString(),
              _lng.toString(),
              'https://maps.googleapis.com/maps/api/staticmap?center=$_lat,$_lng&zoom=17&scale=2&size=400x120&maptype=roadmap&markers=$_lat,$_lng',
              sipostProvider.sipostResponse.isPorteria!,
              _observacionesController.text,
              _prefs.cedulaMensajero,
              false,
            )
                .then((resp) async {
              _scanService.cancel();
              if (resp['Message'] == 'Ingresado Correctamente') {
                setState(() => _certificando = false);

                Certificado _certificado = new Certificado()
                  ..idEdificio = null
                  ..hasFoto = 0
                  ..cargada = 1
                  ..imagenPath = ''
                  ..fecha = DateTime.now().toLocal().toString()
                  ..guia = sipostProvider.barcode
                  ..nombres = sipostProvider.sipostResponse.names
                  ..cedula = sipostProvider.sipostResponse.identification ?? "1"
                  ..telefono =
                      sipostProvider.sipostResponse.phone ?? "1111111111"
                  ..latitud = _lat.toString()
                  ..latitud = _lng.toString()
                  ..urlImagen = 'https://maps.googleapis...'
                  ..isPorteria =
                      sipostProvider.sipostResponse.isPorteria! ? 1 : 0
                  ..observaciones = _observacionesController.text
                  ..cedulaMensajero = _prefs.cedulaMensajero
                  ..isMultiple = 0;

                await SqliteDB.db.crearCertificado(_certificado);
                sipostProvider.sipostResponse = new SipostResponse();
                sipostProvider.barcode = "";
                mensajeSoporteEnviadoPopUp(context);
              } else {
                setState(() => _certificando = false);
                showAlert(
                  context,
                  'Error al certificar',
                  resp["Message"],
                  TextButton(
                    child: Text('ENTENDIDO'),
                    onPressed: () {
                      sipostProvider.sipostResponse = new SipostResponse();
                      sipostProvider.barcode = "";
                      Navigator.pop(context);
                    },
                  ),
                  null,
                );
              }
            });
          }
        }
        */
      } else {
        setState(() {
          _certificando = false;
        });
      }
    } else {
      final read = await sinConexionInternetPopUp(context);

      if (read) {
        // Cuando no hay internet
        Certificado _certificado = new Certificado()
          ..hasFoto = _foto != null ? 1 : 0
          ..cargada = 0
          ..imagenPath = _foto != null ? _foto!.path : ""
          ..fecha = DateTime.now().toLocal().toString()
          ..guia = sipostProvider.barcode
          ..nombres = sipostProvider.sipostResponse.names
          ..cedula = sipostProvider.sipostResponse.identification
          ..telefono = sipostProvider.sipostResponse.phone
          ..latitud = _lat.toString()
          ..longitud = _lng.toString()
          ..urlImagen = 'https://maps.googleapis...'
          ..isPorteria = sipostProvider.sipostResponse.isPorteria! ? 1 : 0
          ..observaciones = _observacionesController.text
          ..cedulaMensajero = _prefs.cedulaMensajero
          ..isMultiple = 0;

        await SqliteDB.db.crearCertificado(_certificado);
        setState(() => _certificando = false);
        Navigator.pushReplacementNamed(context, 'menu');
      }
    }
  }

/*
  // Obtener la posición actual
  void _getCurrentPosition() {
    final Geolocator geo = Geolocator()..forceAndroidLocationManager;

    geo
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
    });
  }
  */
}
