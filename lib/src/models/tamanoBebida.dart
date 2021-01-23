class TamanoBebida {
  int idTamano;
  String tamanoBebida;
  String aproxMl;

  TamanoBebida({
    this.idTamano,
    this.tamanoBebida,
    this.aproxMl,
  });

  factory TamanoBebida.fromJson(Map<String, dynamic> json) {
    return TamanoBebida(
      idTamano: json['idTamano'],
      tamanoBebida: json['tamanoBebida'],
      aproxMl: json['aproxMl'],
    );
  }
}
