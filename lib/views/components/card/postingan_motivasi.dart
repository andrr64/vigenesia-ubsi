import 'package:flutter/material.dart';
import 'package:vigenesia_app/model/motivasi.dart';
import 'package:vigenesia_app/views/home/homescreen.dart';
import 'package:vigenesia_app/views/detail-postingan/detail_postingan_motivasi.dart';
import 'package:vigenesia_app/views/profil/profile_orang_lain.dart';

class KartuPostingan extends StatefulWidget {
  const KartuPostingan({super.key, required this.model});
  final MotivasiModel model;

  @override
  State<KartuPostingan> createState() => _KartuPostinganState();
}

class _KartuPostinganState extends State<KartuPostingan> {
  @override
  Widget build(BuildContext context) {
    Widget renderImage() {
      if (widget.model.linkGambar.isEmpty) {
        return const SizedBox();
      }
      return Center(
        child: Image.network(
          widget.model.linkGambar,
          height: 256,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PeopleProfilPage(dataPengguna: widget.model.user);
              }));
            },
            child: Row(
              children: [
                SizedBox(
                  height: 32,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.model.user.avatarLink),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(
                  width: 2.5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.model.user.nama,
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.model.user.profesi,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black38),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(widget.model.isiMotivasi),
          const SizedBox(
            height: 10,
          ),
          renderImage(),
          dHeight(10),
          Text(
            widget.model.getWaktuUntukPostingan(),
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          dHeight(12.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return PostinganMotivasi(motivasi: widget.model);
                  }));
                },
                child: Icon(Icons.comment),
              )
            ],
          )
        ],
      ),
    );
  }
}