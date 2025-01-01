import 'package:flutter/material.dart';
import 'package:vigenesia_app/model/motivasi.dart';
import 'package:vigenesia_app/model/user.dart';
import 'package:vigenesia_app/views/home/homescreen.dart';
import 'package:vigenesia_app/views/detail-postingan/detail_postingan_motivasi.dart';
import 'package:vigenesia_app/views/profil/profile_sendiri.dart';

class KartuPostinganSendiri extends StatefulWidget {
  const KartuPostinganSendiri({
    super.key,
    required this.userModel,
    required this.model,
    required this.onUpdated,
    required this.onDeleted,
  });

  final MotivasiModel model;
  final UserModel userModel;
  final VoidCallback onUpdated; // Callback untuk update
  final VoidCallback onDeleted; // Callback untuk delete

  @override
  State<KartuPostinganSendiri> createState() => _KartuPostinganSendiriState();
}

class _KartuPostinganSendiriState extends State<KartuPostinganSendiri> {
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
      padding: const EdgeInsets.symmetric(vertical: 12.5, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const HalamanProfilSendiri();
                  }));
                },
                child: Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage(widget.model.user.avatarLink),
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
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
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
              // Wrapper with Expanded to push the popup menu to the right
              Expanded(child: Container()),
              PopupMenuButton<String>(
                color:  Colors.white,
                onSelected: (value) {
                  if (value == 'update') {
                    widget.onUpdated();
                  } else if (value == 'delete') {
                    widget.onDeleted();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'update',
                    child: Text('Update'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.model.isiMotivasi),
          const SizedBox(height: 10),
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
