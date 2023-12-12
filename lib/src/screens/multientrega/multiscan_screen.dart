import 'dart:io';

//import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/connection_overlay.dart';
import 'package:LIQYAPP/src/components/loading_overlay.dart';
import 'package:LIQYAPP/src/components/modals.dart';
//import 'package:LIQYAPP/src/models/edificio_model.dart';
import 'package:LIQYAPP/src/models/sipost_response.dart';
import 'package:LIQYAPP/src/provider/multientrega_provider.dart';
import 'package:LIQYAPP/src/services/certificado_service.dart';
import 'package:LIQYAPP/src/services/consulta_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/services/scanner_service.dart';
import 'package:LIQYAPP/src/services/sqlite_db.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class MultiScanScreen extends StatefulWidget {
  @override
  _MultiScanScreenState createState() => _MultiScanScreenState();
}

class _MultiScanScreenState extends State<MultiScanScreen> {
  final _consultaService = ConsultaService();
  final _prefs = PreferenciasUsuario();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _certificadoService = CertificadoService();

  SipostResponse _guiaDataSipost = new SipostResponse();
  Edificio _edificio = new Edificio();

  bool _buscando = false;
  bool _certificando = false;
  bool _internetConnection = true;
  List<Certificado> _listaCertificados = [];

  TextEditingController _guiaController = new TextEditingController();
  FocusNode _guiaFocus = new FocusNode();

