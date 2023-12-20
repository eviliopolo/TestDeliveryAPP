import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/loading_overlay.dart';
import 'package:LIQYAPP/src/provider/multientrega_provider.dart';
import 'package:LIQYAPP/src/services/geolocator_service.dart';
import 'package:LIQYAPP/src/services/sqlite_db.dart';
import 'package:LIQYAPP/src/theme/theme.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class EdificioScreen extends StatefulWidget {
  @override
  _EdificioScreenState createState() => _EdificioScreenState();
}

class _EdificioScreenState extends State<EdificioScreen> {
  final _formKey = GlobalKey<FormState>();
  final speech = SpeechToText();
  final geo = GeolocatorService();

  String _campoActual = "";
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  double _lat = 4;
  double _lng = -72;
  bool hasSpeech = false;
  bool _isListening = false;
  bool _autovalidate = false;
  bool _cargando = false;

  File? _foto;

  TextEditingController _edificioController = new TextEditingController();
  TextEditingController _direccionController = new TextEditingController();
  TextEditingController _celularController = new TextEditingController();

  FocusNode _direccionFocus = FocusNode();
  FocusNode _celularFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    initSpeechState();
    geo.getCurrentPosition().then((position) {
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
    });
  }

  void dispose() {
    _edificioController.dispose();
    _direccionController.dispose();
    _celularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(6, 69, 147, 1),
        foregroundColor: Colors.white,
        title: Wrap(
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              'Servicios Postales Nacionales',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
            color: blue.withOpacity(0.1),
            constraints: BoxConstraints.expand(),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(12.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Información del sitio de entrega',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 80.0,
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(12.0)),
                            child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: _foto != null
                                    ? _mostrarFoto()
                                    : Icon(Icons.camera_alt)),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: TextButton(
                              /*shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              color: Color.fromRGBO(244, 244, 244, 1.0),
                              */
                              child: Text("Toma una foto"),
                              onPressed: () {
                                //_tomarFoto();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 6.0),
                            TextFormField(
                              autofocus: false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              //autovalidate: _autovalidate,
                              controller: _edificioController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: 14.0),
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                hintText: 'Escriba el nombre del edificio',
                                labelText: 'Nombre del edificio',
                              ),
                              validator: (valor) {
                                if (valor!.isEmpty) {
                                  return 'Ingrese el nombre del edificio';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) {
                                setState(() => _campoActual = "edificio");
                                FocusScope.of(context)
                                    .requestFocus(_direccionFocus);
                              },
                              onTap: () {
                                setState(() => _campoActual = "edificio");
                              },
                            ),
                            SizedBox(height: 6.0),
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              //autovalidate: _autovalidate,
                              focusNode: _direccionFocus,
                              controller: _direccionController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: 14.0),
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                                hintText: 'Escriba la dirección del edificio',
                                labelText: 'Dirección del edificio',
                              ),
                              onFieldSubmitted: (value) {
                                setState(() => _campoActual = "direccion");
                                _direccionFocus.unfocus();
                                FocusScope.of(context)
                                    .requestFocus(_celularFocus);
                              },
                              validator: (valor) {
                                if (valor!.isEmpty) {
                                  return 'Ingrese la dirección del edificio';
                                }
                                return null;
                              },
                              onTap: () {
                                setState(() => _campoActual = "direccion");
                              },
                            ),
                            SizedBox(height: 6.0),
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              //autovalidate: _autovalidate,
                              focusNode: _celularFocus,
                              controller: _celularController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(fontSize: 14.0),
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                hintText: 'Número de 10 digitos',
                                labelText: 'Número celular',
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
                              },
                              onTap: () {
                                setState(() => _campoActual = "celular");
                              },
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              width: double.infinity,
                              child: TextButton(
                                /*
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                color: blue,
                                */
                                child: Text('CONTINUAR',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white)),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_foto != null) {
                                      setState(() => _cargando = true);

                                      Edificio _edificio = new Edificio()
                                        ..imagenPath = _foto!.path
                                        ..edificio = _edificioController.text
                                        ..direccion = _direccionController.text
                                        ..telefono = _celularController.text
                                        ..correo = ""
                                        ..lat = _lat.toString()
                                        ..lng = _lng.toString();

                                      SqliteDB.db
                                          .crearEdificio(_edificio)
                                          .then((id) {
                                        setState(() => _cargando = false);

                                        _edificio.id = id;
                                        Provider.of<MultiEntregaProvider>(
                                                context,
                                                listen: false)
                                            .edificioData = _edificio;
                                        Navigator.of(context)
                                            .pushNamed('multiscan');
                                      }).catchError((e) {
                                        setState(() => _cargando = false);
                                      });
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Información',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            content: Text(
                                                'Debes tomar una foto de evidencia como requisito obligatorio.'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('TOMAR FOTO'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  // _tomarFoto();
                                                },
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                  setState(() => _autovalidate = true);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
              visible: _cargando,
              child: LoadingOverlay(
                  title: "Guardando datos", content: "Por favor espere")),
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
        case "edificio":
          {
            setState(() => _edificioController.text = lastWords.toString());
          }
          break;
        case "direccion":
          {
            setState(() => _direccionController.text = lastWords.toString());
          }
          break;
        case "celular":
          {
            setState(() => _celularController.text =
                lastWords.toString().replaceAll(new RegExp(r"\s+\b|\b\s"), ""));
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

/*
  void _tomarFoto() {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    // Procesar foto marbete
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
    source: origen,
    imageQuality: 90,
    maxWidth: MediaQuery.of(context).size.height,
  );

  if (pickedFile != null) {
    // Convierte XFile a PickedFile
    PickedFile pickedFileConverted = PickedFile(pickedFile.path);
    _foto = pickedFileConverted;
    // Resto de tu lógica aquí
    setState(() {});
  }

    PickedFile pickedFile = await ImagePicker().pickImage(
      source: origen,
    imageQuality: 90,
    maxWidth: MediaQuery.of(context).size.height,
    );
    _foto = File(pickedFile.path);
    if (_foto != null) {}
    setState(() {});
  }
  */
}

class SubHead extends StatelessWidget {
  final String? text;
  SubHead({this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.0),
      width: double.infinity,
      child: Text(
        text!,
        style:
            TextStyle(color: blue, fontSize: 12.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
