# MyPortfolio Mobile

Aplikasi Flutter sederhana sebagai halaman utama portofolio pribadi, dibuat untuk tugas PBP. Repositori ini terpisah dari repositori Django.

## Deskripsi

Halaman utama (`MyHomePage`) menampilkan:

- **Tiga kartu informasi (`InfoCard`)** berisi identitas pemilik portofolio: NPM, Name, dan Class.
- **Pesan sambutan** di bawah kartu informasi.
- **Tiga tombol aksi (`ItemCard`)** dengan ikon dan warna latar berbeda: Lihat Proyek, Tambah Proyek, dan Logout.
- **SnackBar** yang muncul saat tombol ditekan, dengan pesan "Kamu telah menekan tombol [Nama Tombol]!".

Seluruh widget halaman utama berupa `StatelessWidget`.

## Struktur Proyek

```
lib/
├── main.dart   # titik masuk aplikasi, MyApp dan MaterialApp
└── menu.dart   # MyHomePage, InfoCard, ItemHomepage, ItemCard
```

## Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (channel stable). Dart sudah termasuk di dalamnya.
- Git
- Browser Chrome (untuk menjalankan versi web), atau emulator Android/perangkat fisik
- Editor, misalnya VS Code dengan ekstensi Flutter

Pastikan `flutter doctor` tidak menunjukkan masalah pada komponen yang kamu pakai.

## Instruksi Setup

1. Clone repositori dan masuk ke folder proyek:

   ```powershell
   git clone <URL-REPOSITORI-ANDA>
   cd myportofolio_mobile
   ```

   Kalau proyek berada di subfolder repositori, masuk ke folder yang berisi `pubspec.yaml`.

2. Unduh dependensi:

   ```powershell
   flutter pub get
   ```

3. Cek lingkungan Flutter:

   ```powershell
   flutter doctor
   ```

4. Jalankan aplikasi (dari dalam folder proyek):

   ```powershell
   flutter run -d chrome
   ```

   Untuk emulator atau perangkat Android, lihat daftar perangkat dengan `flutter devices`, lalu jalankan `flutter run -d <id-perangkat>`.

5. Analisis kode (hasil yang diharapkan: `No issues found!`):

   ```powershell
   flutter analyze
   ```

Saat aplikasi berjalan, tekan `r` untuk hot reload, `R` untuk hot restart, dan `q` untuk berhenti.



# Week 7

### Dokumentasi Tugas 7: MyPortfolio Mobile (Flutter)

Zidan Fauzan Ikrar, NPM 2506589616, PBP E

## 1. Widget Tree dan Hubungan Parent-Child

**Widget tree** adalah struktur berbentuk pohon yang menyusun seluruh tampilan aplikasi Flutter. Di Flutter hampir semuanya adalah widget: tata letak (`Column`, `Row`), elemen visual (`Text`, `Icon`), bahkan satu halaman utuh. Widget-widget itu tidak berdiri sendiri, tetapi bersarang satu di dalam yang lain sehingga membentuk pohon dengan satu akar (root) di paling atas.

Hubungan **parent-child** bekerja seperti ini:

- **Parent** adalah widget yang membungkus atau memuat widget lain. **Child** adalah widget yang berada di dalamnya. Widget yang menampung satu anak memakai properti `child`, sedangkan yang menampung banyak anak memakai `children`.
- **Parent menentukan batasan (constraints) ke child, lalu child menentukan ukurannya sendiri di dalam batasan itu, dan parent yang memosisikannya.** Karena itu satu widget bisa berukuran dan berposisi berbeda tergantung parent-nya.
- Data dan konfigurasi mengalir **ke bawah** pohon. Contohnya `Theme` dari `MaterialApp` bisa dibaca oleh semua widget turunannya.
- Saat tampilan perlu berubah, Flutter membangun ulang (rebuild) widget yang terkena perubahan beserta turunannya, bukan seluruh aplikasi.

Widget tree pada proyek ini kurang lebih seperti berikut:

