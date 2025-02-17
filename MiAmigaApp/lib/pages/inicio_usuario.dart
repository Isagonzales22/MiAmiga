import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miamiga_app/components/important_button.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';
import 'package:miamiga_app/model/datos_registro_usuario.dart';
import 'package:miamiga_app/pages/incidente_usuario.dart';

class InicioScreen extends StatefulWidget {
  final User? user;
  final IncidentData incidentData;
  final DenuncianteData denunciaData;
  const InicioScreen({
    super.key,
    required this.user,
    required this.incidentData,
    required this.denunciaData,
  });

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  Future<String> getUserName(User? user) async {
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          final fullName = snapshot.get('fullname');
          return fullName;
        } else {
          return 'Usuario desconocido';
        }
      } catch (e) {
        print('Error getting user name: $e');
        return 'Usuario desconocido';
      }
    } else {
      return 'Usuario desconocido';
    }
  }

  void denunciarScreen() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DenunciaIncidente(
          user: widget.user,
          incidentData: widget.incidentData,
          denuncianteData: widget.denunciaData,
        ),
      ),
    );
  }

  Future<UserRegister> fetchDenuncianteData(String? userId) async {
    if (userId == null) {
      throw Exception('User ID is null');
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('No user found with ID $userId');
    }

    return UserRegister(
      ci: doc.get('ci'),
      fullname: doc.get('fullname'),
      email: doc.get('email'),
      phone: doc.get('phone'),
      lat: doc.get('lat'),
      long: doc.get('long'),
    );
  }

  Future<void> createAlert(User? user) async {
    try {
      String? userId = user?.uid;

      if (userId == null) {
        print('Error: User is null or does not have UID');
        return;
      }

      UserRegister userRegister = await fetchDenuncianteData(userId);

      final CollectionReference _alert =
          FirebaseFirestore.instance.collection('alert');

      QuerySnapshot<Object?> userAlerts =
          await _alert.where('user', isEqualTo: userId).get();

      int newAlert = userAlerts.docs.isNotEmpty
          ? userAlerts.docs.first.get('alert') + 1
          : 1;

      bool confirmAlert = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Alerta'),
            content: const Text('Deseas crear un alerta?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    color: Color.fromRGBO(255, 87, 110, 1),
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (confirmAlert == true) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(255, 87, 110, 1),
                ),
              );
            });

        if (userAlerts.docs.isNotEmpty) {
          DocumentSnapshot<Object?> userAlert = userAlerts.docs.first;

          await _alert.doc(userAlert.id).update({
            'alert': newAlert,
            'fecha': DateTime.now(),
          });

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alerta actualizada'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await _alert.add({
            'alert': newAlert,
            'user': userId,
            'ci': userRegister.ci,
            'fullname': userRegister.fullname,
            'email': userRegister.email,
            'phone': userRegister.phone,
            'lat': userRegister.lat,
            'long': userRegister.long,
            'fecha': DateTime.now(),
          });

          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alerta creada'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear alerta'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      print('Error al crear el caso: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            FutureBuilder<String>(
              future: getUserName(widget.user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Color.fromRGBO(255, 87, 110, 1),
                  ));
                } else {
                  final userName = snapshot.data ?? 'Usuario desconocido';
                  return Column(
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Bienvenid@ \n', // Primer línea: Bienvenido seguido de un salto de línea
                          style: TextStyle(fontSize: 40), // Tamaño de letra para 'Bienvenido'
                          children: <TextSpan>[
                            TextSpan(
                              text: '$userName', // Segunda línea: Nombre de usuario
                              style: TextStyle(fontSize: 30), // Tamaño de letra para el nombre de usuario
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center, // Centra el texto
                      ),
                      SizedBox(height: 20), // Espacio entre el texto y el primer botón
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: MyImportantBtn(
                          text: 'DENUNCIAR',
                          onTap: denunciarScreen,
                        ),
                      ),
                      SizedBox(height: 10), // Espacio entre los botones
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: ImportantButton(
                          text: 'ALERTA',
                          onTap: () async {
                            User? user = widget.user;
                            await createAlert(user);
                          },
                          icon: Icons.warning_rounded,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}
