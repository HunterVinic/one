import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:one/services/auth/bloc/auth_bloc.dart';
import 'package:one/services/auth/bloc/auth_event.dart';
import 'package:one/services/cloud/cloud_note.dart';
import '../../constants/routes.dart';
import 'package:one/enums/menu_action.dart';
import 'package:one/services/auth/auth_service.dart';
import 'package:one/services/cloud/firebase_cloud_storage.dart';
import 'package:one/utilities/dialogs/logout_dialog.dart';
import 'package:one/views/notes/note_list_view.dart';


class NotesView extends StatefulWidget {
  const NotesView ({Key? key}) : super(key: key);

  @override
  _NotesViewState createState() => _NotesViewState();
}
class _NotesViewState extends State<NotesView> {

  late final FirebaseCloudStorage _noteService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
   _noteService = FirebaseCloudStorage();
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
                    context.read<AuthBloc>().add(
                      const AuthEventLogOut(),
                    );
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
        body: StreamBuilder <Iterable>(
          stream: _noteService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = List<CloudNote>.from (snapshot.data!);
                  return NoteListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _noteService.deleteNote(documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              default:
                return const CircularProgressIndicator();
          }
        },
      )
    );
  }
}

