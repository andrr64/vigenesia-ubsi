class UserModel {
  final int iduser;
  final String nama;
  final String profesi;
  final String email;
  final bool isActive;
  final String created;
  final String updated;
  final String avatarLink;

  UserModel({
    required this.iduser,
    required this.nama,
    required this.profesi,
    required this.email,
    required this.isActive,
    required this.created,
    required this.updated,
    required this.avatarLink,
  });

  // Fungsi untuk mengonversi JSON menjadi UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      iduser: json['iduser'],
      nama: json['nama'],
      profesi: json['profesi'],
      email: json['email'],
      isActive: json['is_active'],
      created: json['created'],
      updated: json['updated'],
      avatarLink: json['avatar_link'] ?? '', // Default jika null
    );
  }

  // Fungsi untuk mengonversi UserModel ke dalam bentuk JSON
  Map<String, dynamic> toJson() {
    return {
      'iduser': iduser,
      'nama': nama,
      'profesi': profesi,
      'email': email,
      'is_active': isActive,
      'created': created,
      'updated': updated,
      'avatar_link': avatarLink,
    };
  }

  // Fungsi copyWith untuk membuat salinan baru dari UserModel dengan data yang dapat diubah
  UserModel copyWith({
    int? iduser,
    String? nama,
    String? profesi,
    String? email,
    String? password,
    String? roleId,
    bool? isActive,
    String? created,
    String? updated,
    String? avatarLink,
  }) {
    return UserModel(
      iduser: iduser ?? this.iduser,
      nama: nama ?? this.nama,
      profesi: profesi ?? this.profesi,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      avatarLink: avatarLink ?? this.avatarLink,
    );
  }
}
