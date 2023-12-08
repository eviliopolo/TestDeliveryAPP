import 'package:flutter/material.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:prueba_de_entrega/src/components/modals.dart';
//import 'package:prueba_de_entrega/src/models/data_sipost_model.dart';
import 'package:provider/provider.dart';
import 'package:prueba_de_entrega/src/provider/data_sipost_provider.dart';
import 'package:prueba_de_entrega/src/services/consulta_service.dart';
import 'package:prueba_de_entrega/src/services/prefs.dart';
import 'package:prueba_de_entrega/src/services/scanner_service.dart';

class ScanBarcodeScreen extends StatefulWidget {
  @override
  _ScanBarcodeScreenState createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  final _consulta = ConsultaService();
  final _prefs = PreferenciasUsuario();

  bool _buscando = false;
  bool _internetConnection = true;
  DataSipost _guiaDataSipost = new DataSipost();

  TextEditingController _guiaController = new TextEditingController();
  FocusNode _guiaFocus = new FocusNode();

  @override
  void dispose() {
    _guiaController.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    final bool isTelefonica =
        ModalRoute.of(context)!.settings.arguments == "telefonica"
            ? true
            : false;
    final bool isMailAmericas =
        ModalRoute.of(context)!.settings.arguments == "mail_americas"
            ? true
            : false;
    final _scan = Provider.of<ScanService>(context);

    final _connection = Provider.of<InternetConnectionStatus>(context);

    if (_connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (_connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Wrap(
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
            constraints: BoxConstraints.expand(),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            color: background,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    child: isTelefonica
                        ? Text(
                            'Escanea la guía de Telefónica',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          )
                        : Text(
                            'Escanea la guía',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                  ),
                  SizedBox(height: 10.0),
                  Column(
                    children: <Widget>[
                      TextFormField(
                        autofocus: true,
                        focusNode: _guiaFocus,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: _prefs.busquedaAuto
                            ? TextInputAction.done
                            : TextInputAction.search,
                        controller: _guiaController,
                        style: TextStyle(fontSize: 20.0),
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          hintText: '-------------',
                          prefixIcon: Icon(FontAwesomeIcons.barcode),
                        ),
                        onChanged: _prefs.busquedaAuto
                            ? (valor) async {
                                if (valor.length == 13) {
                                  _guiaFocus.unfocus();
                                  _guiaController.text =
                                      _guiaController.text.toUpperCase();

                                  if (!_internetConnection) {
                                    sinInternetPopUp(context);
                                  } else {
                                    setState(() => _buscando = true);
                                    if (isMailAmericas) {
                                      _consulta
                                          .obtenerDatosGuiaMailAmericas(
                                              _guiaController.text,
                                              _prefs.cedulaMensajero)
                                          .then((result) {
                                        if (result["Message"] == "Exitoso") {
                                          setState(() {
                                            _guiaDataSipost =
                                                DataSipost.fromJson(result)
                                                  ..barcode =
                                                      _guiaController.text;
                                            Provider.of<DataSipostProvider>(
                                                    context,
                                                    listen: false)
                                                .dataSipost = _guiaDataSipost;
                                            _buscando = false;
                                            _guiaController.clear();
                                          });

                                          Navigator.pushNamed(
                                              context, 'result_ma');
                                        } else {
                                          setState(() => _buscando = false);
                                          showAlert(context, 'Error',
                                              result["Message"], null, null);
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
                                      _consulta
                                          .obtenerDatosGuia(
                                              _guiaController.text,
                                              _prefs.cedulaMensajero)
                                          .then((result) {
                                        if (result["Message"] == "Exitoso") {
                                          setState(() {
                                            _guiaDataSipost =
                                                DataSipost.fromJson(result)
                                                  ..barcode =
                                                      _guiaController.text;
                                            Provider.of<DataSipostProvider>(
                                                    context,
                                                    listen: false)
                                                .dataSipost = _guiaDataSipost;
                                            _buscando = false;
                                            _guiaController.clear();
                                          });
                                          Navigator.pushNamed(
                                              context, 'result');
                                        } else if (result['Message'] ==
                                            "La guia ya fue entregada") {
                                          setState(() => _buscando = false);
                                          guiaEntregadaPopUp(
                                              context, _guiaController.text);
                                          _guiaController.clear();
                                        } else if (result['Message'] ==
                                            'La guia corresponde a servicio solidario') {
                                          setState(() => _buscando = false);
                                          avisoGuiaIngresoSolidario(context);
                                          _guiaController.clear();
                                        } else if (result['Message'] ==
                                            'La guia corresponde a telefonica') {
                                          setState(() => _buscando = false);
                                          avisoGuiaIsTelefonica(context);
                                          _guiaController.clear();
                                        } else {
                                          setState(() => _buscando = false);
                                          showAlert(context, 'Error',
                                              result["Message"], null, null);
                                        }
                                      }).catchError((error) {
                                        setState(() => _buscando = false);
                                        showErrorPopUp(context, error);
                                      }).timeout(Duration(seconds: 180),
                                              onTimeout: () {
                                        setState(() => _buscando = false);
                                        timeoutPopUp(context);
                                      });
                                    }
                                  }
                                } else if (valor.length > 13) {
                                  codigoBarrasNoValidoPopUp(
                                      context, _guiaController.text);
                                  _guiaController.clear();
                                }
                              }
                            : null,
                        onFieldSubmitted: (valor) async {
                          if (valor.length == 13) {
                            _guiaFocus.unfocus();
                            _guiaController.text =
                                _guiaController.text.toUpperCase();
                            if (!_internetConnection) {
                              sinInternetPopUp(context);
                            } else {
                              setState(() => _buscando = true);
                              if (isTelefonica) {
                                _consulta
                                    .obtenerDatosGuiaTelefonica(
                                        _guiaController.text,
                                        _prefs.cedulaMensajero)
                                    .then((result) {
                                  if (result['Message'] == "Exitoso") {
                                    setState(() {
                                      _guiaDataSipost =
                                          DataSipost.fromJson(result)
                                            ..barcode = _guiaController.text;
                                      Provider.of<DataSipostProvider>(context,
                                              listen: false)
                                          .dataSipost = _guiaDataSipost;
                                      _buscando = false;
                                      _guiaController.clear();
                                    });
                                    Navigator.pushNamed(context, 'result');
                                  } else if (result['Message'] ==
                                      'La guia ya fue entregada') {
                                    setState(() => _buscando = false);
                                    guiaEntregadaPopUp(
                                        context, _guiaController.text);
                                    _guiaController.clear();
                                  } else if (result['Message'] ==
                                      'La guia corresponde a servicio solidario') {
                                    setState(() => _buscando = false);
                                    avisoGuiaIngresoSolidario(context);
                                    _guiaController.clear();
                                  } else if (result['Message'] ==
                                      'La guia no corresponde a telefónica') {
                                    setState(() => _buscando = false);
                                    avisoGuiaIsNotTelefonica(context);
                                    _guiaController.clear();
                                  } else {
                                    setState(() => _buscando = false);
                                    showErrorPopUp(context, result['Message']);
                                  }
                                }).catchError((error) {
                                  setState(() => _buscando = false);
                                  showErrorPopUp(context, error);
                                }).timeout(Duration(seconds: 180),
                                        onTimeout: () {
                                  setState(() => _buscando = false);
                                  timeoutPopUp(context);
                                });
                              } else if (isMailAmericas) {
                                _consulta
                                    .obtenerDatosGuiaMailAmericas(
                                        _guiaController.text,
                                        _prefs.cedulaMensajero)
                                    .then((result) {
                                  if (result["Message"] == "Exitoso") {
                                    setState(() {
                                      _guiaDataSipost =
                                          DataSipost.fromJson(result)
                                            ..barcode = _guiaController.text;
                                      Provider.of<DataSipostProvider>(context,
                                              listen: false)
                                          .dataSipost = _guiaDataSipost;
                                      _buscando = false;
                                      _guiaController.clear();
                                    });

                                    Navigator.pushNamed(context, 'result_ma');
                                  } else {
                                    setState(() => _buscando = false);
                                    showAlert(context, 'Error',
                                        result["Message"], null, null);
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
                                _consulta
                                    .obtenerDatosGuia(_guiaController.text,
                                        _prefs.cedulaMensajero)
                                    .then((result) {
                                  if (result["Message"] == "Exitoso") {
                                    setState(() {
                                      _guiaDataSipost =
                                          DataSipost.fromJson(result)
                                            ..barcode = _guiaController.text;
                                      Provider.of<DataSipostProvider>(context,
                                              listen: false)
                                          .dataSipost = _guiaDataSipost;
                                      _buscando = false;
                                      _guiaController.clear();
                                    });
                                    if (!_guiaDataSipost.isCertificado) {
                                      Navigator.pushNamed(
                                          context, 'certificado');
                                    } else {
                                      Navigator.pushNamed(context, 'result');
                                    }
                                  } else if (result['Message'] ==
                                      "La guia ya fue entregada") {
                                    setState(() => _buscando = false);
                                    guiaEntregadaPopUp(
                                        context, _guiaController.text);
                                    _guiaController.clear();
                                  } else if (result['Message'] ==
                                      'La guia corresponde a servicio solidario') {
                                    setState(() => _buscando = false);
                                    avisoGuiaIngresoSolidario(context);
                                    _guiaController.clear();
                                  } else if (result['Message'] ==
                                      'La guia corresponde a telefonica') {
                                    setState(() => _buscando = false);
                                    avisoGuiaIsTelefonica(context);
                                    _guiaController.clear();
                                  } else {
                                    setState(() => _buscando = false);
                                    showAlert(context, 'Error',
                                        result["Message"], null, null);
                                  }
                                }).catchError((error) {
                                  setState(() => _buscando = false);
                                  showErrorPopUp(context, error);
                                }).timeout(Duration(seconds: 180),
                                        onTimeout: () {
                                  setState(() => _buscando = false);
                                  timeoutPopUp(context);
                                });
                              }
                            }
                          } else if (valor.length > 13) {
                            codigoBarrasNoValidoPopUp(
                                context, _guiaController.text);
                            _guiaController.clear();
                          }
                        },
                      ),
                      SizedBox(height: 8.0),
                      Visibility(
                        visible: !_prefs.lectorExterno,
                        child: Container(
                          width: double.infinity,
                          height: 52.0,
                          child: MaterialButton(
                            color: blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Text(
                              'ESCANEAR',
                              style: TextStyle(
                                  color: white, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              if (!_internetConnection) {
                                sinInternetPopUp(context);
                              } else {
                                _guiaController.clear();
                                await _scan.scanBarcode();

                                setState(() {
                                  _guiaController.text = _scan.scanResult;
                                });

                                if (_guiaController.text.length > 13 ||
                                    _guiaController.text.length < 13) {
                                  codigoBarrasNoValidoPopUp(
                                      context, _guiaController.text);
                                } else {
                                  _guiaFocus.unfocus();
                                  if (!_prefs.busquedaAuto) return;
                                  setState(() => _buscando = true);
                                  if (isTelefonica) {
                                    _consulta
                                        .obtenerDatosGuiaTelefonica(
                                            _guiaController.text,
                                            _prefs.cedulaMensajero)
                                        .then((result) {
                                      if (result['Message'] == "Exitoso") {
                                        setState(() {
                                          _guiaDataSipost =
                                              DataSipost.fromJson(result)
                                                ..barcode =
                                                    _guiaController.text;
                                          Provider.of<DataSipostProvider>(
                                                  context,
                                                  listen: false)
                                              .dataSipost = _guiaDataSipost;
                                          _buscando = false;
                                          _guiaController.clear();
                                        });
                                        Navigator.pushNamed(context, 'result');
                                      } else if (result['Message'] ==
                                          'La guia ya fue entregada') {
                                        setState(() => _buscando = false);
                                        guiaEntregadaPopUp(
                                            context, _guiaController.text);
                                        _guiaController.clear();
                                      } else if (result['Message'] ==
                                          'La guia corresponde a servicio solidario') {
                                        setState(() => _buscando = false);
                                        avisoGuiaIngresoSolidario(context);
                                        _guiaController.clear();
                                      } else if (result['Message'] ==
                                          'La guia no corresponde a telefónica') {
                                        setState(() => _buscando = false);
                                        avisoGuiaIsNotTelefonica(context);
                                        _guiaController.clear();
                                      } else {
                                        setState(() => _buscando = false);
                                        showErrorPopUp(
                                            context, result['Message']);
                                      }
                                    }).catchError((error) {
                                      setState(() => _buscando = false);
                                      showErrorPopUp(context, error);
                                    }).timeout(Duration(seconds: 180),
                                            onTimeout: () {
                                      setState(() => _buscando = false);
                                      timeoutPopUp(context);
                                    });
                                  } else if (isMailAmericas) {
                                    _consulta
                                        .obtenerDatosGuiaMailAmericas(
                                            _guiaController.text,
                                            _prefs.cedulaMensajero)
                                        .then((result) {
                                      if (result["Message"] == "Exitoso") {
                                        setState(() {
                                          _guiaDataSipost =
                                              DataSipost.fromJson(result)
                                                ..barcode =
                                                    _guiaController.text;
                                          Provider.of<DataSipostProvider>(
                                                  context,
                                                  listen: false)
                                              .dataSipost = _guiaDataSipost;
                                          _buscando = false;
                                          _guiaController.clear();
                                        });

                                        Navigator.pushNamed(
                                            context, 'result_ma');
                                      } else {
                                        setState(() => _buscando = false);
                                        showAlert(context, 'Error',
                                            result["Message"], null, null);
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
                                    _consulta
                                        .obtenerDatosGuia(_guiaController.text,
                                            _prefs.cedulaMensajero)
                                        .then((result) {
                                      if (result["Message"] == "Exitoso") {
                                        setState(() {
                                          _guiaDataSipost =
                                              DataSipost.fromJson(result)
                                                ..barcode =
                                                    _guiaController.text;
                                          Provider.of<DataSipostProvider>(
                                                  context,
                                                  listen: false)
                                              .dataSipost = _guiaDataSipost;
                                          _buscando = false;
                                          _guiaController.clear();
                                        });
                                        if (!_guiaDataSipost.isCertificado) {
                                          Navigator.pushNamed(
                                              context, 'certificado');
                                        } else {
                                          Navigator.pushNamed(
                                              context, 'result');
                                        }
                                      } else if (result['Message'] ==
                                          "La guia ya fue entregada") {
                                        setState(() => _buscando = false);
                                        guiaEntregadaPopUp(
                                            context, _guiaController.text);
                                        _guiaController.clear();
                                      } else if (result['Message'] ==
                                          'La guia corresponde a servicio solidario') {
                                        setState(() => _buscando = false);
                                        avisoGuiaIngresoSolidario(context);
                                        _guiaController.clear();
                                      } else if (result['Message'] ==
                                          'La guia corresponde a telefonica') {
                                        setState(() => _buscando = false);
                                        avisoGuiaIsTelefonica(context);
                                        _guiaController.clear();
                                      } else {
                                        setState(() => _buscando = false);
                                        showAlert(context, 'Error',
                                            result["Message"], null, null);
                                      }
                                    }).catchError((error) {
                                      setState(() => _buscando = false);
                                      showErrorPopUp(context, error);
                                    }).timeout(Duration(seconds: 180),
                                            onTimeout: () {
                                      setState(() => _buscando = false);
                                      timeoutPopUp(context);
                                    });
                                  }
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Visibility(
                        visible: !_prefs.busquedaAuto,
                        child: Container(
                          width: double.infinity,
                          height: 52.0,
                          child: MaterialButton(
                            color: blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Text(
                              'BUSCAR',
                              style: TextStyle(
                                  color: white, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              if (_guiaController.text.length == 13) {
                                _guiaFocus.unfocus();
                                _guiaController.text =
                                    _guiaController.text.toUpperCase();
                                if (!_internetConnection) {
                                  sinInternetPopUp(context);
                                } else {
                                  setState(() => _buscando = true);
                                  if (isTelefonica) {
                                    _consulta
                                        .obtenerDatosGuiaTelefonica(
                                            _guiaController.text,
                                            _prefs.cedulaMensajero)
                                        .then((result) {
                                      if (result['Message'] == "Exitoso") {
                                        setState(() {
                                          _guiaDataSipost =
                                              DataSipost.fromJson(result)
                                                ..barcode =
                                                    _guiaController.text;
                                          Provider.of<DataSipostProvider>(
                                                  context,
                                                  listen: false)
                                              .dataSipost = _guiaDataSipost;
                                          _buscando = false;
                                          _guiaController.clear();
                                        });
                                        Navigator.pushNamed(context, 'result');
                                      } else if (result['Message'] ==
                                          'La guia ya fue entregada') {
                                        setState(() => _buscando = false);
                                        guiaEntregadaPopUp(
                                            context, _guiaController.text);
                                        _guiaController.clear();
                                      } else if (result['Message'] ==
                                          'La guia corresponde a servicio solidario') {
                                        setState(() => _buscando = false);
                                        avisoGuiaIngresoSolidario(context);
                                        _guiaController.clear();
                                      } else if (result['Message'] ==
                                          'La guia no corresponde a telefónica') {
                                        setState(() => _buscando = false);
                                        avisoGuiaIsNotTelefonica(context);
                                        _guiaController.clear();
                                      } else {
                                        setState(() => _buscando = false);
                                        showErrorPopUp(
                                            context, result['Message']);
                                      }
                                    }).catchError((error) {
                                      setState(() => _buscando = false);
                                      showErrorPopUp(context, error);
                                    }).timeout(Duration(seconds: 180),
                                            onTimeout: () {
                                      setState(() => _buscando = false);
                                      timeoutPopUp(context);
                                    });
                                  } else if (isMailAmericas) {
                                    _consulta
                                        .obtenerDatosGuiaMailAmericas(
                                            _guiaController.text,
                                            _prefs.cedulaMensajero)
                                        .then((result) {
                                      if (result["Message"] == "Exitoso") {
                                        setState(() {
                                          _guiaDataSipost =
                                              DataSipost.fromJson(result)
                                                ..barcode =
                                                    _guiaController.text;
                                          Provider.of<DataSipostProvider>(
                                                  context,
                                                  listen: false)
                                              .dataSipost = _guiaDataSipost;
                                          _buscando = false;
                                          _guiaController.clear();
                                        });

                                        Navigator.pushNamed(
                                            context, 'result_ma');
                                      } else {
                                        setState(() => _buscando = false);
                                        showAlert(context, 'Error',
                                            result["Message"], null, null);
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
                                    _consulta
                                        .obtenerDatosGuia(_guiaController.text,
                                            _prefs.cedulaMensajero)
                                        .then((result) {
                                      if (result["Message"] == "Exitoso") {
                                        setState(() {
                                          _guiaDataSipost =
                                              DataSipost.fromJson(result)
                                                ..barcode =
                                                    _guiaController.text;
                                          Provider.of<DataSipostProvider>(
                                                  context,
                                                  listen: false)
                                              .dataSipost = _guiaDataSipost;
                                          _buscando = false;
                                          _guiaController.clear();
                                        });
                                        if (!_guiaDataSipost.isCertificado) {
                                          Navigator.pushNamed(
                                              context, 'certificado');
                                        } else {
                                          Navigator.pushNamed(
                                              context, 'result');
                                        }
                                      } else if (result['Message'] ==
                                          "La guia ya fue entregada") {
                                        setState(() => _buscando = false);
                                        guiaEntregadaPopUp(
                                            context, _guiaController.text);
                                        _guiaController.clear();
                                      } else if (result['Message'] ==
                                          'La guia corresponde a servicio solidario') {
                                        setState(() => _buscando = false);
                                        avisoGuiaIngresoSolidario(context);
                                        _guiaController.clear();
                                      } else if (result['Message'] ==
                                          'La guia corresponde a telefonica') {
                                        setState(() => _buscando = false);
                                        avisoGuiaIsTelefonica(context);
                                        _guiaController.clear();
                                      } else {
                                        setState(() => _buscando = false);
                                        showAlert(context, 'Error',
                                            result["Message"], null, null);
                                      }
                                    }).catchError((error) {
                                      setState(() => _buscando = false);
                                      showErrorPopUp(context, error);
                                    }).timeout(Duration(seconds: 180),
                                            onTimeout: () {
                                      setState(() => _buscando = false);
                                      timeoutPopUp(context);
                                    });
                                  }
                                }
                              } else if (_guiaController.text.length > 13) {
                                codigoBarrasNoValidoPopUp(
                                    context, _guiaController.text);
                                _guiaController.clear();
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _buscando,
            child: Container(
              constraints: BoxConstraints.expand(),
              color: Colors.white60,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(blue)),
                    SizedBox(height: 16.0),
                    Text(
                      'Consultando datos',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Por favor espere...',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: !_internetConnection,
            child: Container(
              constraints: BoxConstraints.expand(),
              color: Colors.white60,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.cloud_off, size: 120, color: blue),
                    SizedBox(height: 16.0),
                    Text(
                      'Sin internet',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Revisa tu plan de internet',
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
    );
  }
}
