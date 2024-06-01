import 'dart:io';

import 'package:chitchat/models/UIhelper.dart';
import 'package:chitchat/pages/homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseUser;

  const CompleteProfile(
      {super.key, required this.usermodel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Upload Profile Picture"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Select from gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a photo"),
                ),
              ]));
        });
  }

  void checkValues() {
    String fullName = fullNameController.text.trim();
    if (fullName == "" || imageFile == null) {
      UIhelper.showAlertDialog(context, "Incomplete Data",
          "Please fill all the fields and upload a profile picture");
    } else {
      UploadData(fullName);
    }
  }

  void UploadData(String fullName) async {
    UIhelper.showLoadingDialog(context, "Uploading Image..");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.usermodel.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String imageurl = await snapshot.ref.getDownloadURL();

    widget.usermodel.fullname = fullName;
    widget.usermodel.profilepic = imageurl;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.usermodel.uid)
        .set(widget.usermodel.toMap())
        .then((value) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(
            userModel: widget.usermodel, firebaseUser: widget.firebaseUser);
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text("Complete Profile"),
        ),
        body: SafeArea(
          child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
              ),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      showPhotoOptions();
                    },
                    padding: const EdgeInsets.all(0),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          (imageFile != null) ? FileImage(imageFile!) : null,
                      child: (imageFile == null)
                          ? const Icon(
                              Icons.person,
                              size: 60,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: fullNameController,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: () {
                      checkValues();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: const Text("Submit"),
                  )
                ],
              )),
        ));
  }
}
