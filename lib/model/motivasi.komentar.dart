class KomentarMotivasiModel {
  int iduser;
  int idmotivasi;
  String komentar;
  String namapengguna;
  int idkomentar;
  String linkavatarPengguna;

  KomentarMotivasiModel({
    required this.iduser,
    required this.linkavatarPengguna,
    required this.idkomentar,
    required this.namapengguna,
    required this.idmotivasi,
    required this.komentar
  });

  factory KomentarMotivasiModel.fromJson(Map<String, dynamic> data){
    return KomentarMotivasiModel(
        idkomentar: data['id'],
        linkavatarPengguna: data['user']['avatar_link'],
        iduser: data['user']['iduser'],
        namapengguna: data['user']['nama'],
        idmotivasi: data['idmotivasi'],
        komentar: data['komentar']
    );
  }
}
