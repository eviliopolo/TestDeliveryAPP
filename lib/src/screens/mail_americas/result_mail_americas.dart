import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_de_entrega/src/provider/data_sipost_provider.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';

class ResultMailAmericasScreen extends StatefulWidget {
  @override
  _ResultMailAmericasScreenState createState() =>
      _ResultMailAmericasScreenState();
}

class _ResultMailAmericasScreenState extends State<ResultMailAmericasScreen> {
  final _formKey = GlobalKey<FormState>();
  double fontSize = 12.0;

  @override
  Widget build(BuildContext context) {
    final _guiaDataSipost = Provider.of<DataSipostProvider>(context).dataSipost;
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
            color: blue.withOpacity(0.2),
            child: SingleChildScrollView(
              child: Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(vertical: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: Column(
                          children: <Widget>[
                            BarcodeWidget(
                              data: _guiaDataSipost.barcode,
                              barcode: Barcode.code128(),
                              height: 50.0,
                              width: MediaQuery.of(context).size.width * 0.5,
                              drawText: true,
                              style: TextStyle(
                                  fontFamily: "",
                                  height: 2.0,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Divider(),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          direction: Axis.vertical,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text(
                              'CÓDIGO OPERATIVO',
                              style: TextStyle(fontSize: fontSize),
                            ),
                            Text(
                              _guiaDataSipost.operativeCode,
                              style: TextStyle(
                                  fontSize: 24.0,
                                  fontFamily: '',
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              child: Text(
                                'DATOS DEL REMITENTE',
                                style:
                                    TextStyle(fontSize: fontSize, color: blue),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Wrap(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Text(
                                    'Nombre completo',
                                    style: TextStyle(
                                        fontSize: fontSize, color: grey),
                                  ),
                                  Text(
                                    _guiaDataSipost.names == null
                                        ? 'No registra'
                                        : _guiaDataSipost.names,
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Wrap(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Text(
                                    'Dirección',
                                    style: TextStyle(
                                        fontSize: fontSize, color: grey),
                                  ),
                                  Text(
                                    _guiaDataSipost.address == null
                                        ? 'No registra'
                                        : _guiaDataSipost.address,
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Wrap(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Text(
                                    'Ciudad',
                                    style: TextStyle(
                                        fontSize: fontSize, color: grey),
                                  ),
                                  Text(
                                    _guiaDataSipost.address == null
                                        ? 'No registra'
                                        : _guiaDataSipost.cityName,
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Wrap(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Text(
                                    'Departamento',
                                    style: TextStyle(
                                        fontSize: fontSize, color: grey),
                                  ),
                                  Text(
                                    _guiaDataSipost.address == null
                                        ? 'No registra'
                                        : _guiaDataSipost.departamentName,
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Wrap(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Text(
                                    'No. de Identifiación',
                                    style: TextStyle(
                                        fontSize: fontSize, color: grey),
                                  ),
                                  Text(
                                    _guiaDataSipost.identification == null
                                        ? 'No registra'
                                        : _guiaDataSipost.identification,
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Container(
                              width: double.infinity,
                              child: MaterialButton(
                                color: blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Text(
                                  "Escanear otro",
                                  style: TextStyle(color: white),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
