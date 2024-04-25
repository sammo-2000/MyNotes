import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/provider/cloudProvider.dart';
import 'package:notes/screens/listNoteScreen.dart';
import 'package:notes/services/dbConnect.dart';
import 'package:notes/services/firebase.dart';
import 'package:notes/widget/button.dart';
import 'package:notes/widget/dialog.dart';
import 'package:notes/widget/form/input.dart';
import 'package:notes/widget/form/text.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  // Variables
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  XFile? imageFile;
  String? filePath;
  DateTime? reminderDateTime;

  // Functions
  void validateFields() {
    if (titleController.text.isEmpty) throw 'Title is required';
    if (noteController.text.isEmpty) throw 'Note is required';
  }

  Future<void> saveImage() async {
    if (imageFile == null) return;
    DateTime now = DateTime.now();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String imagePath = '${appDocDir.path}/$now';
    File(imageFile!.path).copy(imagePath);
    filePath = imagePath;
  }

  Future<void> formSubmit(bool isSyncToCloud) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw 'User not authenticated';
      }

      if (user.email == null) {
        throw 'User email not available';
      }

      print('User email: ${user.email}');

      validateFields();
      await saveImage();

      Note newNote = Note(
        email: user!.email,
        title: titleController.text,
        note: noteController.text,
        filePath: filePath,
        reminderDateTime: reminderDateTime,
        createAt: DateTime.now(),
      );

      int noteID = await MyDatabase.addNote(newNote);

      if (isSyncToCloud) {
        newNote.id = noteID;
        MyFireBase myFirebase = MyFireBase();
        myFirebase.add(newNote);
      }

      redirect();
      return;
    } catch (e) {
      showError(e);
      return;
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
    final cloudProvider = Provider.of<CloudProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('A D D   N O T E S')),
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
              if (imageFile == null)
                const SizedBox()
              else
                Image.file(File(imageFile!.path), height: 300),
              CustomButton(
                onClick: () {
                  formSubmit(cloudProvider.isSync);
                },
                label: 'Add',
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
