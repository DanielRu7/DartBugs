import 'dart:convert';
import 'dart:io' show File;
import '../data/almacen_local.dart';
import '../model/incidencia.dart';
import 'package:diacritic/diacritic.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  List<Incidencia> buscar(String texto) {
    if (texto.trim().isEmpty) return incidencias;
    
    return incidencias.where((x) =>removeDiacritics(x.titulo.toLowerCase().trim()).contains(removeDiacritics(texto.trim().toLowerCase()))||removeDiacritics(x.descripcion.toLowerCase().trim()).contains(removeDiacritics(texto.trim().toLowerCase()))).toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {//QUE HACES AQUI????
    //if (estado == 'Pendiente') return cantidadPendientes;
    return incidencias.where((x) => x.estado == estado).length;
  }

//guarda el estado pero por que no persiste??
//el estado no persiste por que los datos vinen de un json mientras este json no se actualice la peristencia es imposible
  Future<void> cambiarEstado(String id, String estado) async {
    
    for(var i=0; i<incidencias.length; i++){
      if(incidencias[i].id==id){
        incidencias[i].estado=estado;
        break;
      }
    }
    await datos.guardar(incidencias);
    /*
    File archivo = File('assets/data/incidencias.json');//selecciona el archivo
    List<dynamic> datos=jsonDecode(await archivo.readAsString());//pone todos los datos en una list dinamica
    var incidencia=datos.firstWhere((dato)=>dato['id']==id);//buscame donde las ids concidan
    incidencia['estado']=estado;//en donde el campo sea estado igualalo a el nuevo estado
    await archivo.writeAsString(jsonEncode(datos),);//escribe todo de nuezen el json
    */
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      fecha: DateTime.now().toIso8601String().split('T').first,
    );
    incidencias.insert(0, nuevo);
    cantidadPendientes++;
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}
