////import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:prueba_de_entrega/src/components/connection_overlay.dart';
import 'package:prueba_de_entrega/src/components/modals.dart';
import 'package:prueba_de_entrega/src/models/ingreso_solidario_model.dart';
import 'package:prueba_de_entrega/src/provider/ingreso_solidario_provider.dart';
import 'package:prueba_de_entrega/src/services/ingreso_solidario_service.dart';
import 'package:prueba_de_entrega/src/services/prefs.dart';
import 'package:prueba_de_entrega/src/services/scanner_service.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';

class ScanBarcodeISScreen extends StatefulWidget {
  @override
  _ScanBarcodeISScreenState createState() => _ScanBarcodeISScreenState();
}

class _ScanBarcodeISScreenState extends State<ScanBarcodeISScreen> {
  final _ingresoSolidarioService = IngresoSolidarioService();
  final _prefs = PreferenciasUsuario();

  bool _buscando = false;
  bool _internetConnection = true;
  IngresoSolidarioModel _guiaISDataSipost = new IngresoSolidarioModel();
  TextEditingController _guiaController = new TextEditingController();
  FocusNode _guiaFocus = new FocusNode();

  @override
  build(BuildContext context) {
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
            constraints: const BoxConstraints.expand(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            color: background,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    child: const Text(
                      'Escanea la guía',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Column(
                    children: <Widget>[
                      TextFormField(
                        autofocus: true,
                        focusNode: _guiaFocus,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        controller: _guiaController,
                        style: TextStyle(fontSize: 20.0),
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          hintText: '-------------',
                          prefixIcon: Icon(FontAwesomeIcons.barcode),
                        ),
                        onChanged: (valor) async {
                          if (valor.length == 13) {
                            _guiaController.text =
                                _guiaController.text.toUpperCase();
                            if (!_internetConnection) {
                              sinInternetPopUp(context);
                            } else {
                              setState(() => _buscando = true);

                              _ingresoSolidarioService
                                  .obtenerDatosGuiaIS(_guiaController.text,
                                      _prefs.cedulaMensajero)
                                  .then((result) {
                                if (result['Message'] == "Exitoso") {
                                  setState(() => _buscando = false);
                                  setState(() {
                                    _guiaISDataSipost =
                                        IngresoSolidarioModel.fromJson(result)
                                          ..barcode = _guiaController.text;
                                    Provider.of<IngresoSolidarioProvider>(
                                                context,
                                                listen: false)
                                            .ingresoSolidarioData =
                                        _guiaISDataSipost;
                                    _buscando = false;
                                  });
                                  Navigator.pushNamed(
                                      context, 'certificado_is');
                                } else {
                                  setState(() => _buscando = false);
                                  showAlert(
                                      context,
                                      'Información',
                                      result["Message"],
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('ENTENDIDO')),
                                      null);
                                }
                              }).catchError((error) {
                                setState(() => _buscando = false);
                                showErrorPopUp(context, error);
                              }).timeout(Duration(seconds: 180), onTimeout: () {
                                setState(() => _buscando = false);
                                timeoutPopUp(context);
                              });
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

                                setState(() =>
                                    _guiaController.text = _scan.scanResult);

                                if (_guiaController.text.length > 13 ||
                                    _guiaController.text.length < 13) {
                                  codigoBarrasNoValidoPopUp(
                                      context, _guiaController.text);
                                } else {
                                  setState(() => _buscando = true);
                                  _ingresoSolidarioService
                                      .obtenerDatosGuiaIS(_guiaController.text,
                                          _prefs.cedulaMensajero)
                                      .then((result) {
                                    if (result['Message'] == "Exitoso") {
                                      setState(() => _buscando = false);
                                      setState(() {
                                        _guiaISDataSipost =
                                            IngresoSolidarioModel.fromJson(
                                                result)
                                              ..barcode = _guiaController.text;
                                        Provider.of<IngresoSolidarioProvider>(
                                                    context,
                                                    listen: false)
                                                .ingresoSolidarioData =
                                            _guiaISDataSipost;
                                        _buscando = false;
                                      });

                                      Navigator.pushNamed(
                                          context, 'certificado_is');
                                    } else {
                                      setState(() {
                                        _buscando = false;
                                      });
                                      showAlert(
                                        context,
                                        'Información',
                                        result["Message"],
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('ENTENDIDO')),
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
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Solamente Ingreso Solidario',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
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
          ConnectionOverlay(
            internetConnection: !_internetConnection,
          ),
        ],
      ),
    );
  }
}