  @override
  Widget build(BuildContext context) {
    final _scan = Provider.of<ScanService>(context);
    _edificio = Provider.of<MultiEntregaProvider>(context).edificioData;
    final _connection = Provider.of<InternetConnectionStatus>(context);

    if (_connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (_connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (_listaCertificados.isNotEmpty) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Hay entregas sin certificar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                            'Debes certificar las entregas para generar los soportes de entrega'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('SALIR SIN CERTIFICAR'),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, 'menu');
                            },
                          ),
                          TextButton(
                            child: Text('CERTIFICAR TODAS'),
                            onPressed: () {
                              certificarTodasLasEntregas(_listaCertificados);
                            },
                          ),
                        ],
                      );
                    });
              } else {
                await SqliteDB.db.borrarEdificio(_edificio.id!);
                Navigator.pushReplacementNamed(context, 'menu');
              }
            },
          ),
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.cloud_upload),
              onPressed: _listaCertificados.isEmpty
                  ? null
                  : () {
                      certificarTodasLasEntregas(_listaCertificados);
                    },
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
              color: blue.withOpacity(0.2),
              constraints: BoxConstraints.expand(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(12.0),
                      // shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      itemCount: _listaCertificados.length,
                      itemBuilder: (context, i) {
                        if (_listaCertificados.isNotEmpty) {
                          return Material(
                            elevation: 1.0,
                            color: white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: ListTile(
                              dense: true,
                              title: Text(_listaCertificados[i].guia!,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${_listaCertificados[i].nombres}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: red,
                                ),
                                onPressed: () {
                                  SqliteDB.db
                                      .borrarCertificado(
                                          _listaCertificados[i].id!)
                                      .then((id) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text('Registro eliminado'),
                                    ));
                                    setState(() {
                                      _listaCertificados
                                          .remove(_listaCertificados[i]);
                                    });
                                  });
                                },
                              ),
                            ),
                          );
                        }
                        return Text('No se han agregado guías');
                      },
                      separatorBuilder: (context, i) {
                        return SizedBox(height: 8.0);
                      },
                    ),
                  ),
                  Container(
                    color: white,
                    child: ListTile(
                      selected: true,
                      contentPadding: EdgeInsets.all(8.0),
                      title: TextFormField(
                        autofocus: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        //autovalidate: true,
                        controller: _guiaController,
                        textCapitalization: TextCapitalization.characters,
                        focusNode: _guiaFocus,
                        textInputAction: TextInputAction.search,
                        style: TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          hintText: 'Ingrese la guía',
                          // prefixIcon: Icon(FontAwesomeIcons.barcode),
                        ),
                        onChanged: (valor) async {
                          if (valor.length == 13) {
                            _guiaFocus.unfocus();
                            _guiaController.text =
                                _guiaController.text.toUpperCase();
                            // Detecta cuando la conexión a internet y notifica al usuario
                            if (!_internetConnection) {
                              sinInternetPopUp(context);
                            } else {
                              setState(() => _buscando = true);
                              // Verifica si existe en la lista para agregarla
                              var exist = _listaCertificados.firstWhere(
                                  (cert) => cert.guia == _guiaController.text
                                  //orElse: () => null);
                                  );
                              if (exist == null) {
                                // Consulta los datos a SIPOST
                                _consultaService
                                    .consultarGuia(_guiaController.text,
                                        _prefs.cedulaMensajero, true, true)
                                    .then((result) {
                                  if (result["Message"] == "Exitoso") {
                                    setState(() {
                                      _guiaDataSipost =
                                          SipostResponse.fromJson(result);

                                      Certificado _certificado =
                                          new Certificado()
                                            ..idEdificio = _edificio.id
                                            ..hasFoto = 1
                                            ..cargada = 0
                                            ..imagenPath = _edificio.imagenPath
                                            ..fecha = DateTime.now()
                                                .toLocal()
                                                .toString()
                                            ..guia = _guiaController.text
                                            ..nombres = _guiaDataSipost.names
                                            ..cedula = _guiaDataSipost
                                                        .identification ==
                                                    null
                                                ? "1"
                                                : _guiaDataSipost.identification
                                            ..telefono =
                                                _guiaDataSipost.phone!.isEmpty
                                                    ? _edificio.telefono
                                                    : _guiaDataSipost.phone
                                            ..latitud = _edificio.lat
                                            ..longitud = _edificio.lng
                                            ..urlImagen =
                                                'https://google.maps...'
                                            ..isPorteria = 1
                                            ..observaciones =
                                                'Se entrega en porteria del edificio ${_edificio.edificio}'
                                            ..cedulaMensajero =
                                                _prefs.cedulaMensajero
                                            ..isMultiple = 1;

                                      // Agregar a Sqlite y a la lista.
                                      SqliteDB.db
                                          .crearCertificado(_certificado)
                                          .then((id) {
                                        setState(() {
                                          _certificado.id = id;
                                          _listaCertificados.add(_certificado);
                                          _buscando = false;
                                        });
                                        _guiaController.clear();
                                      }).catchError((e) {
                                        setState(() => _buscando = false);
                                      });
                                    });
                                  } else {
                                    setState(() => _buscando = false);
                                    showAlert(
                                      context,
                                      'Aviso',
                                      "Error al cargar: ${result['Message']}",
                                      TextButton(
                                        child: Text('ENTENDIDO'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      null,
                                    );
                                    _guiaController.clear();
                                  }
                                }).catchError((error) {
                                  setState(() => _buscando = false);
                                  showErrorPopUp(context, error);
                                }).timeout(Duration(seconds: 180),
                                        onTimeout: () {
                                  setState(() => _buscando = false);
                                  timeoutPopUp(context);
                                });
                              } else {
                                setState(() => _buscando = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content:
                                        Text('Esta guía ya esta escaneada'),
                                  ),
                                );
                              }
                            }
                          } else if (valor.length > 13) {
                            codigoBarrasNoValidoPopUp(
                                context, _guiaController.text);
                            _guiaController.clear();
                            FocusScope.of(context).requestFocus(_guiaFocus);
                          }
                        },
                        onFieldSubmitted: (valor) {
                          if (valor.length == 13) {
                            _guiaFocus.unfocus();
                            _guiaController.text =
                                _guiaController.text.toUpperCase();
                            // Detecta cuando la conexión a internet y notifica al usuario
                            if (!_internetConnection) {
                              sinInternetPopUp(context);
                            } else {
                              setState(() => _buscando = true);
                              // Verifica si existe en la lista para agregarla
                              var exist = _listaCertificados.firstWhere(
                                (cert) => cert.guia == _guiaController.text,
                                //orElse: () => null);
                              );
                              if (exist == null) {
                                // Consulta los datos a SIPOST
                                _consultaService
                                    .consultarGuia(_guiaController.text,
                                        _prefs.cedulaMensajero, true, true)
                                    .then((result) {
                                  if (result["Message"] == "Exitoso") {
                                    setState(() {
                                      _guiaDataSipost =
                                          SipostResponse.fromJson(result);

                                      Certificado _certificado =
                                          new Certificado()
                                            ..idEdificio = _edificio.id
                                            ..hasFoto = 1
                                            ..cargada = 0
                                            ..imagenPath = _edificio.imagenPath
                                            ..fecha = DateTime.now()
                                                .toLocal()
                                                .toString()
                                            ..guia = _guiaController.text
                                            ..nombres = _guiaDataSipost.names
                                            ..cedula = _guiaDataSipost
                                                        .identification ==
                                                    null
                                                ? "1"
                                                : _guiaDataSipost.identification
                                            ..telefono =
                                                _guiaDataSipost.phone!.isEmpty
                                                    ? _edificio.telefono
                                                    : _guiaDataSipost.phone
                                            ..latitud = _edificio.lat
                                            ..longitud = _edificio.lng
                                            ..urlImagen =
                                                'https://google.maps...'
                                            ..isPorteria = 1
                                            ..observaciones =
                                                'Se entrega en porteria del edificio ${_edificio.edificio}'
                                            ..cedulaMensajero =
                                                _prefs.cedulaMensajero
                                            ..isMultiple = 1;

                                      // Agregar a Sqlite y a la lista.
                                      SqliteDB.db
                                          .crearCertificado(_certificado)
                                          .then((id) {
                                        setState(() {
                                          _certificado.id = id;
                                          _listaCertificados.add(_certificado);
                                          _buscando = false;
                                        });
                                        _guiaController.clear();
                                      }).catchError((e) {
                                        setState(() => _buscando = false);
                                      });
                                    });
                                  } else {
                                    setState(() => _buscando = false);
                                    showAlert(
                                      context,
                                      'Aviso',
                                      "Error al cargar: ${result['Message']}",
                                      TextButton(
                                        child: Text('ENTENDIDO'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      null,
                                    );
                                  }
                                }).catchError((error) {
                                  setState(() => _buscando = false);
                                  showErrorPopUp(context, error);
                                }).timeout(Duration(seconds: 180),
                                        onTimeout: () {
                                  setState(() => _buscando = false);
                                  timeoutPopUp(context);
                                });
                              } else {
                                setState(() => _buscando = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content:
                                        Text('Esta guía ya esta escaneada'),
                                  ),
                                );
                              }
                            }
                          } else if (valor.length > 13) {
                            codigoBarrasNoValidoPopUp(
                                context, _guiaController.text);
                            _guiaController.clear();
                            FocusScope.of(context).requestFocus(_guiaFocus);
                          }
                        },
                      ),
                      trailing: _butonEscanear(_scan),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _buscando,
              child: LoadingOverlay(
                title: "Consultando guía",
                content: "Por favor espere",
              ),
            ),
            ConnectionOverlay(
              internetConnection: !_internetConnection,
            ),
            Visibility(
                visible: _certificando,
                child: LoadingOverlay(
                    title: "Certificando", content: "Por favor espere")),
          ],
        ),
      ),
    );
  }

  _butonEscanear(ScanService _scan) {
    return IconButton(
      icon: Icon(Icons.photo_camera),
      onPressed: () async {
        // Detecta cuando la conexión a internet y notifica al usuario
        _guiaFocus.unfocus();
        if (!_internetConnection) {
          sinInternetPopUp(context);
        } else {
          // Limpia el campo y escanea
          _guiaController.clear();
          await _scan.scanBarcode();

          setState(() {
            _guiaController.text = _scan.scanResult;
            _buscando = true;
          });
          // Verifica si existe en la lista para agregarla
          var exist = _listaCertificados.firstWhere(
            (cert) => cert.guia == _guiaController.text,
            //orElse: () => null);
          );
          if (exist == null) {
            // Consulta los datos a SIPOST
            _consultaService
                .consultarGuia(
                    _guiaController.text, _prefs.cedulaMensajero, true, true)
                .then((result) {
              if (result["Message"] == "Exitoso") {
                setState(() {
                  _guiaDataSipost = SipostResponse.fromJson(result);

                  Certificado _certificado = new Certificado()
                    ..idEdificio = _edificio.id
                    ..hasFoto = 1
                    ..cargada = 0
                    ..imagenPath = _edificio.imagenPath
                    ..fecha = DateTime.now().toLocal().toString()
                    ..guia = _guiaController.text
                    ..nombres = _guiaDataSipost.names
                    ..cedula = _guiaDataSipost.identification == null
                        ? "1"
                        : _guiaDataSipost.identification
                    ..telefono = _guiaDataSipost.phone!.isEmpty
                        ? _edificio.telefono
                        : _guiaDataSipost.phone
                    ..latitud = _edificio.lat
                    ..longitud = _edificio.lng
                    ..urlImagen = 'https://google.maps...'
                    ..isPorteria = 1
                    ..observaciones =
                        'Se entrega en porteria del edificio ${_edificio.edificio}'
                    ..cedulaMensajero = _prefs.cedulaMensajero
                    ..isMultiple = 1;

                  // Agregar a Sqlite y a la lista.
                  SqliteDB.db.crearCertificado(_certificado).then((id) {
                    setState(() {
                      _certificado.id = id;
                      _listaCertificados.add(_certificado);
                      _buscando = false;
                    });
                    _guiaController.clear();
                  }).catchError((e) {
                    setState(() => _buscando = false);
                  });
                });
              } else if (result['Message'] == "la guia ya fue entregada") {
                setState(() => _buscando = false);
                guiaEntregadaPopUp(context, _guiaController.text);
              } else if (result['Message'] ==
                  'La guia corresponde a servicio solidario') {
                setState(() => _buscando = false);
                showAlert(
                  context,
                  'Aviso',
                  'La guia corresponde a Ingreso solidario',
                  TextButton(
                    child: Text('ENTENDIDO'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  null,
                );
              } else {
                setState(() => _buscando = false);
                showAlert(
                  context,
                  'Aviso',
                  "Error al cargar: ${result['Message']}",
                  TextButton(
                    child: Text('ENTENDIDO'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  null,
                );
              }
            }).timeout(Duration(seconds: 180), onTimeout: () {
              setState(() => _buscando = false);
              timeoutPopUp(context);
            });
          } else {
            setState(() => _buscando = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Esta guía ya esta escaneada'),
              ),
            );
          }
        }
      },
    );
  }

  certificarTodasLasEntregas(List<Certificado> listaCertificados) {
    listaCertificados.forEach((certificado) async {
      setState(() => _certificando = true);

      Map<String, dynamic> resp =
          await _certificadoService.generarCertificadoConImagen(
              File(_edificio.imagenPath),
              certificado.guia!,
              certificado.nombres!,
              certificado.cedula == null ? '1' : certificado.cedula!,
              _edificio.telefono,
              _edificio.lat.toString(),
              _edificio.lng.toString(),
              'https://maps.googleapis.com/maps/api/staticmap?center=${_edificio.lat},${_edificio.lng}&zoom=17&scale=2&size=400x120&maptype=roadmap&markers=${_edificio.lat},${_edificio.lng}',
              true,
              'Se entrega en porteria del edificio ${_edificio.edificio}',
              _prefs.cedulaMensajero,
              true);

      if (resp["Message"] == 'Ingresado Correctamente') {
        certificado.cargada = 1;
        await SqliteDB.db.actualizarCertificado(certificado);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Ingresado correctamente'),
          ),
        );
        setState(() {
          _certificando = false;
          _listaCertificados.remove(certificado);
        });
      } else if (resp["Message"] == "La guia ya fue entregada") {
        showAlert(
          context,
          'Ha habido un error',
          "La guia ya fue entregada",
          TextButton(
            child: Text('ENTENDIDO'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          null,
        );
        await SqliteDB.db.actualizarCertificado(certificado);
        setState(() {
          _certificando = false;
          _listaCertificados.remove(certificado);
        });
      } else if (resp["Message"] == "Ingresado , pero sin liquidacion") {
        await SqliteDB.db.actualizarCertificado(certificado);
        setState(() {
          _certificando = false;
          _listaCertificados.remove(certificado);
        });
        showAlert(
          context,
          'Ha habido un error',
          "Ingresado , pero sin liquidacion",
          TextButton(
            child: Text('ENTENDIDO'),
            onPressed: () {
              Navigator.pop(context);
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
              Navigator.pop(context);
            },
          ),
          null,
        );
      } else {
        setState(() => _certificando = false);
        showAlert(
          context,
          'Ha habido un error',
          resp["Message"],
          TextButton(
            child: Text('ENTENDIDO'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          null,
        );
      }
      if (_listaCertificados.isEmpty) {
        setState(() {
          _certificando = false;
        });
        Navigator.pushReplacementNamed(context, 'menu');
      }
    });
  }
}
