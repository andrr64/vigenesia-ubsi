import 'user.dart'; // Pastikan import UserModel di sini

class MotivasiModel {
  final int id;
  final UserModel user;
  String isiMotivasi;
  String linkGambar;
  final String tanggalInput;

  MotivasiModel({
    required this.id,
    required this.user,
    required this.isiMotivasi,
    required this.linkGambar,
    required this.tanggalInput, // Menambahkan tanggalInput
  });

  // Fungsi untuk mengonversi JSON menjadi MotivasiModel
  factory MotivasiModel.fromJson(Map<String, dynamic> json) {
    return MotivasiModel(
      user:
          UserModel.fromJson(json['user']), // Memastikan user ada di dalam JSON
      id: json['id'], // Pastikan id diproses dengan benar
      isiMotivasi: json['isi_motivasi'],
      tanggalInput: json['tanggal_input'],
      linkGambar: json['link_gambar'] ?? '',
    );
  }

  // Fungsi untuk mengonversi MotivasiModel ke dalam bentuk JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'isi_motivasi': isiMotivasi,
      'link_gambar': linkGambar,
      'tanggal_input': tanggalInput, // Menambahkan tanggal_input ke JSON
    };
  }

  // Fungsi copyWith untuk membuat salinan baru dari MotivasiModel dengan data yang dapat diubah
  MotivasiModel copyWith({
    UserModel? user,
    String? isiMotivasi,
    String? linkGambar,
    String? tanggalInput,
  }) {
    return MotivasiModel(
      user: user ?? this.user,
      id: id,
      isiMotivasi: isiMotivasi ?? this.isiMotivasi,
      linkGambar: linkGambar ?? this.linkGambar,
      tanggalInput: tanggalInput ?? this.tanggalInput,
    );
  }

  // Fungsi untuk mendapatkan waktu format 'Senin, 12 Desember 2024'
  String getWaktuUntukPostingan() {
    DateTime dateTime = DateTime.parse(
        tanggalInput); // Mengonversi tanggal_input menjadi DateTime

    // Array nama hari dalam bahasa Indonesia
    List<String> hari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];

    // Array nama bulan dalam bahasa Indonesia
    List<String> bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    // Mendapatkan nama hari dan bulan berdasarkan DateTime
    String namaHari = hari[dateTime.weekday -
        1]; // Mengambil nama hari berdasarkan index (1=Senin, 7=Minggu)
    String namaBulan =
        bulan[dateTime.month - 1]; // Mengambil nama bulan berdasarkan index

    // Format tanggal dalam format 'Senin, 12 Desember 2024'
    return '$namaHari, ${dateTime.day} $namaBulan ${dateTime.year}';
  }
}
