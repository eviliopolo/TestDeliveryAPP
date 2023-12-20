import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:LIQYAPP/src/models/sipost_response.dart';
import 'package:LIQYAPP/src/provider/data_sipost_provider.dart';
import 'package:LIQYAPP/src/services/consulta_service.dart';
import 'package:LIQYAPP/src/services/prefs.dart';
import 'package:LIQYAPP/src/theme/theme.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CardResultadoSipost extends StatelessWidget {
  final String guiaBarcode;
  final _formKey = GlobalKey<FormState>();
  CardResultadoSipost(this.guiaBarcode, {super.key});

  @override
  Widget build(BuildContext context) {
    SipostResponse? _sipostResponse =
        Provider.of<DataSipostProvider>(context, listen: false).sipostResponse;
    final _consultaService = ConsultaService();
    final _prefs = PreferenciasUsuario();

    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    BarcodeWidget(
                      data: guiaBarcode,
                      barcode: Barcode.code128(),
                      height: 80.0,
                      width: MediaQuery.of(context).size.width * 0.8,
                      drawText: true,
                      style: const TextStyle(
                          fontFamily: "",
                          height: 2.0,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12.0),
                    const Divider(),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'DATOS DEL REMITENTE',
                            style: TextStyle(fontSize: 12.0, color: blue),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Text(
                                'Nombre completo',
                                style: TextStyle(fontSize: 12.0, color: grey),
                              ),
                              AutoSizeText(
                                _sipostResponse.names.toString(),
                                style: const TextStyle(fontSize: 12.0),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Text(
                                'Dirección',
                                style: TextStyle(fontSize: 12.0, color: grey),
                              ),
                              Text(
                                _sipostResponse.address ??
                                    "Dirección no disponible",
                                style: const TextStyle(fontSize: 12.0),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Form(
                          key: _formKey,
                          child: Visibility(
                            visible: _sipostResponse.isEntregaTercero! &&
                                !_sipostResponse.isPorteria!,
                            child: TextFormField(
                                controller: TextEditingController(
                                    text: _sipostResponse.phone),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 12.0),
                                decoration: InputDecoration(
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.phone_android),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                ),
                                validator: (valor) {
                                  _sipostResponse.phone = valor!;
                                  if (valor.length != 10) {
                                    return "Ingrese un número celular válido";
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) =>
                                    _sipostResponse.phone = value!),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Visibility(
                          visible: ((!_sipostResponse.isFirma! &&
                                      !_sipostResponse.isOtp!) &&
                                  _sipostResponse.isPorteria!) ||
                              _sipostResponse.isEntregaTercero!,
                          child: Container(
                            width: double.infinity,
                            child: MaterialButton(
                              color: blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Text(
                                "Continuar",
                                style: TextStyle(color: white),
                              ),
                              onPressed: () {
                                _consultaService
                                    .searchGuideSipost(guiaBarcode)
                                    .then((guiaSipost) {
                                  //Codigo para consultar si la guia ya fue digitalizada o esta en un cargue
                                  if (guiaSipost != null &&
                                      guiaSipost.availableForDelivery &&
                                      !guiaSipost.delivered) {
                                    if (_sipostResponse.isFirma!) {
                                      Navigator.pushNamed(
                                          context, "certificar_firma");
                                    } else {
                                      Navigator.pushNamed(
                                          context, "certificar");
                                    }
                                  } else {
                                    if (guiaSipost == null) {
                                      guideNotFound(context);
                                    } else if (guiaSipost.delivered) {
                                      imgDigitalized(context);
                                    } else if (!guiaSipost
                                        .availableForDelivery) {
                                      loadPostmanNotFound(context);
                                    } else {
                                      guideNotFound(context);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  imgDigitalized(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Guía ya digitalizada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              'Lo sentimos, esta guía ya se encuentra digitalizada.'),
          actions: <Widget>[
            TextButton(
              child: const Text('ENTENDIDO'),
              onPressed: () {
                Navigator.popAndPushNamed(context, 'menu');
              },
            )
          ],
        );
      },
    );
  }

  guideNotFound(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Guía no encontrada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              'Lo sentimos, se produjo un error en el sistema, vuelva a intentarlo'),
          actions: <Widget>[
            TextButton(
              child: const Text('ENTENDIDO'),
              onPressed: () {
                Navigator.popAndPushNamed(context, 'menu');
              },
            )
          ],
        );
      },
    );
  }

  loadPostmanNotFound(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cargue a sector de distribucion',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              'Lo sentimos, esta guía no se encuentra en un cargue a sector de distribución.'),
          actions: <Widget>[
            TextButton(
              child: const Text('ENTENDIDO'),
              onPressed: () {
                Navigator.popAndPushNamed(context, 'menu');
              },
            )
          ],
        );
      },
    );
  }
}
