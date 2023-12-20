import 'package:flutter/material.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: const Text(
                  'Configuracion',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Material(
                color: white,
                child: SwitchListTile(
                  dense: true,
                  isThreeLine: true,
                  title: const Text(
                    'Lector incorporado',
                  ),
                  subtitle: Text('Desactiva el escaneo por cámara.'),
                  value: _prefs.lectorExterno,
                  onChanged: (valor) {
                    setState(() {
                      _prefs.lectorExterno = valor;
                    });
                  },
                ),
              ),
              const Divider(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: const Text(
                  'Servicios',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Material(
                color: white,
                child: SwitchListTile(
                  dense: true,
                  title: const Text(
                    'Entrega Indivídual',
                  ),
                  value: _prefs.individual,
                  onChanged: (valor) {
                    setState(() {
                      _prefs.individual = valor;
                    });
                  },
                ),
              ),
              /*
              Material(
                color: white,
                child: SwitchListTile(
                  dense: true,
                  title: Text(
                    'Entrega Múltiple',
                  ),
                  value: _prefs.multiple,
                  onChanged: (valor) {
                    setState(() {
                      _prefs.multiple = valor;
                    });
                  },
                ),
              ),
              */

              /*
              Material(
                color: white,
                child: SwitchListTile(
                  dense: true,
                  title: Text(
                    'Mail Americas',
                  ),
                  value: _prefs.mailAmericas,
                  onChanged: (valor) {
                    setState(() {
                      _prefs.mailAmericas = valor;
                    });
                  },
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
