--[[
    Roblox Araç Aydınlatma Sistemi
    Farlar, stop lambaları, sinyal lambaları
    
    Kullanım: Araç modeline yerleştirin
    Gereksinimler: Araç modelinde uygun ışık parçaları olmalı
]]

local VehicleLights = {}
VehicleLights.__index = VehicleLights

local TweenService = game:GetService("TweenService")

-- Işık konfigürasyonu
local LIGHT_CONFIG = {
    -- Ön farlar
    Headlights = {
        LowBeam = {
            Brightness = 2,
            Range = 40,
            Color = Color3.fromRGB(255, 250, 240), -- Sıcak beyaz
            Angle = 70,
            Shadows = true,
        },
        HighBeam = {
            Brightness = 4,
            Range = 80,
            Color = Color3.fromRGB(255, 255, 255), -- Soğuk beyaz
            Angle = 50,
            Shadows = true,
        },
    },
    
    -- Arka lambalar
    TailLights = {
        Normal = {
            Brightness = 0.5,
            Color = Color3.fromRGB(255, 0, 0),
        },
        Brake = {
            Brightness = 2,
            Color = Color3.fromRGB(255, 0, 0),
        },
    },
    
    -- Geri vites lambası
    ReverseLight = {
        Brightness = 1.5,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    -- Sinyal lambaları
    TurnSignals = {
        Brightness = 1.5,
        Color = Color3.fromRGB(255, 165, 0), -- Turuncu
        BlinkRate = 0.5, -- Saniyede yanıp sönme
    },
    
    -- Gündüz farları (DRL)
    DaytimeRunning = {
        Brightness = 1,
        Color = Color3.fromRGB(255, 255, 255),
    },
    
    -- Sis farları
    FogLights = {
        Brightness = 1.5,
        Range = 25,
        Color = Color3.fromRGB(255, 255, 200), -- Sarımsı
        Angle = 90,
    },
}

-- Yeni aydınlatma sistemi oluştur
function VehicleLights.new(vehicleModel)
    local self = setmetatable({}, VehicleLights)
    
    self.Vehicle = vehicleModel
    self.Config = LIGHT_CONFIG
    
    -- Işık durumları
    self.States = {
        Headlights = false,
        HighBeam = false,
        TailLights = false,
        BrakeLights = false,
        LeftTurnSignal = false,
        RightTurnSignal = false,
        HazardLights = false,
        ReverseLight = false,
        FogLights = false,
        DaytimeRunning = false,
    }
    
    -- Işık referansları
    self.Lights = {
        HeadlightLeft = nil,
        HeadlightRight = nil,
        TaillightLeft = nil,
        TaillightRight = nil,
        TurnSignalFrontLeft = nil,
        TurnSignalFrontRight = nil,
        TurnSignalRearLeft = nil,
        TurnSignalRearRight = nil,
        ReverseLeft = nil,
        ReverseRight = nil,
        FogLeft = nil,
        FogRight = nil,
    }
    
    -- Sinyal zamanlayıcı
    self.SignalTimer = 0
    self.SignalState = false
    
    -- Işıkları bul ve referansla
    self:FindLights()
    
    return self
end

-- Araç modelinde ışıkları bul
function VehicleLights:FindLights()
    local function findLight(name)
        return self.Vehicle:FindFirstChild(name, true)
    end
    
    -- Ön farlar
    self.Lights.HeadlightLeft = findLight("HeadlightLeft") or findLight("HeadlightL") or findLight("FarSol")
    self.Lights.HeadlightRight = findLight("HeadlightRight") or findLight("HeadlightR") or findLight("FarSag")
    
    -- Arka lambalar
    self.Lights.TaillightLeft = findLight("TaillightLeft") or findLight("TaillightL") or findLight("StopSol")
    self.Lights.TaillightRight = findLight("TaillightRight") or findLight("TaillightR") or findLight("StopSag")
    
    -- Sinyal lambaları
    self.Lights.TurnSignalFrontLeft = findLight("TurnSignalFL") or findLight("SinyalOnSol")
    self.Lights.TurnSignalFrontRight = findLight("TurnSignalFR") or findLight("SinyalOnSag")
    self.Lights.TurnSignalRearLeft = findLight("TurnSignalRL") or findLight("SinyalArkaSol")
    self.Lights.TurnSignalRearRight = findLight("TurnSignalRR") or findLight("SinyalArkaSag")
    
    -- Geri vites lambaları
    self.Lights.ReverseLeft = findLight("ReverseLeft") or findLight("GeriSol")
    self.Lights.ReverseRight = findLight("ReverseRight") or findLight("GeriSag")
    
    -- Sis farları
    self.Lights.FogLeft = findLight("FogLeft") or findLight("SisSol")
    self.Lights.FogRight = findLight("FogRight") or findLight("SisSag")
end

-- Işık parçasını ayarla
function VehicleLights:SetLightPart(part, enabled, config)
    if not part then return end
    
    -- SpotLight veya PointLight bul veya oluştur
    local light = part:FindFirstChildOfClass("SpotLight") or part:FindFirstChildOfClass("PointLight")
    
    if not light then
        -- Işık yoksa oluştur
        if config.Angle then
            light = Instance.new("SpotLight")
            light.Angle = config.Angle
        else
            light = Instance.new("PointLight")
        end
        light.Parent = part
    end
    
    -- Işık özelliklerini ayarla
    if enabled then
        light.Enabled = true
        light.Brightness = config.Brightness or 1
        light.Color = config.Color or Color3.new(1, 1, 1)
        if light:IsA("SpotLight") then
            light.Range = config.Range or 30
            light.Shadows = config.Shadows or false
        end
        
        -- Parçanın Material'ini değiştir (ışık efekti için)
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Neon
            part.Color = config.Color or Color3.new(1, 1, 1)
        end
    else
        light.Enabled = false
        
        -- Parçayı normale döndür
        if part:IsA("BasePart") then
            part.Material = Enum.Material.SmoothPlastic
            part.Color = Color3.fromRGB(50, 50, 50)
        end
    end
end

-- Ön farları aç/kapat
function VehicleLights:SetHeadlights(enabled, highBeam)
    self.States.Headlights = enabled
    self.States.HighBeam = highBeam or false
    
    local config = highBeam and self.Config.Headlights.HighBeam or self.Config.Headlights.LowBeam
    
    self:SetLightPart(self.Lights.HeadlightLeft, enabled, config)
    self:SetLightPart(self.Lights.HeadlightRight, enabled, config)
    
    -- Arka lambalar da açılsın (park lambası)
    if enabled then
        self:SetTailLights(true, false)
    end
end

-- Farları değiştir (toggle)
function VehicleLights:ToggleHeadlights()
    if not self.States.Headlights then
        self:SetHeadlights(true, false) -- Kısa far
    elseif not self.States.HighBeam then
        self:SetHeadlights(true, true) -- Uzun far
    else
        self:SetHeadlights(false, false) -- Kapat
    end
end

-- Arka lambaları ayarla
function VehicleLights:SetTailLights(enabled, braking)
    self.States.TailLights = enabled
    self.States.BrakeLights = braking
    
    local config = braking and self.Config.TailLights.Brake or self.Config.TailLights.Normal
    
    self:SetLightPart(self.Lights.TaillightLeft, enabled, config)
    self:SetLightPart(self.Lights.TaillightRight, enabled, config)
end

-- Fren lambaları
function VehicleLights:SetBrakeLights(braking)
    if self.States.Headlights then
        self:SetTailLights(true, braking)
    else
        self:SetTailLights(braking, braking)
    end
end

-- Geri vites lambası
function VehicleLights:SetReverseLight(enabled)
    self.States.ReverseLight = enabled
    
    self:SetLightPart(self.Lights.ReverseLeft, enabled, self.Config.ReverseLight)
    self:SetLightPart(self.Lights.ReverseRight, enabled, self.Config.ReverseLight)
end

-- Sol sinyal
function VehicleLights:SetLeftTurnSignal(enabled)
    self.States.LeftTurnSignal = enabled
    if enabled then
        self.States.RightTurnSignal = false
        self.States.HazardLights = false
    end
end

-- Sağ sinyal
function VehicleLights:SetRightTurnSignal(enabled)
    self.States.RightTurnSignal = enabled
    if enabled then
        self.States.LeftTurnSignal = false
        self.States.HazardLights = false
    end
end

-- Dörtlü (tehlike) lambaları
function VehicleLights:SetHazardLights(enabled)
    self.States.HazardLights = enabled
    if enabled then
        self.States.LeftTurnSignal = false
        self.States.RightTurnSignal = false
    end
end

-- Dörtlü değiştir
function VehicleLights:ToggleHazardLights()
    self:SetHazardLights(not self.States.HazardLights)
end

-- Sis farları
function VehicleLights:SetFogLights(enabled)
    self.States.FogLights = enabled
    
    self:SetLightPart(self.Lights.FogLeft, enabled, self.Config.FogLights)
    self:SetLightPart(self.Lights.FogRight, enabled, self.Config.FogLights)
end

-- Sis farlarını değiştir
function VehicleLights:ToggleFogLights()
    self:SetFogLights(not self.States.FogLights)
end

-- Gündüz farları
function VehicleLights:SetDaytimeRunning(enabled)
    self.States.DaytimeRunning = enabled
    -- DRL genellikle ön farlarda düşük parlaklıkta çalışır
    if enabled and not self.States.Headlights then
        local config = self.Config.DaytimeRunning
        self:SetLightPart(self.Lights.HeadlightLeft, true, config)
        self:SetLightPart(self.Lights.HeadlightRight, true, config)
    end
end

-- Sinyal lambalarını güncelle (yanıp sönme)
function VehicleLights:UpdateSignals(deltaTime)
    local blinkRate = self.Config.TurnSignals.BlinkRate
    
    self.SignalTimer = self.SignalTimer + deltaTime
    if self.SignalTimer >= blinkRate then
        self.SignalTimer = 0
        self.SignalState = not self.SignalState
    end
    
    local config = self.Config.TurnSignals
    
    -- Sol sinyal
    local leftEnabled = (self.States.LeftTurnSignal or self.States.HazardLights) and self.SignalState
    self:SetLightPart(self.Lights.TurnSignalFrontLeft, leftEnabled, config)
    self:SetLightPart(self.Lights.TurnSignalRearLeft, leftEnabled, config)
    
    -- Sağ sinyal
    local rightEnabled = (self.States.RightTurnSignal or self.States.HazardLights) and self.SignalState
    self:SetLightPart(self.Lights.TurnSignalFrontRight, rightEnabled, config)
    self:SetLightPart(self.Lights.TurnSignalRearRight, rightEnabled, config)
end

-- Ana güncelleme döngüsü
function VehicleLights:Update(deltaTime, vehicleData)
    -- Sinyal lambalarını güncelle
    self:UpdateSignals(deltaTime)
    
    -- Araç verilerine göre otomatik ışık kontrolü
    if vehicleData then
        -- Fren lambaları
        if vehicleData.IsBraking then
            self:SetBrakeLights(true)
        else
            self:SetBrakeLights(false)
        end
        
        -- Geri vites lambası
        if vehicleData.Gear == -1 then
            self:SetReverseLight(true)
        else
            self:SetReverseLight(false)
        end
    end
end

-- Tüm ışıkları kapat
function VehicleLights:TurnOffAll()
    self:SetHeadlights(false, false)
    self:SetTailLights(false, false)
    self:SetLeftTurnSignal(false)
    self:SetRightTurnSignal(false)
    self:SetHazardLights(false)
    self:SetReverseLight(false)
    self:SetFogLights(false)
    self:SetDaytimeRunning(false)
end

-- Işık durumlarını al
function VehicleLights:GetLightStates()
    return self.States
end

-- Işık konfigürasyonunu güncelle
function VehicleLights:UpdateConfig(newConfig)
    for category, values in pairs(newConfig) do
        if self.Config[category] then
            for key, value in pairs(values) do
                self.Config[category][key] = value
            end
        end
    end
end

-- Işık parçası oluştur (yardımcı fonksiyon)
function VehicleLights:CreateLightPart(name, position, parent, lightType)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(0.3, 0.2, 0.1)
    part.Position = position
    part.Anchored = false
    part.CanCollide = false
    part.Material = Enum.Material.SmoothPlastic
    part.Color = Color3.fromRGB(50, 50, 50)
    part.Parent = parent
    
    -- Weld oluştur
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part
    weld.Part1 = parent
    weld.Parent = part
    
    -- Işık ekle
    local light
    if lightType == "Spot" then
        light = Instance.new("SpotLight")
        light.Angle = 60
        light.Range = 30
    else
        light = Instance.new("PointLight")
        light.Range = 10
    end
    light.Enabled = false
    light.Parent = part
    
    return part
end

return VehicleLights
