import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FireStorageProvider {
  static String TAG = "FireStorageProvider";

  static String FIRESTORAGE_REF_USERPROFILE = "userprofile";
  static String FIRESTORAGE_REF_EVENEMENT = "evenements";
  static String FIRESTORAGE_REF_SONDAGE = "sondages";
  static String FIRESTORAGE_REF_ANNONCER = "annoncer";
  static String FIRESTORAGE_REF_POST = "post";

  static Future<String> fireUploadFileToRef(
      String fireStorageRef, String filePath, String filename) async {
    File file = File(filePath);

    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('$fireStorageRef/$filename');
    UploadTask uploadTask = firebaseStorageRef.putFile(file);
    /*TaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshot.ref.getDownloadURL().then(
            (value) => ("Done: $value"),
          );*/
    return await uploadTask.then((res) {
      return res.ref.getDownloadURL();
    });

    /*try {
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('$fireStorageRef/$filename');
      UploadTask uploadTask = firebaseStorageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshot.ref.getDownloadURL().then(
            (value) => ("Done: $value"),
          );

      return await taskSnapshot.ref.getDownloadURL();

      /*var resultUpload = await firebase_storage.FirebaseStorage.instance
          .ref().child('$fireStorageRef/$filename');
      firebase_storage.StorageUploadTask uploadTask = resultUpload.putFile(file);
      print("$TAG:fireUploadFileToRef file uploaded success resultUpload=${await resultUpload.getDownloadURL()}\n${resultUpload.toString()}\nfilePath=${filePath} | filename=$filename");

      return resultUpload.getDownloadURL();*/
    } catch (e) {
      print("$TAG:fireUploadFileToRef:catch ${e}");
      return null;
    }*/
  }
}
