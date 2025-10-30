import 'package:mysql_client/mysql_client.dart';
import 'package:dotenv/dotenv.dart';

// Classe pour gérer la connexion à la base de données
class Database {
  static MySQLConnection? _connection;

  static Future<MySQLConnection> getConnection() async {
    if (_connection != null) {
      return _connection!;
    }

    final env = DotEnv()..load();

    try {
      _connection = await MySQLConnection.createConnection(
        host: env['DB_HOST'] ?? 'localhost',
        port: int.parse(env['DB_PORT'] ?? '3306'),
        userName: env['DB_USER'] ?? 'root',
        password: env['DB_PASSWORD'] ?? 'password',
        databaseName: env['DB_NAME'] ?? 'dhash_db',
      );
      await _connection!.connect();
      print('MySQL connecté avec succès !');
      return _connection!;
    } catch (e) {
      print('Erreur de connexion MySQL : $e');
      rethrow;
    }
  }

  static Future<void> closeConnection() async {
    await _connection?.close();
    _connection = null;
  }
}