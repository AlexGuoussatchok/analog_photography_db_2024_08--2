import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TableDefinition {
  final String tableName;
  final String tableColumns;

  TableDefinition({required this.tableName, required this.tableColumns});
}

final Map<String, List<TableDefinition>> databaseDefinitions = {
  'inventory_collection.db': [
    TableDefinition(
        tableName: 'cameras',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            serial_number TEXT,
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            film_load_date TEXT,
            film_loaded TEXT,
            average_price REAL,
            comments TEXT 
            
        '''
    ),
    TableDefinition(
        tableName: 'lenses',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            serial_number TEXT,
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'flashes',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT,
            serial_number TEXT,
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'exposure_meters',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            serial_number TEXT,
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'films',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            name TEXT,
            type TEXT,
            size_type TEXT, 
            ISO TEXT,
            frames_number TEXT,
            expiration_date TEXT,
            is_expired TEXT,
            quantity INTEGER,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'filters',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            type TEXT,
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'photo_papers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            name TEXT, 
            size TEXT,
            type TEXT,
            expiration_date TEXT,
            is_expired TEXT,
            quantity INTEGER,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'enlargers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'color_analyzers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'film_processors',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'paper_dryers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'print_washers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'film_scanners',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT,          
            purchase_date TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'photo_chemistry',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            chemical TEXT, 
            type TEXT,
            price_paid REAL,
            condition TEXT,
            average_price REAL,
            comments TEXT
        '''
    ),
    // ... add other tables here with their columns for this database
  ],
  'inventory_wishlist.db': [
    TableDefinition(
        tableName: 'cameras',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT,
            condition TEXT,
            comments TEXT            
        '''
    ),
    TableDefinition(
        tableName: 'lenses',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT
            mount TEXT,
            condition TEXT,
            comments TEXT            
        '''
    ),
    TableDefinition(
        tableName: 'flashes',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'exposure_meters',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'films',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            name TEXT, 
            quantity INTEGER,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'filters',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'photo_papers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            quantity INTEGER,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'enlargers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'color_analyzers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'film_processors',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'paper_dryers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'print_washers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'film_scanners',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'Photo_chemistry',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            chemical TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    // ... add other tables here with their columns for this database
  ],
  'inventory_sell_list.db': [
    TableDefinition(
        tableName: 'cameras',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'lenses',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'flashes',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'exposure_meters',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'films',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            quantity INTEGER,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'filters',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'photo_papers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            quantity INTEGER,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'enlargers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'color_analyzers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'film_processors',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'paper_dryers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'print_washers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'film_scanners',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            condition TEXT,
            comments TEXT
        '''
    ),
    TableDefinition(
        tableName: 'Photo_chemistry',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            chemical TEXT, 
            quantity INTEGER,
            comments TEXT
        '''
    ),
    // ... add other tables here with their columns for this database
  ],
  'inventory_borrowed_stuff.db': [
    TableDefinition(
        tableName: 'cameras',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'lenses',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'flashes',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'exposure_meters',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'filters',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'enlargers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'color_analyzers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'film_processors',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'paper_dryers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'print_washers',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
    TableDefinition(
        tableName: 'film_scanners',
        tableColumns: '''
            id INTEGER PRIMARY KEY, 
            brand TEXT, 
            model TEXT, 
            who_borrowed TEXT,
            borrowed_to TEXT,
            borrowed_to_phone_number TEXT,
            date_borrowed TEXT,
            should_get_back TEXT
        '''
    ),
  ],
};

class InventoryDatabaseHelper {
  static Database? _database;
  static Future<Database> initDatabase(String dbName) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    return openDatabase(
        path,
        version: 1,
        onCreate: (db, version) => _onCreate(db, version, dbName)
    );
  }

  static Future<void> _onCreate(Database db, int version, String dbName) async {
    final tables = databaseDefinitions[dbName];
    if (tables != null) {
      for (var table in tables) {
        await db.execute('''
          CREATE TABLE ${table.tableName}(
            ${table.tableColumns}
          )
        ''');
      }
    }
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
