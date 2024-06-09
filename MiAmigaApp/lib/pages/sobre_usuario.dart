import 'package:flutter/material.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //image of logo 
          Image(
            image: AssetImage('lib/images/logo.png'),
            height: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Sobre la aplicacion',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Slim es tu compañera confiable en la lucha contra la violencia de género! Con nuestra aplicación móvil, puedes crear un perfil personal desde el cual puedes reportar de manera segura y rápida agresiones hacia la mujer. Ya sea que tengas evidencia en forma de videos, audio, fotos o texto, Slim te brinda la plataforma para compartir tu experiencia y buscar apoyo.',
              style: TextStyle(
                fontSize: 20,  
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
