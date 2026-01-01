#!/bin/bash

echo "========================================"
echo "  ROBLOX ARAÇ SİSTEMİ - KURULUM"
echo "========================================"
echo ""

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Rojo kontrolü
if ! command -v rojo &> /dev/null; then
    echo -e "${RED}[!] Rojo bulunamadı!${NC}"
    echo ""
    echo "Rojo'yu yüklemek için:"
    echo ""
    echo "  macOS (Homebrew):"
    echo "    brew install rojo"
    echo ""
    echo "  Cargo ile:"
    echo "    cargo install rojo"
    echo ""
    echo "  Aftman ile:"
    echo "    aftman install"
    echo ""
    exit 1
fi

echo -e "${GREEN}[✓] Rojo bulundu!${NC}"
echo ""

# Seçenekleri göster
echo "Seçenekler:"
echo "  1) .rbxl dosyası oluştur (Roblox Studio ile aç)"
echo "  2) Canlı senkronizasyon başlat (rojo serve)"
echo "  3) Çıkış"
echo ""

read -p "Seçiminiz (1/2/3): " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}[*] CarSystem.rbxl oluşturuluyor...${NC}"
        rojo build -o CarSystem.rbxl
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}[✓] CarSystem.rbxl başarıyla oluşturuldu!${NC}"
            echo "[*] Dosyayı Roblox Studio ile açabilirsiniz."
        else
            echo -e "${RED}[!] Hata oluştu!${NC}"
        fi
        ;;
    2)
        echo ""
        echo -e "${YELLOW}[*] Rojo server başlatılıyor...${NC}"
        echo "[*] Roblox Studio'da Rojo plugin'ini açın ve 'Connect' butonuna basın."
        echo "[*] Durdurmak için Ctrl+C"
        echo ""
        rojo serve
        ;;
    3)
        echo "Çıkış yapılıyor..."
        exit 0
        ;;
    *)
        echo -e "${RED}Geçersiz seçim!${NC}"
        exit 1
        ;;
esac
