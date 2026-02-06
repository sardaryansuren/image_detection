# image_processing

Flutter app for **face detection** and **document scanning** using **Google ML Kit**.

## Features
- Camera & gallery image input  
- Live face and text detection  
- Face processing  
- Document scan → PDF  
- Text extraction  
- Local history (SQLite)

## Tech
- Flutter
- GetX
- Google ML Kit (Face & Text)
- Camera
- Sqflite
- PDF generation


## Dependencies
```yaml

  # State management & navigation
  get: ^4.6.6

  # Camera & image input
  camera: ^0.11.2
  image_picker: ^1.1.2

  # Google ML Kit
  google_mlkit_face_detection: ^0.13.1
  google_mlkit_text_recognition: ^0.15.0

  # Image processing
  image: ^4.2.0

  # PDF generation
  pdf: ^3.11.0
  path_provider: ^2.1.4
  path: ^1.9.0

  # Local database
  sqflite: ^2.4.1

  # Utilities
  intl: ^0.19.0
  open_filex: ^4.7.0
