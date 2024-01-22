import 'package:flutter/material.dart';
//import 'package:get_version/get_version.dart';
//import 'package:package_info/package_info.dart';
import 'package:LIQYAPP/src/components/modals.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer();

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final _prefs = PreferenciasUsuario();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 40.0,
              ),
              //_historialEntregas(),
              // _resumenMultientregas(),
              _configuracion(),
              _cerrarSesion(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color: blue,
                ),
              ),

              _ayudaSoporte(),
              _acercaDe(),
              /*
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListTile(title: Text("Versión ${snapshot.data}"));
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              */
              const SizedBox(
                height: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*
  Widget _historialEntregas() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      title: const Text(
        'Historial de entregas',
        style: TextStyle(fontSize: 16.0),
      ),
      leading: Icon(Icons.assignment),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, 'historial', arguments: 0);
      },
    );
  }
  */

  Widget _configuracion() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: const Text(
        'Configuración',
        style: TextStyle(fontSize: 16.0),
      ),
      leading: const Icon(Icons.settings),
      onTap: () {
        Navigator.pop(context);

        Navigator.of(context).pushNamed('settings');
      },
    );
  }

  Widget _cerrarSesion() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      title: const Text(
        'Cerrar sesión',
        style: TextStyle(fontSize: 16.0),
      ),
      leading: const Icon(Icons.exit_to_app),
      onTap: () {
        Future.value(true).then((_) {
          setState(() {
            _prefs.logged = false;

            _prefs.cedulaMensajero = "";
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
          });
        });
      },
    );
  }

  Widget _ayudaSoporte() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: const Text(
        'Ayuda',
        style: TextStyle(fontSize: 16.0),
      ),
      leading: const Icon(Icons.help_outline),
      onTap: () {
        Navigator.pop(context);
        showInfo(context);
      },
    );
  }

  Widget _acercaDe() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: const Text(
        'Acerca de',
        style: TextStyle(fontSize: 16.0),
      ),
      leading: const Icon(Icons.info),
      onTap: () {
        Navigator.pop(context);

        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text(
                  'Acerca de',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                    'Esta aplicación es propiedad intelectual de Servicios Postales Nacionales, 4-72.'),
              );
            });
      },
    );
  }
}
