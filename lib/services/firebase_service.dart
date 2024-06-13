import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<void> updateSupervisor(String uid, String newName) async {
  await db.collection('supervisor').doc(uid).set({"fullname": newName});
}

Future<List> getSupervisor() async {
  List supervisor = [];
  CollectionReference collectionReference = db.collection('supervisor');

  QuerySnapshot querySupervisor = await collectionReference.get();

  querySupervisor.docs.forEach((documento) {
    supervisor.add(documento.data());
  });

  return supervisor;
}

Future<List> getCasos() async {
  List supervisor = [];
  CollectionReference collectionReference = db.collection('cases');

  QuerySnapshot query = await collectionReference.get();

  query.docs.forEach((documento) {
    supervisor.add(documento.data());
  });

  return supervisor;
}

Future<int> getCasosCount() async {
  CollectionReference collectionReferenceCasos = db.collection('cases');
  QuerySnapshot queryCasos = await collectionReferenceCasos
      .where('estado', isEqualTo: 'pendiente')
      .get();
  return queryCasos.size;
}

Future<int> getSupervisorCount() async {
  CollectionReference collectionReferenceSupervisor = db.collection('users');
  QuerySnapshot querySupervisor = await collectionReferenceSupervisor
      .where('role', isEqualTo: 'Supervisor')
      .get();
  return querySupervisor.size;
}

Future<int> getUsersCount() async {
  CollectionReference collectionReferenceCasos = db.collection('users');
  QuerySnapshot queryUsers = await collectionReferenceCasos.get();
  return queryUsers.size;
}

//Guardar un descripcion en la BD
Future<void> addCase(
  String name,
  String email,
  String phone,
  String ci,
  //String latitude,
  //String longitude,
  //int status,
  //String creationDate,
  //String lastUpdate
) async {
  await db.collection("supervisor").add({
    "fullname": name,
    "email": email,
    "phone": phone,
    "ci": ci,
    "role": "Supervisor"
    //"latitude": latitude,
    //"longitude": longitude,
    //"status": 1,
    //"creationDate": 18/10/2003,
    //"lasUpdate": ""
  });
}