```
MyApp (StatelessWidget)
└── MaterialApp
    └── MyHomePage (StatelessWidget)
        └── Scaffold
            ├── AppBar
            │   └── Text ('MyPortfolio')
            └── body: SingleChildScrollView
                └── Column
                    ├── Row
                    │   ├── InfoCard (NPM)
                    │   ├── InfoCard (Name)
                    │   └── InfoCard (Class)
                    │       └── Card → Container → Column → [Text, SizedBox, Text]
                    ├── SizedBox
                    ├── Padding → Text (pesan sambutan)
                    └── GridView.extent
                        ├── ItemCard (Lihat Proyek)
                        ├── ItemCard (Tambah Proyek)
                        └── ItemCard (Logout)
                            └── Material → InkWell → Container → Center
                                └── Column → [Icon, Padding, Text]
```

`MaterialApp` adalah parent dari `MyHomePage`, `Scaffold` adalah parent dari `AppBar` dan body, dan `Column` adalah parent dari `Row`, `SizedBox`, `Padding`, serta `GridView`. Sebaliknya `Text('MyPortfolio')` adalah child dari `AppBar`.

## 2. Widget yang Digunakan dalam Proyek

| Widget | Fungsi |
| --- | --- |
| `MyApp` | Widget root buatan sendiri (`StatelessWidget`) yang membangun `MaterialApp`. |
| `MaterialApp` | Membungkus aplikasi dengan fitur Material Design: tema, judul, navigasi, dan halaman awal (`home`). |
| `MyHomePage` | Widget halaman utama buatan sendiri (`StatelessWidget`) yang berada di `lib/menu.dart`. |
| `Scaffold` | Kerangka dasar halaman: menyediakan `appBar`, `body`, dan tempat tampilnya `SnackBar`. |
| `AppBar` | Bilah judul di bagian atas halaman, berisi tulisan MyPortfolio dengan warna latar dari tema. |
| `Text` | Menampilkan teks, seperti judul, isi kartu informasi, pesan sambutan, dan nama tombol. |
| `SingleChildScrollView` | Membuat isi halaman bisa di-scroll sehingga tidak terpotong atau overflow di layar yang pendek. |
| `Column` | Menyusun widget anak secara vertikal (isi halaman, isi `InfoCard`, isi `ItemCard`). |
| `Row` | Menyusun tiga `InfoCard` secara horizontal dan sejajar. |
| `SizedBox` | Memberi jarak kosong dengan ukuran tetap antar widget. |
| `Padding` | Memberi ruang kosong di sekeliling child, misalnya pada pesan sambutan dan ikon. |
| `GridView.extent` | Menampilkan `ItemCard` dalam kisi dengan lebar maksimal tiap kotak yang dibatasi. |
| `InfoCard` | Widget buatan sendiri untuk kartu informasi (judul dan isi), dipakai untuk NPM, nama, dan kelas. |
| `Card` | Kartu dengan sudut membulat dan bayangan (`elevation`) sebagai wadah `InfoCard`. |
| `Container` | Wadah serbaguna untuk mengatur lebar, padding, dan dekorasi child. |
| `ItemCard` | Widget buatan sendiri untuk tombol menu portofolio (Lihat Proyek, Tambah Proyek, Logout). |
| `Material` | Menyediakan permukaan Material dengan warna latar dan sudut membulat; warnanya berbeda untuk tiap tombol. |
| `InkWell` | Membuat area bisa ditekan dan memberi efek riak (ripple), serta menjalankan aksi `onTap`. |
| `Center` | Memusatkan child di dalam ruang yang tersedia. |
| `Icon` | Menampilkan ikon pada tiap tombol. |
| `SnackBar` | Pesan singkat di bagian bawah layar yang muncul saat tombol ditekan, ditampilkan lewat `ScaffoldMessenger`. |

Selain widget di atas, proyek ini juga memakai `ThemeData` dan `ColorScheme.fromSeed` untuk mengatur tema, serta `Theme.of(context)`, `MediaQuery.of(context)`, dan `ScaffoldMessenger.of(context)` untuk mengambil informasi dari widget induk.

## 3. Fungsi `MaterialApp` dan Alasan Dipakai sebagai Root

`MaterialApp` adalah widget tingkat atas yang menyiapkan fondasi aplikasi berbasis **Material Design**. Fungsi utamanya:

