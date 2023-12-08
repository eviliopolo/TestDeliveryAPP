import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:prueba_de_entrega/src/models/edificio_model.dart';
import 'package:prueba_de_entrega/src/provider/multientrega_provider.dart';
import 'package:prueba_de_entrega/src/services/sqlite_db.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';

class ResumenEdificiosScreen extends StatefulWidget {
  @override
  _ResumenEdificiosScreenState createState() => _ResumenEdificiosScreenState();
}

class _ResumenEdificiosScreenState extends State<ResumenEdificiosScreen> {
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Edificios',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.0),
                Flexible(
                  flex: 1,
                  child: FutureBuilder<List<Edificio>>(
                    future: SqliteDB.db.obtenerTodosEdificios(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final edificios = snapshot.data;

                      if (edificios!.isEmpty) {
                        return Center(
                            child: Text('No hay Edificios registrados'));
                      }

                      return ListView.builder(
                          itemCount: edificios.length,
                          itemBuilder: (context, i) {
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Provider.of<MultiEntregaProvider>(context,
                                          listen: false)
                                      .edificioData = edificios[i];
                                  Navigator.pushNamed(
                                      context, 'resumen_entrega_edificio',
                                      arguments: edificios[i].id);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Image.file(
                                        File(edificios[i].imagenPath),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.only(
                                          top: 16.0, left: 16.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Icon(Icons.domain,
                                              color: Colors.black54),
                                          SizedBox(width: 8.0),
                                          Text(
                                            edificios[i].edificio,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.only(
                                          top: 4.0, left: 16.0, bottom: 4.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Icon(Icons.location_on,
                                              color: Colors.black54),
                                          SizedBox(width: 8.0),
                                          Text(
                                            edificios[i].direccion == '1'
                                                ? 'No registrada'
                                                : edificios[i].direccion,
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.only(
                                          top: 4.0,
                                          left: 16.0,
                                          bottom: 16.0,
                                          right: 16.0),
                                      child: TextButton(
                                        //color: red,
                                        child: Text(
                                          'Eliminar',
                                          style: TextStyle(
                                              color: white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                    '¿Estas seguro que quieres eliminar este registro?'),
                                                content: Text(
                                                    'Si eliminas este registro, borrarás todos los datos de las guías que han sido entregadas en este edificio.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('AHORA NO'),
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('ELIMINAR'),
                                                    onPressed: () async {
                                                      setState(() {
                                                        _cargando = true;
                                                      });
                                                      await SqliteDB.db
                                                          .borrarTodosCertificadosPorEdificio(
                                                              edificios[i].id!);
                                                      await SqliteDB.db
                                                          .borrarEdificio(
                                                              edificios[i].id!);
                                                      setState(() {
                                                        edificios.remove(
                                                            edificios[i]);
                                                        _cargando = false;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
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
        ],
      ),
    );
  }
}
