import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/database/firebase.dart';
import 'package:notes/database/sqlite.dart';
import 'package:notes/models/noteModel.dart';
import 'package:notes/providers/cloudProvider.dart';
import 'package:notes/providers/notesProvider.dart';
import 'package:notes/screens/homeScreen.dart';
import 'package:notes/widgets/button.dart';
import 'package:notes/widgets/forms/input.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateEditNoteScreen extends StatefulWidget {
  final bool createPage;
  final Note? note;
  const CreateEditNoteScreen({
    super.key,
    required this.createPage,
    this.note,
  });

  @override
  State<CreateEditNoteScreen> createState() => _CreateEditNoteScreenState();
}

class _CreateEditNoteScreenState extends State<CreateEditNoteScreen> {
  String errorMessege = "";
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  XFile? imageFile;
  String? filePath;
  DateTime? reminderDateTime;
  DateTime? createAt;
  DateTime? editAt;

  // Handle edit
  @override
  void initState() {
    super.initState();
    if (widget.createPage == false) {
      titleController.text = widget.note!.title;
      noteController.text = widget.note!.note;
      widget.note!.filePath != null ? filePath = widget.note!.filePath : "";
      widget.note!.reminderDateTime != null
          ? reminderDateTime = widget.note!.reminderDateTime
          : "";
      createAt = widget.note!.createAt;
      widget.note!.editAt != null ? editAt = widget.note!.editAt : "";
    }
  }

  // Handle form submit
  Future<void> handleSubmit(bool isSync, var noteProvider ) async {
    try {
      if (titleController.text.isEmpty) throw 'Title is required';
      if (noteController.text.isEmpty) throw 'Note is required';
      await addImage();
      if (widget.createPage == true) {
        await createNote(isSync, noteProvider);
      } else {
        await updateNote(isSync, noteProvider);
      }
      redirect();
    } catch (e) {
      setState(() {
        errorMessege = e.toString();
      });
    }
  }

  Future<void> createNote(bool isSync, var noteProvider) async {
    final User? user = FirebaseAuth.instance.currentUser;
    Note note = Note(
      email: user!.email,
      title: titleController.text,
      note: noteController.text,
      filePath: filePath,
      reminderDateTime: reminderDateTime,
      createAt: DateTime.now(),
    );
    // Save To Local Storage
    int noteID = await MyDatabase.addNote(note);
    if (isSync) {
      // Save To Cloud Storage
      note.id = noteID;
      MyFireBase myFirebase = MyFireBase();
      myFirebase.add(note);
    }
    // Add The Note To state
    noteProvider.addNote(note);
  }

  Future<void> updateNote(bool isSync, var noteProvider) async {
    Note note = Note(
      email: widget.note!.email,
      id: widget.note!.id,
      title: titleController.text,
      note: noteController.text,
      filePath: filePath,
      reminderDateTime: reminderDateTime,
      createAt: createAt,
      editAt: DateTime.now(),
    );
    // Save To Local Storage
    await MyDatabase.updateNote(note);
    if (isSync) {
      MyFireBase myFirebase = MyFireBase();
      myFirebase.update(note);
    }
    // Add The Note To state
    noteProvider.editNote(note);
  }

  void redirect() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  // IMAGE HANDLER START -------------------------------------------------------
  Future<void> addImage() async {
    // If user has not selected image return
    if (imageFile == null) return;
    // If the user is on edit page, delete older image first
    if (filePath != null && widget.createPage == false) {
      await deleteImage(filePath!);
    }
    // Create new image name
    DateTime now = DateTime.now();
    // Get app DIR to save image at
    Directory appDocDir = await getApplicationDocumentsDirectory();
    // Create image path
    String imagePath = '${appDocDir.path}/$now';
    // Save the image
    File(imageFile!.path).copy(imagePath);
    // Return the path name to store in DB
    filePath = imagePath;
  }

  // Delete image from storage
  Future<void> deleteImage(String imagePath) async {
    // Check image path is not empty
    if (imagePath.isNotEmpty) {
      // Get the image from storage
      File imageFile = File(imagePath);
      // Check if image exists
      if (await imageFile.exists()) {
        // Delete the image
        await imageFile.delete();
      }
    }
  }

  // Image Picker
  Future<void> pickImage() async {
    showDialog(
      context: context,
      builder: (context) {
        // Create Dialog To Ask User If They
        // Want Image From Storage Or Camera
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4,
          actions: [
            const SizedBox(height: 20.0),
            CustomButton(
              label: 'Camera',
              icon: Icons.camera_alt,
              onClick: fromCamera,
            ),
            CustomButton(
              label: 'Gallery',
              icon: Icons.photo_sharp,
              onClick: fromGallery,
            ),
            CustomButton(
              label: 'Cancel',
              icon: Icons.cancel,
              onClick: () {
                Navigator.of(context).pop();
              },
              color: Colors.red.shade400,
            ),
          ],
        );
      },
    );
  }

  // Image From Gallery
  Future fromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;

    setState(() {
      imageFile = returnedImage;
      Navigator.pop(context);
    });
  }

  // Image From Camera
  Future fromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage == null) return;
    setState(() {
      imageFile = returnedImage;
      Navigator.pop(context);
    });
  }
  // IMAGE HANDLER END -------------------------------------------------------

  // REMINDER HANDLER START -------------------------------------------------------
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

    setState(
      () {
        reminderDateTime = pickedDateTime;
      },
    );
  }

  Future<DateTime?> pickDate(DateTime now) => showDatePicker(
        context: context,
        firstDate: DateTime(now.year),
        lastDate: DateTime(2200),
        initialDate: DateTime(
          now.year.toInt(),
        ),
      );

  Future<TimeOfDay?> pickTime(DateTime now) => showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: now.hour,
          minute: now.minute,
        ),
      );
  // REMINDER HANDLER END -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cloudProvider = Provider.of<CloudProvider>(context);
    final noteProvider = Provider.of<NoteProvider>(context);
    return Scaffold(
      appBar: AppBar(
          title: widget.createPage
              ? const Text('C R E A T E   N O T E')
              : const Text('E D I T   N O T E')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
              if (errorMessege == "")
                const SizedBox()
              else
                CustomButton(
                  label: errorMessege,
                  icon: Icons.error,
                  color: Colors.red,
                  onClick: () {},
                ),
              Row(
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
              CustomInput(controller: titleController, label: 'Title'),
              CustomInput(controller: noteController, label: 'Note'),
              showImage(filePath, imageFile),
              CustomButton(
                label: widget.createPage
                    ? 'C R E A T E   N O T E S'
                    : 'E D I T   N O T E S',
                icon: widget.createPage ? Icons.add : Icons.edit,
                onClick: () {
                  handleSubmit(
                    cloudProvider.isSync,
                    noteProvider
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget showImage(String? filePath, XFile? imageFile) {
  if (filePath == null && imageFile == null) {
    // Display nothing if there are no images
    return const Text('No IMAGE');
  } else if (filePath != null && imageFile == null) {
    // Display older images if it exists and no new image is selected
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.file(
            File(filePath),
            height: 300,
          ),
        ),
      ],
    );
  } else {
    // Display the new image
    return imageFile == null
        ? const SizedBox()
        : Image.file(
            File(imageFile.path),
            height: 300,
          );
  }
}