- **Tema** lewat properti `theme` (`ThemeData`, `ColorScheme`), sehingga warna dan gaya teks konsisten di seluruh aplikasi. Pada proyek ini, tema dipakai untuk warna `AppBar` dan warna dasar aplikasi.
- **Halaman awal** lewat properti `home` (di proyek ini `MyHomePage`).
- **Navigasi dan routing**, karena `MaterialApp` membuat `Navigator` untuk berpindah antar halaman.
- **Judul aplikasi** lewat properti `title`, serta dukungan lokalisasi dan mode gelap (`darkTheme`, `themeMode`).
- Menyediakan layanan yang dipakai widget di bawahnya, seperti `Theme`, `MediaQuery`, dan `ScaffoldMessenger`.

`MaterialApp` umumnya dijadikan root karena widget seperti `Scaffold`, `AppBar`, `Card`, `InkWell`, dan `SnackBar` bergantung pada konfigurasi yang disediakan di atas mereka dalam pohon. Dengan menaruhnya di akar, semua widget turunan otomatis mendapat tema, navigasi, dan layanan tersebut tanpa perlu mengaturnya satu per satu. Ini bukan keharusan mutlak: aplikasi bergaya iOS memakai `CupertinoApp`, dan ada juga `WidgetsApp` yang lebih dasar, tetapi untuk Material Design `MaterialApp` adalah pilihan standar.

## 4. `StatelessWidget` vs `StatefulWidget`

|  | `StatelessWidget` | `StatefulWidget` |
| --- | --- | --- |
| Sifat | Tidak punya state yang berubah; tampilannya hanya bergantung pada properti yang diberikan saat dibuat | Punya objek `State` yang bisa berubah selama widget hidup |
| Pembaruan tampilan | Hanya berubah bila parent membuatnya ulang dengan data baru | Berubah saat `setState()` dipanggil |
| Struktur | Satu kelas dengan metode `build` | Dua kelas: widget dan `State`-nya, dengan `createState()`, `initState()`, `dispose()`, dan lain-lain |

**Pilih `StatelessWidget`** bila tampilan bersifat tetap atau sepenuhnya ditentukan oleh data dari luar. Di proyek ini `MyApp`, `MyHomePage`, `InfoCard`, dan `ItemCard` semuanya `StatelessWidget`, karena isi kartu dan daftar tombol tidak berubah selama aplikasi berjalan. Pesan `SnackBar` pun ditangani oleh `ScaffoldMessenger`, jadi tidak membutuhkan state pada widget kita.

**Pilih `StatefulWidget`** bila ada data yang berubah dan harus memperbarui tampilan, misalnya penghitung (counter), isian form, checkbox atau switch, animasi, atau data yang diambil dari server. Contoh pada proyek ini: jika halaman Tambah Proyek nanti punya form yang isinya berubah saat diketik, halaman itu harus `StatefulWidget`.

Praktik yang baik adalah memulai dengan `StatelessWidget` dan baru memakai `StatefulWidget` ketika benar-benar ada state lokal yang berubah.

## 5. `BuildContext`

`BuildContext` adalah objek yang menunjukkan **lokasi sebuah widget di dalam widget tree**. Lewat context itu sebuah widget bisa "melihat ke atas" pohon untuk mengambil informasi dari widget leluhurnya (ancestor).

Pentingnya `BuildContext`:

- Menjadi cara widget mengakses data yang disediakan induknya, seperti tema, ukuran layar, dan navigator, tanpa harus meneruskannya lewat konstruktor.
- Menentukan dari posisi mana pencarian dilakukan, sehingga hasilnya bisa berbeda untuk widget yang berada di bagian pohon yang berbeda.

Metode `build(BuildContext context)` menerima context milik widget itu sendiri. Contoh penggunaannya di proyek ini:

```dart
// Mengambil warna primer dari tema untuk AppBar
backgroundColor: Theme.of(context).colorScheme.primary,

// Mengambil lebar layar untuk menentukan lebar InfoCard
width: MediaQuery.of(context).size.width / 3.5,

// Menampilkan SnackBar saat tombol ditekan
ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(content: Text('Kamu telah menekan tombol ${item.name}!')),
  );
```

Catatan: context harus berada di bawah widget yang dicari. Misalnya `Scaffold.of(context)` yang dipanggil di `build` milik widget yang membuat `Scaffold` itu sendiri tidak akan menemukannya, sehingga perlu `Builder` atau widget terpisah. Context juga tidak boleh dipakai setelah proses asinkron tanpa memeriksa bahwa widget masih terpasang (`mounted`).

