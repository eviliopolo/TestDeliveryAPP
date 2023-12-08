import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:prueba_de_entrega/src/theme/theme.dart';

class ConnectionOverlay extends StatelessWidget {
  const ConnectionOverlay({
    Key? key,
    @required bool? internetConnection,
  })  : _internetConnection = internetConnection,
        super(key: key);

  final bool? _internetConnection;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _internetConnection ?? false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Container(
          constraints: BoxConstraints.expand(),
          padding: EdgeInsets.all(16.0),
          color: Colors.white60,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.cloud_off, size: 120, color: blue),
                const SizedBox(height: 16.0),
                const Text(
                  'Sin internet',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Revisa la conexión o tu plan de internet',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
