--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║       ROBLOX ARAÇ SİSTEMİ - TAM OTOMATİK KURULUM                ║
    ╠══════════════════════════════════════════════════════════════════╣
    ║  Tek komutla:                                                    ║
    ║  - Tüm scriptler yüklenir                                        ║
    ║  - Araç modeli oluşturulur                                       ║
    ║  - VehicleSeat eklenir                                           ║
    ║  - Işıklar eklenir                                               ║
    ║  - Her şey hazır!                                                ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    KULLANIM:
    Command Bar'a yapıştırın:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/istebu557-png/Car-/main/install_from_github.lua"))()
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")
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

-- ═══════════════════════════════════════════════════════════════
-- ARAÇ MODELİ OLUŞTURMA FONKSİYONU
-- ═══════════════════════════════════════════════════════════════

local function CreateCarModel()
    print("[*] Araç modeli oluşturuluyor...")
    
    -- Ana model
    local car = Instance.new("Model")
    car.Name = "SportCar"
    
    -- Gövde (Body)
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(6, 2, 12)
    body.Position = Vector3.new(0, 3, 0)
    body.Anchored = false
    body.BrickColor = BrickColor.new("Bright red")
    body.Material = Enum.Material.SmoothPlastic
    body.Parent = car
    
    -- Gövde mesh (daha güzel görünüm)
    local bodyMesh = Instance.new("SpecialMesh")
    bodyMesh.MeshType = Enum.MeshType.Brick
    bodyMesh.Parent = body
    
    -- Tavan
    local roof = Instance.new("Part")
    roof.Name = "Roof"
    roof.Size = Vector3.new(5, 1.5, 5)
    roof.Position = Vector3.new(0, 4.5, -1)
    roof.Anchored = false
    roof.BrickColor = BrickColor.new("Bright red")
    roof.Material = Enum.Material.SmoothPlastic
    roof.Parent = car
    
    -- Tavan weld
    local roofWeld = Instance.new("WeldConstraint")
    roofWeld.Part0 = roof
    roofWeld.Part1 = body
    roofWeld.Parent = roof
    
    -- Ön cam
    local windshield = Instance.new("Part")
    windshield.Name = "Windshield"
    windshield.Size = Vector3.new(4.8, 1.5, 0.2)
    windshield.Position = Vector3.new(0, 4.5, 1.6)
    windshield.Rotation = Vector3.new(-30, 0, 0)
    windshield.Anchored = false
    windshield.BrickColor = BrickColor.new("Pastel light blue")
    windshield.Material = Enum.Material.Glass
    windshield.Transparency = 0.5
    windshield.Parent = car
    
    local windshieldWeld = Instance.new("WeldConstraint")
    windshieldWeld.Part0 = windshield
    windshieldWeld.Part1 = body
    windshieldWeld.Parent = windshield
    
    -- Arka cam
    local rearWindow = Instance.new("Part")
    rearWindow.Name = "RearWindow"
    rearWindow.Size = Vector3.new(4.8, 1.2, 0.2)
    rearWindow.Position = Vector3.new(0, 4.3, -3.6)
    rearWindow.Rotation = Vector3.new(30, 0, 0)
    rearWindow.Anchored = false
    rearWindow.BrickColor = BrickColor.new("Pastel light blue")
    rearWindow.Material = Enum.Material.Glass
    rearWindow.Transparency = 0.5
    rearWindow.Parent = car
    
    local rearWindowWeld = Instance.new("WeldConstraint")
    rearWindowWeld.Part0 = rearWindow
    rearWindowWeld.Part1 = body
    rearWindowWeld.Parent = rearWindow
    
    -- VehicleSeat (Sürücü koltuğu)
    local seat = Instance.new("VehicleSeat")
    seat.Name = "VehicleSeat"
    seat.Size = Vector3.new(2, 1, 2)
    seat.Position = Vector3.new(-1, 3, 0)
    seat.Anchored = false
    seat.BrickColor = BrickColor.new("Black")
    seat.Material = Enum.Material.Fabric
    seat.MaxSpeed = 150
    seat.Torque = 20000
    seat.TurnSpeed = 2
    seat.Parent = car
    
    local seatWeld = Instance.new("WeldConstraint")
    seatWeld.Part0 = seat
    seatWeld.Part1 = body
    seatWeld.Parent = seat
    
    -- Tekerlekler oluşturma fonksiyonu
    local function CreateWheel(name, position)
        local wheel = Instance.new("Part")
        wheel.Name = name
        wheel.Shape = Enum.PartType.Cylinder
        wheel.Size = Vector3.new(1.2, 0.8, 1.2)
        wheel.Position = position
        wheel.Rotation = Vector3.new(0, 0, 90)
        wheel.Anchored = false
        wheel.BrickColor = BrickColor.new("Really black")
        wheel.Material = Enum.Material.Rubber
        wheel.Parent = car
        
        -- Jant
        local rim = Instance.new("Part")
        rim.Name = name .. "Rim"
        rim.Shape = Enum.PartType.Cylinder
        rim.Size = Vector3.new(0.5, 0.85, 0.5)
        rim.Position = position
        rim.Rotation = Vector3.new(0, 0, 90)
        rim.Anchored = false
        rim.BrickColor = BrickColor.new("Medium stone grey")
        rim.Material = Enum.Material.Metal
        rim.Parent = car
        
        local rimWeld = Instance.new("WeldConstraint")
        rimWeld.Part0 = rim
        rimWeld.Part1 = wheel
        rimWeld.Parent = rim
        
        -- Tekerlek body'ye bağlantı
        local wheelWeld = Instance.new("WeldConstraint")
        wheelWeld.Part0 = wheel
        wheelWeld.Part1 = body
        wheelWeld.Parent = wheel
        
        return wheel
    end
    
    -- 4 tekerlek oluştur
    CreateWheel("WheelFL", Vector3.new(-2.8, 1.6, 4))   -- Ön sol
    CreateWheel("WheelFR", Vector3.new(2.8, 1.6, 4))    -- Ön sağ
    CreateWheel("WheelRL", Vector3.new(-2.8, 1.6, -4))  -- Arka sol
    CreateWheel("WheelRR", Vector3.new(2.8, 1.6, -4))   -- Arka sağ
    
    -- Işık oluşturma fonksiyonu
    local function CreateLight(name, position, color, isSpot)
        local light = Instance.new("Part")
        light.Name = name
        light.Size = Vector3.new(0.8, 0.4, 0.2)
        light.Position = position
        light.Anchored = false
        light.BrickColor = BrickColor.new(color)
        light.Material = Enum.Material.SmoothPlastic
        light.Parent = car
        
        local lightWeld = Instance.new("WeldConstraint")
        lightWeld.Part0 = light
        lightWeld.Part1 = body
        lightWeld.Parent = light
        
        -- SpotLight veya PointLight ekle
        if isSpot then
            local spotlight = Instance.new("SpotLight")
            spotlight.Brightness = 0
            spotlight.Range = 40
            spotlight.Angle = 60
            spotlight.Color = Color3.new(1, 1, 0.9)
            spotlight.Enabled = false
            spotlight.Parent = light
        else
            local pointlight = Instance.new("PointLight")
            pointlight.Brightness = 0
            pointlight.Range = 8
            pointlight.Color = Color3.fromRGB(255, 0, 0)
            pointlight.Enabled = false
            pointlight.Parent = light
        end
        
        return light
    end
    
    -- Ön farlar
    CreateLight("HeadlightLeft", Vector3.new(-2, 2.8, 6), "White", true)
    CreateLight("HeadlightRight", Vector3.new(2, 2.8, 6), "White", true)
    
    -- Arka stop lambaları
    CreateLight("TaillightLeft", Vector3.new(-2, 2.8, -6), "Bright red", false)
    CreateLight("TaillightRight", Vector3.new(2, 2.8, -6), "Bright red", false)
    
    -- Sinyal lambaları (ön)
    CreateLight("TurnSignalFL", Vector3.new(-2.8, 2.8, 5.5), "Bright orange", false)
    CreateLight("TurnSignalFR", Vector3.new(2.8, 2.8, 5.5), "Bright orange", false)
    
    -- Sinyal lambaları (arka)
    CreateLight("TurnSignalRL", Vector3.new(-2.8, 2.8, -5.5), "Bright orange", false)
    CreateLight("TurnSignalRR", Vector3.new(2.8, 2.8, -5.5), "Bright orange", false)
    
    -- Ön tampon
    local frontBumper = Instance.new("Part")
    frontBumper.Name = "FrontBumper"
    frontBumper.Size = Vector3.new(6, 0.8, 0.5)
    frontBumper.Position = Vector3.new(0, 2.2, 6.2)
    frontBumper.Anchored = false
    frontBumper.BrickColor = BrickColor.new("Dark stone grey")
    frontBumper.Material = Enum.Material.SmoothPlastic
    frontBumper.Parent = car
    
    local frontBumperWeld = Instance.new("WeldConstraint")
    frontBumperWeld.Part0 = frontBumper
    frontBumperWeld.Part1 = body
    frontBumperWeld.Parent = frontBumper
    
    -- Arka tampon
    local rearBumper = Instance.new("Part")
    rearBumper.Name = "RearBumper"
    rearBumper.Size = Vector3.new(6, 0.8, 0.5)
    rearBumper.Position = Vector3.new(0, 2.2, -6.2)
    rearBumper.Anchored = false
    rearBumper.BrickColor = BrickColor.new("Dark stone grey")
    rearBumper.Material = Enum.Material.SmoothPlastic
    rearBumper.Parent = car
    
    local rearBumperWeld = Instance.new("WeldConstraint")
    rearBumperWeld.Part0 = rearBumper
    rearBumperWeld.Part1 = body
    rearBumperWeld.Parent = rearBumper
    
    -- PrimaryPart ayarla
    car.PrimaryPart = body
    
    -- Modeli Workspace'e ekle
    car.Parent = Workspace
    
    -- Spawn noktasının üstüne yerleştir
    local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
    if spawnLocation then
        car:SetPrimaryPartCFrame(CFrame.new(spawnLocation.Position + Vector3.new(10, 5, 0)))
    else
        car:SetPrimaryPartCFrame(CFrame.new(0, 5, 0))
    end
    
    print("  [✓] Araç modeli oluşturuldu: " .. car.Name)
    
    return car
