import 'package:flutter/material.dart';
import 'package:one/enums/menu_action.dart';
import 'package:one/services/auth/auth_service.dart';
import 'package:one/services/crud/note_service.dart';
import 'package:one/utilities/dialogs/logout_dialog.dart';
import 'package:one/views/notes/note_list_view.dart';
import '../../constants/routes.dart';
import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView ({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}
class _NotesViewState extends State<NotesView> {

  late final NoteService _noteService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
   _noteService = NoteService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(onPressed: (){
            Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
          },
          icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              switch(value){
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                          (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context){
              return const [
                PopupMenuItem< MenuAction>(
                  value:MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _noteService.getOrCreateUser(email: userEmail),
        builder:(context,snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return  StreamBuilder(
                  stream: _noteService.allNotes,
                  builder: (context,snapshot){
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                       if (snapshot.hasData){
                         final allNotes = snapshot.data as List<DatabaseNotes>;
                         return NoteListView(
                             notes: allNotes,
                             onDeleteNote:(note) async{
                               await _noteService.deleteNote(id: note.id);
                             },
                           onTap: (note)async{
                             Navigator.of(context).pushNamed(
                               createOrUpdateNoteRoute,
                             arguments: note,
                             );
                           },
                         );
                       }
                       else {
                         return const CircularProgressIndicator();
                       }
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

