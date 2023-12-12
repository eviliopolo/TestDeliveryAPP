////import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/connection_overlay.dart';
import 'package:LIQYAPP/src/components/loading_overlay.dart';
import 'package:LIQYAPP/src/components/modals.dart';
import 'package:LIQYAPP/src/services/auth_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _prefs = PreferenciasUsuario();
  final _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _cedulaController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  FocusNode _cedulaFocus = FocusNode();
  FocusNode _passFocus = FocusNode();
  bool _cargando = false;
  bool _internetConnection = true;

  final styleText = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  @override
  void dispose() {
    _cedulaController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _connection = InternetConnectionChecker().connectionStatus;

    if (_connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (_connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: blue,
        title: Wrap(
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              'Servicios Postales Nacionales',
              style: TextStyle(
                  fontSize: 16.0, fontWeight: FontWeight.bold, color: white),
            ),
            Text(
              '#OperadorPostalOficial',
              style:
                  TextStyle(fontSize: 14.0, fontFamily: 'Light', color: white),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: 10.0),
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Inicio de sesión',
                      style: styleText,
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20.0),
                        TextFormField(
                          //initialValue: '72245215',
                          focusNode: _cedulaFocus,
                          // keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              labelText: 'Usuario',
                              hintText: 'Ingrese usuario'),
                          onFieldSubmitted: (value) {
                            _cedulaFocus.unfocus();
                            FocusScope.of(context).requestFocus(_passFocus);
                          },
                          onChanged: (value) {
                            setState(() {
                              _cedulaController.text = value;
                            });
                          },
                          validator: (valor) {
                            if (valor!.isEmpty) {
                              return 'Ingrese su nombre de usuario.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12.0),
                        TextFormField(
                          //initialValue: '72245215',
                          focusNode: _passFocus,
                          obscureText: true,
                          // keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              labelText: 'Contraseña',
                              hintText: 'Ingrese su contraseña'),
                          onFieldSubmitted: (value) {
                            _passFocus.unfocus();
                          },
                          validator: (valor) {
                            if (valor!.isEmpty) {
                              return 'Ingrese la contraseña';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _passController.text = value;
                            });
                          },
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 52.0,
                          width: double.infinity,
                          child: MaterialButton(
                            elevation: 0.0,
                            color: blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: Text(
                              'Ingresar',
                              style: TextStyle(
                                  color: white, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              bool _hasConnection =
                                  await InternetConnectionChecker()
                                      .hasConnection;
                              if (_hasConnection) {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _cargando = true);
                                  _auth
                                      .login(_cedulaController.text,
                                          _passController.text)
                                      .then((resp) {
                                    if (resp['token'] != null) {
                                      setState(() {
                                        _cargando = false;
                                        _prefs.cedulaMensajero = '72245215';
                                        _prefs.logged = true;
                                        _prefs.usuarioSipost =
                                            _cedulaController.text;
                                      });
                                      Navigator.pushReplacementNamed(
                                          context, 'menu');
                                    } else {
                                      setState(() => _cargando = false);
                                      showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context) {
                                            return const AlertDialog(
                                              title: Text(
                                                  'Error de inicio de sesión'),
                                              content: Text(
                                                  'Información no valida. comuniquese con el supervisor para más información.'),
                                            );
                                          });
                                    }
                                  }).catchError((error) {
                                    setState(() => _cargando = false);
                                  }).timeout(const Duration(seconds: 180),
                                          onTimeout: () {
                                    setState(() => _cargando = false);
                                    timeoutPopUp(context);
                                  });
                                }
                              } else {
                                setState(() => _cargando = false);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('No hay conexión a internet'),
                                ));
                                return;
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Señor Distribuidor. No olvide informar a la persona que  recibe el envío que todos los datos suministrados durante este proceso serán tratados bajo la política de protección y tratamiento de datos personales de  4-72',
                          textAlign: TextAlign.justify,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Visibility(
              visible: _cargando,
              child: LoadingOverlay(
                  title: "Iniciando sesión", content: "Por favor espera")),
          ConnectionOverlay(
            internetConnection: !_internetConnection,
          ),
        ],
      ),
    );
  }
}
