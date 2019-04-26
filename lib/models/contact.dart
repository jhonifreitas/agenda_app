import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String table = 'contactTable';
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String phoneColumn = 'phoneColumn';
final String imgColumn = 'imgColumn';

class ContactHelper {

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if(this._db != null) return this._db;
    else {
      this._db = await this.initDb();
      return this._db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contacts.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $table($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> save(Contact contact) async {
    Database db = await this.db;
    contact.id = await db.insert(table, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database db = await this.db;
    List<Map> maps = await db.query(table, 
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if(maps.length > 0) return Contact.fromMap(maps.first);
    else return null;
  }

}

class Contact {

  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact.fromMap(Map map){
    this.id = map[idColumn];
    this.name = map[nameColumn];
    this.email = map[emailColumn];
    this.phone = map[phoneColumn];
    this.img = map[imgColumn];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn: this.name,
      emailColumn: this.email,
      phoneColumn: this.phone,
      imgColumn: this.img,
    };
    if(this.id != null) map[idColumn] = this.id;
    return map;
  }

  @override
  String toString() => this.name;

}