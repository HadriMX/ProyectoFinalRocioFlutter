import 'bebida.dart';
import 'tamanoBebida.dart';

class BebidaLista {
  Bebida sabor;
  TamanoBebida tamano;
  String titulo;

  BebidaLista({this.sabor, this.tamano, this.titulo});

  factory BebidaLista.fromJson(Map<String, dynamic> json, String titulo) {
    return BebidaLista(
      sabor: Bebida.fromJson(json['bebida']),
      tamano: TamanoBebida.fromJson(json['tamano']),
      titulo: titulo,
    );
  }
}
