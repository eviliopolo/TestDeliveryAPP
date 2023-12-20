import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/card_resultado_sipost.dart';
import 'package:LIQYAPP/src/components/connection_overlay.dart';
import 'package:LIQYAPP/src/components/loading_overlay.dart';
import 'package:LIQYAPP/src/models/sipost_response.dart';
import 'package:LIQYAPP/src/provider/data_sipost_provider.dart';
import 'package:LIQYAPP/src/services/consulta_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/services/scanner_service.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class ScanModuleScreen extends StatefulWidget {
  const ScanModuleScreen({super.key});
  @override
  ScanModuleScreenState createState() => ScanModuleScreenState();
}

class ScanModuleScreenState extends State<ScanModuleScreen> {
  final _prefs = PreferenciasUsuario();

  final TextEditingController _guiaController = TextEditingController();
  final FocusNode _guiaFocus = FocusNode();
  bool? _isPorteria;
  bool _internetConnection = true;

  @override
  void initState() {
    super.initState();
    _guiaController.clear();
    final sipostProvider =
        Provider.of<DataSipostProvider>(context, listen: false);
    sipostProvider.clear();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sipostProvider =
        Provider.of<DataSipostProvider>(context, listen: false);

    final scanService = Provider.of<ScanService>(context, listen: false);
    final connection = Provider.of<InternetConnectionStatus>(context);

    if (connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(6, 69, 147, 1),
        foregroundColor: Colors.white,
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
                    child: (sipostProvider.barcode.length == 13)
                        ? FutureBuilder<Map<String, dynamic>>(
                            future: (sipostProvider.barcode.length == 13)
                                ? ConsultaService().consultarGuia(
                                    _guiaController.text,
                                    _prefs.cedulaMensajero,
                                    false,
                                    _isPorteria ?? false)
                                : null,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                SipostResponse sipostResponse =
                                    SipostResponse.fromJson(snapshot.data!);
                                if (sipostResponse.response!) {
                                  sipostProvider.sipostResponse =
                                      sipostResponse;
                                  _guiaFocus.unfocus();
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CardResultadoSipost(
                                        sipostProvider.barcode),
                                  );
                                } else {
                                  var message = "";
                                  if (sipostResponse.message!
                                      .contains('Modelo Invalido')) {
                                    message = "La guía tiene formato invalido";
                                  } else if (sipostResponse.message!
                                      .contains('Multiples')) {
                                    message =
                                        "Esta guia no se puede digitalizar";
                                  } else {
                                    message = sipostResponse.message!;
                                  }

                                  return Center(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(30.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const Text(
                                            "Importante:",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Custom"),
                                          ),
                                          Text(
                                            message,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                _guiaFocus.unfocus();
                                return const LoadingOverlay(
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
                                  const SizedBox(height: 50.0),
                                  SvgPicture.asset(
                                      "assets/images/scan-icon.svg"),
                                  const SizedBox(height: 8.0),
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
                        offset: const Offset(0.0, -0.0),
                        blurRadius: 5.0)
                  ]),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(6.0),
                    selected: true,
                    title: Form(
                      child: TextFormField(
                        autofocus: true,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontSize: 14.0),
                        controller: _guiaController,
                        focusNode: _guiaFocus,
                        decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            hintText: "NÚMERO DE GUÍA",
                            suffixIcon: sipostProvider.barcode.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      sipostProvider.barcode = "";
                                      _guiaController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null),
                        onChanged: (valor) async {
                          if (valor.length == 13) {
                            _isPorteria = true;
                            setState(() => sipostProvider.barcode = valor);
                          }
                        },
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.photo_camera,
                      ),
                      onPressed: () async {
                        await scanService.scanBarcode();
                        _isPorteria = true;
                        sipostProvider.barcode = scanService.scanResult;
                        _guiaController.text = scanService.scanResult;
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
