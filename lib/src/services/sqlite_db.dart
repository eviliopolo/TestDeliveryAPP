import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:LIQYAPP/src/models/edificio_model.dart';
export 'package:LIQYAPP/src/models/edificio_model.dart';
import 'package:LIQYAPP/src/models/certificado_model.dart';
export 'package:LIQYAPP/src/models/certificado_model.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDB {
  static Database? _database;
  static final SqliteDB db = SqliteDB._();

  SqliteDB._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();

    return _database!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'Certificados.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Certificados ('
          'id INTEGER PRIMARY KEY,'
          'id_edificio INTEGER FOREING KEY,'
          'hasFoto INTEGER,'
          'cargada INTEGER,'
          'imagenPath TEXT,'
          'fecha TEXT,'
          'guia TEXT,'
          'nombres TEXT,'
          'cedula TEXT,'
          'telefono TEXT,'
          'latitud TEXT,'
          'longitud TEXT,'
          'urlImagen TEXT,'
          'isPorteria INTEGER,'
          'observaciones TEXT,'
          'cedulaMensajero TEXT,'
          'isMultiple INTEGER'
          ')');
      await db.execute('CREATE TABLE Edificios ('
          'id INTEGER PRIMARY KEY,'
          'imagenPath TEXT,'
          'edificio TEXT,'
          'direccion TEXT,'
          'telefono TEXT,'
          'correo TEXT,'
          'lat TEXT,'
          'lng TEXT'
          ')');
    });
  }

  // CRUD CERTICADO
  Future<int> crearCertificado(Certificado certificado) async {
    final db = await database;
    final resp = await db.insert('Certificados', certificado.toJson());
    return resp;
  }

  Future<Certificado?> obtenerCertificado(int id) async {
    final db = await database;
    final resp =
        await db.query('Certificados', where: 'id = ?', whereArgs: [id]);
    return resp.isNotEmpty ? Certificado.fromJson(resp.first) : null;
  }

  Future<List<Certificado>> obtenerTodosCertificados() async {
    final db = await database;
    final resp = await db.query('Certificados');
    List<Certificado> list = resp.isNotEmpty
        ? resp.map((guia) => Certificado.fromJson(guia)).toList()
        : [];
    return list;
  }

  Future<List<Certificado>> obtenerTodosCertificadosPorEstado(
      int estado) async {
    final db = await database;
    final resp = await db
        .query('Certificados', where: 'cargada = ?', whereArgs: [estado]);
    List<Certificado> list = resp.isNotEmpty
        ? resp.map((guia) => Certificado.fromJson(guia)).toList()
        : [];
    return list;
  }

  Future<List<Certificado>> obtenerTodosCertPorEstado(bool cargada) async {
    final db = await database;
    final resp = await db
        .query('Certificados', where: 'cargada = ?', whereArgs: [cargada]);
    List<Certificado> list = resp.isNotEmpty
        ? resp.map((guia) => Certificado.fromJson(guia)).toList()
        : [];
    return list;
  }

  Future<List<Certificado>> obtenerTodosCertPorEdificio(int idEdif) async {
    final db = await database;
    final resp = await db
        .query('Certificados', where: 'id_edificio = ?', whereArgs: [idEdif]);
    List<Certificado> list = resp.isNotEmpty
        ? resp.map((guia) => Certificado.fromJson(guia)).toList()
        : [];
    return list;
  }

  Future<List<Certificado>> obtenerTodosCertConFoto(bool hasFoto) async {
    final db = await database;
    final resp = await db
        .query('Certificados', where: 'hasFoto = ?', whereArgs: [hasFoto]);
    List<Certificado> list = resp.isNotEmpty
        ? resp.map((guia) => Certificado.fromJson(guia)).toList()
        : [];
    return list;
  }

  Future<int> actualizarCertificado(Certificado cert) async {
    final db = await database;
    final resp = await db.update('Certificados', cert.toJson(),
        where: 'id = ?', whereArgs: [cert.id]);
    return resp;
  }

  Future<int> borrarCertificado(int id) async {
    final db = await database;
    final resp =
        await db.delete('Certificados', where: 'id = ?', whereArgs: [id]);
    return resp;
  }

  Future<int> borrarTodosCertificados() async {
    final db = await database;
    final resp = await db.delete('Certificados');
    return resp;
  }

  Future<int> borrarTodosCertificadosPorEdificio(int idEdif) async {
    final db = await database;
    final resp = await db
        .delete('Certificados', where: 'id_edificio = ?', whereArgs: [idEdif]);
    return resp;
  }

  // CRUD EDIFICIO
  Future<int> crearEdificio(Edificio edif) async {
    final db = await database;
    final resp = await db.insert('Edificios', edif.toJson());
    return resp;
  }

  Future<Edificio?> obtenerEdificio(int id) async {
    final db = await database;
    final resp = await db.query('Edificios', where: 'id = ?', whereArgs: [id]);
    return resp.isNotEmpty ? Edificio.fromJson(resp.first) : null;
  }

  Future<List<Edificio>> obtenerTodosEdificios() async {
    final db = await database;
    final resp = await db.query('Edificios');
    List<Edificio> list = resp.isNotEmpty
        ? resp.map((guia) => Edificio.fromJson(guia)).toList()
        : [];
    return list;
  }

  Future<int> actualizarEdificio(Edificio edif) async {
    final db = await database;
    final resp = await db.update('Edificios', edif.toJson(),
        where: 'id = ?', whereArgs: [edif.id]);
    return resp;
  }

  Future<int> borrarEdificio(int id) async {
    final db = await database;
    final resp = await db.delete('Edificios', where: 'id = ?', whereArgs: [id]);
    return resp;
  }
}
