import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreDataSuper {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required Uint8List file,
    required String userId,
  }) async {
    String res = "Se occurio un error";
    try {
      String folderPath = 'PerfilSupervisor/$userId/';
      String imageUrl = await uploadImageToStorage(
          '$folderPath${DateTime.now().millisecondsSinceEpoch}', file);
      await _firestore.collection('imageUser').doc(userId).set({
        'imageUrl': imageUrl,
        'id': userId,
      });
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
