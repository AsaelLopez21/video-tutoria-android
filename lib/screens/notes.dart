import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({Key? key}) : super(key: key);

  void _mostrarDialogoAgregar(BuildContext context) {
    final tituloController = TextEditingController();
    final contenidoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whitte,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Agregar nota',
            style: TextStyle(color: AppColors.darkBlue),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: contenidoController,
                  decoration: const InputDecoration(labelText: 'Contenido'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.lightBlue),
              ),
            ),
            TextButton(
              onPressed: () async {
                final titulo = tituloController.text.trim();
                final contenido = contenidoController.text.trim();

                if (titulo.isNotEmpty && contenido.isNotEmpty) {
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final docRef =
                      FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(uid)
                          .collection('notas')
                          .doc();

                  await docRef.set({
                    'titulo': titulo,
                    'contenido': contenido,
                    'fecha': DateTime.now(),
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: AppColors.lightViolet),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditar(
    BuildContext context,
    Map<String, dynamic> notaData,
    String notaId,
  ) {
    final tituloController = TextEditingController(text: notaData['titulo']);
    final contenidoController = TextEditingController(
      text: notaData['contenido'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whitte,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Editar nota',
            style: TextStyle(color: AppColors.darkBlue),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: contenidoController,
                  decoration: const InputDecoration(labelText: 'Contenido'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('notas')
                    .doc(notaId)
                    .delete();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.lightViolet),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('notas')
                    .doc(notaId)
                    .update({
                      'titulo': tituloController.text,
                      'contenido': contenidoController.text,
                    });
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: AppColors.lightBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/peakpx.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(35, 0, 187, 255),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(uid)
                          .collection('notas')
                          .orderBy('fecha', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error al cargar notas'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final notas = snapshot.data!.docs;

                    if (notas.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tienes notas aún.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: notas.length,
                      itemBuilder: (context, index) {
                        final nota = notas[index];
                        final data = nota.data() as Map<String, dynamic>;

                        return Card(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: GestureDetector(
                              onTap:
                                  () => _mostrarDialogoEditar(
                                    context,
                                    data,
                                    nota.id,
                                  ),
                              child: Text(
                                data['titulo'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              data['contenido'] ?? '',
                              style: const TextStyle(color: Colors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoAgregar(context),
        backgroundColor: AppColors.lightViolet,
        child: const Icon(Icons.note_add, color: Colors.white),
      ),
    );
  }
}