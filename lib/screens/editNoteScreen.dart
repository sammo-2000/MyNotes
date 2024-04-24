import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/listNoteScreen.dart';
import 'package:notes/services/dbConnect.dart';
import 'package:notes/widget/button.dart';
import 'package:notes/widget/dialog.dart';
import 'package:notes/widget/form/input.dart';
import 'package:notes/widget/form/text.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;
  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  // Variables
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  XFile? imageFile;
  String? filePath;
  DateTime? reminderDateTime;
  DateTime? createAt;
  DateTime? editAt;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.note.title;
    noteController.text = widget.note.note;
    widget.note.filePath != null ? filePath = widget.note.filePath : "";
    widget.note.reminderDateTime != null ? reminderDateTime = widget.note.reminderDateTime : "";
    createAt = widget.note.createAt;
    widget.note.editAt != null ? editAt = widget.note.editAt : "";
  }

  // Functions
  void validateFields() {
    if (titleController.text.isEmpty) throw 'Title is required';
    if (noteController.text.isEmpty) throw 'Note is required';
  }

  Future<void> updateImage() async {
    if (imageFile == null) return;
    if (filePath != null ) await deleteImage(filePath!);
    DateTime now = DateTime.now();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String imagePath = '${appDocDir.path}/$now';
    File(imageFile!.path).copy(imagePath);
    filePath = imagePath;
  }

  Future<void> deleteImage(String imagePath) async {
    if (imagePath.isNotEmpty) {
      File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }
  }

  void formSubmit() async {
    try {
      validateFields();
      await updateImage();

      Note noteToEdit = Note(
        id: widget.note.id,
        title: titleController.text,
        note: noteController.text,
        filePath: filePath,
        reminderDateTime: reminderDateTime,
        createAt: createAt,
        editAt: DateTime.now(),
      );
      await MyDatabase.updateNote(noteToEdit);
      redirect();
    } catch (e) {
      showError(e);
    }
  }

  void showError(Object e) {
    CustomDialog.show(
      context,
      'Error',
      e.toString(),
    );
  }

  void redirect() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ListNoteScreen(),
      ),
    );
  }

  void pickImage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4,
          actions: [
            const SizedBox(height: 20.0),
            CustomButton(
                label: 'Camera', icon: Icons.camera_alt, onClick: fromCamera),
            CustomButton(
                label: 'Gallery',
                icon: Icons.photo_sharp,
                onClick: fromGallery),
            CustomButton(
              label: 'Cancel',
              icon: Icons.cancel,
              onClick: () {
                Navigator.of(context).pop();
              },
              color: Colors.red.shade400,
            )
          ],
        );
      },
    );
  }

  Future fromGallery() async {
    final returnedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;

    setState(() {
      imageFile = returnedImage;
      Navigator.pop(context);
    });
  }

  Future fromCamera() async {
    final returnedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage == null) return;
    setState(() {
      imageFile = returnedImage;
      Navigator.pop(context);
    });
  }

  Future pickDateTime() async {
    DateTime now = DateTime.now();

    DateTime? date = await pickDate(now);
    if (date == null) return;

    TimeOfDay? time = await pickTime(now);
    if (time == null) return;

    final pickedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      reminderDateTime = pickedDateTime;
    });
  }

  Future<DateTime?> pickDate(DateTime now) => showDatePicker(
    context: context,
    firstDate: DateTime(now.year),
    lastDate: DateTime(2200),
    initialDate: DateTime(now.year.toInt()),
  );

  Future<TimeOfDay?> pickTime(DateTime now) => showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: now.hour,
      minute: now.minute,
    ),
  );

  // Widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E D I T   N O T E S')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onClick: pickImage,
                      label: 'Image',
                      icon: Icons.image,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: CustomButton(
                      onClick: pickDateTime,
                      label: 'Reminder',
                      icon: Icons.timer,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    reminderDateTime == null
                        ? const Text('No reminder set')
                        : Text(
                      DateFormat('MMMM dd, yyyy - hh:mm a')
                          .format(reminderDateTime!)
                          .toString(),
                    ),
                  ],
                ),
              ),
              CustomInput(controller: titleController, label: 'Title'),
              CustomText(controller: noteController, label: 'Note'),
              imageFile == null
                  ? const SizedBox()
                  : Image.file(
                File(imageFile!.path),
                height: 300,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    onClick: formSubmit,
                    label: 'Edit',
                    icon: Icons.edit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
