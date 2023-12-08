//import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:prueba_de_entrega/src/components/card_resultado_sipost.dart';
import 'package:prueba_de_entrega/src/components/connection_overlay.dart';
import 'package:prueba_de_entrega/src/components/loading_overlay.dart';
import 'package:prueba_de_entrega/src/models/sipost_response.dart';
import 'package:prueba_de_entrega/src/provider/data_sipost_provider.dart';
//import 'package:prueba_de_entrega/src/services/connection_service.dart';
import 'package:prueba_de_entrega/src/services/consulta_service.dart';
import 'package:prueba_de_entrega/src/services/prefs.dart';
import 'package:prueba_de_entrega/src/services/scanner_service.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';

class ScanModuleScreen extends StatefulWidget {
  const ScanModuleScreen({super.key});

  @override
  _ScanModuleScreenState createState() => _ScanModuleScreenState();
}

class _ScanModuleScreenState extends State<ScanModuleScreen> {
  final _prefs = PreferenciasUsuario();

  final TextEditingController _guiaController = TextEditingController();
  final FocusNode _guiaFocus = FocusNode();
  bool? _isPorteria;
  bool _internetConnection = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _sipostProvider =
        Provider.of<DataSipostProvider>(context, listen: false);
    final _scanService = Provider.of<ScanService>(context, listen: false);

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
            color: background,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: (_sipostProvider.barcode.length == 13)
                        ? FutureBuilder<Map<String, dynamic>>(
                            future: (_sipostProvider.barcode.length == 13)
                                ? ConsultaService().consultarGuia(
                                    _guiaController.text,
                                    _prefs.cedulaMensajero,
                                    false,
                                    _isPorteria ?? false)
                                : null,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                //print("Future response: ${snapshot.data}");

                                SipostResponse sipostResponse =
                                    SipostResponse.fromJson(snapshot.data!);
                                if (sipostResponse.response!) {
                                  _sipostProvider.sipostResponse =
                                      sipostResponse;
                                  _guiaFocus.unfocus();
                                  return SingleChildScrollView(
                                    padding: EdgeInsets.all(8.0),
                                    child: CardResultadoSipost(
                                        _sipostProvider.barcode),
                                  );
                                } else {
                                  return Center(
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.all(30.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const Text(
                                            "Aviso",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Custom"),
                                          ),
                                          Text(
                                            sipostResponse.message!,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                _guiaFocus.unfocus();
                                return LoadingOverlay(
                                  title: "Consultando Guia",
                                  content: "Por favor espere",
                                );
                              }
                            },
                          )
                        : Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 50.0),
                                  SvgPicture.asset(
                                      "assets/images/scan-icon.svg"),
                                  SizedBox(height: 8.0),
                                  const Text("Escanea el número de guía",
                                      style: TextStyle(
                                          fontFamily: "Custom",
                                          fontSize: 18.0)),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: white, boxShadow: [
                    BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.4),
                        offset: Offset(0.0, -0.0),
                        blurRadius: 5.0)
                  ]),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(6.0),
                    selected: true,
                    title: Form(
                      child: TextFormField(
                        textCapitalization: TextCapitalization.characters,
                        style: TextStyle(fontSize: 14.0),
                        controller: _guiaController,
                        focusNode: _guiaFocus,
                        decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            hintText: "NÚMERO DE GUÍA",
                            suffixIcon: _sipostProvider.barcode.length > 0
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      _sipostProvider.barcode = "";
                                      _guiaController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null),
                        onChanged: (valor) async {
                          if (valor.length == 13) {
                            _isPorteria = await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    //"¿Entrega en Portería?",
                                    "¿Desea continuar?",
                                    style: TextStyle(fontFamily: "Bold"),
                                  ),
                                  content: Text("Seleccione una opción"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("SI"),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                    TextButton(
                                      child: Text("NO"),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            setState(() => _sipostProvider.barcode = valor);
                          }
                        },
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.photo_camera,
                      ),
                      onPressed: () async {
                        await _scanService.scanBarcode();
                        _isPorteria = await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                //"¿Entrega en Portería?",
                                "¿Desea continuar?",
                                style: TextStyle(fontFamily: "Bold"),
                              ),
                              content: Text("Seleccione una opción"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("SI"),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                ),
                                TextButton(
                                  child: Text("NO"),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        _sipostProvider.barcode = _scanService.scanResult;
                        _guiaController.text = _scanService.scanResult;
                        setState(() {});
                      },
                    ),
                  ),
                )
              ],
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
