class Bebida {
  int idBebida;
  String nombre;
  String tipo;
  double ltContenedor;
  int idTemporada;

  Bebida({
    this.idBebida,
    this.nombre,
    this.tipo,
    this.ltContenedor,
    this.idTemporada,
  });

  factory Bebida.fromJson(Map<String, dynamic> json) {
    return Bebida(
      idBebida: json['idBebida'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      ltContenedor: json['ltContenedor'].toDouble(),
      idTemporada: json['idTemporada'],
    );
  }
}
