import 'package:flutter/material.dart';
import 'package:one/services/crud/note_service.dart';
import 'package:one/utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallBack = void Function(DatabaseNotes note);
class NoteListView extends StatelessWidget {

  final List<DatabaseNotes>notes;
  final DeleteNoteCallBack onDeleteNote;

  const NoteListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context,index){
        final note = notes[index];
        return ListTile(
          title: Text (
            note.text,
            maxLines: 1,
            softWrap:  true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async{
              final shouldDelete = await showDeleteDialog(context);
              if(shouldDelete){
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}