## 6. Hot Reload, Hot Restart, dan Full Restart

**Hot reload** memasukkan kode terbaru ke aplikasi yang sedang berjalan di Dart VM, lalu membangun ulang widget tree. **State aplikasi tetap dipertahankan**, dan prosesnya sangat cepat, sehingga cocok untuk mengubah tampilan seperti warna, teks, atau tata letak.

**Hot restart** menjalankan ulang aplikasi dari `main()` dengan kode terbaru. **Seluruh state direset** ke kondisi awal, tetapi tetap lebih cepat daripada menghentikan dan menjalankan ulang aplikasi sepenuhnya.

|  | Hot reload | Hot restart |
| --- | --- | --- |
| Kode baru dimuat | Ya | Ya |
| State dipertahankan | Ya | Tidak, direset |
| `main()` dijalankan ulang | Tidak | Ya |
| Kecepatan | Paling cepat | Cepat |

Ketika hot reload saja **tidak cukup** dan perlu hot restart atau full restart:

- Mengubah `main()` atau bagian yang hanya dijalankan sekali saat aplikasi mulai, seperti inisialisasi variabel global dan field statis.
- Mengubah logika `initState()` pada `StatefulWidget`, karena `initState` tidak dipanggil lagi untuk state yang sudah ada.
- Perubahan bentuk tipe, misalnya mengubah `StatelessWidget` menjadi `StatefulWidget`, mengubah enum menjadi kelas biasa, atau mengubah tipe generik.
- Perubahan yang membuat state lama tidak cocok lagi dengan kode baru; hot restart (`R`) akan menyetel ulang kondisinya.
- Menambah dependensi di `pubspec.yaml` (jalankan `flutter pub get`, lalu restart) atau menambah aset dan font baru.
- Mengubah kode native (Android, iOS, atau konfigurasi platform seperti `AndroidManifest.xml`), yang membutuhkan **full restart**, yaitu menghentikan aplikasi lalu menjalankan `flutter run` lagi agar dikompilasi ulang.

Pada Flutter web, dukungan hot reload bisa berbeda antar versi. Jika perubahan tidak tampak di Chrome, gunakan hot restart (`R` di terminal) atau jalankan ulang `flutter run -d chrome`.

## AI Disclosure

Menggunakan Claude Sonnet 5.5 High untuk mempelajari terkait cara kerja elemen-elemen umum seperti Widget (StatelessWidget dan StatefulWidget), MaterialApp, dan BuildContext pada Flutter, mem-fix eror saat setup SDK Flutter, dan membantu dokumentasi serta instruksi setup, termasuk command-command umum untuk membantu membiasakan saya menavigasi Flutter dengan terminal agar tampilan webnya up-to-date dengan kode saya.

## Link Log Chat AI

https://claude.ai/share/fc6126cf-faf3-44a2-a56e-ded772f49f48



# Week 8

### Dokumentasi Tugas 8: Formulir, Navigasi, dan Validasi (MyPortfolio Mobile)

Zidan Fauzan Ikrar, NPM 2506589616, PBP E

## 1. `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`

`Navigator` mengelola halaman aplikasi sebagai sebuah **tumpukan (stack) route**. Halaman yang tampil di layar adalah route paling atas pada tumpukan itu.

| Metode | Efek pada tumpukan | Halaman sebelumnya | Pemakaian di proyek |
| --- | --- | --- | --- |
| `Navigator.push()` | Menambahkan route baru di atas tumpukan | Tetap ada di bawahnya, sehingga bisa kembali ke sana | Kartu aksi Tambah Proyek dan Tambah Pengalaman di `project_card.dart` |
| `Navigator.pushReplacement()` | Mengganti route teratas dengan route baru | Dibuang dari tumpukan, sehingga tidak bisa kembali ke halaman yang diganti | Opsi Home, Add Project, dan Add Experience di `left_drawer.dart` |
| `Navigator.pop()` | Membuang route teratas | Halaman di bawahnya kembali tampil | Tombol OK pada `AlertDialog` untuk menutup dialog |

`AlertDialog` yang dibuka lewat `showDialog()` juga merupakan sebuah route, itulah sebabnya `Navigator.pop(context)` dapat menutupnya.

