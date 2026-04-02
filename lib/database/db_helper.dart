import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sport.dart';
import '../models/exercise.dart';
import '../models/user.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "sportfit.db");

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          email TEXT,
          password TEXT
        )
        ''');

        await db.execute('''
        CREATE TABLE sports(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          description TEXT,
          image TEXT
        )
        ''');

        await db.execute('''
        CREATE TABLE exercises(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sportId INTEGER,
          name TEXT,
          description TEXT,
          type TEXT,
          duration INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE favorites(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          sportId INTEGER,
          UNIQUE(userId, sportId)
        )
        ''');

        await db.execute('''
        CREATE TABLE history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          sportId INTEGER,
          exerciseId INTEGER,
          date TEXT,
          UNIQUE(userId, sportId, exerciseId)
        )
        ''');

        await db.execute(
          'CREATE INDEX idx_exercises_sportId ON exercises(sportId)',
        );
        await db.execute(
          'CREATE INDEX idx_favorites_user_sport ON favorites(userId, sportId)',
        );
        await db.execute(
          'CREATE INDEX idx_history_user_sport ON history(userId, sportId)',
        );
        await db.execute(
          'CREATE INDEX idx_history_user_sport_exercise ON history(userId, sportId, exerciseId)',
        );

        await insertDefaultSports(db);
        await insertDefaultExercises(db);
      },
    );

    return _database!;
  }

  static Future<void> insertDefaultSports(Database db) async {
    List<Sport> sports = [
      Sport(
        name: "Basketball",
        description: "A team sport focused on dribbling, passing and shooting.",
        image: "assets/images/basketball.png",
      ),
      Sport(
        name: "Tennis",
        description: "A racket sport focused on serving, control and footwork.",
        image: "assets/images/tennis.png",
      ),
      Sport(
        name: "Soccer",
        description: "A sport focused on passing, dribbling and stamina.",
        image: "assets/images/soccer.png",
      ),
    ];

    Batch batch = db.batch();

    for (int i = 0; i < sports.length; i++) {
      batch.insert('sports', sports[i].toMap());
    }

    await batch.commit(noResult: true);
  }

  static Future<void> insertDefaultExercises(Database db) async {
    List<Exercise> exercises = [
      Exercise(
        sportId: 1,
        name: "Dribbling Drill",
        description: "Practice ball control and movement.",
        type: "outdoor",
        duration: 5,
      ),
      Exercise(
        sportId: 1,
        name: "Wall Sit",
        description: "Build lower body strength indoors.",
        type: "indoor",
        duration: 3,
      ),
      Exercise(
        sportId: 2,
        name: "Serve Practice",
        description: "Practice tennis serves.",
        type: "outdoor",
        duration: 5,
      ),
      Exercise(
        sportId: 2,
        name: "Shadow Swings",
        description: "Practice swings indoors.",
        type: "indoor",
        duration: 4,
      ),
      Exercise(
        sportId: 3,
        name: "Squats",
        description: "Build leg strength indoors.",
        type: "indoor",
        duration: 3,
      ),
      Exercise(
        sportId: 3,
        name: "Passing Drill",
        description: "Practice passing accuracy.",
        type: "outdoor",
        duration: 5,
      ),
    ];

    Batch batch = db.batch();

    for (int i = 0; i < exercises.length; i++) {
      batch.insert('exercises', exercises[i].toMap());
    }

    await batch.commit(noResult: true);
  }

  static Future<int> signup(User user) async {
    Database db = await getDatabase();
    return await db.insert('users', user.toMap());
  }

  static Future<List<Map<String, dynamic>>> signin(
    String email,
    String password,
  ) async {
    Database db = await getDatabase();

    return await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
  }

  static Future<List<Map<String, dynamic>>> getSports() async {
    Database db = await getDatabase();
    return await db.query('sports');
  }

  static Future<List<Map<String, dynamic>>> getExercisesBySport(
    int sportId,
  ) async {
    Database db = await getDatabase();

    return await db.query(
      'exercises',
      where: 'sportId = ?',
      whereArgs: [sportId],
    );
  }

  static Future<void> addFavorite(int userId, int sportId) async {
    Database db = await getDatabase();

    await db.insert('favorites', {
      'userId': userId,
      'sportId': sportId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<List<Map<String, dynamic>>> getFavorites(int userId) async {
    Database db = await getDatabase();

    return await db.rawQuery(
      '''
      SELECT favorites.id, favorites.sportId, sports.name, sports.description, sports.image
      FROM favorites
      INNER JOIN sports ON favorites.sportId = sports.id
      WHERE favorites.userId = ?
      ''',
      [userId],
    );
  }

  static Future<int> deleteFavorite(int favoriteId) async {
    Database db = await getDatabase();

    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [favoriteId],
    );
  }

  static Future<void> addHistory(
    int userId,
    int sportId,
    int exerciseId,
    String date,
  ) async {
    Database db = await getDatabase();

    await db.insert('history', {
      'userId': userId,
      'sportId': sportId,
      'exerciseId': exerciseId,
      'date': date,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<List<Map<String, dynamic>>> getHistory(int userId) async {
    Database db = await getDatabase();

    return await db.rawQuery(
      '''
      SELECT history.id, history.sportId, sports.name AS sportName, exercises.name AS exerciseName, history.date
      FROM history
      INNER JOIN sports ON history.sportId = sports.id
      INNER JOIN exercises ON history.exerciseId = exercises.id
      WHERE history.userId = ?
      ''',
      [userId],
    );
  }

  static Future<int> deleteHistory(int historyId) async {
    Database db = await getDatabase();

    return await db.delete('history', where: 'id = ?', whereArgs: [historyId]);
  }

  static Future<List<Map<String, dynamic>>> checkFavorite(
    int userId,
    int sportId,
  ) async {
    Database db = await getDatabase();

    return await db.query(
      'favorites',
      where: 'userId = ? AND sportId = ?',
      whereArgs: [userId, sportId],
    );
  }

  static Future<int> getTotalExercisesCount(int sportId) async {
    Database db = await getDatabase();

    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM exercises
      WHERE sportId = ?
      ''',
      [sportId],
    );

    return result[0]['total'] as int;
  }

  static Future<int> getCompletedExercisesCount(int userId, int sportId) async {
    Database db = await getDatabase();

    List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM history
      WHERE userId = ? AND sportId = ?
      ''',
      [userId, sportId],
    );

    return result[0]['total'] as int;
  }

  static Future<bool> isExerciseAlreadyCompleted(
    int userId,
    int sportId,
    int exerciseId,
  ) async {
    Database db = await getDatabase();

    List<Map<String, dynamic>> result = await db.query(
      'history',
      where: 'userId = ? AND sportId = ? AND exerciseId = ?',
      whereArgs: [userId, sportId, exerciseId],
    );

    return result.isNotEmpty;
  }

  static Future<int> removeFavoriteBySportId(int userId, int sportId) async {
    Database db = await getDatabase();

    return await db.delete(
      'favorites',
      where: 'userId = ? AND sportId = ?',
      whereArgs: [userId, sportId],
    );
  }
}