end

-- ═══════════════════════════════════════════════════════════════
-- ANA KURULUM
-- ═══════════════════════════════════════════════════════════════

print("╔══════════════════════════════════════════════════════════════╗")
print("║       ROBLOX ARAÇ SİSTEMİ - TAM OTOMATİK KURULUM            ║")
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

print("[✓] CarSystem klasörü oluşturuldu")
print("")
print("[*] Modüller indiriliyor...")
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
        print("  [✗] " .. file.name .. " - HATA!")
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
    print("[✗] CarSystemClient - HATA!")
    failCount = failCount + 1
end

print("")

-- Araç modeli oluştur
local car = CreateCarModel()

print("")
print("════════════════════════════════════════════════════════════════")

if failCount == 0 then
    print("")
    print("  ✅ KURULUM BAŞARIYLA TAMAMLANDI!")
    print("")
    print("  📦 Yüklenen: " .. successCount .. " modül")
    print("  🚗 Araç modeli: Workspace'e eklendi")
    print("")
    print("  ▶️  ŞİMDİ NE YAPMALI:")
    print("     1. Play butonuna basın")
    print("     2. Araca yaklaşın ve binin")
    print("     3. Sürmeye başlayın!")
    print("")
    print("  🎮 KONTROLLER:")
    print("     W/S     - İleri/Geri")
    print("     A/D     - Sola/Sağa")
    print("     E/Q     - Vites Yükselt/Düşür")
    print("     Space   - El Freni")
    print("     L       - Farlar")
    print("     Y       - Motor Aç/Kapat")
    print("     Tab     - Ayarlar Menüsü")
    print("")
else
    print("")
    print("  ⚠️  KURULUM TAMAMLANDI (Bazı hatalar var)")
    print("")
    print("  Başarılı: " .. successCount)
    print("  Başarısız: " .. failCount)
    print("")
    print("  HttpService'i kontrol edin:")
    print("  Game Settings > Security > Allow HTTP Requests")
    print("")
end

print("════════════════════════════════════════════════════════════════")

-- Oluşturulan araç modelini seç
Selection:Set({car})
