--[[
    Roblox Şanzıman Sistemi
    Manuel ve Otomatik vites desteği
    Özelleştirilebilir şanzıman oranları
    
    Kullanım: CarEngine modülü ile birlikte çalışır
]]

local TransmissionSystem = {}
TransmissionSystem.__index = TransmissionSystem

-- Varsayılan şanzıman profilleri
local TRANSMISSION_PROFILES = {
    -- Spor Şanzıman (Kısa oranlar, hızlı ivme)
    Sport = {
        Name = "Sport",
        GearRatios = {
            [-1] = 3.5,
            [0] = 0,
            [1] = 3.8,
            [2] = 2.5,
            [3] = 1.8,
            [4] = 1.4,
            [5] = 1.1,
            [6] = 0.9,
        },
        FinalDriveRatio = 4.1,
        ShiftTime = 0.15,
        AutoShiftUp = 7000,
        AutoShiftDown = 2500,
    },
    
    -- Ekonomi Şanzıman (Uzun oranlar, yakıt tasarrufu)
    Economy = {
        Name = "Economy",
        GearRatios = {
            [-1] = 3.0,
            [0] = 0,
            [1] = 3.2,
            [2] = 2.1,
            [3] = 1.5,
            [4] = 1.1,
            [5] = 0.85,
            [6] = 0.7,
        },
        FinalDriveRatio = 3.3,
        ShiftTime = 0.25,
        AutoShiftUp = 5500,
        AutoShiftDown = 1800,
    },
    
    -- Standart Şanzıman (Dengeli)
    Standard = {
        Name = "Standard",
        GearRatios = {
            [-1] = 3.2,
            [0] = 0,
            [1] = 3.5,
            [2] = 2.3,
            [3] = 1.7,
            [4] = 1.3,
            [5] = 1.0,
            [6] = 0.8,
        },
        FinalDriveRatio = 3.7,
        ShiftTime = 0.2,
        AutoShiftUp = 6500,
        AutoShiftDown = 2000,
    },
    
    -- Yarış Şanzıman (Çok kısa oranlar, maksimum performans)
    Racing = {
        Name = "Racing",
        GearRatios = {
            [-1] = 3.8,
            [0] = 0,
            [1] = 4.0,
            [2] = 2.8,
            [3] = 2.1,
            [4] = 1.6,
            [5] = 1.25,
            [6] = 1.0,
        },
        FinalDriveRatio = 4.5,
        ShiftTime = 0.1,
        AutoShiftUp = 7500,
        AutoShiftDown = 3000,
    },
    
    -- Off-Road Şanzıman (Düşük hız, yüksek tork)
    OffRoad = {
        Name = "Off-Road",
        GearRatios = {
            [-1] = 4.0,
            [0] = 0,
            [1] = 4.5,
            [2] = 3.0,
            [3] = 2.2,
            [4] = 1.6,
            [5] = 1.2,
            [6] = 0.95,
        },
        FinalDriveRatio = 4.8,
        ShiftTime = 0.3,
        AutoShiftUp = 5000,
        AutoShiftDown = 1500,
    },
}

-- Yeni şanzıman sistemi oluştur
function TransmissionSystem.new(profileName)
    local self = setmetatable({}, TransmissionSystem)
    
    self.CurrentProfile = TRANSMISSION_PROFILES[profileName] or TRANSMISSION_PROFILES.Standard
    self.TransmissionType = "Manual" -- "Manual" veya "Automatic"
    self.CurrentGear = 0
    self.IsShifting = false
    self.ShiftTimer = 0
    self.TargetGear = 0
    self.ClutchPosition = 1 -- 0 = basılı, 1 = bırakılmış
    self.IsNeutral = true
    
    -- Çift kavrama simülasyonu için
    self.PreSelectedGear = nil
    self.DCTMode = false -- Çift Kavramalı Şanzıman modu
    
    return self
end

-- Profil değiştir
function TransmissionSystem:SetProfile(profileName)
    if TRANSMISSION_PROFILES[profileName] then
        self.CurrentProfile = TRANSMISSION_PROFILES[profileName]
        return true
    end
    return false
end

-- Özel profil oluştur
function TransmissionSystem:CreateCustomProfile(name, config)
    TRANSMISSION_PROFILES[name] = config
    return true
end

-- Mevcut profilleri listele
function TransmissionSystem:GetAvailableProfiles()
    local profiles = {}
    for name, _ in pairs(TRANSMISSION_PROFILES) do
        table.insert(profiles, name)
    end
    return profiles
end

-- Şanzıman tipini değiştir
function TransmissionSystem:SetTransmissionType(transmissionType)
    if transmissionType == "Manual" or transmissionType == "Automatic" then
        self.TransmissionType = transmissionType
        return true
    end
    return false
end

-- DCT modunu aç/kapat
function TransmissionSystem:SetDCTMode(enabled)
    self.DCTMode = enabled
    if enabled then
        self.CurrentProfile.ShiftTime = self.CurrentProfile.ShiftTime * 0.5
    end
end

-- Vites yükselt
function TransmissionSystem:ShiftUp()
    if self.IsShifting then return false end
    
    local maxGear = self:GetMaxGear()
    if self.CurrentGear < maxGear then
        self:InitiateShift(self.CurrentGear + 1)
        return true
    end
    return false
