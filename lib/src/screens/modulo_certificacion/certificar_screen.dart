import 'dart:io';
import 'package:LIQYAPP/src/components/connection_overlay.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:LIQYAPP/src/services/geolocator_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/loading_overlay.dart';
import 'package:LIQYAPP/src/components/modals.dart';
import 'package:LIQYAPP/src/provider/data_sipost_provider.dart';
import 'package:LIQYAPP/src/services/digital_image_sipost.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/services/scanner_service.dart';
import 'package:LIQYAPP/src/services/sqlite_db.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class CertificarScreen extends StatefulWidget {
  const CertificarScreen({super.key});

  @override
  CertificarScreenState createState() => CertificarScreenState();
}

class CertificarScreenState extends State<CertificarScreen> {
  File? _foto;
  final _scanService = ScanService();
  final _prefs = PreferenciasUsuario();
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataSipostProvider sipostProvider =
        Provider.of<DataSipostProvider>(context, listen: false);
    final connection =
        Provider.of<InternetConnectionStatus>(context, listen: false);

    if (connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (connection == InternetConnectionStatus.connected) {
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
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: <Widget>[
                                  BarcodeWidget(
                                    data: sipostProvider.barcode,
                                    barcode: Barcode.code128(),
                                    height: 80.0,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
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
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                            border: Border.all(),
                                            borderRadius:
                                                BorderRadius.circular(12.0)),
                                        child: AspectRatio(
                                            aspectRatio: 5 / 3,
                                            child: _foto != null
                                                ? _mostrarFoto()
                                                : const Icon(Icons.camera_alt)),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: MaterialButton(
                                          elevation: 0.0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          color: const Color.fromRGBO(
                                              244, 244, 244, 1.0),
                                          child: const Text("Toma una foto"),
                                          onPressed: () {
                                            _tomarFoto();
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        const SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            'DATOS DE LA PERSONA QUE RECIBE',
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontFamily: "Custom"),
                                          ),
                                        ),
                                        const SizedBox(height: 6.0),
                                        TextFormField(
                                          readOnly: sipostProvider
                                              .sipostResponse.isEntregaTercero!,
                                          style:
                                              const TextStyle(fontSize: 12.0),
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
                                        const SizedBox(height: 6.0),
                                        Visibility(
                                          visible: !sipostProvider
                                              .sipostResponse.isPorteria!,
                                          child: TextFormField(
                                            style:
                                                const TextStyle(fontSize: 12.0),
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
                                        const SizedBox(height: 6.0),
                                        Visibility(
                                          visible: !sipostProvider
                                              .sipostResponse.isPorteria!,
                                          child: TextFormField(
                                              readOnly: !sipostProvider
                                                  .sipostResponse
                                                  .isEntregaTercero!,
                                              style: const TextStyle(
                                                  fontSize: 12.0),
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
                                        const SizedBox(height: 6.0),
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
                                          style:
                                              const TextStyle(fontSize: 12.0),
                                        ),
                                        SizedBox(
                                          width: double.infinity,
                                          child: TextButton.icon(
                                            icon: const Icon(
                                              Icons.cloud_upload,
                                              size: 20.0,
                                            ),
                                            // color: yellow,
                                            /*shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),*/
                                            label: const Text(
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
          ConnectionOverlay(
            internetConnection: !_internetConnection,
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
        child: Image.file(
          _foto!,
          fit: BoxFit.cover,
        ),
      );
    }
    return const Icon(Icons.edit);
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
                  _prefs.usuarioSipost,
                  _prefs.usuarioSipost,
                  _prefs.usuarioSipost,
                  _prefs.usuarioSipost)
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
                      child: const Text('OK'),
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
                  child: const Text('OK'),
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
          }).timeout(const Duration(seconds: 180), onTimeout: () {
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
          Certificado certificado = Certificado()
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

          await SqliteDB.db.crearCertificado(certificado);
          setState(() => _certificando = false);
          Navigator.pushReplacementNamed(context, 'menu');
        }
      }
    }
  }
}
