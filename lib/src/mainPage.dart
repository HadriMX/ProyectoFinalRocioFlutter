import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'customDrinkPage.dart';
import 'models/bebida.dart';
import 'models/bebidaLista.dart';
import 'models/user.dart';

class MainPage extends StatefulWidget {
  static const routeName = '/main';
  final User currentUser;

  MainPage({Key key, this.currentUser}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState(currentUser: currentUser);
}

class _MainPageState extends State<MainPage> {
  User currentUser;
  Future<List<BebidaLista>> ftrMenuBebidas;

  _MainPageState({this.currentUser});

  @override
  void initState() {
    super.initState();
    ftrMenuBebidas = fetchMenu(currentUser.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('TOMAUAS - ${currentUser.name}'),
        ),
        body: Center(
          child: FutureBuilder<List<BebidaLista>>(
            future: ftrMenuBebidas,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var bebidas = snapshot.data;

                return ListView.builder(
                  itemCount: bebidas.length,
                  itemBuilder: (BuildContext context, int index) {
                    var bebidaLista = bebidas[index];

                    String titulo;
                    String subtitulo;
                    String imgName =
                        'assets/img_bebidas/${bebidaLista.sabor.idBebida}.jpg';

                    if (index == 0) {
                      titulo = 'Nuevo pedido';
                      subtitulo = 'Elige el sabor y tamaño que prefieras';
                    } else {
                      titulo = bebidaLista.titulo;

                      if (index == 1) {
                        subtitulo =
                            'Sabor ${bebidaLista.sabor.nombre}, Tamaño ${bebidaLista.tamano.tamanoBebida} (${bebidaLista.tamano.aproxMl})';
                      } else {
                        subtitulo =
                            'Sabor ${bebidaLista.sabor.nombre}, Elige un tamaño';
                      }
                    }

                    return Card(
                      child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          if (bebidaLista.sabor.idBebida == 0) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CustomDrinkPage(
                                  idSaborSeleccionado: 1,
                                  idTamanoSeleccionado: 1,
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CustomDrinkPage(
                                  idSaborSeleccionado:
                                      bebidaLista.sabor.idBebida,
                                  idTamanoSeleccionado:
                                      bebidaLista.tamano?.idTamano,
                                  idCliente: currentUser.id,
                                ),
                              ),
                            );
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text(titulo),
                              subtitle: Text(subtitulo),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Image.asset(imgName),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text("No se pudo cargar el contenido");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

Future<List<BebidaLista>> fetchMenu(int idCliente) async {
  final response =
      await http.get('https://192.168.0.10:5001/api/main/$idCliente');

  if (response.statusCode == 200) {
    var menu = List<BebidaLista>();
    var res = json.decode(response.body);
    var favorita = BebidaLista.fromJson(res['favorita'], 'Tu favorita');
    var masVendida = Bebida.fromJson(res['bebidaMasVendida']);
    var menosVendida = Bebida.fromJson(res['bebidaMenosVendida']);

    // sirve para poner un botón personalizado al inicio de la lista
    menu.add(
      BebidaLista(
        sabor: Bebida(idBebida: 0),
      ),
    );

    menu.add(favorita);

    menu.add(
      BebidaLista(
        sabor: masVendida,
        titulo: 'Recomendación de hoy',
      ),
    );

    menu.add(
      BebidaLista(
        sabor: menosVendida,
        titulo: 'Prueba el nuevo sabor',
      ),
    );

    return menu;
  } else {
    throw Exception('Failed to load resources');
  }
}

// Future<Bebida> fetchBebida() async {
//   final response = await http.get('https://192.168.0.10:5001/api/bebidas/1');

//   if (response.statusCode == 200) {
//     return Bebida.fromJson(jsonDecode(response.body));
//   } else {
//     throw Exception('Failed to load resources');
//   }
// }
