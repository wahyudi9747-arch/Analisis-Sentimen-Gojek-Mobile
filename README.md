# GUI Mobile - Analisis Sentimen Ulasan Gojek

Frontend Flutter untuk project UAS "Klasifikasi Sentimen Ulasan Gojek (CNN vs CNN-BiLSTM Hybrid)".
Menggantikan `gui_web/app_streamlit.py` dengan versi mobile, tanpa mengubah backend FastAPI sama sekali.

## Cara pakai

1. Salin folder ini ke dalam project utama, sejajar dengan `backend/`:
   ```
   gojek-sentiment-analysis-cnn-bilstm/
   ├── backend/
   ├── data/
   ├── gui_mobile/   <-- folder ini
   └── ...
   ```
2. Install dependency:
   ```
   flutter pub get
   ```
3. Jalankan (emulator atau HP fisik yang sudah di-debug mode):
   ```
   flutter run
   ```

## Status saat ini: DUMMY DATA

Backend/model masih dalam proses training, jadi `lib/services/sentiment_service.dart`
diset `useDummyData = true` — aplikasi sudah bisa dijalankan dan didemokan
tampilannya sekarang juga, hasilnya random tapi formatnya sudah sesuai skema asli.

## Setelah backend & model selesai

1. Jalankan backend FastAPI (`uvicorn app.main:app --reload` dari folder `backend/`).
2. Buka `lib/services/sentiment_service.dart`, ubah:
   ```dart
   static const bool useDummyData = false;
   static const String baseUrl = 'http://<SESUAIKAN>:8000';
   ```
   - Emulator Android -> `http://10.0.2.2:8000`
   - HP fisik satu WiFi dengan laptop -> `http://<IP_LOKAL_LAPTOP>:8000`
   - Sudah deploy (Railway/Render) -> URL publiknya langsung
3. Jalankan ulang `flutter run`. Tidak ada bagian UI lain yang perlu diubah.

## Kontrak API (mengikuti backend asli)

**POST** `/api/sentiment/predict`
```json
// request
{ "text": "aplikasinya bagus banget cepat responnya" }

// response
{
  "original_text": "...",
  "clean_text": "...",
  "predicted_label": "positif",
  "confidence": 0.92,
  "probabilities": { "positif": 0.92, "netral": 0.05, "negatif": 0.03 }
}
```

**GET** `/api/sentiment/history?limit=20`
Mengembalikan list riwayat prediksi. Field `text`/`label` di `HistoryItem`
(lib/models/prediction_result.dart) dibuat fleksibel menerima `original_text`
atau `predicted_label` — sesuaikan lagi kalau struktur asli dari `get_history()`
di `database.py` ternyata beda.

## Struktur folder

```
lib/
├── main.dart
├── models/
│   └── prediction_result.dart   # PredictionResult & HistoryItem
├── services/
│   └── sentiment_service.dart   # pemanggil API + toggle dummy data
├── pages/
│   ├── home_page.dart           # input teks + hasil prediksi
│   └── history_page.dart        # daftar riwayat
└── widgets/
    └── probability_bar.dart     # bar chart probabilitas per kelas
```
