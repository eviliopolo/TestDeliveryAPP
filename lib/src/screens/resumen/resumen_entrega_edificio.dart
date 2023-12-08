import 'dart:io';

//import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_de_entrega/src/components/connection_overlay.dart';

import 'package:prueba_de_entrega/src/services/sqlite_db.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';

class ResumenEntregaEdificioScreen extends StatefulWidget {
  @override
  _ResumenEntregaEdificioScreenState createState() =>
      _ResumenEntregaEdificioScreenState();
}

class _ResumenEntregaEdificioScreenState
    extends State<ResumenEntregaEdificioScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _cargando = false;
  bool _internetConnection = true;
  List<Certificado> _listaCertificados = [];

  @override
  Widget build(BuildContext context) {
    int idEdif = ModalRoute.of(context)!.settings.arguments as int;

    final _connection = Provider.of<InternetConnectionStatus>(context);

    if (_connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (_connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Wrap(
          direction: Axis.vertical,
          children: <Widget>[
            Text(
              'Servicios Postales Nacionales',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '#OperadorPostalOficial',
              style: TextStyle(fontSize: 16.0, fontFamily: 'Light'),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cloud_upload),
            onPressed: () {
              if (_listaCertificados.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('No hay para certificar'),
                ));
              } else {
                // certificarTodasLasEntregas(_listaCertificados, _edificio);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
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
                    'Guías de entregadas',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.0),
                Flexible(
                  flex: 1,
                  child: FutureBuilder<List<Certificado>>(
                    future: SqliteDB.db.obtenerTodosCertPorEdificio(idEdif),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      _listaCertificados = snapshot.data!;

                      if (_listaCertificados.isEmpty) {
                        return Center(
                            child: Text(
                                'No hay registros de entregas realizadas en este edificio'));
                      }

                      return ListView.builder(
                        itemCount: _listaCertificados.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              color: _listaCertificados[i].cargada == 0
                                  ? red
                                  : Colors.green,
                              padding: EdgeInsets.only(left: 4.0),
                              child: Material(
                                color: Colors.white,
                                child: ListTile(
                                  leading: _listaCertificados[i].hasFoto == 1
                                      ? Image.file(File(
                                          _listaCertificados[i].imagenPath!))
                                      : Image.asset(
                                          'assets/images/ic_launcher.png'),
                                  contentPadding: EdgeInsets.all(12.0),
                                  title: Text(
                                    '${_listaCertificados[i].guia}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Wrap(
                                      direction: Axis.vertical,
                                      children: <Widget>[
                                        Text(
                                            '${_listaCertificados[i].nombres}'),
                                        _listaCertificados[i].cargada == 0
                                            ? Text('Sin certificar')
                                            : Text('Certificada'),
                                      ]),
                                  isThreeLine: true,
                                  trailing: _listaCertificados[i].cargada == 0
                                      ? Icon(Icons.cloud_upload)
                                      : Icon(
                                          Icons.cloud_done,
                                          color: Colors.green,
                                        ),
                                  onTap: () {
                                    if (_listaCertificados[i].cargada == 0) {
                                      setState(() {
                                        _cargando = true;
                                      });
                                      // certificarEntrega(_listaCertificados[i], _edificio);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content:
                                            Text('La guía ya esta certificada'),
                                      ));
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _cargando,
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
                      'Cargando, por favor espere...',
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
