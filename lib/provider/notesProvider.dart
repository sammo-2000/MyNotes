import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];

  List<Note> get getMyNotes => _notes;

  void setNotes(List<Note> notes) {
    _notes = notes;
    _notes.sort((a, b) {
      // Compare the edit dates first
      var editDateA = a.editAt ?? a.createAt;
      var editDateB = b.editAt ?? b.createAt;

      // If the edit dates are equal, compare the create dates
      if (editDateA == editDateB) {
        return a.createAt!.compareTo(b.createAt!);
      } else {
        return editDateB!.compareTo(editDateA!); // Sort by edit date descending
      }
    });
    notifyListeners();
  }


  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void deleteNote(Note note) {
    _notes.remove(note);
    notifyListeners();
  }

  void editNote(Note oldNote, Note newNote) {
    // TODO
    notifyListeners();
  }
}
