import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sport.dart';
import '../models/exercise.dart';
import '../models/user.dart';

class DatabaseSevice {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    Directory dbDirectory = await getApplicationDocumentsDirectory();
    String path = join(dbDirectory.path, "sportfit.db");

    _database = await openDatabase(
      path,
      version: 2,
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
          date TEXT
        )
        ''');

        await db.execute('''
        CREATE TABLE completed_exercises(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          sportId INTEGER,
          exerciseId INTEGER,
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
        await db.execute(
          'CREATE INDEX idx_completed_user_sport_exercise ON completed_exercises(userId, sportId, exerciseId)',
        );

        await insertDefaultSports(db);
        await insertDefaultExercises(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE completed_exercises(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            sportId INTEGER,
            exerciseId INTEGER,
            UNIQUE(userId, sportId, exerciseId)
          )
          ''');

          await db.execute(
            'CREATE INDEX idx_completed_user_sport_exercise ON completed_exercises(userId, sportId, exerciseId)',
          );

          List<Map<String, dynamic>> oldHistory = await db.query('history');

          for (int i = 0; i < oldHistory.length; i++) {
            await db.insert('completed_exercises', {
              'userId': oldHistory[i]['userId'],
              'sportId': oldHistory[i]['sportId'],
              'exerciseId': oldHistory[i]['exerciseId'],
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
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
        description: "Practice ball control while moving around the court.",
        type: "outdoor",
        duration: 30,
      ),
      Exercise(
        sportId: 1,
        name: "Layup Practice",
        description:
            "Practice right-hand and left-hand layups near the basket.",
        type: "outdoor",
        duration: 30,
      ),
      Exercise(
        sportId: 1,
        name: "Shooting Drill",
        description:
            "Take repeated shots from different positions on the court.",
        type: "outdoor",
        duration: 60,
      ),
      Exercise(
        sportId: 1,
        name: "Passing Drill",
        description: "Work on chest passes and bounce passes with accuracy.",
        type: "outdoor",
        duration: 90,
      ),
      Exercise(
        sportId: 1,
        name: "Wall Sit",
        description:
            "Build leg strength and endurance for better court movement.",
        type: "indoor",
        duration: 30,
      ),
      Exercise(
        sportId: 1,
        name: "Squats",
        description:
            "Strengthen lower body muscles used in jumping and defense.",
        type: "indoor",
        duration: 20,
      ),
      Exercise(
        sportId: 1,
        name: "Jumping Jacks",
        description: "Improve stamina and warm up the full body indoors.",
        type: "indoor",
        duration: 20,
      ),
      Exercise(
        sportId: 1,
        name: "High Knees",
        description: "Boost speed, coordination, and cardio indoors.",
        type: "indoor",
        duration: 40,
      ),
      Exercise(
        sportId: 2,
        name: "Serve Practice",
        description: "Practice consistent tennis serves with proper form.",
        type: "outdoor",
        duration: 20,
      ),
      Exercise(
        sportId: 2,
        name: "Forehand Rally",
        description: "Improve your forehand control and accuracy.",
        type: "outdoor",
        duration: 30,
      ),
      Exercise(
        sportId: 2,
        name: "Backhand Rally",
        description: "Practice backhand shots with balance and timing.",
        type: "outdoor",
        duration: 60,
      ),
      Exercise(
        sportId: 2,
        name: "Footwork Cones",
        description: "Move quickly through cones to improve court footwork.",
        type: "outdoor",
        duration: 40,
      ),
      Exercise(
        sportId: 2,
        name: "Shadow Swings",
        description: "Practice swing technique indoors without hitting a ball.",
        type: "indoor",
        duration: 20,
      ),
      Exercise(
        sportId: 2,
        name: "Lunges",
        description: "Strengthen legs for fast movement across the court.",
        type: "indoor",
        duration: 30,
      ),
      Exercise(
        sportId: 2,
        name: "Core Twists",
        description: "Build core strength for stronger and more stable shots.",
        type: "indoor",
        duration: 30,
      ),
      Exercise(
        sportId: 2,
        name: "Jump Rope",
        description: "Improve rhythm, stamina, and foot speed indoors.",
        type: "indoor",
        duration: 60,
      ),
      Exercise(
        sportId: 3,
        name: "Passing Drill",
        description: "Practice accurate short and long passes on the field.",
        type: "outdoor",
        duration: 20,
      ),
      Exercise(
        sportId: 3,
        name: "Dribbling Through Cones",
        description: "Weave through cones to improve ball control and agility.",
        type: "outdoor",
        duration: 30,
      ),
      Exercise(
        sportId: 3,
        name: "Shooting Practice",
        description: "Take repeated shots on goal to improve finishing.",
        type: "outdoor",
        duration: 20,
      ),
      Exercise(
        sportId: 3,
        name: "Sprint Intervals",
        description: "Build speed and endurance with short sprint sets.",
        type: "outdoor",
        duration: 20,
      ),
      Exercise(
        sportId: 3,
        name: "Squats",
        description: "Build leg strength for running, shooting, and balance.",
        type: "indoor",
        duration: 20,
      ),
      Exercise(
        sportId: 3,
        name: "Plank Hold",
        description: "Strengthen the core for better balance and stability.",
        type: "indoor",
        duration: 30,
      ),
      Exercise(
        sportId: 3,
        name: "Mountain Climbers",
        description: "Improve cardio, coordination, and lower body movement.",
        type: "indoor",
        duration: 40,
      ),
      Exercise(
        sportId: 3,
        name: "Toe Taps",
        description: "Practice quick foot movement and coordination indoors.",
        type: "indoor",
        duration: 30,
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
    });
  }

  static Future<void> markExerciseCompleted(
    int userId,
    int sportId,
    int exerciseId,
  ) async {
    Database db = await getDatabase();

    await db.insert('completed_exercises', {
      'userId': userId,
      'sportId': sportId,
      'exerciseId': exerciseId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<List<Map<String, dynamic>>> getHistory(int userId) async {
    Database db = await getDatabase();

    return await db.rawQuery(
      '''
    SELECT 
      history.id,
      history.sportId,
      history.exerciseId,
      history.date,
      sports.name AS sportName,
      exercises.name AS exerciseName,
      exercises.type,
      exercises.duration
    FROM history
    INNER JOIN sports ON history.sportId = sports.id
    INNER JOIN exercises ON history.exerciseId = exercises.id
    WHERE history.userId = ?
    ORDER BY history.date DESC
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
      FROM completed_exercises
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
      'completed_exercises',
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
