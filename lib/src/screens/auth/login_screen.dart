////import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/connection_overlay.dart';
import 'package:LIQYAPP/src/components/loading_overlay.dart';
import 'package:LIQYAPP/src/components/modals.dart';
import 'package:LIQYAPP/src/services/auth_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _prefs = PreferenciasUsuario();
  final _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController cedulaController = TextEditingController();
  TextEditingController passController = TextEditingController();
  final FocusNode _cedulaFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  bool _cargando = false;
  bool _internetConnection = true;

  final styleText =
      const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  @override
  void dispose() {
    cedulaController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connection = InternetConnectionChecker().connectionStatus;

    if (connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: const Color.fromRGBO(7, 69, 149, 1),
        body: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height - 80,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SafeArea(
                child: SingleChildScrollView(
                  //padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              Expanded(
                                flex: 3,
                                child: SvgPicture.asset(
                                    "assets/icons/logo-4-72.svg"),
                              ),
                              const Spacer(),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          Expanded(
                            flex: 10,
                            child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      style:
                                          const TextStyle(color: Colors.white),
                                      focusNode: _cedulaFocus,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      cursorColor: Colors.white,
                                      decoration: const InputDecoration(
                                        filled: false,
                                        fillColor: Colors.white,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              style: BorderStyle.solid,
                                              color: Colors.yellow),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              style: BorderStyle.solid,
                                              color: Colors.red),
                                        ),
                                        isDense: false,
                                        hintText: "Usuario",
                                        hintStyle: TextStyle(
                                            color: Color.fromARGB(
                                                255, 144, 170, 183)),
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.yellow,
                                          ),
                                        ),
                                        errorStyle:
                                            TextStyle(color: Colors.yellow),
                                      ),
                                      onFieldSubmitted: (value) {
                                        _cedulaFocus.unfocus();
                                        FocusScope.of(context)
                                            .requestFocus(_passFocus);
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          cedulaController.text = value;
                                        });
                                      },
                                      validator: (valor) {
                                        if (valor!.isEmpty) {
                                          return 'Ingrese su nombre de usuario.';
                                        }
                                        return null;
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: Colors.white),
                                        focusNode: _passFocus,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        textInputAction: TextInputAction.done,
                                        obscureText: true,
                                        cursorColor: Colors.white,
                                        decoration: const InputDecoration(
                                            filled: false,
                                            fillColor: Colors.white,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.yellow),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  style: BorderStyle.solid,
                                                  color: Colors.red),
                                            ),
                                            hintStyle: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 144, 170, 183)),
                                            hintText: "Contraseña",
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Icon(Icons.lock,
                                                  color: Colors.yellow),
                                            ),
                                            errorStyle: TextStyle(
                                                color: Colors.yellow)),
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
                                            passController.text = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    ElevatedButton(
                                      child: Text(
                                        "Ingresar".toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      onPressed: () async {
                                        _passFocus.unfocus();
                                        _cedulaFocus.unfocus();
                                        bool hasConnection =
                                            await InternetConnectionChecker()
                                                .hasConnection;
                                        if (hasConnection) {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() => _cargando = true);
                                            _auth
                                                .login(cedulaController.text,
                                                    passController.text)
                                                .then((resp) {
                                              if (resp != null &&
                                                  resp['token'] != null) {
                                                setState(() {
                                                  _cargando = false;
                                                  _prefs.cedulaMensajero =
                                                      '72245215';
                                                  _prefs.logged = true;
                                                  _prefs.usuarioSipost =
                                                      cedulaController.text;
                                                });
                                                Navigator.pushReplacementNamed(
                                                    context, 'menu');
                                              } else {
                                                setState(
                                                    () => _cargando = false);
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
                                            }).timeout(
                                                    const Duration(
                                                        seconds: 180),
                                                    onTimeout: () {
                                              setState(() => _cargando = false);
                                              timeoutPopUp(context);
                                            });
                                          }
                                        } else {
                                          setState(() => _cargando = false);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'No hay conexión a internet'),
                                          ));
                                          showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: (context) {
                                                return const AlertDialog(
                                                  title: Text(
                                                    'Importante',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  content: Text(
                                                      'No hay conexión a internet'),
                                                );
                                              });
                                          return;
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 34.0),
                                    const Text(
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                      'Señor Distribuidor. No olvide informar a la persona que  recibe el envío que todos los datos suministrados durante este proceso serán tratados bajo la política de protección y tratamiento de datos personales de  4-72',
                                      textAlign: TextAlign.justify,
                                    )
                                  ],
                                )),
                          ),
                          const Spacer(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: _cargando,
                  child: const LoadingOverlay(
                      title: "Iniciando sesión", content: "Por favor espera")),
              ConnectionOverlay(
                internetConnection: !_internetConnection,
              ),
            ],
          ),
        ));
  }
}
