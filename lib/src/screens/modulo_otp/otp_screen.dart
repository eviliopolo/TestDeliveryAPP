////import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/connection_overlay.dart';
import 'package:LIQYAPP/src/components/modals.dart';
import 'package:LIQYAPP/src/provider/data_sipost_provider.dart';
import 'package:LIQYAPP/src/services/consulta_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class OTPValidateScreen extends StatefulWidget {
  @override
  _OTPValidateScreenState createState() => _OTPValidateScreenState();
}

class _OTPValidateScreenState extends State<OTPValidateScreen> {
  final _consultaService = ConsultaService();
  final _prefs = PreferenciasUsuario();

  TextEditingController _one = new TextEditingController();
  TextEditingController _two = new TextEditingController();
  TextEditingController _three = new TextEditingController();
  TextEditingController _four = new TextEditingController();
  TextEditingController _five = new TextEditingController();
  TextEditingController _six = new TextEditingController();

  FocusNode _oneFocus = new FocusNode();
  FocusNode _twoFocus = new FocusNode();
  FocusNode _threeFocus = new FocusNode();
  FocusNode _fourFocus = new FocusNode();
  FocusNode _fiveFocus = new FocusNode();
  FocusNode _sixFocus = new FocusNode();

  bool _buscando = false;
  bool _internetConnection = true;

  @override
  Widget build(BuildContext context) {
    final _sipostProvider =
        Provider.of<DataSipostProvider>(context, listen: false);

    final _connection = Provider.of<InternetConnectionStatus>(context);

    if (_connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (_connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

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
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 14.0),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Ingrese el número de verificación',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Flexible(
                            child: TextField(
                                controller: _one,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0))),
                                focusNode: _oneFocus,
                                onChanged: (valor) {
                                  if (valor.length == 1) {
                                    _oneFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_twoFocus);
                                  }
                                })),
                        SizedBox(width: 4.0),
                        Flexible(
                            child: TextField(
                                controller: _two,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0))),
                                focusNode: _twoFocus,
                                onChanged: (valor) {
                                  if (valor.length == 1) {
                                    _twoFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_threeFocus);
                                  }
                                })),
                        SizedBox(width: 4.0),
                        Flexible(
                            child: TextField(
                                controller: _three,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0))),
                                focusNode: _threeFocus,
                                onChanged: (valor) {
                                  if (valor.length == 1) {
                                    _threeFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_fourFocus);
                                  }
                                })),
                        SizedBox(width: 4.0),
                        Flexible(
                            child: TextField(
                                controller: _four,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0))),
                                focusNode: _fourFocus,
                                onChanged: (valor) {
                                  if (valor.length == 1) {
                                    _fourFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_fiveFocus);
                                  }
                                })),
                        SizedBox(width: 4.0),
                        Flexible(
                            child: TextField(
                                controller: _five,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0))),
                                focusNode: _fiveFocus,
                                onChanged: (valor) {
                                  if (valor.length == 1) {
                                    _fiveFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_sixFocus);
                                  }
                                })),
                        SizedBox(width: 4.0),
                        Flexible(
                            child: TextField(
                                controller: _six,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0))),
                                focusNode: _sixFocus,
                                onChanged: (valor) {
                                  if (valor.length == 1) {
                                    _sixFocus.unfocus();
                                  }
                                })),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      width: double.infinity,
                      child: MaterialButton(
                        color: yellow,
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Text(
                          'Validar el código',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          final String code = _one.text +
                              _two.text +
                              _three.text +
                              _four.text +
                              _five.text +
                              _six.text;
                          if (code.length < 6) {
                            codigoOtpCortoPopUp(context);
                          } else {
                            setState(() => _buscando = true);
                            _consultaService
                                .comprobarGuiaOtp(_sipostProvider.barcode,
                                    _prefs.cedulaMensajero, code)
                                .then((resp) {
                              if (resp['Message'] == 'Exitoso') {
                                setState(() => _buscando = false);
                                codigoOtpCorrectoPopUp(context);
                              } else {
                                setState(() => _buscando = false);
                                codigoOtpIncorrectoPopUp(context);
                              }
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '¿No ha llegado el sms?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: double.infinity,
                      child: MaterialButton(
                        color: Color.fromRGBO(230, 230, 230, 1.0),
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Text(
                          'Intente nuevamente',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          setState(() => _buscando = true);
                          _consultaService
                              .enviarOTP(
                                  _sipostProvider.barcode,
                                  _prefs.cedulaMensajero,
                                  _sipostProvider.sipostResponse.phone!)
                              .then((resp) {
                            print(resp);
                            setState(() => _buscando = false);
                            if (resp["Message"] ==
                                "Codigo enviado exitosamente") {
                              codigoOtpEnviadoPopUp(context,
                                  _sipostProvider.sipostResponse.phone!);
                            } else if (resp['Message'] ==
                                "sobrepaso los intentos de envios") {
                              intentosExcedidosPopUp(context);
                            }
                          });
                        },
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
                      CircularProgressIndicator(),
                      SizedBox(height: 16.0),
                      Text(
                        'Validando codigo de seguridad...',
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
        ));
  }
}
