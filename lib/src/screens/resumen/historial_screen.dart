import 'dart:io';

//import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/connection_overlay.dart';
import 'package:LIQYAPP/src/components/loading_overlay.dart';
import 'package:LIQYAPP/src/components/modals.dart';
import 'package:LIQYAPP/src/provider/multientrega_provider.dart';
import 'package:LIQYAPP/src/search/certificado_search.dart';
import 'package:LIQYAPP/src/services/certificado_service.dart';
import 'package:LIQYAPP/src/services/consulta_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/services/sqlite_db.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class HistorialScreen extends StatefulWidget {
  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _certificadoService = CertificadoService();
  final _consultaService = ConsultaService();
  final _prefs = PreferenciasUsuario();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _internetConnection = true;
  bool _certificando = false;
  List<Certificado> _listaCertificados = [];
  List<Certificado> _listaNoCertificados = [];
  List<Certificado> _listaTodosCertificados = [];

  @override
  void initState() {
    super.initState();
    _consultaService
        .obtenerGuiasCertificadas(_prefs.cedulaMensajero)
        .then((resp) {
      final List listaTempCertificados = resp['GuiasCertificadas'];

      if (listaTempCertificados.isEmpty) {
        return _listaTodosCertificados = [];
      }

      listaTempCertificados.forEach((cert) {
        Certificado _certificado = new Certificado()
          ..guia = cert['Guia']
          ..fecha = cert['FechaEntrega']
          ..cargada = cert['IsLiquidado'] ? 1 : 0;
        _listaTodosCertificados.add(_certificado);
      });
      return _listaTodosCertificados;
    });
    SqliteDB.db.obtenerTodosCertificadosPorEstado(0).then((list) {
      if (list.isNotEmpty) {
        _listaTodosCertificados.addAll(list);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int _startTab = ModalRoute.of(context)!.settings.arguments as int;
    final _connection = Provider.of<InternetConnectionStatus>(context);

    if (_connection == InternetConnectionStatus.disconnected) {
      _internetConnection = false;
    } else if (_connection == InternetConnectionStatus.connected) {
      _internetConnection = true;
    }

    return DefaultTabController(
      initialIndex: _startTab,
      length: 2,
      child: Scaffold(
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CertificadoSearch(
                    listaCertificados: _listaTodosCertificados,
                  ),
                );
              },
            )
          ],
          bottom: TabBar(tabs: [
            Tab(
              child: Text('CERTIFICADAS'),
            ),
            Tab(
              child: Text('NO CERTIFICADAS'),
            )
          ]),
        ),
        body: Stack(
          children: <Widget>[
            TabBarView(
              children: <Widget>[
                _vistaCetrificados(),
                _vistaNoCertificados(),
              ],
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

  _vistaCetrificados() {
    return Container(
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      color: background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20.0),
          Container(
            width: double.infinity,
            child: Text(
              'Historial de entregas certificadas',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8.0),
          Flexible(
            flex: 1,
            child: FutureBuilder<Map<String, dynamic>>(
              future: _consultaService
                  .obtenerGuiasCertificadas(_prefs.cedulaMensajero),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                _listaCertificados.clear();

                final List listaTempCertificados =
                    snapshot.data!['GuiasCertificadas'];

                if (listaTempCertificados.isEmpty) {
                  return Center(
                      child: Text('No hay registros de entregas realizadas'));
                }

                listaTempCertificados.forEach((cert) {
                  Certificado _certificado = new Certificado()
                    ..guia = cert['Guia']
                    ..fecha = cert['FechaEntrega']
                    ..cargada = cert['IsLiquidado'] ? 1 : 0;
                  _listaCertificados.add(_certificado);
                });
                // return Container();

                return ListView.builder(
                    itemCount: _listaCertificados.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          color: !(_listaCertificados[i].cargada == 1)
                              ? red
                              : Colors.green,
                          padding: EdgeInsets.only(left: 4.0),
                          child: Material(
                            elevation: 2.0,
                            color: Colors.white,
                            child: ListTile(
                              dense: true,
                              leading: Icon(FontAwesomeIcons.barcode),
                              trailing: _listaCertificados[i].cargada == 1
                                  ? Icon(
                                      Icons.cloud_done,
                                      color: Colors.green,
                                    )
                                  : Icon(Icons.cloud_upload),
                              contentPadding: EdgeInsets.all(12.0),
                              title: Text(
                                '${_listaCertificados[i].guia}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Wrap(
                                  direction: Axis.vertical,
                                  children: <Widget>[
                                    Text(
                                      '${_listaCertificados[i].fecha}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    _listaCertificados[i].cargada == 1
                                        ? Text('Certificada')
                                        : Text('Sin certificar')
                                  ]),
                              isThreeLine: true,
                            ),
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  _vistaNoCertificados() {
    return Container(
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      color: background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20.0),
          Container(
            width: double.infinity,
            child: Text(
              'Historial de entregas sin certificar',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8.0),
          Flexible(
            flex: 1,
            child: FutureBuilder<List<Certificado>>(
              future: SqliteDB.db.obtenerTodosCertificadosPorEstado(0),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                _listaNoCertificados = snapshot.data!;

                if (_listaNoCertificados.isEmpty) {
                  return Center(
                      child:
                          Text('No hay registros de entregas sin certificar'));
                }

                return ListView.builder(
                    itemCount: _listaNoCertificados.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          color: _listaNoCertificados[i].cargada == 0
                              ? red
                              : Colors.green,
                          padding: EdgeInsets.only(left: 4.0),
                          child: Material(
                            elevation: 2.0,
                            color: Colors.white,
                            child: ListTile(
                              dense: true,
                              leading: _listaNoCertificados[i].hasFoto == 1
                                  ? Image.file(
                                      File(_listaNoCertificados[i].imagenPath!))
                                  : Image.asset(
                                      'assets/images/ic_launcher.png'),
                              contentPadding: EdgeInsets.all(12.0),
                              title: Text(
                                '${_listaNoCertificados[i].guia}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Wrap(
                                  direction: Axis.vertical,
                                  children: <Widget>[
                                    Text(
                                      '${_listaNoCertificados[i].fecha}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    _listaNoCertificados[i].cargada == 1
                                        ? Text('Certificada')
                                        : Text('Sin certificar')
                                  ]),
                              isThreeLine: true,
                              trailing: _listaNoCertificados[i].cargada == 1
                                  ? Icon(
                                      Icons.cloud_done,
                                      color: Colors.green,
                                    )
                                  : IconButton(
                                      icon: Icon(Icons.cloud_upload),
                                      onPressed: () {
                                        _certificarEntrega(
                                            _listaNoCertificados[i]);
                                      },
                                    ),
                            ),
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  _certificarEntrega(Certificado cert) async {
    setState(() => _certificando = true);

    if (_internetConnection) {
      if (cert.hasFoto == 1) {
        _certificadoService
            .generarCertificadoConImagen(
          File(cert.imagenPath!),
          cert.guia!,
          cert.nombres!,
          cert.cedula == null ? "1" : cert.cedula!,
          cert.telefono!.isEmpty ? "111111111" : cert.telefono!,
          cert.latitud.toString(),
          cert.longitud.toString(),
          'https://maps.googleapis.com/maps/api/staticmap?center=${cert.latitud},${cert.longitud}&zoom=17&scale=2&size=400x120&maptype=roadmap&markers=${cert.latitud},${cert.longitud}',
          cert.isPorteria == 1 ? true : false,
          cert.observaciones!,
          _prefs.cedulaMensajero,
          cert.isMultiple == 1 ? true : false,
        )
            .then((Map<String, dynamic> resp) async {
          if (resp["Message"] == 'Ingresado Correctamente') {
            setState(() => _certificando = false);
            Certificado _certificado = cert
              ..cargada = 1
              ..fecha = DateTime.now().toLocal().toString();

            await SqliteDB.db.actualizarCertificado(_certificado);
            setState(() => _listaNoCertificados.remove(cert));
            Provider.of<MultiEntregaProvider>(context, listen: false)
                .listaNoCertificado = _listaNoCertificados;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.check, color: white),
                  SizedBox(width: 4.0),
                  Text('Entrega certificada!'),
                ],
              ),
            ));
          } else if (resp["Message"] == "La guia ya fue entregada") {
            setState(() => _certificando = false);
            showAlert(
              context,
              'Ha habido un error',
              "La guia ya fue entregada",
              TextButton(
                child: Text('ENTENDIDO'),
                onPressed: () async {
                  Certificado _certificado = cert
                    ..cargada = 1
                    ..fecha = DateTime.now().toLocal().toString();

                  await SqliteDB.db.actualizarCertificado(_certificado);
                  setState(() => _listaNoCertificados.remove(cert));
                  Provider.of<MultiEntregaProvider>(context, listen: false)
                      .listaNoCertificado = _listaNoCertificados;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.green,
                    content: Wrap(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Icon(Icons.check, color: white),
                        Text("La guia ya fue entregada"),
                      ],
                    ),
                  ));
                },
              ),
              null,
            );
          } else if (resp["Message"] == "Ingresado , pero sin liquidacion") {
            setState(() => _certificando = false);
            showAlert(
              context,
              'Ha habido un error',
              "Ingresado , pero sin liquidacion",
              TextButton(
                child: Text('ENTENDIDO'),
                onPressed: () async {
                  Certificado _certificado = cert
                    ..cargada = 1
                    ..fecha = DateTime.now().toLocal().toString();

                  await SqliteDB.db.actualizarCertificado(_certificado);
                  setState(() => _listaNoCertificados.remove(cert));
                  Provider.of<MultiEntregaProvider>(context, listen: false)
                      .listaNoCertificado = _listaNoCertificados;

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.green,
                    content: Wrap(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Icon(Icons.check, color: white),
                        Text("Ingresado , pero sin liquidacion."),
                      ],
                    ),
                  ));
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
                onPressed: () async {
                  Certificado _certificado = cert
                    ..cargada = 1
                    ..fecha = DateTime.now().toLocal().toString();

                  await SqliteDB.db.actualizarCertificado(_certificado);
                  setState(() => _listaNoCertificados.remove(cert));
                  Provider.of<MultiEntregaProvider>(context, listen: false)
                      .listaNoCertificado = _listaNoCertificados;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.green,
                    content: Wrap(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Icon(Icons.check, color: white),
                        Text(
                            "No se encontro el cargue o el envío ya fue liquidado."),
                      ],
                    ),
                  ));
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
              null,
              null,
            );
          }
        }).catchError((error) {
          setState(() => _certificando = false);
          showErrorPopUp(context, error);
        }).timeout(Duration(seconds: 180), onTimeout: () {
          setState(() => _certificando = false);
          timeoutPopUp(context);
        });
      } else {
        _certificadoService
            .generarCertificado(
          cert.guia!,
          cert.nombres!,
          cert.cedula!,
          cert.telefono!,
          cert.latitud.toString(),
          cert.longitud.toString(),
          'https://maps.googleapis.com/maps/api/staticmap?center=${cert.latitud},${cert.longitud}&zoom=17&scale=2&size=400x120&maptype=roadmap&markers=${cert.latitud},${cert.longitud}',
          cert.isPorteria == 1 ? true : false,
          cert.observaciones!,
          _prefs.cedulaMensajero,
          cert.isMultiple == 1 ? true : false,
        )
            .then((resp) async {
          if (resp['Message'] == 'Ingresado Correctamente') {
            setState(() => _certificando = false);

            Certificado _certificado = cert
              ..cargada = 1
              ..fecha = DateTime.now().toLocal().toString();

            await SqliteDB.db.actualizarCertificado(_certificado);
            setState(() => _listaNoCertificados.remove(cert));
            Provider.of<MultiEntregaProvider>(context, listen: false)
                .listaNoCertificado = _listaNoCertificados;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Wrap(
                direction: Axis.horizontal,
                children: <Widget>[
                  Icon(Icons.check, color: white),
                  Text('Entrega certificada!'),
                ],
              ),
            ));
          } else {
            setState(() => _certificando = false);
            /*
            bool read = await _mostrarMensaje(resp['Message']);
            if (read) {
              Navigator.pushReplacementNamed(context, 'menu');
            }*/
          }
        }).catchError((error) {
          setState(() => _certificando = false);
          showErrorPopUp(context, error);
        }).timeout(Duration(seconds: 60), onTimeout: () {
          setState(() => _certificando = false);
          timeoutPopUp(context);
        });
      }
    } else {
      await sinConexionInternetPopUp(context);
    }
  }

  certificarTodasLasEntregas(List<Certificado> listaCertificados) {
    listaCertificados.forEach((certificado) async {
      setState(() => _certificando = true);

      Map<String, dynamic> resp =
          await _certificadoService.generarCertificadoConImagen(
        File(certificado.imagenPath!),
        certificado.guia!,
        certificado.nombres!,
        certificado.cedula == null ? '1' : certificado.cedula!,
        certificado.telefono!,
        certificado.latitud.toString(),
        certificado.longitud.toString(),
        'https://maps.googleapis.com/maps/api/staticmap?center=${certificado.latitud},${certificado.longitud}&zoom=17&scale=2&size=400x120&maptype=roadmap&markers=${certificado.latitud},${certificado.longitud}',
        true,
        certificado.observaciones!,
        _prefs.cedulaMensajero,
        certificado.isMultiple == 1 ? true : false,
      );

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
      } else {
        setState(() => _certificando = false);
        showErrorPopUp(context, resp["Message"]);
      }
      if (_listaCertificados.isEmpty) {
        setState(() => _certificando = false);
        Navigator.pushReplacementNamed(context, 'menu');
      }
    });
  }

/*
  Future<bool> _mostrarMensaje(String mensaje) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(mensaje),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('ENTENDIDO'))
            ],
          );
        });
  }
  */
}
