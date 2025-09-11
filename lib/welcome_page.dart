import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final String nomeDoUsuario;

  const WelcomePage({super.key, required this.nomeDoUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text ('MyApp', style: TextStyle(color: Colors.white, fontSize: 25)),
        centerTitle: true,
        backgroundColor: const Color(0xFF005050),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bem-Vindo, $nomeDoUsuario!', 
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF005050),
                  fontWeight: FontWeight.w400,
                )
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF005050),
                  foregroundColor: Colors.white,
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Sair'),
              ),
            ),
          ],
        )
      ),
    );
  }
}
