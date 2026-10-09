import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ============================================================
  // BASE URL
  // ============================================================
  //
  // Android Emulator:
  // 10.0.2.2 = komputer/localhost Windows
  //
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Kalau nanti Flutter dijalankan di Windows/Desktop:
  // static const String baseUrl = 'http://127.0.0.1:8000/api';


  // ============================================================
  // HELPER RESPONSE
  // ============================================================
  //
  // PENTING: dibuat mengembalikan `dynamic`, bukan dipaksa
  // Map<String, dynamic>, karena beberapa endpoint Laravel bisa
  // saja mengembalikan JSON array langsung (List), bukan objek
  // yang dibungkus {"data": [...]}. Kalau dipaksa jadi Map,
  // response berupa List akan menyebabkan crash.
  //
  // Fungsi extractList() / extractMap() di main.dart sudah
  // dirancang untuk menangani dynamic (List ATAU Map), jadi
  // di sini cukup dikembalikan apa adanya setelah didecode.

  static dynamic _handleResponse(
    http.Response response,
  ) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      throw Exception(
        'Response API tidak valid: ${response.body}',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return decoded;
    }

    if (decoded is Map && decoded['message'] != null) {
      throw Exception(decoded['message'].toString());
    }

    throw Exception('API Error ${response.statusCode}');
  }


  // ============================================================
  // PELANGGAN
  // ============================================================

  static Future<dynamic> register({
    required String nama,
    required String noHp,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pelanggan'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'nama': nama,
        'no_hp': noHp,
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // LOGIN PELANGGAN
  // ============================================================
  //
  // identitas = email ATAU no_hp (bebas salah satu)

  static Future<dynamic> loginPelanggan({
    required String identitas,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/pelanggan'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'identitas': identitas,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // LOGIN ADMIN
  // ============================================================

  static Future<dynamic> loginAdmin({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/admin'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // KAPSTER
  // ============================================================

  static Future<dynamic> getKapster() async {
    final response = await http.get(
      Uri.parse('$baseUrl/kapster'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  static Future<dynamic> createKapster({
    required String nama,
    required String noHp,
    required String password,
    String? spesialisasi,
    bool statusAktif = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kapster'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'nama': nama,
        'no_hp': noHp,
        'password': password,
        'spesialisasi': spesialisasi,
        'status_aktif': statusAktif,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // UPDATE KAPSTER
  // ============================================================

  static Future<dynamic> updateKapster({
    required int idKapster,
    String? nama,
    String? noHp,
    String? password,
    String? spesialisasi,
    bool? statusAktif,
  }) async {
    final Map<String, dynamic> body = {};

    if (nama != null) {
      body['nama'] = nama;
    }

    if (noHp != null) {
      body['no_hp'] = noHp;
    }

    if (password != null) {
      body['password'] = password;
    }

    if (spesialisasi != null) {
      body['spesialisasi'] = spesialisasi;
    }

    if (statusAktif != null) {
      body['status_aktif'] = statusAktif;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/kapster/$idKapster'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // HAPUS KAPSTER
  // ============================================================

  static Future<dynamic> deleteKapster(
    int idKapster,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/kapster/$idKapster'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // PELANGGAN (untuk admin)
  // ============================================================

  static Future<dynamic> getPelanggan() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pelanggan'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // UPLOAD FOTO KAPSTER
  // ============================================================
  //
  // Beda dari fungsi lain: ini multipart/form-data (ngirim file),
  // bukan JSON biasa.

  static Future<dynamic> uploadFotoKapster({
    required int idKapster,
    required String fotoPath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/kapster/$idKapster/foto'),
    );

    request.headers['Accept'] = 'application/json';

    request.files.add(
      await http.MultipartFile.fromPath('foto', fotoPath),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return _handleResponse(response);
  }


  // ============================================================
  // LAYANAN
  // ============================================================

  static Future<dynamic> getLayanan() async {
    final response = await http.get(
      Uri.parse('$baseUrl/layanan'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // TAMBAH LAYANAN
  // ============================================================

  static Future<dynamic> createLayanan({
    required String namaLayanan,
    required double harga,
    required int durasiMenit,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/layanan'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'nama_layanan': namaLayanan,
        'harga': harga,
        'durasi_menit': durasiMenit,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // DETAIL LAYANAN
  // ============================================================

  static Future<dynamic> getLayananById(
    int idLayanan,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/layanan/$idLayanan'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // UPDATE LAYANAN
  // ============================================================

  static Future<dynamic> updateLayanan({
    required int idLayanan,
    String? namaLayanan,
    double? harga,
    int? durasiMenit,
  }) async {
    final Map<String, dynamic> body = {};

    if (namaLayanan != null) {
      body['nama_layanan'] = namaLayanan;
    }

    if (harga != null) {
      body['harga'] = harga;
    }

    if (durasiMenit != null) {
      body['durasi_menit'] = durasiMenit;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/layanan/$idLayanan'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // HAPUS LAYANAN
  // ============================================================

  static Future<dynamic> deleteLayanan(
    int idLayanan,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/layanan/$idLayanan'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // JADWAL KAPSTER
  // ============================================================

  static Future<dynamic> getJadwalKapster() async {
    final response = await http.get(
      Uri.parse('$baseUrl/jadwal-kapster'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // TAMBAH JADWAL KAPSTER
  // ============================================================
  //
  // tanggal format: 'YYYY-MM-DD'
  // jamMulai / jamSelesai format: 'HH:mm' (24 jam)

  static Future<dynamic> createJadwalKapster({
    required int idKapster,
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    String statusSlot = 'tersedia',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jadwal-kapster'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'id_kapster': idKapster,
        'tanggal': tanggal,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'status_slot': statusSlot,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // DETAIL JADWAL KAPSTER
  // ============================================================

  static Future<dynamic> getJadwalKapsterById(
    int idJadwal,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jadwal-kapster/$idJadwal'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // UPDATE JADWAL KAPSTER (LENGKAP)
  // ============================================================
  //
  // Beda dengan updateStatusJadwal() di bawah: fungsi ini bisa
  // mengubah kapster, tanggal, jam, DAN status sekaligus (dipakai
  // di halaman admin untuk edit jadwal).

  static Future<dynamic> updateJadwalKapster({
    required int idJadwal,
    int? idKapster,
    String? tanggal,
    String? jamMulai,
    String? jamSelesai,
    String? statusSlot,
  }) async {
    final Map<String, dynamic> body = {};

    if (idKapster != null) {
      body['id_kapster'] = idKapster;
    }

    if (tanggal != null) {
      body['tanggal'] = tanggal;
    }

    if (jamMulai != null) {
      body['jam_mulai'] = jamMulai;
    }

    if (jamSelesai != null) {
      body['jam_selesai'] = jamSelesai;
    }

    if (statusSlot != null) {
      body['status_slot'] = statusSlot;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/jadwal-kapster/$idJadwal'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // UPDATE STATUS JADWAL KAPSTER
  // ============================================================
  //
  // Dipakai setelah booking berhasil dibuat, untuk menandai
  // slot jadwal jadi 'dipesan' supaya tidak bisa dipilih lagi
  // oleh pelanggan lain.

  static Future<dynamic> updateStatusJadwal({
    required int idJadwal,
    required String statusSlot,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/jadwal-kapster/$idJadwal'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'status_slot': statusSlot,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // HAPUS JADWAL KAPSTER
  // ============================================================

  static Future<dynamic> deleteJadwalKapster(
    int idJadwal,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/jadwal-kapster/$idJadwal'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // LOGIN KAPSTER
  // ============================================================

  static Future<dynamic> loginKapster({
    required String noHp,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/kapster'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'no_hp': noHp,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // AMBIL BOOKING (opsional: milik satu kapster saja)
  // ============================================================

  static Future<dynamic> getBooking({
    int? idKapster,
    int? idPelanggan,
  }) async {
    final Map<String, String> query = {};

    if (idKapster != null) {
      query['id_kapster'] = idKapster.toString();
    }

    if (idPelanggan != null) {
      query['id_pelanggan'] = idPelanggan.toString();
    }

    final uri = Uri.parse('$baseUrl/booking').replace(
      queryParameters: query.isEmpty ? null : query,
    );

    final response = await http.get(
      uri,

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // UPDATE STATUS BOOKING
  // ============================================================
  //
  // Alur: menunggu_konfirmasi -> datang -> dilayani -> selesai

  static Future<dynamic> updateStatusBooking({
    required int idBooking,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/booking/$idBooking/status'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'status': status,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // ULASAN (untuk admin)
  // ============================================================

  static Future<dynamic> getUlasan() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ulasan'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // GALERI HASIL KERJA (diunggah kapster, bebas tanpa terikat
  // booking/layanan tertentu)
  // ============================================================

  static Future<dynamic> getGaleri() async {
    final response = await http.get(
      Uri.parse('$baseUrl/galeri'),

      headers: {
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  static Future<dynamic> createGaleri({
    required int idKapster,
    required String judul,
    required String fotoPath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/galeri'),
    );

    request.headers['Accept'] = 'application/json';
    request.fields['id_kapster'] = idKapster.toString();
    request.fields['judul'] = judul;

    request.files.add(
      await http.MultipartFile.fromPath('foto', fotoPath),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return _handleResponse(response);
  }


  // ============================================================
  // BOOKING
  // ============================================================

  static Future<dynamic> createBooking({
    required int idPelanggan,
    required int idKapster,
    required int idJadwal,
    required double totalBiaya,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/booking'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'id_pelanggan': idPelanggan,
        'id_kapster': idKapster,
        'id_jadwal': idJadwal,
        'total_biaya': totalBiaya,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // BATALKAN BOOKING
  // ============================================================
  //
  // Hanya berhasil kalau status booking masih 'menunggu_konfirmasi'.

  static Future<dynamic> cancelBooking({
    required int idBooking,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/booking/$idBooking/batalkan'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    return _handleResponse(response);
  }


  // ============================================================
  // DETAIL BOOKING
  // ============================================================

  static Future<dynamic> createDetailBooking({
    required int idBooking,
    required int idLayanan,
    required double subtotal,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/detail-booking'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'id_booking': idBooking,
        'id_layanan': idLayanan,
        'subtotal': subtotal,
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // PEMBAYARAN
  // ============================================================

  static Future<dynamic> createPembayaran({
    required int idBooking,
    required String metode,
    required double jumlahBayar,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pembayaran'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'id_booking': idBooking,
        'metode': metode,
        'jumlah_bayar': jumlahBayar,
        'status_bayar': 'lunas',
      }),
    );

    return _handleResponse(response);
  }


  // ============================================================
  // ULASAN
  // ============================================================

  static Future<dynamic> createUlasan({
    required int idBooking,
    required int idPelanggan,
    required int rating,
    String? komentar,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ulasan'),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },

      body: jsonEncode({
        'id_booking': idBooking,
        'id_pelanggan': idPelanggan,
        'rating': rating,
        'komentar': komentar,
      }),
    );

    return _handleResponse(response);
  }
}