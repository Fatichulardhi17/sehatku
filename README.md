# Sehatku

Aplikasi kesehatan mobile yang diimplementasikan dari `sehatku.fig` menggunakan Flutter + Supabase.

## Stack

- Flutter (Material 3)
- Supabase (Auth + Postgres + RLS)
- Google Fonts (Lato)

## Struktur

```
lib/
  core/        environment, service global, format, error
  theme/       warna, tipografi, dan tema
  models/      model data
  data/        auth controller dan repository Supabase
  widgets/     komponen UI bersama
  screens/     layar produksi
supabase/
  migrations/  skema dan RLS
```

## Layar

- Masuk dan daftar
- Beranda
- Aktivitas
- Jadwal latihan
- Profil
- Dasbor admin
- Daftar pengguna
- Setup kredensial

Kondisi loading, kosong, error, dan validasi ditangani langsung di layar terkait. Aplikasi tidak memakai data contoh dan tidak menyediakan galeri demo.

## Setup

1. Buat proyek di Supabase.
2. Jalankan migrasi `supabase/migrations/20260101000000_init.sql` lewat SQL Editor atau Supabase CLI.
3. Ambil Project URL dan publishable/anon key dari dashboard Supabase.
4. Jalankan aplikasi:

```powershell
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

Tanpa kredensial, aplikasi menampilkan layar setup dan tidak masuk ke mode demo.

## Menjalankan di Chrome (mode dev)

```powershell
flutter pub get
flutter run -d chrome --web-port=8080
```

Chrome terbuka otomatis dengan hot restart. Ganti port dengan `--web-port=<angka>` bila 8080 dipakai. Untuk memilih kredensial lain, tambahkan lagi `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.

Daftar perangkat yang terdeteksi bisa dicek dengan `flutter devices`.

## Menjalankan lewat Express (mode produksi)

Hasil build web disajikan oleh server Express kecil di folder `server/`.

```powershell
# sekali saja
cd server
npm install

# build web lalu jalankan server
npm run serve
```

Buka `http://localhost:8080`. Perintah lain:

| Perintah | Fungsi |
| --- | --- |
| `npm run build` | `flutter build web --release` ke `build/web` |
| `npm start` | Jalankan server dari build yang sudah ada |
| `PORT=3000 npm start` | Ganti port (PowerShell: `$env:PORT=3000; npm start`) |

### Menampilkan di HP (tanpa Expo)

Server Express mendengarkan semua antarmuka jaringan, jadi HP di Wi-Fi yang sama bisa membukanya lewat browser:

1. Jalankan `npm run serve` (atau `npm start` jika `build/web` sudah ada).
2. Perhatikan baris `Dari HP (jaringan sama): http://<ip>:8080` di terminal.
3. Buka alamat itu di Chrome/Safari HP.

Jika HP tidak bisa terhubung, izinkan Node.js di Windows Firewall (sekali saja, jalankan PowerShell sebagai Administrator):

```powershell
New-NetFirewallRule -DisplayName "Sehatku Web 8080" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
```

Alternatif tanpa server: build APK lalu pasang di HP.

```powershell
flutter build apk --release
# hasil: build/app/outputs/flutter-apk/app-release.apk (universal, ~52 MB)

flutter build apk --release --split-per-abi
# hasil: app-arm64-v8a-release.apk (~19 MB, mayoritas HP modern),
#        app-armeabi-v7a-release.apk (~16 MB, HP lama 32-bit)
```

Build Android memerlukan **JDK 17 atau 21**. JDK 27 gagal di `JdkImageTransform`
(`jlink ... cannot find the build signature`). Jika JDK default terlalu baru,
pasang Temurin 21 lalu arahkan Flutter ke sana:

```powershell
flutter config --jdk-dir="C:\Users\<user>\AppData\Local\Programs\jdk21\jdk-21.0.13+9"
```

Catatan:

- Kredensial Supabase dibaca saat **build**, bukan saat server jalan. Jika URL/key berubah, build ulang dengan `--dart-define`, misalnya `flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.
- Untuk akses dari HP, tambahkan juga `http://<ip-lan>:8080` ke **Supabase → Authentication → URL Configuration**.
- Tambahkan `http://localhost:8080` (dan domain produksi) di **Supabase Dashboard → Authentication → URL Configuration** agar tautan konfirmasi email/OAuth kembali ke aplikasi.
- Folder `build/web` dan `server/node_modules` tidak ikut di-commit.
- APK release saat ini ditandatangani dengan debug keystore dan memakai
  `applicationId com.example.sehatku`. Untuk Play Store, buat keystore rilis di
  `android/app/build.gradle.kts` dan ganti `applicationId` ke ID unik (mis.
  `com.sehatku.app`) sebelum build.

## Admin

Setelah pengguna pertama mendaftar, jadikan admin jika perlu:

```sql
update public.profiles set role = 'admin' where email = 'admin@contoh.com';
```

Menu **Dasbor admin** muncul di Profil hanya untuk akun dengan role `admin`.

## Troubleshooting

**"Profil akun belum lengkap sehingga data tidak bisa disimpan" saat membuat rencana/latihan.**
Baris `profiles` untuk akun Anda tidak ada (biasanya akun dibuat sebelum migrasi/trigger terpasang), sehingga insert ke `plans` gagal karena foreign key. Jalankan migrasi backfill di SQL Editor:

```sql
-- isi file supabase/migrations/20260102000000_backfill_profiles.sql
insert into public.profiles (id, email, full_name, avatar_initial, role)
select u.id, coalesce(u.email, ''),
       coalesce(u.raw_user_meta_data ->> 'full_name', split_part(coalesce(u.email, ''), '@', 1)),
       upper(left(coalesce(u.raw_user_meta_data ->> 'full_name', u.email, 'S'), 1)), 'user'
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;
```

**"Tabel database belum tersedia" / "Struktur database belum sesuai".**
Migrasi belum dijalankan atau belum lengkap. Jalankan `supabase/migrations/20260101000000_init.sql`, lalu backfill di atas.

**Aktivitas kosong padahal sudah mencatat langkah.**
Tab Aktivitas memuat data sekali saat login; tekan **Muat ulang** di kartu tersebut. Data hanya masuk lewat tombol **Catat** di Beranda karena aplikasi belum tersambung ke Google Fit/Health Connect.

## Verifikasi

```powershell
flutter analyze
flutter test
flutter build web
```

Build Android memerlukan Android SDK dan Java yang terpasang.