end

-- Vites düşür
function TransmissionSystem:ShiftDown()
    if self.IsShifting then return false end
    
    if self.CurrentGear > -1 then
        self:InitiateShift(self.CurrentGear - 1)
        return true
    end
    return false
end

-- Belirli bir vitese geç
function TransmissionSystem:ShiftToGear(gear)
    if self.IsShifting then return false end
    
    local maxGear = self:GetMaxGear()
    if gear >= -1 and gear <= maxGear then
        self:InitiateShift(gear)
        return true
    end
    return false
end

-- Vites değiştirme işlemi başlat
function TransmissionSystem:InitiateShift(targetGear)
    self.IsShifting = true
    self.ShiftTimer = self.CurrentProfile.ShiftTime
    self.TargetGear = targetGear
    
    -- DCT modunda önceden seçilmiş vites varsa daha hızlı geçiş
    if self.DCTMode and self.PreSelectedGear == targetGear then
        self.ShiftTimer = self.ShiftTimer * 0.3
    end
end

-- Maksimum vites sayısını al
function TransmissionSystem:GetMaxGear()
    local maxGear = 0
    for gear, _ in pairs(self.CurrentProfile.GearRatios) do
        if gear > maxGear then
            maxGear = gear
        end
    end
    return maxGear
end

-- Mevcut vites oranını al
function TransmissionSystem:GetCurrentGearRatio()
    return self.CurrentProfile.GearRatios[self.CurrentGear] or 0
end

-- Toplam şanzıman oranını al (vites oranı × diferansiyel)
function TransmissionSystem:GetTotalRatio()
    local gearRatio = self:GetCurrentGearRatio()
    return gearRatio * self.CurrentProfile.FinalDriveRatio
end

-- Kavrama kontrolü
function TransmissionSystem:SetClutch(position)
    self.ClutchPosition = math.clamp(position, 0, 1)
end

-- Kavrama durumunu al
function TransmissionSystem:GetClutchEngagement()
    return self.ClutchPosition
end

-- Otomatik vites kontrolü
function TransmissionSystem:AutomaticShiftCheck(currentRPM)
    if self.TransmissionType ~= "Automatic" then return end
    if self.IsShifting then return end
    
    local profile = self.CurrentProfile
    
    -- Vites yükseltme
    if currentRPM >= profile.AutoShiftUp and self.CurrentGear > 0 then
        self:ShiftUp()
    -- Vites düşürme
    elseif currentRPM <= profile.AutoShiftDown and self.CurrentGear > 1 then
        self:ShiftDown()
    end
    
    -- DCT için sonraki vitesi önceden seç
    if self.DCTMode then
        if currentRPM > (profile.AutoShiftUp * 0.8) then
            self.PreSelectedGear = self.CurrentGear + 1
        elseif currentRPM < (profile.AutoShiftDown * 1.2) then
            self.PreSelectedGear = self.CurrentGear - 1
        end
    end
end

-- Güncelleme döngüsü
function TransmissionSystem:Update(deltaTime, currentRPM)
    -- Vites değiştirme işlemi
    if self.IsShifting then
        self.ShiftTimer = self.ShiftTimer - deltaTime
        if self.ShiftTimer <= 0 then
            self.CurrentGear = self.TargetGear
            self.IsShifting = false
            self.IsNeutral = (self.CurrentGear == 0)
        end
    end
    
    -- Otomatik vites kontrolü
    self:AutomaticShiftCheck(currentRPM)
end

-- Şanzıman verilerini al
function TransmissionSystem:GetTransmissionData()
    return {
        CurrentGear = self.CurrentGear,
        GearRatio = self:GetCurrentGearRatio(),
        TotalRatio = self:GetTotalRatio(),
        IsShifting = self.IsShifting,
        ShiftProgress = self.IsShifting and (1 - (self.ShiftTimer / self.CurrentProfile.ShiftTime)) or 0,
        TransmissionType = self.TransmissionType,
        ProfileName = self.CurrentProfile.Name,
        ClutchPosition = self.ClutchPosition,
        IsNeutral = self.IsNeutral,
        MaxGear = self:GetMaxGear(),
        DCTMode = self.DCTMode,
        PreSelectedGear = self.PreSelectedGear,
    }
end

-- Vites gösterge metni
function TransmissionSystem:GetGearDisplayText()
    if self.IsShifting then
        return "-"
    elseif self.CurrentGear == -1 then
        return "R"
    elseif self.CurrentGear == 0 then
        return "N"
    else
        return tostring(self.CurrentGear)
    end
end

-- Tüm vites oranlarını al
function TransmissionSystem:GetAllGearRatios()
    return self.CurrentProfile.GearRatios
end

-- Tek bir vites oranını güncelle
function TransmissionSystem:SetGearRatio(gear, ratio)
    if self.CurrentProfile.GearRatios[gear] ~= nil then
        self.CurrentProfile.GearRatios[gear] = ratio
        return true
    end
    return false
end

-- Diferansiyel oranını güncelle
function TransmissionSystem:SetFinalDriveRatio(ratio)
    self.CurrentProfile.FinalDriveRatio = ratio
end

-- Math.clamp fonksiyonu
if not math.clamp then
    function math.clamp(value, min, max)
        return math.max(min, math.min(max, value))
    end
end

return TransmissionSystem
