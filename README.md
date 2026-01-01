# 🚗 Roblox Araç Sistemi

Roblox için gelişmiş, tam özellikli araç simülasyon sistemi. Gerçekçi motor fiziği, 6 vitesli şanzıman, modern UI ve tamamen özelleştirilebilir kontroller.

![Roblox](https://img.shields.io/badge/Roblox-Ready-red)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)

---

## ⚡ Tek Komutla Kurulum

### Yöntem 1: Command Bar (En Kolay)

Roblox Studio'da **View > Command Bar** açın ve şu komutu yapıştırın:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/istebu557-png/Car-/main/install_from_github.lua"))()
```

> ⚠️ **Not:** HttpService'in etkin olması gerekir: `Game Settings > Security > Allow HTTP Requests`

### Yöntem 2: Rojo ile Kurulum

```bash
# Repoyu klonla
git clone https://github.com/istebu557-png/Car-.git
cd Car-

# Windows
install.bat

# macOS/Linux
./install.sh
```

### Yöntem 3: Manuel Kurulum

1. `src/Shared/CarSystem/` içindeki tüm `.lua` dosyalarını `ReplicatedStorage/CarSystem/` altına ModuleScript olarak ekleyin
2. `src/Client/CarSystemClient.client.lua` dosyasını `StarterPlayerScripts/` altına LocalScript olarak ekleyin

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
- Gerçekçi HP ve tork eğrileri
- Ayarlanabilir motor parametreleri (100-1000 HP)
- RPM bazlı performans hesaplaması
- Yakıt tüketimi simülasyonu

### ⚙️ Şanzıman Sistemi
- 6 ileri + 1 geri vites
- Manuel ve otomatik mod
- 5 hazır profil:
  - **Standard** - Dengeli performans
  - **Sport** - Kısa oranlar, hızlı ivme
  - **Economy** - Uzun oranlar, yakıt tasarrufu
  - **Racing** - Maksimum performans
  - **Off-Road** - Yüksek tork

### 💡 Aydınlatma Sistemi
- Kısa/uzun far
- Stop lambaları
- Sinyal lambaları
- Geri vites lambası

### 📊 Modern UI
- Dijital hız göstergesi
- RPM bar göstergesi (kırmızı bölge uyarısı)
- Yakıt göstergesi (düşük yakıt uyarısı)
- Vites göstergesi
- HP ve Tork bilgisi

### ⚙️ Ayarlar Menüsü
- Tuş atamalarını değiştirme
- Motor parametrelerini ayarlama
- Şanzıman profili seçimi
- Vites oranlarını özelleştirme

---

## 📁 Dosya Yapısı

```
Car-/
├── src/
│   ├── Client/
│   │   └── CarSystemClient.client.lua    # Ana client script
│   ├── Server/
│   │   └── (boş - gerekirse server scriptleri)
│   └── Shared/
│       └── CarSystem/
│           ├── CarEngine.lua             # Motor fiziği
│           ├── TransmissionSystem.lua    # Şanzıman sistemi
│           ├── InputController.lua       # Kontrol sistemi
│           ├── VehicleLights.lua         # Aydınlatma
│           ├── DashboardUI.lua           # Gösterge paneli
│           └── SettingsUI.lua            # Ayarlar menüsü
├── default.project.json                   # Rojo yapılandırması
├── install.bat                            # Windows kurulum
├── install.sh                             # macOS/Linux kurulum
├── install_from_github.lua                # Command Bar kurulum
└── README.md
```

---

## 🚙 Araç Modeli Hazırlama

Araç modelinizde şu parçalar bulunmalıdır:

### Zorunlu
- `VehicleSeat` - Sürücü koltuğu

### İsteğe Bağlı (Işıklar için)
- `HeadlightLeft` / `HeadlightRight` - Ön farlar
- `TaillightLeft` / `TaillightRight` - Arka lambalar
- `TurnSignalFL` / `TurnSignalFR` - Ön sinyal lambaları
- `TurnSignalRL` / `TurnSignalRR` - Arka sinyal lambaları

### Örnek Model Yapısı
```
Car (Model)
├── Body (Part)
├── VehicleSeat (VehicleSeat)
├── WheelFL (Part)
├── WheelFR (Part)
├── WheelRL (Part)
├── WheelRR (Part)
├── HeadlightLeft (Part)
├── HeadlightRight (Part)
├── TaillightLeft (Part)
└── TaillightRight (Part)
```

---

## 🔧 Özelleştirme

### Motor Ayarları
```lua
Engine = {
    MaxHP = 350,           -- 100-1000 arası
    MaxTorque = 450,       -- 200-800 Nm arası
    RedlineRPM = 7500,     -- Kırmızı çizgi
    MaxRPM = 8000,
}
```

### Şanzıman Oranları
```lua
GearRatios = {
    [-1] = 3.2,  -- Geri
    [0] = 0,     -- Boş
    [1] = 3.5,   -- 1. vites
    [2] = 2.3,   -- 2. vites
    [3] = 1.7,   -- 3. vites
    [4] = 1.3,   -- 4. vites
    [5] = 1.0,   -- 5. vites
    [6] = 0.8,   -- 6. vites
}
```

---

## 📝 Lisans

MIT License - Dilediğiniz gibi kullanabilirsiniz.

---

## 🤝 Katkıda Bulunma

Pull request'ler memnuniyetle karşılanır!

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/YeniOzellik`)
3. Commit yapın (`git commit -m 'Yeni özellik eklendi'`)
4. Push yapın (`git push origin feature/YeniOzellik`)
5. Pull Request açın

---

## 📞 Destek

Sorularınız için:
- GitHub Issues açın
- Roblox DevForum'da konu oluşturun

---

**Versiyon:** 1.0.0  
**Son Güncelleme:** Ocak 2026
