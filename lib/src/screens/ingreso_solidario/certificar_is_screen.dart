import 'dart:async';
import 'dart:io';

////import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prueba_de_entrega/src/components/modals.dart';
import 'package:prueba_de_entrega/src/models/ingreso_solidario_model.dart';
import 'package:prueba_de_entrega/src/provider/ingreso_solidario_provider.dart';
import 'package:prueba_de_entrega/src/services/certificado_service.dart';
import 'package:prueba_de_entrega/src/services/ingreso_solidario_service.dart';
import 'package:prueba_de_entrega/src/services/prefs.dart';
import 'package:prueba_de_entrega/src/services/sqlite_db.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CertificarISScreen extends StatefulWidget {
  @override
  _CertificarISScreenState createState() => _CertificarISScreenState();
}

class _CertificarISScreenState extends State<CertificarISScreen> {
  final _prefs = PreferenciasUsuario();
  final _certificadoService = CertificadoService();
  final _ingresoSolidarioService = IngresoSolidarioService();

  final speech = SpeechToText();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _campoActual = "";
  bool hasSpeech = false;
  bool _isListening = false;
  bool _isPorteria = false;
  bool _isCarta = false;
  bool _autovalidate = false;
  bool _internetConnection = true;
  bool _certificando = false;
  double _lat = 4;
  double _lng = -72;

  IngresoSolidarioModel _guiaDataSipost = new IngresoSolidarioModel();

  File? _foto;

  TextEditingController _nombreController = new TextEditingController();
  TextEditingController _cedulaController = new TextEditingController();
  TextEditingController _celularController = new TextEditingController();
  TextEditingController _correoController = new TextEditingController();
  TextEditingController _observacionesController = new TextEditingController();

