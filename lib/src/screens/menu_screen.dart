import 'package:badges/badges.dart' as badgesdart;
////import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:get_version/get_version.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:prueba_de_entrega/src/components/connection_overlay.dart';
import 'package:prueba_de_entrega/src/components/custom_drawer.dart';
import 'package:prueba_de_entrega/src/components/modals.dart';
import 'package:prueba_de_entrega/src/provider/multientrega_provider.dart';
import 'package:prueba_de_entrega/src/services/consulta_service.dart';
import 'package:prueba_de_entrega/src/services/prefs.dart';
import 'package:prueba_de_entrega/src/services/sqlite_db.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';
import 'package:store_redirect/store_redirect.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _consultaService = ConsultaService();

  final _prefs = PreferenciasUsuario();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _projectVersion = "";

  bool _internetConnection = true;

  bool _updated = true;

  List<Certificado> _listCertificados = [];

  @override
  void initState() {
    super.initState();

    _getVersion();
  }

  void _getVersion() async {
    String projectVersion;

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      projectVersion = packageInfo.version;
    } on PlatformException {
      projectVersion = 'Failed to get project version.';
    }

    if (!mounted) return;

    setState(() {
      _projectVersion = projectVersion;
    });

    print(_projectVersion);

    _consultaService
        .validarVersion(_prefs.cedulaMensajero, _projectVersion)
        .then((resp) {
      if (resp["Message"] == "Exitoso") {
        setState(() {
          _updated = true;
        });
      } else {
        setState(() {
          _updated = false;
        });
      }
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    _listCertificados =
        Provider.of<MultiEntregaProvider>(context).listaNoCertificado;

    final _connection = Provider.of<InternetConnectionStatus>(context);

    if (_connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (_connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const FittedBox(
          child: Wrap(
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
        actions: <Widget>[
          FutureBuilder<List<Certificado>>(
            future: SqliteDB.db.obtenerTodosCertificadosPorEstado(0),
            initialData: [],
            builder: (context, snapshot) {
              _listCertificados = snapshot.data!;

              return IconButton(
                icon: badgesdart.Badge(
                  showBadge: _listCertificados.isNotEmpty,

                  //badgeColor: yellow,

                  //position: badgesdart.BadgePosition.topStart(top: -12.0, right: -6.0),

                  badgeContent: Text('${_listCertificados.length}'),

                  child: Icon(Icons.notifications),
                ),
                onPressed: () {
                  if (_listCertificados.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      //_scaffoldKey.currentState.showSnackBar(SnackBar(

                      behavior: SnackBarBehavior.floating,

                      content: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.notifications_off, color: white),
                          SizedBox(width: 8.0),
                          Text('No tienes notificaciones!'),
                        ],
                      ),
                    ));
                  } else {
                    notificacionEntregasPendientesPorCert(
                        context, _listCertificados.length);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: blue.withOpacity(0.1),
            constraints: BoxConstraints.expand(),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Visibility(
                    visible: _prefs.individual,
                    child: Material(
                      color: white,
                      borderRadius: BorderRadius.circular(16.0),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.all(12.0),
                        leading: const CircleAvatar(
                            child: Icon(FontAwesomeIcons.solidEnvelope)),
                        title: Text(
                          'Entrega individual',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: SvgPicture.asset(
                          'assets/images/arrow.svg',
                          width: 36.0,
                          color: Colors.black26,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, 'scan_module',
                              arguments: "entrega_individual");
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),

                  /* ESTE COMPONENTE ES PARA Entrega multiple
                  Visibility(
                    visible: false, //_prefs.multiple,
                    child: Material(
                      color: white,
                      borderRadius: BorderRadius.circular(16.0),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.all(12.0),
                        leading: CircleAvatar(
                            child: Icon(FontAwesomeIcons.mailBulk)),
                        title: Text(
                          'Entrega multiple',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: SvgPicture.asset(
                          'assets/images/arrow.svg',
                          width: 36.0,
                          color: Colors.black26,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, 'edificio');
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  */

                  /* ESTE COMPONENTE ES PARA MAILAMERICAS
                  Visibility(
                    visible: false, //_prefs.mailAmericas,
                    child: Material(
                      borderRadius: BorderRadius.circular(16.0),
                      color: white,
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.all(12.0),
                        leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            child: Icon(FontAwesomeIcons.envelope)),
                        title: Text(
                          'Mail Americas',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: SvgPicture.asset(
                          'assets/images/arrow.svg',
                          width: 36.0,
                          color: Colors.black26,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, 'scan',
                              arguments: "mail_americas");
                        },
                      ),
                    ),
                  ),
                  */
                ],
              ),
            ),
          ),
          ConnectionOverlay(
            internetConnection: !_internetConnection,
          ),

          /* COMPONENTE QUEMADO PARA VALIDAR VERSIONES DE 5 CONTACTO
          Visibility(
            visible: false,
            child: Container(
              constraints: BoxConstraints.expand(),
              color: Colors.black.withOpacity(0.6),
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Actualizar 5nTacto',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Una nueva version de 5nTacto está disponible!',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w500),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: const Text('ACTUALIZAR AHORA'),
                                onPressed: () {
                                  StoreRedirect.redirect(
                                      androidAppId:
                                          "co.com.a472.prueba_de_entrega");
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          */
        ],
      ),
      drawer: CustomDrawer(),
    );
  }
}
