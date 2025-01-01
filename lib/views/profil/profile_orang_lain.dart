import 'package:flutter/material.dart';
import 'package:vigenesia_app/services/layanan.motivasi.dart';
import 'package:vigenesia_app/model/user.dart';
import 'package:vigenesia_app/views/components/card/postingan_motivasi.dart';

class PeopleProfilPage extends StatefulWidget {
  final UserModel dataPengguna;

  const PeopleProfilPage({super.key, required this.dataPengguna});

  @override
  State<PeopleProfilPage> createState() => _PeopleProfilPageState();
}

class _PeopleProfilPageState extends State<PeopleProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.chevron_left),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(widget.dataPengguna.avatarLink),
                    radius: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.dataPengguna.nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.dataPengguna.profesi,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.dataPengguna.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Heading Postingan
            const Text(
              'Postingan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder(
                future: LayananMotivasi.getMotivasi(
                    idUser: widget.dataPengguna.iduser),
                builder: (context, data) {
                  if (data.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        for (var motiv in data.data!)
                          KartuPostingan(
                            model: motiv,
                          )
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                })
          ],
        ),
      ),
    );
  }
}