  // FocusNode _nombreFocus = FocusNode();
  // FocusNode _cedulaFocus = FocusNode();
  FocusNode _celularFocus = FocusNode();
  FocusNode _correoFocus = FocusNode();
  FocusNode _observacionesFocus = FocusNode();
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  @override
  void initState() {
    //_getCurrentPosition();
    initSpeechState();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _guiaDataSipost =
        Provider.of<IngresoSolidarioProvider>(context, listen: false)
            .ingresoSolidarioData;
    setState(() {
      _nombreController.text = _guiaDataSipost.names;
      _cedulaController.text = _guiaDataSipost.identification;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _connection = Provider.of<InternetConnectionStatus>(context);

    if (_connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (_connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Wrap(
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              'Servicios Postales Nacionales',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '#OperadorPostalOficial',
              style: TextStyle(fontSize: 14.0, fontFamily: 'Light'),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Certificado de entrega Ingreso solidario',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Número de la guía',
                          style: TextStyle(
                            color: blue,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Wrap(
                        direction: Axis.horizontal,
                        children: <Widget>[
                          _guiaDataSipost.isCertificado
                              ? Icon(FontAwesomeIcons.certificate,
                                  color: Colors.amber)
                              : Icon(
                                  Icons.local_post_office,
                                  color: Colors.blueGrey,
                                ),
                          SizedBox(width: 8.0),
                          Text(
                            _guiaDataSipost.barcode,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'Regular',
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        width: double.infinity,
                        child: Text(
                          'Foto de evidencia (opcional)',
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          //_tomarFoto();
                        },
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _foto != null
                              ? _mostrarFoto()
                              : Container(
                                  color: blue.withOpacity(0.1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(Icons.camera_alt),
                                      Text('Tomar foto')
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      Visibility(
                        visible: true,
                        child: CheckboxListTile(
                          activeColor: blue,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text('Se entrega carta'),
                          value: _isCarta,
                          onChanged: (value) {
                            setState(() {
                              _isCarta = value!;
                            });
                          },
                        ),
                      ),
                      Divider(),
                      Container(
                        width: double.infinity,
                        child: Text(
                          '2. Datos de la persona que recibe',
                          style:
                              TextStyle(fontSize: 18.0, fontFamily: 'Regular'),
                        ),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          readOnly: true,
                          initialValue: _guiaDataSipost.names,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              border:
                                  OutlineInputBorder(borderSide: BorderSide()),
                              isDense: true,
                              labelText: 'Nombre completo de quíen recibe',
                              hintText: 'Escribe el nombre completo',
                              helperText: _guiaDataSipost.isColombian
                                  ? 'Nacionalidad: Colombiano'
                                  : 'Nacionalidad: Extranjero'),
                        ),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          readOnly: true,
                          initialValue: _guiaDataSipost.identification,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            isDense: true,
                            labelText: 'Cédula de quíen recibe',
                            hintText: '00000000',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      Visibility(
                        visible: !_isCarta,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          margin: EdgeInsets.only(bottom: 12.0),
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            //autovalidate: _autovalidate,
                            focusNode: _celularFocus,
                            controller: _celularController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border:
                                  OutlineInputBorder(borderSide: BorderSide()),
                              isDense: true,
                              labelText: 'Número de celular de notificación',
                              hintText: 'Número de 10 dígitos',
                            ),
                            validator: (valor) {
                              if (valor!.isEmpty || valor.length < 10) {
                                return 'Ingrese un número de 10 digitos';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              setState(() => _campoActual = "celular");
                              _celularFocus.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_observacionesFocus);
                            },
                            onTap: () {
                              setState(() => _campoActual = "celular");
                            },
                          ),
                        ),
                      ),

                      Visibility(
                        visible: !_guiaDataSipost.isColombian && !_isCarta,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          margin: EdgeInsets.only(bottom: 12.0),
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            //autovalidate: _autovalidate,
                            focusNode: _correoFocus,
                            controller: _correoController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              labelText: 'Correo electrónico',
                              hintText: 'micorreo@ejemplo.com',
                            ),
                            validator: (valor) {
                              RegExp regExp = RegExp(pattern);

                              if (!regExp.hasMatch(valor!.trim())) {
                                return 'Escribe un correo válido';
                              } else if (valor.isEmpty) {
                                return 'Escribe un correo eléctronico';
                              }
                              return null;
                            },
                            onFieldSubmitted: (valor) {
                              _correoFocus.unfocus();
                              setState(() => _campoActual = "correo");
                            },
                            onTap: () {
                              setState(() => _campoActual = "correo");
                            },
                          ),
                        ),
                      ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width * 0.8,
                      //   child: TextFormField(
                      //     focusNode: _observacionesFocus,
                      //     controller: _observacionesController,
                      //     keyboardType: TextInputType.multiline,
                      //     textInputAction: TextInputAction.done,
                      //     decoration: InputDecoration(
                      //       border:
                      //           OutlineInputBorder(borderSide: BorderSide()),
                      //       isDense: true,
                      //       labelText: 'Observaciones',
                      //       hintText: 'Escribe aquí',
                      //     ),
                      //     onFieldSubmitted: (value) {
                      //       setState(() {
                      //         _campoActual = "observaciones";
                      //       });
                      //       _observacionesFocus.unfocus();
                      //     },
                      //     onTap: () {
                      //       setState(() {
                      //         _campoActual = "observaciones";
                      //       });
                      //     },
                      //   ),
                      // ),
                      SizedBox(height: 20.0),
                      Container(
                        height: 52.0,
                        width: double.infinity,
                        child: MaterialButton(
                          color: blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Text(
                              _isCarta ? 'FINALIZAR' : 'CERTIFICAR ENTREGA',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white)),
                          onPressed: () async {
                            if (_internetConnection) {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _certificando = true);
                                // 1. Validamos email de ingreso solidario
                                _ingresoSolidarioService
                                    .emailIngresoSolidario(
                                        _guiaDataSipost.barcode,
                                        _prefs.cedulaMensajero,
                                        _guiaDataSipost.identification,
                                        _correoController.text,
                                        _isCarta)
                                    .then((resp) {
                                  if (resp["Message"] == "Exitoso") {
                                    // 2. entrega carta y finaliza el proceso
                                    if (_isCarta) {
                                      setState(() => _certificando = false);
                                      seEntregaCartaPopUp(context);
                                    } else {
                                      // 2. si la foto existe certifica la entrega
                                      if (_foto != null) {
                                        _certificadoService
                                            .generarCertificadoConImagen(
                                                _foto,
                                                _guiaDataSipost.barcode,
                                                _guiaDataSipost.names,
                                                _guiaDataSipost.identification,
                                                _celularController.text.isEmpty
                                                    ? "1111111111"
                                                    : _celularController.text,
                                                _lat.toString(),
                                                _lng.toString(),
                                                'https://maps.googleapis.com/maps/api/staticmap?center=$_lat,$_lng&zoom=17&scale=2&size=400x120&maptype=roadmap&markers=$_lat,$_lng',
                                                _isPorteria,
                                                'Ingreso solidario: Documento No. ${_guiaDataSipost.identification}.',
                                                _prefs.cedulaMensajero,
                                                false)
                                            .then((resp) async {
                                          if (resp["Message"] ==
                                              'Ingresado Correctamente') {
                                            setState(
                                                () => _certificando = false);

                                            Certificado _certificado =
                                                new Certificado()
                                                  ..idEdificio = null
                                                  ..hasFoto = 1
                                                  ..cargada = 1
                                                  ..imagenPath = _foto!.path
                                                  ..fecha = DateTime.now()
                                                      .toLocal()
                                                      .toString()
                                                  ..guia =
                                                      _guiaDataSipost.barcode
                                                  ..nombres =
                                                      _guiaDataSipost.names
                                                  ..cedula = _guiaDataSipost
                                                      .identification
                                                  ..telefono =
                                                      _celularController.text
                                                  ..latitud = _lat.toString()
                                                  ..latitud = _lng.toString()
                                                  ..urlImagen =
                                                      'https://maps.googleapis...'
                                                  ..isPorteria = 0
                                                  ..observaciones =
                                                      'Ingreso solidario: Documento No. ${_guiaDataSipost.identification}.'
                                                  ..cedulaMensajero =
                                                      _prefs.cedulaMensajero
                                                  ..isMultiple = 0;

                                            await SqliteDB.db
                                                .crearCertificado(_certificado);
                                            mensajeSoporteEnviadoPopUp(context);
                                          } else if (resp["Message"] ==
                                              "La guia ya fue entregada") {
                                            setState(
                                                () => _certificando = false);
                                            showAlert(
                                              context,
                                              'Ha habido un error',
                                              "La guia ya fue entregada",
                                              TextButton(
                                                child: Text('ENTENDIDO'),
                                                onPressed: () {
                                                  Navigator.popAndPushNamed(
                                                      context, 'menu');
                                                },
                                              ),
                                              null,
                                            );
                                          } else if (resp["Message"] ==
                                              "Ingresado , pero sin liquidacion") {
                                            setState(
                                                () => _certificando = false);
                                            showAlert(
                                              context,
                                              'Ha habido un error',
                                              "Ingresado , pero sin liquidacion",
                                              TextButton(
                                                child: Text('ENTENDIDO'),
                                                onPressed: () {
                                                  Navigator.popAndPushNamed(
                                                      context, 'menu');
                                                },
                                              ),
                                              null,
                                            );
                                          } else if (resp["Message"] ==
                                              "No se encontro el cargue o el envío ya fue liquidado.") {
                                            setState(
                                                () => _certificando = false);
                                            showAlert(
                                              context,
                                              'Ha habido un error',
                                              "No se encontro el cargue o el envío ya fue liquidado.",
                                              TextButton(
                                                child: Text('ENTENDIDO'),
                                                onPressed: () {
                                                  Navigator.popAndPushNamed(
                                                      context, 'menu');
                                                },
                                              ),
                                              null,
                                            );
                                          } else {
                                            setState(
                                                () => _certificando = false);
                                            showAlert(
                                              context,
                                              'Ha habido un error',
                                              resp["Message"],
                                              TextButton(
                                                child: Text('ENTENDIDO'),
                                                onPressed: () {
                                                  Navigator.popAndPushNamed(
                                                      context, 'menu');
                                                },
                                              ),
                                              null,
                                            );
                                          }
                                        }).catchError((error) {
                                          setState(() => _certificando = false);
                                          showErrorPopUp(context, error);
                                        }).timeout(Duration(seconds: 60),
                                                onTimeout: () {
                                          setState(() => _certificando = false);
                                          timeoutPopUp(context);
                                        });
                                      } else {
                                        // Notificar que la foto es obligatoria
                                        setState(() => _certificando = false);
                                        showAlert(
                                            context,
                                            'Importante',
                                            'Debes tomar una foto al documento de identidad como soporte de entrega.',
                                            TextButton(
                                              child: Text('TOMAR FOTO'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                //_tomarFoto();
                                              },
                                            ),
                                            null);
                                      }
                                    }
                                  } else if (resp["Message"] ==
                                      'Se dejo carta') {
                                    setState(() => _certificando = false);
                                    showAlert(
                                        context,
                                        'No puedes certificar',
                                        'Ya se ha dejado una carta de notificación de Ingreso Solidario previamente.',
                                        TextButton(
                                          child: Text('FINALIZAR'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pushReplacementNamed(
                                                context, 'menu');
                                          },
                                        ),
                                        null);
                                  } else {
                                    setState(() => _certificando = false);
                                    showAlert(
                                        context,
                                        'Aviso',
                                        'Error: $resp',
                                        TextButton(
                                          child: Text('FINALIZAR'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.pushReplacementNamed(
                                                context, 'menu');
                                          },
                                        ),
                                        null);
                                  }
                                }).catchError((error) {
                                  setState(() => _certificando = false);
                                  showErrorPopUp(context, error);
                                }).timeout(Duration(seconds: 60),
                                        onTimeout: () {
                                  setState(() => _certificando = false);
                                  timeoutPopUp(context);
                                });
                              } else {
                                setState(() {
                                  _certificando = false;
                                  _autovalidate = true;
                                });
                              }
                            } else {
                              final read =
                                  await sinConexionInternetPopUp(context);

                              if (read) {
                                // Cuando no hay internet
                                Certificado _certificado = new Certificado()
                                  ..hasFoto = _foto != null ? 1 : 0
                                  ..cargada = 0
                                  ..imagenPath =
                                      _foto != null ? _foto!.path : ""
                                  ..fecha = DateTime.now().toLocal().toString()
                                  ..guia = _guiaDataSipost.barcode
                                  ..nombres = _guiaDataSipost.names
                                  ..cedula = _guiaDataSipost.identification
                                  ..telefono = _celularController.text
                                  ..latitud = _lat.toString()
                                  ..longitud = _lng.toString()
                                  ..urlImagen = 'https://maps.googleapis...'
                                  ..isPorteria = _isPorteria ? 1 : 0
                                  ..observaciones =
                                      'Ingreso solidario: Documento No. ${_guiaDataSipost.identification}.'
                                  ..cedulaMensajero = _prefs.cedulaMensajero
                                  ..isMultiple = 0;

                                await SqliteDB.db
                                    .crearCertificado(_certificado);
                                setState(() => _certificando = false);
                                Navigator.pushReplacementNamed(context, 'menu');
                              }
                            }
                          },
                        ),
                      ),
                    ]),
              ),
            ),
          ),
          Visibility(
            visible: _certificando,
            child: Container(
              constraints: BoxConstraints.expand(),
              padding: EdgeInsets.all(20.0),
              color: Colors.white70,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(blue)),
                    SizedBox(height: 16.0),
                    Text(
                      'Certificando',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Por favor espere...',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        maintainAnimation: true,
        maintainState: true,
        visible: _keyboardIsVisible(),
        child: FloatingActionButton(
          backgroundColor: _isListening ? red : blue,
          elevation: 0.0,
          child: _isListening
              ? Icon(Icons.stop, color: Colors.white)
              : Icon(FontAwesomeIcons.microphoneAlt, color: yellow),
          onPressed: () {
            setState(() {
              if (_isListening) {
                stopListening();
              } else {
                startListening();
              }
            });
          },
        ),
      ),
    );
  }

  // Obtener la posición actual
  /*
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

  // Speech to text
  bool _keyboardIsVisible() {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }

  Future<void> initSpeechState() async {
    bool speechResult = await speech.initialize(
        onError: errorListener, onStatus: statusListener);

    if (!mounted) return;
    setState(() => hasSpeech = speechResult);
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    _isListening = true;
    speech.listen(listenFor: Duration(seconds: 10), onResult: resultListener);
  }

  void stopListening() {
    speech.stop();
    setState(() {
      _isListening = false;
      FocusScope.of(context).unfocus();
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      _isListening = false;
      FocusScope.of(context).unfocus();
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() => lastError = "${error.errorMsg} - ${error.permanent}");
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      switch (_campoActual) {
        case "nombre":
          {
            setState(() => _nombreController.text = lastWords.toString());
          }
          break;
        case "cedula":
          {
            setState(() => _cedulaController.text =
                lastWords.toString().replaceAll(new RegExp(r"\s+\b|\b\s"), ""));
          }
          break;
        case "celular":
          {
            setState(() => _celularController.text =
                lastWords.toString().replaceAll(new RegExp(r"\s+\b|\b\s"), ""));
          }
          break;
        case "correo":
          {
            setState(() => _correoController.text =
                lastWords.toString().replaceAll(new RegExp(r"\s+\b|\b\s"), ""));
          }
          break;
        case "observaciones":
          {
            setState(
                () => _observacionesController.text = lastWords.toString());
          }
          break;
      }
      if (result.finalResult) {
        _isListening = false;
        FocusScope.of(context).unfocus();
      }
    });
  }

  void statusListener(String status) {
    setState(() => lastStatus = "$status");
  }

  // Capturar foto
  Widget _mostrarFoto() {
    // Mostrar la foto del marbete
    if (_foto != null) {
      return Container(
        height: 56.0,
        width: 56.0,
        child: Image.file(
          _foto!,
          fit: BoxFit.cover,
        ),
      );
    }
    return Icon(FontAwesomeIcons.barcode);
  }

/*
  void _tomarFoto() {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    // Procesar foto marbete
    PickedFile pickedFile = await ImagePicker().getImage(
      source: origen,
      imageQuality: 90,
      maxWidth: MediaQuery.of(context).size.height,
    );
    _foto = File(pickedFile.path);
    if (_foto != null) {}
    setState(() {});
  */
}
