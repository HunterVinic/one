// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:one/extensions/list/filter.dart';
// import 'package:one/services/crud/crud_exceptions.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DatabaseAlreadyOpenException implements Exception{}
//
// class NoteService{
//   Database? _db;
//   List<DatabaseNotes> _note = [];
//   DatabaseUser ? _user;
//
//   static final NoteService _shared =NoteService._sharedInstance();
//   NoteService._sharedInstance(){
//     _noteStreamController = StreamController<List<DatabaseNotes>>.broadcast(
//       onListen: (){
//         _noteStreamController.sink.add(_note);
//       },
//     );
//   }
//   factory NoteService() => _shared;
//
//   late final StreamController<List<DatabaseNotes>>_noteStreamController;
//
//   Stream<List<DatabaseNotes>> get allNotes=>
//       _noteStreamController.stream.filter((note){
//         final currentUser =_user;
//         if (currentUser !=null){
//            return note.userId == currentUser.id;
//         }else{
//           throw UserShouldBESetBeforeReadingAllNotes();
//         }
//       });
//
//   Future<DatabaseUser>getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   })async{
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser){
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser{
//       final createdUser = await createUser(email:email);
//       if (setAsCurrentUser){
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e){
//       rethrow;
//     }
//   }
//
//   Future<void> _cacheNotes()async{
//     final allNotes = await getAllNote();
//     _note = allNotes.toList();
//     _noteStreamController.add(_note);
//   }
//
//
//   Future<DatabaseNotes>updateNote({
//
//   required DatabaseNotes note,
//   required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db =_getDatabaseOrThrow();
//     await getNote(id:note.id);
//
//   final updatesCount = await db.update(noteTable,{
//     textColumn: text,
//     isSyncedWithCloudColumn:0,
//   },
//     where: 'id = ?',
//   whereArgs: [note.id],
//   );
//
//   if (updatesCount == 0){
//     throw CouldNotUpdateNote();
//   }else{
//     final updatedNote = await getNote(id: note.id);
//     _note.removeWhere((note) => note.id == updatedNote.id);
//     _note.add(updatedNote);
//     _noteStreamController.add(_note);
//     return updatedNote;
//   }
// }
//
//   Future<Iterable<DatabaseNotes>>getAllNote()async{
//     await _ensureDbIsOpen();
//     final db=_getDatabaseOrThrow();
//     final notes =await db.query(noteTable);
//     return notes.map((noteRow) =>DatabaseNotes.fromRow(noteRow));
//   }
//
//   Future<DatabaseNotes>getNote({required int id})async {
//     await _ensureDbIsOpen();
//     final db=_getDatabaseOrThrow();
//     final notes =await db.query(
//         noteTable,
//       limit:1,
//     where: 'id =?',
//     whereArgs: [id],
//     );
//     if(notes.isEmpty){
//       throw CouldNotFindNote();
//     } else{
//      final note = DatabaseNotes.fromRow(notes.first);
//      _note.removeWhere((note) => note.id == id);
//      _note.add(note);
//      _noteStreamController.add(_note);
//      return note;
//     }
//   }
//
//   Future<int> deleteAllNotes() async{
//     await _ensureDbIsOpen();
//   final db = _getDatabaseOrThrow();
//   final numberOfDeletions = await db.delete(noteTable);
//   _note =[];
//   _noteStreamController.add(_note);
//   return numberOfDeletions;
// }
//
//   Future<void>deleteNote({required int id}) async{
//     await _ensureDbIsOpen();
//     final db= _getDatabaseOrThrow();
//     final deleteCount = await db.delete(
//       noteTable,
//       where:'id = ?',
//       whereArgs: [id],
//     );
//     if (deleteCount == 0){
//       throw CouldNotDeleteNote();
//     } else{
//       _note.removeWhere((note) => note.id ==id);
//     _noteStreamController.add(_note);
//     }
//   }
//
//   Future<DatabaseNotes>createNote({required DatabaseUser owner})async{
//     final db=_getDatabaseOrThrow();
//     final dbUser =await getUser(email: owner.email);
//     if (dbUser != owner){
//       throw CouldNotFindUser();
//     }
//     const text ='';
//     final noteId = await db.insert(noteTable,{
//      userIdColumn: owner.id,
//     textColumn: text,
//     isSyncedWithCloudColumn: 1
//     });
//     final notes= DatabaseNotes(
//         id: noteId,
//         userId: owner.id,
//         text: text,
//         isSyncedwithCloud: true
//     );
//     _note.add(notes);
//     _noteStreamController.add(_note);
//
//     return notes;
//   }
//
//   Future<DatabaseUser> getUser({required String email}) async{
//     await _ensureDbIsOpen();
// final db= _getDatabaseOrThrow();
// final results = await db.query(
//   userTable,
//   limit: 1,
//   where: 'email = ?',
//   whereArgs: [email.toLowerCase()],
// );
// if(results.isEmpty) {
//   throw CouldNotFindUser();
// }else{
//   return DatabaseUser.fromRow(results.first);
// }
//   }
//
//   Future<DatabaseUser> createUser({required String email}) async{
//     await _ensureDbIsOpen();
//     final db =_getDatabaseOrThrow();
//     final results = await db.query(
//         userTable,
//         limit: 1,
//         where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if(results.isNotEmpty) {
//       throw UserAlreadyExists();
//     }
//     final userId = await db.insert(userTable,{
//       emailColumn:email.toLowerCase(),
//     });
//     return DatabaseUser(
//         id: userId,
//         email: email,
//     );
//   }
//
//   Future<void>deleteUser({required String email}) async{
//     await _ensureDbIsOpen();
//     final db= _getDatabaseOrThrow();
//    final deleteCount = await db.delete(
//      userTable,
//      where:'email = ?',
//     whereArgs: [email.toLowerCase()],
//     );
//    if (deleteCount != 1){
//      throw CouldNotDeleteUser();
//    }
//   }
//   Database _getDatabaseOrThrow(){
//     final db=_db;
//     if(db ==null){
//       throw DatabaseIsNotOpen();
//     } else{
//       return db;
//     }
//   }
//
//   Future<void> close() async{
//  final db= _db;
//     if (db == null){
//       throw DatabaseIsNotOpen();
//     }else{
//       await db.close();
//       _db =null;
//     }
// }
//
//  Future<void> _ensureDbIsOpen()async{
//       try{
//         await open();
//       } on DatabaseAlreadyOpenException{
//     }
// }
//
//   Future<void> open() async{
//     if (_db != null){
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db =db;
//
//       await db.execute(createUserTable);
//
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException{
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
// }
// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser ({
//     required this.id,
//     required this.email,
// });
//   DatabaseUser.fromRow(Map<String,Object?>map):
//         id = map[idColumn]as int,
//         email = map[emailColumn]as String;
//   @override
//   String toString() => 'Person, ID =$id. email =  $email';
//
//   @override
//   bool operator ==(covariant DatabaseUser other)=> id == other.id;
//
//   @override
//   int get hashCode =>id.hashCode;
//   }
//
//   class DatabaseNotes{
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedwithCloud;
//
//   DatabaseNotes({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedwithCloud
//   });
//   DatabaseNotes.fromRow(Map<String,Object?>map):
//         id = map[idColumn]as int,
//         userId = map[userIdColumn]as int,
//         text = map[textColumn] as String,
//         isSyncedwithCloud =
//         (map[isSyncedWithCloudColumn]as int) ==1 ? true :false;
//
//   @override
//     String toString() =>
//       'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedwithCloud, text =$text';
//
//
//   @override
//   bool operator ==(covariant DatabaseUser other)=> id == other.id;
//
//   @override
//   int get hashCode =>id.hashCode;
//
//   }
//   const dbName ='notes.db';
// const noteTable ='note';
// const userTable ='user';
// const idColumn ='id';
// const emailColumn ='email';
// const userIdColumn ='user_id';
// const textColumn ='text';
// const isSyncedWithCloudColumn= 'is_synced_with_cloud';
// const createUserTable ='''CREATE TABLE IF NOT EXISTS "user" (
// 	"id"	INTEGER NOT NULL,/
// 	"email"	TEXT NOT NULL UNIQUE,
// 	PRIMARY KEY("id" AUTOINCREMENT)
// );''';
// const createNoteTable = '''CREATE TABLE "note" (
// 	"id"	INTEGER NOT NULL,
// 	"user_id"	INTEGER NOT NULL,
// 	"text"	TEXT,
// 	"is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
// 	PRIMARY KEY("id" AUTOINCREMENT),
// 	FOREIGN KEY("user_id") REFERENCES "user"("id")
// );''';