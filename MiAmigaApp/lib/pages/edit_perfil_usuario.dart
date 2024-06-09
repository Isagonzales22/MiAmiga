import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/phoneKeyboard.dart';
import 'package:miamiga_app/pages/google_maps.dart';

class EditPerfil extends StatefulWidget {
  final User? user;

  const EditPerfil({
    super.key,
    required this.user,
  });

  @override
  State<EditPerfil> createState() => _EditPerfilState();
}

class _EditPerfilState extends State<EditPerfil> {
  late LocationData modifiedLocation;

  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  bool controlVentanaRefresh = false;

  final CollectionReference _registration =
      FirebaseFirestore.instance.collection('users');

  Future<bool> _updateData(String userId, String fullName, int phone,
      double lat, double long) async {
    try {
      final DocumentReference userDocument = _registration.doc(userId);
      final DocumentSnapshot currentData = await userDocument.get();
      final Map<String, dynamic> currentValues =
          currentData.data() as Map<String, dynamic>;

      if (fullName.isEmpty || phone.toString().isEmpty || lat.toString().isEmpty || long.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete su perfil antes de actualizar'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }

      if (currentValues['fullname'] == fullName &&
          currentValues['phone'] == phone &&
          currentValues['lat'] == lat &&
          currentValues['long'] == long) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se han realizado cambios.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      } else {
        await userDocument.update({
          'fullname': fullName,
          'phone': phone,
          'lat': lat,
          'long': long,
        });
        controlVentanaRefresh = false;
        _fetchData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guardado exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        return true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error actualizando datos: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
  }

  double lat = 0.0;
  double long = 0.0;

  Future<void> _fetchData() async {
    try {
      if (widget.user != null && controlVentanaRefresh != true) {
        final DocumentSnapshot documentSnapshot =
            await _registration.doc(widget.user!.uid).get();

        if (documentSnapshot.exists) {
          fullnameController.text = documentSnapshot['fullname'];
          phoneController.text = documentSnapshot['phone'].toString();
          double latitude = documentSnapshot['lat'] as double;
          double longitude = documentSnapshot['long'] as double;

          lat = latitude;
          long = longitude;
        } else {
          print("No existe el documento.");
        }
      } else {
        print("El usuario es nulo.");
      }
    } catch (e) {
      print("Error en obtener datos: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<Map<String, String>> getUserModifiedLocation() async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        long,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        final String calle = placemark.thoroughfare ?? '';
        final String avenida = placemark.subLocality ?? '';
        final String localidad = placemark.locality ?? '';
        final String pais = placemark.country ?? '';

        final String fullStreet =
            avenida.isNotEmpty ? '$calle, $avenida' : calle;

        return {
          'street': fullStreet,
          'locality': localidad,
          'country': pais,
        };
      } else {
        return {
          'street': 'No se pudo obtener la ubicación',
          'locality': 'No se pudo obtener la ubicación',
          'country': 'No se pudo obtener la ubicación',
        };
      }
    } catch (e) {
      return {
        'street': 'No se pudo obtener la ubicación',
        'locality': 'No se pudo obtener la ubicación',
        'country': 'No se pudo obtener la ubicación',
      };
    }
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
              Row(
                children: [
                  const Header(
                    header: 'Editar Perfil',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              FutureBuilder(
                future: _fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(255, 87, 110, 1),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Column(
                      children: [
                        const SizedBox(height: 25),
                        MyTextField(
                          controller: fullnameController,
                          text: 'Nombre Completo',
                          hintText: 'Nombre Completo',
                          obscureText: false,
                          isEnabled: true,
                          isVisible: true,
                        ),
                        const SizedBox(height: 15),
                        MyPhoneKeyboard(
                          controller: phoneController,
                          text: 'Teléfono',
                          hintText: 'Teléfono',
                          obscureText: false,
                          isEnabled: true,
                          isVisible: true,
                        ),
                        const SizedBox(height: 15),
                        FutureBuilder<Map<String, String>>(
                          future: getUserModifiedLocation(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                color: Color.fromRGBO(255, 87, 110, 1),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final locationData = snapshot.data!;
                              final calle = locationData['street'];
                              final localidad = locationData['locality'];
                              final pais = locationData['country'];
                              return Column(
                                children: [
                                  const SizedBox(height: 10),
                                  MyTextField(
                                    controller: latController,
                                    text: 'Latitud',
                                    hintText: 'Latitud',
                                    obscureText: false,
                                    isEnabled: false,
                                    isVisible: false,
                                  ),
                                  const SizedBox(height: 10),
                                  MyTextField(
                                    controller: longController,
                                    text: 'Longitud',
                                    hintText: 'Longitud',
                                    obscureText: false,
                                    isEnabled: false,
                                    isVisible: false,
                                  ),
                                  const SizedBox(height: 10),
                                  Text('Calle: $calle'),
                                  Text('Localidad: $localidad'),
                                  Text('País: $pais'),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(248, 181, 149, 1),
                            ),
                          ),
                          onPressed: () async {
                            controlVentanaRefresh = true;
                            final selectedLocation =
                                await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return const CurrentLocationScreen();
                                },
                              ),
                            );
                            if (selectedLocation != null &&
                                selectedLocation is Map<String, double>) {
                              setState(() {
                                lat = selectedLocation['latitude']!;
                                long = selectedLocation['longitude']!;
                              });
                              final locationData =
                                  await getUserModifiedLocation();
                              final calle = locationData['street'];
                              final localidad = locationData['locality'];
                              final pais = locationData['country'];
                              latController.text = lat.toString();
                              longController.text = long.toString();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Column(children: [
                                    Text('Calle: $calle'),
                                    Text('Localidad: $localidad'),
                                    Text('País: $pais'),
                                  ]),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Seleccionar Ubicación',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        MyImportantBtn(
                          onTap: () async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color.fromRGBO(255, 87, 110, 1),
                                    ),
                                  );
                                },
                              );

                              bool changesMade = await _updateData(
                                widget.user!.uid,
                                fullnameController.text,
                                int.parse(phoneController.text),
                                double.parse(lat.toString()),
                                double.parse(long.toString()),
                              );

                              if (changesMade) {
                                Navigator.pushReplacementNamed(
                                    context, '/screens_usuario');
                              } else {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              print('Error parsing double: $e');
                            }
                          },
                          text: 'Guardar',
                        ),
                        const SizedBox(height: 10),
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
