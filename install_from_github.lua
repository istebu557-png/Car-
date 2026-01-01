--[[
    ROBLOX ARAÇ SİSTEMİ - OTOMATİK KURULUM
    
    Command Bar'a yapıştırın:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/istebu557-png/Car-/main/install_from_github.lua"))()
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Selection = game:GetService("Selection")

local GITHUB_RAW = "https://raw.githubusercontent.com/istebu557-png/Car-/main/"

local FILES = {
    {name = "CarEngine", path = "src/Shared/CarSystem/CarEngine.lua"},
    {name = "TransmissionSystem", path = "src/Shared/CarSystem/TransmissionSystem.lua"},
    {name = "InputController", path = "src/Shared/CarSystem/InputController.lua"},
    {name = "VehicleLights", path = "src/Shared/CarSystem/VehicleLights.lua"},
    {name = "DashboardUI", path = "src/Shared/CarSystem/DashboardUI.lua"},
    {name = "SettingsUI", path = "src/Shared/CarSystem/SettingsUI.lua"},
}

local CLIENT_SCRIPT = "src/Client/CarSystemClient.client.lua"

print("╔══════════════════════════════════════════════════════════════╗")
print("║           ROBLOX ARAÇ SİSTEMİ - OTOMATİK KURULUM            ║")
print("╚══════════════════════════════════════════════════════════════╝")
print("")

-- Mevcut CarSystem varsa sil
local existingCarSystem = ReplicatedStorage:FindFirstChild("CarSystem")
if existingCarSystem then
    print("[!] Mevcut CarSystem siliniyor...")
    existingCarSystem:Destroy()
end

-- CarSystem klasörü oluştur
local CarSystem = Instance.new("Folder")
CarSystem.Name = "CarSystem"
CarSystem.Parent = ReplicatedStorage

print("[*] CarSystem klasörü oluşturuldu")
print("")

-- Modülleri indir ve oluştur
local successCount = 0
local failCount = 0

for _, file in ipairs(FILES) do
    local success, result = pcall(function()
        local url = GITHUB_RAW .. file.path
        local source = game:HttpGet(url)
        
        local module = Instance.new("ModuleScript")
        module.Name = file.name
        module.Source = source
        module.Parent = CarSystem
        
        return true
    end)
    
    if success then
        print("  [✓] " .. file.name)
        successCount = successCount + 1
    else
        print("  [✗] " .. file.name .. " - HATA: " .. tostring(result))
        failCount = failCount + 1
    end
end

print("")

-- Client script'i indir ve oluştur
local StarterPlayerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
if not StarterPlayerScripts then
    StarterPlayerScripts = Instance.new("Folder")
    StarterPlayerScripts.Name = "StarterPlayerScripts"
    StarterPlayerScripts.Parent = StarterPlayer
end

-- Mevcut client script varsa sil
local existingClient = StarterPlayerScripts:FindFirstChild("CarSystemClient")
if existingClient then
    existingClient:Destroy()
end

local clientSuccess, clientResult = pcall(function()
    local url = GITHUB_RAW .. CLIENT_SCRIPT
    local source = game:HttpGet(url)
    
    local clientScript = Instance.new("LocalScript")
    clientScript.Name = "CarSystemClient"
    clientScript.Source = source
    clientScript.Parent = StarterPlayerScripts
    
    return true
end)

if clientSuccess then
    print("[✓] CarSystemClient (LocalScript)")
    successCount = successCount + 1
else
    print("[✗] CarSystemClient - HATA: " .. tostring(clientResult))
    failCount = failCount + 1
end

print("")
print("════════════════════════════════════════════════════════════════")

if failCount == 0 then
    print("  ✓ KURULUM BAŞARIYLA TAMAMLANDI!")
    print("")
    print("  Yüklenen modül sayısı: " .. successCount)
    print("")
    print("  SONRAKİ ADIMLAR:")
    print("  1. Workspace'e bir araç modeli ekleyin")
    print("  2. Araç modeline VehicleSeat ekleyin")
    print("  3. Play tuşuna basın ve test edin!")
    print("")
    print("  KONTROLLER:")
    print("    W/S - İleri/Geri")
    print("    A/D - Sola/Sağa")
    print("    E/Q - Vites Yükselt/Düşür")
    print("    Space - El Freni")
    print("    L - Farlar")
    print("    Tab - Ayarlar")
else
    print("  ⚠ KURULUM TAMAMLANDI (Bazı hatalar oluştu)")
    print("")
    print("  Başarılı: " .. successCount)
    print("  Başarısız: " .. failCount)
    print("")
    print("  HttpService'in etkin olduğundan emin olun:")
    print("  Game Settings > Security > Allow HTTP Requests")
end

print("════════════════════════════════════════════════════════════════")

-- Oluşturulan klasörü seç
Selection:Set({CarSystem})
