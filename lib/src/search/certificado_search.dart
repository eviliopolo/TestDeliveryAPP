import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/modals.dart';
import 'package:LIQYAPP/src/services/certificado_service.dart';
//import 'package:LIQYAPP/src/services/connection_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/services/sqlite_db.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class CertificadoSearch extends SearchDelegate {
  final List<Certificado> listaCertificados;

  Certificado _certificado = new Certificado();
  bool _internetConnection = true;

  CertificadoSearch({
    required this.listaCertificados,
    String hintText = "Digita la guía",
  }) : super(
          searchFieldLabel: hintText,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty && _certificado.guia != null) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Material(
              elevation: 2.0,
              color: white,
              child: ListTile(
                dense: true,
                isThreeLine: true,
                leading: Icon(
                  FontAwesomeIcons.barcode,
                ),
                contentPadding: EdgeInsets.all(12.0),
                title: Text(
                  '${_certificado.guia}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Wrap(direction: Axis.vertical, children: <Widget>[
                  Text(
                    '${_certificado.fecha}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  _certificado.cargada == 1
                      ? Text('Certificada')
                      : Text('Sin certificar')
                ]),
                trailing: _certificado.cargada == 1
                    ? Icon(
                        Icons.cloud_done,
                        color: Colors.green,
                      )
                    : Icon(
                        Icons.cloud_upload,
                        color: Colors.blueGrey,
                      ),
                onTap: _certificado.cargada == 1
                    ? null
                    : () {
                        _certificarEntrega(context, _certificado);
                      },
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text('No hay resultados'),
      );
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final listSugerencias = (query.isEmpty)
        ? []
        : listaCertificados
            .where((c) => c.guia!.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: listSugerencias.length,
      itemBuilder: (context, i) {
        return Material(
          color: white,
          elevation: 2.0,
          child: ListTile(
              dense: true,
              isThreeLine: true,
              leading: Icon(
                FontAwesomeIcons.barcode,
              ),
              contentPadding: EdgeInsets.all(12.0),
              title: Text(
                '${listSugerencias[i].guia}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Wrap(direction: Axis.vertical, children: <Widget>[
                Text(
                  '${listSugerencias[i].fecha}',
                  overflow: TextOverflow.ellipsis,
                ),
                listSugerencias[i].cargada == 1
                    ? Text('Certificada')
                    : Text('Sin certificar')
              ]),
              trailing: listSugerencias[i].cargada == 1
                  ? Icon(
                      Icons.cloud_done,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.cloud_upload,
                      color: Colors.blueGrey,
                    ),
              onTap: listSugerencias[i].cargada == 1
                  ? null
                  : () {
                      _certificado = listSugerencias[i];
                      query = _certificado.guia!;
                      showResults(context);
                    }),
        );
      },
    );
  }

  _certificarEntrega(BuildContext context, Certificado cert) async {
    final _connection =
        Provider.of<InternetConnectionStatus>(context, listen: false);
    final _prefs = PreferenciasUsuario();

    loading(context);
    if (_connection == InternetConnectionStatus.disconnected) {
      _internetConnection = false;
    } else if (_connection == InternetConnectionStatus.connected) {
      _internetConnection = true;
    }

    final _certificadoService = CertificadoService();

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
            .then((resp) async {
          Navigator.pop(context);

          if (resp["Message"] == 'Ingresado Correctamente') {
            cert
              ..cargada = 1
              ..fecha = DateTime.now().toLocal().toString();

            _certificado = cert;

            await SqliteDB.db.actualizarCertificado(_certificado);

            query = "";

            // close(context, null);
          } else if (resp["Message"] == "La guia ya fue entregada") {
            showAlert(
              context,
              'Ha habido un error',
              "La guia ya fue entregada",
              TextButton(
                child: Text('ENTENDIDO'),
                onPressed: () async {
                  cert
                    ..cargada = 1
                    ..fecha = DateTime.now().toLocal().toString();
                  _certificado = cert;

                  await SqliteDB.db.actualizarCertificado(_certificado);
                  query = "";
                },
              ),
              null,
            );
          } else if (resp["Message"] == "Ingresado , pero sin liquidacion") {
            showAlert(
              context,
              'Ha habido un error',
              "Ingresado , pero sin liquidacion",
              TextButton(
                child: Text('ENTENDIDO'),
                onPressed: () async {
                  cert
                    ..cargada = 1
                    ..fecha = DateTime.now().toLocal().toString();
                  _certificado = cert;

                  await SqliteDB.db.actualizarCertificado(_certificado);
                  query = "";
                },
              ),
              null,
            );
          } else if (resp["Message"] ==
              "No se encontro el cargue o el envío ya fue liquidado.") {
            showAlert(
              context,
              'Ha habido un error',
              "No se encontro el cargue o el envío ya fue liquidado.",
              TextButton(
                child: Text('ENTENDIDO'),
                onPressed: () async {
                  cert
                    ..cargada = 1
                    ..fecha = DateTime.now().toLocal().toString();

                  _certificado = cert;

                  await SqliteDB.db.actualizarCertificado(_certificado);
                  query = "";
                },
              ),
              null,
            );
          } else {
            showAlert(
              context,
              'Ha habido un error',
              resp["Message"],
              null,
              null,
            );
          }
        }).catchError((error) {
          showErrorPopUp(context, error);
        }).timeout(Duration(seconds: 180), onTimeout: () {
          timeoutPopUp(context);
        });
      }
    } else {
      await sinConexionInternetPopUp(context);
    }
  }
}
