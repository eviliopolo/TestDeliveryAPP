import 'package:flutter/material.dart';

loading(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Cargando',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color?>(Colors.indigoAccent[700]),
            ),
            SizedBox(
              width: 20.0,
            ),
            Text('Por favor espere...'),
          ],
        ),
      );
    },
  );
}

sinInternetPopUp(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Sin internet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
            'Lo sentimos, esta aplicación requiere de una conexión de internet para funcionar correctamente.'),
        actions: <Widget>[
          TextButton(
            child: Text('ENTENDIDO'),
            onPressed: () {
              Navigator.popAndPushNamed(context, 'menu');
            },
          )
        ],
      );
    },
  );
}

timeoutPopUp(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Error de conexión',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('El servidor ha tomado mucho tiempo en responder.'),
        actions: <Widget>[
          TextButton(
            child: Text('ENTENDIDO'),
            onPressed: () {
              Navigator.popAndPushNamed(context, 'menu');
            },
          )
        ],
      );
    },
  );
}

showErrorPopUp(BuildContext context, dynamic error) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Ha habido un error',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Error: $error'),
      );
    },
  );
}

guiaEntregadaPopUp(BuildContext context, String guia) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Aviso',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('La guía No. $guia ya fue entregada.'),
        );
      });
}

intentosExcedidosPopUp(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Aviso',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
              'Ha excedido el número de intentos para enviar el código de seguridad. Proceda a realizar la certificación manual.'),
          actions: <Widget>[
            TextButton(
              child: Text('ENTENDIDO'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      });
}

codigoOtpCortoPopUp(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Código no válido',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content:
              Text('Ingresa los seis números del código para poder continuar.'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ENTENDIDO'))
          ],
        );
      });
}

Future<bool> sinConexionInternetPopUp(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Sin internet',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
              'No hay conexión de internet, pero puedes certificar esta entrega luego.'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('ENTENDIDO'))
          ],
        );
      });
}

codigoOtpEnviadoPopUp(BuildContext context, String phone) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Mensaje enviado exitosamente',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Se ha enviado un código de seguridad al número celular: $phone.'),
        actions: <Widget>[
          TextButton(
            child: Text('CONTINUAR'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

codigoOtpCorrectoPopUp(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Código correcto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
                'Puedes realizar la entrega del envio.\n Recuerda seguir los protocolos de Bioseguridad:\n\n1. Deja el paquete o correspondecia donde se te indique.\n\n2. Conserva la 1.5 m de distancia.\n\n3. Certifica la entrega una vez el cliente haya recogido el envio.'),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('CONTINUAR'),
                onPressed: () {
                  Navigator.pushNamed(context, 'certificar_firma');
                })
          ],
        );
      });
}

codigoOtpIncorrectoPopUp(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Código incorrecto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
              'El código no coincide con el código enviado.\n revise e intente nuevamente.'),
          actions: <Widget>[
            TextButton(
              child: Text('ENTENDIDO'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      });
}

mensajeSoporteEnviadoPopUp(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Entrega certificada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
              'La guía ya ha quedado certificada y el usuario ha sido notificado mediante un mensaje de texto, puedes continuar.'),
          actions: <Widget>[
            TextButton(
              child: Text('FINALIZAR'),
              onPressed: () => Navigator.pushReplacementNamed(context, 'menu'),
            )
          ],
        );
      });
}

Future<bool> codigoBarrasNoValidoPopUp(
    BuildContext context, String guia) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Código Invalido',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
              'La guía $guia debe tener 13 digitos, intenta escaneando nuevamente'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ENTENDIDO'))
          ],
        );
      });
}

seEntregaCartaPopUp(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Notificación importante',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content:
              Text('Entregue la carta de notificación de Ingreso Solidario'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, 'menu');
                },
                child: Text('ENTENDIDO'))
          ],
        );
      });
}

showAlert(BuildContext context, String title, String content,
    [Widget? onSuccess, Widget? onCancel]) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(content),
          actions: <Widget>[
            if (onSuccess != null) onSuccess,
            if (onCancel != null) onCancel
          ],
        );
      });
}

avisoGuiaIngresoSolidario(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Aviso',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('La guia corresponde a Ingreso solidario'),
          actions: <Widget>[
            TextButton(
              child: Text('ENTENDIDO'),
              onPressed: () {
                Navigator.popAndPushNamed(context, 'menu');
              },
            )
          ],
        );
      });
}

avisoGuiaIsTelefonica(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Aviso',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('La guia corresponde a Telefónica'),
          actions: <Widget>[
            TextButton(
              child: Text('ENTENDIDO'),
              onPressed: () {
                Navigator.popAndPushNamed(context, 'menu');
              },
            )
          ],
        );
      });
}

avisoGuiaIsNotTelefonica(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Aviso',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('La guia no corresponde a Telefónica'),
          actions: <Widget>[
            TextButton(
              child: Text('ENTENDIDO'),
              onPressed: () {
                Navigator.popAndPushNamed(context, 'menu');
              },
            )
          ],
        );
      });
}

notificacionEntregasPendientesPorCert(BuildContext context, int cant) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '¡Importante!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Tienes $cant entregas pendientes por certificar.'),
          actions: <Widget>[
            TextButton(
              child: Text('LO HARÉ LUEGO'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('CERTIFICAR AHORA'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'historial', arguments: 1);
              },
            ),
          ],
        );
      });
}

showInfo(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Información de ayuda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 8.0),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Entrega individual',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Ingresa aquí si necesitas hacer la entrega de un solo paquete, o correo a un cliente.',
                    textAlign: TextAlign.justify,
                  ),
                ),
                SizedBox(height: 8.0),
                /*Container(
                  width: double.infinity,
                  child: Text(
                    'Entrega multiple',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Esta opción está diseñada para realizar la de varios paquetes o correos en una unidad residencial.',
                    textAlign: TextAlign.justify,
                  ),
                ),*/
                SizedBox(height: 8.0),
              ]),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('ENTENDIDO'))
        ],
      );
    },
  );
}
