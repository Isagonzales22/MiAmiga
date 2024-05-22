// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';
import 'package:miamiga_app/pages/sobre_usuario.dart';
import 'package:miamiga_app/pages/inicio_usuario.dart';

import 'package:miamiga_app/pages/perfil_usuario.dart';

class Screens extends StatefulWidget {
  const Screens({Key? key}) : super(key: key);

  @override
  _ScreensState createState() => _ScreensState();
}

class _ScreensState extends State<Screens> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;
  late List<Widget> _screens;

  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();

    _screens = [
      InicioScreen(
          user: user!,
          incidentData: IncidentData(
              description: '',
              date: DateTime.now(),
              lat: 0,
              long: 0,
              imageUrls: [],
              audioUrl: ''),
          denunciaData: DenuncianteData(
              ci: 1,
              fullName: '',
              phone: 1,
              lat: 0,
              long: 0,
              documentId: '',
              estado: '')),
      const SobreScreen(),
      PerfilScreen(user: user!),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _screens[_selectedIndex],
            ),
            Container(
              color: const Color.fromRGBO(192, 108, 132, 1),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
                child: GNav(
                  backgroundColor: const Color.fromRGBO(192, 108, 132, 1),
                  color: Colors.white,
                  activeColor: Colors.white,
                  tabBackgroundColor: const Color.fromRGBO(248, 181, 149, 1),
                  gap: 8,
                  padding: const EdgeInsets.all(16),
                  tabs: const [
                    GButton(icon: Icons.home, text: 'Inicio'),
                    GButton(icon: Icons.info, text: 'Sobre'),
                    GButton(icon: Icons.person, text: 'Perfil'),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
