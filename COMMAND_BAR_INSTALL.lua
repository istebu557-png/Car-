--[[
╔══════════════════════════════════════════════════════════════════╗
║           ROBLOX ARAÇ SİSTEMİ - TEK KOMUT KURULUM               ║
╠══════════════════════════════════════════════════════════════════╣
║  Bu scripti Roblox Studio Command Bar'a yapıştırın ve Enter'a   ║
║  basın. Tüm sistem otomatik olarak kurulacaktır.                ║
╚══════════════════════════════════════════════════════════════════╝

KULLANIM:
1. Roblox Studio'yu açın
2. View > Command Bar'ı açın
3. Aşağıdaki TÜM kodu kopyalayın
4. Command Bar'a yapıştırın
5. Enter'a basın
6. Kurulum tamamlandığında bir araca binin ve test edin!

]]

-- TEK SATIRLIK VERSİYON (Command Bar'a yapıştırın):
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/istebu557-png/Car-/main/install_from_github.lua"))()

-- VEYA AŞAĞIDAKİ TÜM KODU KOPYALAYIN:

local function Install()
    print("========================================")
    print("  ARAÇ SİSTEMİ KURULUYOR...")
    print("========================================")
    
    -- ReplicatedStorage'da CarSystem klasörü oluştur
    local RS = game:GetService("ReplicatedStorage")
    local CarSystem = Instance.new("Folder")
    CarSystem.Name = "CarSystem"
    CarSystem.Parent = RS
    
    -- Modül scriptleri oluştur
    local modules = {
        "CarEngine",
        "TransmissionSystem", 
        "InputController",
        "VehicleLights",
        "DashboardUI",
        "SettingsUI"
    }
    
    for _, moduleName in ipairs(modules) do
        local module = Instance.new("ModuleScript")
        module.Name = moduleName
        module.Parent = CarSystem
        print("  [+] " .. moduleName .. " oluşturuldu")
    end
    
    -- StarterPlayerScripts'e client script ekle
    local StarterPlayer = game:GetService("StarterPlayer")
    local StarterPlayerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
    if not StarterPlayerScripts then
        StarterPlayerScripts = Instance.new("Folder")
        StarterPlayerScripts.Name = "StarterPlayerScripts"
        StarterPlayerScripts.Parent = StarterPlayer
    end
    
    local clientScript = Instance.new("LocalScript")
    clientScript.Name = "CarSystemClient"
    clientScript.Parent = StarterPlayerScripts
    
    print("")
    print("========================================")
    print("  ✓ KURULUM TAMAMLANDI!")
    print("========================================")
    print("")
    print("SONRAKİ ADIMLAR:")
    print("1. GitHub'dan script içeriklerini kopyalayın")
    print("2. Her ModuleScript'e ilgili kodu yapıştırın")
    print("3. Araç modelinize VehicleSeat ekleyin")
    print("4. Test edin!")
    print("")
    print("GitHub: https://github.com/istebu557-png/Car-")
    print("========================================")
    
    -- Selection ile oluşturulan klasörü seç
    game:GetService("Selection"):Set({CarSystem})
end

Install()
