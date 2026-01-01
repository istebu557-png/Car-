# 🚗 Roblox Araç Sistemi

Roblox için gelişmiş, tam özellikli araç simülasyon sistemi. **Tek komutla kurulum** - araç modeli dahil her şey otomatik!

![Roblox](https://img.shields.io/badge/Roblox-Ready-red)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-1.1.0-blue)

---

## ⚡ Tek Komutla Kurulum

Roblox Studio'da **View > Command Bar** açın ve şu komutu yapıştırın:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/istebu557-png/Car-/main/install_from_github.lua"))()
```

**Bu komut otomatik olarak:**
- ✅ Tüm scriptleri yükler
- ✅ Araç modelini oluşturur
- ✅ VehicleSeat ekler
- ✅ Farları ve lambaları ekler
- ✅ Tekerlekleri ekler
- ✅ Her şeyi hazır hale getirir!

> ⚠️ **İlk kullanımda:** `Game Settings > Security > Allow HTTP Requests` seçeneğini aktif edin.

---

## 🎬 Kurulumdan Sonra

1. **Play** butonuna basın
2. Araca yaklaşın ve **binin**
3. **Sürmeye başlayın!**

---

## 🎮 Kontroller

| Tuş | Aksiyon |
|-----|---------|
| `W` / `↑` | İleri (Gaz) |
| `S` / `↓` | Fren / Geri |
| `A` / `←` | Sola Dön |
| `D` / `→` | Sağa Dön |
| `E` | Vites Yükselt |
| `Q` | Vites Düşür |
| `Space` | El Freni |
| `L` | Farlar |
| `Y` | Motor Aç/Kapat |
| `N` | Boş Vites |
| `R` | Geri Vites |
| `Tab` | Ayarlar Menüsü |

> 💡 Tüm tuşlar ayarlar menüsünden değiştirilebilir!

---

## ✨ Özellikler

### 🔧 Motor Sistemi
- Gerçekçi HP ve tork eğrileri (100-1000 HP)
- RPM bazlı performans hesaplaması
- Yakıt tüketimi simülasyonu

### ⚙️ Şanzıman Sistemi
- 6 ileri + 1 geri vites
- Manuel ve otomatik mod
- 5 hazır profil: Standard, Sport, Economy, Racing, Off-Road

### 💡 Aydınlatma Sistemi
- Kısa/uzun far
- Stop lambaları
- Sinyal lambaları

### 📊 Modern UI
- Dijital hız göstergesi
- RPM bar (kırmızı bölge uyarısı)
- Yakıt göstergesi
- Vites göstergesi

### ⚙️ Ayarlar Menüsü
- Tuş atamalarını değiştirme
- Motor parametrelerini ayarlama
- Şanzıman profili seçimi

---

## 🚙 Otomatik Oluşturulan Araç

Kurulum scripti şu parçaları içeren bir spor araba oluşturur:

- Gövde (kırmızı)
- Tavan ve camlar
- 4 tekerlek (jantlı)
- VehicleSeat (sürücü koltuğu)
- Ön farlar (2 adet)
- Arka stop lambaları (2 adet)
- Sinyal lambaları (4 adet)
- Ön ve arka tamponlar

---

## 📁 Dosya Yapısı

```
Car-/
├── src/
│   ├── Client/
│   │   └── CarSystemClient.client.lua
│   └── Shared/
│       └── CarSystem/
│           ├── CarEngine.lua
│           ├── TransmissionSystem.lua
│           ├── InputController.lua
│           ├── VehicleLights.lua
│           ├── DashboardUI.lua
│           └── SettingsUI.lua
├── install_from_github.lua    # ← TEK KOMUT KURULUM
├── default.project.json
└── README.md
```

---

## 🔧 Özelleştirme

Ayarlar menüsünden (Tab tuşu) şunları değiştirebilirsiniz:

- **Motor:** HP, Tork, Redline RPM
- **Şanzıman:** Profil, vites oranları
- **Kontroller:** Tüm tuş atamaları

---

## 📝 Lisans

MIT License - Dilediğiniz gibi kullanabilirsiniz.

---

**Versiyon:** 1.1.0  
**Son Güncelleme:** Ocak 2026
