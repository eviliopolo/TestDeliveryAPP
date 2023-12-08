import 'dart:io';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prueba_de_entrega/src/services/geolocator_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:prueba_de_entrega/src/components/loading_overlay.dart';
import 'package:prueba_de_entrega/src/components/modals.dart';
import 'package:prueba_de_entrega/src/provider/data_sipost_provider.dart';
import 'package:prueba_de_entrega/src/services/digital_image_sipost.dart';
import 'package:prueba_de_entrega/src/services/prefs.dart';
import 'package:prueba_de_entrega/src/services/scanner_service.dart';
import 'package:prueba_de_entrega/src/services/sqlite_db.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';

class CertificarScreen extends StatefulWidget {
  @override
  _CertificarScreenState createState() => _CertificarScreenState();
}

class _CertificarScreenState extends State<CertificarScreen> {
  File? _foto;
  final _scanService = ScanService();
  final _prefs = PreferenciasUsuario();
  //final _certificadoService = CertificadoService();
  final _position = GeolocatorService();
  final _digtalImageSipost = DigitalImageSipost();
  bool _internetConnection = true;
  bool _certificando = false;
  double? _lat;
  double? _lng;

  final TextEditingController _observacionesController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    //_getCurrentPosition();
    super.initState();
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
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "menu");
          },
        ),
        title: const Wrap(
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              'Servicios Postales Nacionales',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '#OperadorPostalOficial --',
              style: TextStyle(fontSize: 12.0, fontFamily: 'Light'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: background,
            constraints: BoxConstraints.expand(),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8.0),
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
                                    height: 30.0,
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    drawText: true,
                                    style: const TextStyle(
                                        fontFamily: "",
                                        height: 2.0,
                                        letterSpacing: 2.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 12.0),
                                  Divider(),
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
                                            _tomarFoto();
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
                                          readOnly: sipostProvider
                                              .sipostResponse.isEntregaTercero!,
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
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText:
                                                  "Número cedula de quien recibe",
                                              isDense: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                            initialValue: sipostProvider
                                                        .sipostResponse
                                                        .identification ==
                                                    null
                                                ? ""
                                                : sipostProvider.sipostResponse
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
                                              style: TextStyle(fontSize: 12.0),
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
                                              onSaved: (value) => sipostProvider
                                                  .sipostResponse.phone = value,
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
                                          controller: _observacionesController,
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
                                            // color: yellow,
                                            /*shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),*/
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
              ),
            ),
          ),
          Visibility(
            visible: _certificando,
            child: LoadingOverlay(
              title: "Certificando entrega",
              content: "Por favor espere",
            ),
          ),
        ],
      ),
    );
  }

  void _tomarFoto() {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    final XFile? filePicked = await ImagePicker().pickImage(
      source: origen,
      imageQuality: 100,
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.height,
    );

    if (filePicked != null) {
      _foto = File(filePicked.path);
    }
    setState(() {});
  }

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

        /* computo latitud longitud */
        Position position = await _position.determinePosition();
        print(position.latitude);
        print(position.longitude);
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
        });

        if (_foto != null) {
          _digtalImageSipost
              .liquidation(
                  sipostProvider.barcode,
                  sipostProvider.sipostResponse.names!,
                  _observacionesController.text,
                  DateTime.now().toLocal(),
                  _prefs.cedulaMensajero,
                  _prefs.cedulaMensajero,
                  _prefs.cedulaMensajero,
                  _prefs.cedulaMensajero)
              .then((resp) async {
            _scanService.cancel();
            if (resp['Message'] == 'Exitoso') {
              //setState(() => _certificando = false);
              _digtalImageSipost
                  .file_sipost(sipostProvider.barcode, _foto, _lat!, _lng!)
                  .then((resp) async {
                if (resp["Message"] == "Exitoso") {
                  setState(() => _certificando = false);
                  showAlert(
                    context,
                    'Guía Digitalizada',
                    "Entregada",
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        //sipostProvider.sipostResponse = SipostResponse();
                        //sipostProvider.barcode = sipostProvider.barcode;
                        Navigator.popAndPushNamed(context, 'menu');
                      },
                    ),
                    null,
                  );
                } else {
                  setState(() => _certificando = false);
                  showAlert(
                    context,
                    'MENSAJE',
                    resp["Message"],
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        //sipostProvider.sipostResponse = new SipostResponse();
                        // sipostProvider.barcode = "";
                        Navigator.popAndPushNamed(context, 'menu');
                      },
                    ),
                    null,
                  );
                }
              });
            } else {
              setState(() => _certificando = false);
              showAlert(
                context,
                'MENSAJE',
                resp["Message"],
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    //sipostProvider.sipostResponse = new SipostResponse();
                    //sipostProvider.barcode = "";
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
  }
}
