# 🥚 Sistem Admin Telor Gulung

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**Aplikasi Manajemen Bisnis Telor Gulung | Egg Roll Business Management App | 卵巻きビジネス管理アプリ**

[🇮🇩 Indonesia](#-indonesia) • [🇬🇧 English](#-english) • [🇯🇵 日本語](#-日本語)

</div>

---

## 🇮🇩 Indonesia

### 📋 Deskripsi

**Sistem Admin Telor Gulung** adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk membantu pengelolaan bisnis kuliner telor gulung (telur gulung). Aplikasi ini menyediakan fitur lengkap untuk manajemen pesanan, produk, pengguna, serta analisis penjualan dalam satu platform yang mudah digunakan.

### ✨ Fitur Utama

| Fitur                       | Deskripsi                                                 |
| --------------------------- | --------------------------------------------------------- |
| 🕌 **Jadwal Sholat**        | Menampilkan jadwal waktu sholat harian berdasarkan lokasi |
| 📦 **Manajemen Pesanan**    | Kelola pesanan pelanggan dengan status tracking           |
| 🍳 **Manajemen Produk**     | Tambah, edit, dan hapus produk dengan gambar              |
| 👥 **Persetujuan Pengguna** | Sistem approval untuk pengguna baru                       |
| 📊 **Grafik Penjualan**     | Visualisasi data penjualan untuk analisis bisnis          |
| ℹ️ **Tentang Kami**         | Informasi tim pengembang aplikasi                         |

### 🛠️ Teknologi yang Digunakan

- **Framework**: Flutter 3.x
- **Bahasa**: Dart
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **Navigation**: curved_navigation_bar
- **Environment**: flutter_dotenv

### 📱 Instalasi

```bash
# Clone repository
git clone https://github.com/Sanikhsan12/sistem_admin_telor_gulung.git

# Masuk ke direktori project
cd sistem_admin_telor_gulung

# Buat file .env dan konfigurasi
# (Salin dari .env.example jika tersedia)

# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

### ⚙️ Konfigurasi

Buat file `.env` di root project dengan konfigurasi berikut:

```env
BASE_URL=your_api_base_url
API_KEY=your_api_key
```

---

## 🇬🇧 English

### 📋 Description

**Sistem Admin Telor Gulung** is a Flutter-based mobile application specifically designed to help manage egg roll (telor gulung) culinary businesses. This application provides comprehensive features for order management, products, users, and sales analysis in one easy-to-use platform.

### ✨ Key Features

| Feature                   | Description                                    |
| ------------------------- | ---------------------------------------------- |
| 🕌 **Prayer Schedule**    | Displays daily prayer times based on location  |
| 📦 **Order Management**   | Manage customer orders with status tracking    |
| 🍳 **Product Management** | Add, edit, and delete products with images     |
| 👥 **User Approval**      | Approval system for new users                  |
| 📊 **Sales Graph**        | Sales data visualization for business analysis |
| ℹ️ **About Us**           | Application developer team information         |

### 🛠️ Technologies Used

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **Navigation**: curved_navigation_bar
- **Environment**: flutter_dotenv

### 📱 Installation

```bash
# Clone the repository
git clone https://github.com/Sanikhsan12/sistem_admin_telor_gulung.git

# Navigate to project directory
cd sistem_admin_telor_gulung

# Create .env file and configure
# (Copy from .env.example if available)

# Install dependencies
flutter pub get

# Run the application
flutter run
```

### ⚙️ Configuration

Create a `.env` file in the project root with the following configuration:

```env
BASE_URL=your_api_base_url
API_KEY=your_api_key
```

---

## 🇯🇵 日本語

### 📋 説明

**Sistem Admin Telor Gulung** は、卵巻き（テロールグルン）料理ビジネスの管理を支援するために特別に設計された Flutter ベースのモバイルアプリケーションです。このアプリケーションは、注文管理、製品、ユーザー、および販売分析のための包括的な機能を、使いやすい一つのプラットフォームで提供します。

### ✨ 主な機能

| 機能                    | 説明                                 |
| ----------------------- | ------------------------------------ |
| 🕌 **礼拝スケジュール** | 場所に基づいた毎日の礼拝時間を表示   |
| 📦 **注文管理**         | ステータス追跡付きで顧客注文を管理   |
| 🍳 **製品管理**         | 画像付きで製品を追加、編集、削除     |
| 👥 **ユーザー承認**     | 新規ユーザーの承認システム           |
| 📊 **売上グラフ**       | ビジネス分析のための売上データ可視化 |
| ℹ️ **私たちについて**   | アプリケーション開発チームの情報     |

### 🛠️ 使用技術

- **フレームワーク**: Flutter 3.x
- **言語**: Dart
- **状態管理**: StatefulWidget
- **HTTP クライアント**: http パッケージ
- **ローカルストレージ**: shared_preferences
- **ナビゲーション**: curved_navigation_bar
- **環境設定**: flutter_dotenv

### 📱 インストール

```bash
# リポジトリをクローン
git clone https://github.com/Sanikhsan12/sistem_admin_telor_gulung.git

# プロジェクトディレクトリに移動
cd sistem_admin_telor_gulung

# .envファイルを作成して設定
# （利用可能な場合は.env.exampleからコピー）

# 依存関係をインストール
flutter pub get

# アプリケーションを実行
flutter run
```

### ⚙️ 設定

プロジェクトルートに以下の設定で `.env` ファイルを作成してください：

```env
BASE_URL=your_api_base_url
API_KEY=your_api_key
```

---

## 📁 Struktur Proyek | Project Structure | プロジェクト構造

```
lib/
├── main.dart                 # Entry point aplikasi
├── model/                    # Model data
│   ├── jadwal_sholat_model.dart
│   ├── order_model.dart
│   ├── product_model.dart
│   └── user_model.dart
├── service/                  # API services
│   ├── auth_service.dart
│   ├── jadwal_sholat_service.dart
│   ├── order_service.dart
│   ├── product_service.dart
│   └── user_approval_service.dart
└── view/                     # UI pages
    ├── about_page.dart
    ├── container_page.dart
    ├── home_page.dart
    ├── login_page.dart
    ├── order_page.dart
    ├── product_page.dart
    ├── sales_graph_page.dart
    ├── splash_screen_page.dart
    └── user_approval_page.dart
```

---

## 👨‍💻 Tim Pengembang | Development Team | 開発チーム

<table>
  <tr>
    <td align="center">
      <strong>Muhammad Ikhsan</strong><br>
      <sub>NIM: 152022001</sub>
    </td>
    <td align="center">
      <strong>Muhammad Usri Yusron</strong><br>
      <sub>NIM: 152022132</sub>
    </td>
    <td align="center">
      <strong>Muhammad Yazid</strong><br>
      <sub>NIM: 152022192</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>Budi Amin</strong><br>
      <sub>NIM: 152022213</sub>
    </td>
    <td align="center">
      <strong>Ahmad Faoyan</strong><br>
      <sub>NIM: 152024601</sub>
    </td>
    <td align="center"></td>
  </tr>
</table>

---

## 📄 Lisensi | License | ライセンス

Proyek ini dibuat untuk keperluan tugas mata kuliah **Pemrograman Mobile**.

This project was created for **Mobile Programming** course assignment.

このプロジェクトは**モバイルプログラミング**の授業課題のために作成されました。

---

<div align="center">

**Made with ❤️ using Flutter**

</div>
