import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/components/connection_overlay.dart';
import 'package:LIQYAPP/src/components/custom_drawer.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/theme/theme.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  final _prefs = PreferenciasUsuario();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _internetConnection = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final connection = Provider.of<InternetConnectionStatus>(context);

    if (connection == InternetConnectionStatus.disconnected) {
      setState(() => _internetConnection = false);
    } else if (connection == InternetConnectionStatus.connected) {
      setState(() => _internetConnection = true);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(6, 69, 147, 1),
        foregroundColor: Colors.white,
        title: const FittedBox(
          child: Wrap(
            direction: Axis.vertical,
            children: <Widget>[
              Text(
                'Servicios Postales Nacionales',
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                '#OperadorPostalOficial',
                style: TextStyle(
                    fontSize: 14.0, fontFamily: 'Light', color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: blue.withOpacity(0.1),
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
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
                        contentPadding: const EdgeInsets.all(12.0),
                        leading: const CircleAvatar(
                            child: Icon(FontAwesomeIcons.solidEnvelope)),
                        title: const Text(
                          'Entrega individual',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: SvgPicture.asset(
                          'assets/images/arrow.svg',
                          width: 36.0,
                          //color: Colors.black26,
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, 'scan_module',
                              arguments: "entrega_individual");
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
          ConnectionOverlay(
            internetConnection: !_internetConnection,
          ),
        ],
      ),
      drawer: CustomDrawer(),
    );
  }
}