**Metode untuk membuka formulir dari kartu aksi adalah `Navigator.push()`.** Kode pada `ItemCard`:

```dart
if (item.name == 'Tambah Pengalaman') {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ExperienceFormPage()),
  );
}
```

Karena memakai `push`, halaman utama tetap berada di bawah formulir pada tumpukan. Pengguna bisa kembali dengan tombol kembali bawaan perangkat jika tersedia, misalnya tombol Back pada Android. Pada `AppBar` formulir yang tampil adalah ikon drawer (hamburger), bukan panah kembali, karena `Scaffold` memiliki drawer. Saat aplikasi dijalankan di Chrome, alur kembali diuji lewat opsi Home pada drawer.

**Opsi Home pada drawer** membawa pengguna ke halaman utama dengan `pushReplacement`:

```dart
ListTile(
  leading: const Icon(Icons.home_outlined),
  title: const Text('Home'),
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  },
),
```

Halaman formulir yang sedang tampil diganti dengan `MyHomePage` yang baru. Drawer merupakan bagian dari halaman formulir yang diganti, sehingga ikut tertutup. Karena halaman lama dibuang, pengguna tidak kembali ke formulir lewat tombol kembali. Catatan: jika formulir sebelumnya dibuka lewat kartu (`push`), halaman utama yang lama masih ada di bawah halaman utama yang baru. Bila ingin tumpukan bersih, dapat dipakai `Navigator.pushAndRemoveUntil()` dengan `(route) => false`.

## 2. Susunan `Scaffold`, `AppBar`, dan `Drawer`

`Scaffold` adalah kerangka halaman Material yang menyediakan slot tetap: `appBar` di atas, `drawer` di sisi kiri, dan `body` untuk isi halaman. Setiap halaman di proyek ini (halaman utama, formulir proyek, formulir pengalaman) memakai susunan yang sama:

```dart
Scaffold(
  appBar: AppBar(...),
  drawer: const LeftDrawer(),
  body: ...,
)
```

Susunan ini menjaga struktur halaman tetap konsisten karena:

- **Bentuk halaman selalu sama.** Pengguna selalu menemukan bilah judul di atas, isi di tengah, dan menu di drawer, sehingga mudah mengenali di mana mereka berada.
- **Drawer dibuat sekali dan dipakai ulang.** `LeftDrawer` didefinisikan di satu berkas dan dipanggil di setiap halaman, jadi menu navigasinya selalu sama dan perubahan cukup dilakukan di satu tempat.
- **`AppBar` otomatis menampilkan tombol untuk membuka drawer** ketika `Scaffold` memiliki `drawer`, tanpa kode tambahan.
- Hanya `body` yang berbeda antar halaman.

**Contoh penggunaan warna tema portofolio di lebih dari satu halaman:** warna indigo.

```dart
// main.dart: warna dasar tema aplikasi
colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),

// project_form.dart dan experience_form.dart: AppBar formulir
backgroundColor: Colors.indigo,
foregroundColor: Colors.white,

// left_drawer.dart: header drawer, tampil di semua halaman
DrawerHeader(decoration: BoxDecoration(color: Colors.indigo), ...)
```

Warna yang sama juga dipakai pada tombol Save di kedua formulir. Dengan begitu halaman utama, formulir proyek, dan formulir pengalaman terlihat sebagai satu aplikasi yang utuh.

## 3. Tata Letak Formulir

Susunan widget pada formulir:

```
Scaffold
  body: Form (key: _formKey)
    SingleChildScrollView
      Column (crossAxisAlignment: start)
        Padding > TextFormField (nama)
        Padding > TextFormField (deskripsi, maxLines: 5)
        Padding > DropdownButtonFormField (kategori)
        Padding > TextFormField (tanggal, membuka showDatePicker)
        Align > Padding > ElevatedButton (Save)
```

Alasan pemilihannya:

- **`Column`** menyusun satu input per baris dari atas ke bawah. Ini pola yang paling mudah dibaca dan diisi pada layar sempit, dan `crossAxisAlignment.start` meratakan isinya ke kiri.
- **`Padding` (widget pengatur jarak)** memberi ruang 8 piksel di sekeliling setiap input, sehingga kolom tidak menempel satu sama lain maupun ke tepi layar, dan area sentuhnya terpisah jelas. Untuk jarak tetap antar widget di tempat lain, seperti halaman utama, dipakai `SizedBox`.
- **`SingleChildScrollView` (widget penggulir)** dipakai karena total tinggi formulir bisa melebihi tinggi layar, terutama pada layar sempit atau pendek, mode landscape, atau saat papan ketik di layar menutupi sebagian halaman. Tanpa penggulir, Flutter menampilkan garis overflow kuning-hitam dan tombol Simpan bisa tidak terjangkau. Dengan penggulir, semua input dan tombol Simpan tetap bisa dijangkau dengan menggulir halaman.
- **`Form` membungkus penggulir** sehingga semua `TextFormField` dan dropdown di dalamnya tergabung dalam satu formulir yang dapat divalidasi sekaligus.

## 4. `GlobalKey<FormState>`, `validator`, dan `validate()`

- **`GlobalKey<FormState>`** (`_formKey`) dipasang pada widget `Form`. Kunci ini memberi akses ke `FormState` dari luar widget, sehingga tombol Simpan dapat memerintahkan seluruh form untuk memeriksa dirinya, dan setelah berhasil menyetelnya ulang lewat `reset()`.
- **`validator`** adalah fungsi pada setiap `TextFormField`. Fungsi ini menerima isian dan mengembalikan `null` jika isian valid, atau teks pesan kesalahan jika tidak valid.
- **`validate()`** dipanggil pada `FormState`. Metode ini menjalankan semua `validator` di dalam form. Pesan kesalahan ditampilkan tepat di bawah kolom yang bermasalah, dan hasilnya `true` hanya bila semua validator mengembalikan `null`.

Alur saat tombol Simpan ditekan:

```dart
onPressed: () {
  if (_formKey.currentState!.validate()) {
    // Semua input lolos: tampilkan ringkasan di AlertDialog
    showDialog(...);
  }
  // Jika ada yang tidak valid, validate() sudah menampilkan
  // pesan kesalahan di kolom terkait dan dialog tidak muncul.
},
```

**Contoh nilai yang ditolak:** kolom Nama Pengalaman diisi tiga spasi saja (`'   '`). Validatornya:

```dart
validator: (String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nama pengalaman tidak boleh kosong!';
  }
  return null;
},
```

`trim()` membuang spasi di awal dan akhir, sehingga isian berspasi saja menjadi kosong dan ditolak dengan pesan kesalahan. Contoh lain yang ditolak: nama yang melebihi batas panjang, dan tanggal selesai yang lebih awal daripada tanggal mulai.

**Mengapa memilih jenis input atau papan ketik saja belum cukup:**

- Jenis papan ketik (misalnya `TextInputType`) hanya memandu tampilan papan ketik. Ia tidak melarang pengguna mengosongkan kolom, mengetik spasi saja, menempelkan (paste) teks, atau mengetik lewat papan ketik fisik, misalnya saat aplikasi berjalan di Chrome.
- Dropdown dan `showDatePicker()` membatasi pilihan, tetapi tidak dapat memeriksa kolom yang wajib diisi atau hubungan antar kolom, seperti tanggal selesai yang tidak boleh sebelum tanggal mulai.
- Aturan seperti isian wajib, batas panjang, format URL, dan urutan tanggal harus ditegakkan oleh `validator`. Jika data nanti dikirim ke backend Django, validasi di server tetap diperlukan sebagai pertahanan terakhir.

## AI Disclosure

Menggunakan Claude Sonnet 5.5 High untuk membantu menambahkan field yang menggunakan tanggal pada experience (berupa start date dan end date), validasi tambahan untuk jumlah karakter maksimal, merapikan tampilan menu utama, dan dokumentasi. AI tersebut juga digunakan untuk membantu saya menerapkan dark mode sebagai fungsionalitas tambahan. Namun, pada awalnya warna tombol-tombol di menu utama tidak berubah saat men-toggle dark mode, lalu saya menanyakan AI nya terkait masalah tersebut dan menerapkan sebagian bantuannya serta melakukan perubahan manual agar sesuai dengan tampilan dark mode yang seharusnya.

## Link Log Chat AI

https://claude.ai/share/fc6126cf-faf3-44a2-a56e-ded772f49f48


