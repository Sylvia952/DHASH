import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static Database? _database;

  // Initialisation de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Ouvrir/Créer la base de données
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'dhash_local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  // Créer les tables locales (pour le cache, l'historique local, etc.)
  void _createDb(Database db, int version) async {
    // Exemple : Cache des produits pour consultation hors ligne
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        api_id TEXT UNIQUE,
        title TEXT,
        price REAL,
        description TEXT
      )
    ''');
    
    // Exemple : Historique de recherche de l'utilisateur
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT UNIQUE,
        timestamp TEXT
      )
    ''');
  }

  // Exemple de fonction d'insertion de cache
  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    // Remplace si l'ID API est déjà présent
    return await db.insert('products', product, conflictAlgorithm: ConflictAlgorithm.replace); 
  }
}