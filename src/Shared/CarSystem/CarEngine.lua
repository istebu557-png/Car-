--[[
    Roblox Araba Motor Sistemi
    Gelişmiş fizik, HP, tork ve şanzıman sistemi
    
    Kullanım: Bu scripti araç modeline (VehicleSeat içeren) yerleştirin
]]

local CarEngine = {}
CarEngine.__index = CarEngine

-- Motor Konfigürasyonu
local DEFAULT_CONFIG = {
    -- Motor Özellikleri
    Engine = {
        MaxHP = 350,                    -- Maksimum beygir gücü
        MaxTorque = 450,                -- Maksimum tork (Nm)
        RedlineRPM = 7500,              -- Kırmızı çizgi RPM
        IdleRPM = 800,                  -- Rölanti RPM
        MaxRPM = 8000,                  -- Maksimum RPM
        EngineInertia = 0.15,           -- Motor ataleti
        ThrottleResponse = 0.08,        -- Gaz tepki hızı
    },
    
    -- Şanzıman Oranları
    Transmission = {
        GearRatios = {
            [-1] = 3.2,                 -- Geri vites
            [0] = 0,                    -- Boş
            [1] = 3.5,                  -- 1. vites
            [2] = 2.3,                  -- 2. vites
            [3] = 1.7,                  -- 3. vites
            [4] = 1.3,                  -- 4. vites
            [5] = 1.0,                  -- 5. vites
            [6] = 0.8,                  -- 6. vites
        },
        FinalDriveRatio = 3.7,          -- Diferansiyel oranı
        ShiftTime = 0.2,                -- Vites değiştirme süresi (saniye)
        AutoShiftUp = 6500,             -- Otomatik vites yükseltme RPM
        AutoShiftDown = 2000,           -- Otomatik vites düşürme RPM
        TransmissionType = "Manual",    -- "Manual" veya "Automatic"
    },
    
    -- Araç Fiziği
    Physics = {
        Mass = 1500,                    -- Araç kütlesi (kg)
        DragCoefficient = 0.32,         -- Hava direnci katsayısı
        RollingResistance = 0.015,      -- Yuvarlanma direnci
        BrakeForce = 3500,              -- Fren kuvveti
        MaxSpeed = 280,                 -- Maksimum hız (km/s)
        WheelRadius = 0.35,             -- Tekerlek yarıçapı (metre)
        Downforce = 0.5,                -- Yere basma kuvveti çarpanı
    },
    
    -- Yakıt Sistemi
    Fuel = {
        MaxFuel = 65,                   -- Maksimum yakıt (litre)
        CurrentFuel = 65,               -- Mevcut yakıt
        ConsumptionRate = 0.008,        -- Yakıt tüketim oranı (litre/saniye tam gazda)
        IdleConsumption = 0.001,        -- Rölanti yakıt tüketimi
    }
}

-- Yeni araba motoru oluştur
function CarEngine.new(vehicle, customConfig)
    local self = setmetatable({}, CarEngine)
    
    self.Vehicle = vehicle
    self.Config = customConfig or DEFAULT_CONFIG
    
    -- Motor Durumu
    self.CurrentRPM = self.Config.Engine.IdleRPM
    self.CurrentGear = 0
    self.CurrentSpeed = 0
    self.ThrottleInput = 0
    self.BrakeInput = 0
    self.ClutchEngaged = true
    self.EngineRunning = false
    
    -- Yakıt Durumu
    self.CurrentFuel = self.Config.Fuel.CurrentFuel
    
    -- Vites değiştirme durumu
    self.IsShifting = false
    self.ShiftTimer = 0
    
    return self
end

-- Motoru çalıştır
function CarEngine:StartEngine()
    if self.CurrentFuel > 0 then
        self.EngineRunning = true
        self.CurrentRPM = self.Config.Engine.IdleRPM
        return true
    end
    return false
end

-- Motoru durdur
function CarEngine:StopEngine()
    self.EngineRunning = false
    self.CurrentRPM = 0
    self.CurrentGear = 0
end

-- Tork hesaplama (RPM'e göre tork eğrisi)
function CarEngine:CalculateTorque(rpm)
    local config = self.Config.Engine
    local normalizedRPM = (rpm - config.IdleRPM) / (config.RedlineRPM - config.IdleRPM)
    
    -- Gerçekçi tork eğrisi (düşük RPM'de düşük, orta RPM'de yüksek, yüksek RPM'de düşüş)
    local torqueMultiplier
    if normalizedRPM < 0.3 then
        torqueMultiplier = 0.6 + (normalizedRPM / 0.3) * 0.4
    elseif normalizedRPM < 0.7 then
        torqueMultiplier = 1.0
    else
        torqueMultiplier = 1.0 - ((normalizedRPM - 0.7) / 0.3) * 0.3
    end
    
    return config.MaxTorque * torqueMultiplier * self.ThrottleInput
end

-- Beygir gücü hesaplama
function CarEngine:CalculateHP(rpm, torque)
    -- HP = (Tork × RPM) / 5252
    return (torque * rpm) / 5252
end

-- Vites yükselt
function CarEngine:ShiftUp()
    if self.IsShifting then return false end
    
    local maxGear = 6
    if self.CurrentGear < maxGear then
        self:InitiateShift(self.CurrentGear + 1)
        return true
    end
    return false
end

-- Vites düşür
function CarEngine:ShiftDown()
    if self.IsShifting then return false end
    
    if self.CurrentGear > -1 then
        self:InitiateShift(self.CurrentGear - 1)
        return true
    end
    return false
end

-- Vites değiştirme işlemi başlat
function CarEngine:InitiateShift(targetGear)
    self.IsShifting = true
    self.ShiftTimer = self.Config.Transmission.ShiftTime
    self.TargetGear = targetGear
end

-- Otomatik vites kontrolü
function CarEngine:AutomaticShiftCheck()
    if self.Config.Transmission.TransmissionType ~= "Automatic" then return end
    if self.IsShifting then return end
    
    local config = self.Config.Transmission
    
    -- Vites yükseltme
    if self.CurrentRPM >= config.AutoShiftUp and self.CurrentGear > 0 and self.CurrentGear < 6 then
        self:ShiftUp()
    -- Vites düşürme
    elseif self.CurrentRPM <= config.AutoShiftDown and self.CurrentGear > 1 then
        self:ShiftDown()
    end
end

-- Hız hesaplama (km/s)
function CarEngine:CalculateSpeed()
    if self.CurrentGear == 0 then return 0 end
    
    local config = self.Config
    local gearRatio = config.Transmission.GearRatios[self.CurrentGear]
    local finalDrive = config.Transmission.FinalDriveRatio
    local wheelRadius = config.Physics.WheelRadius
    
    -- Tekerlek RPM'i hesapla
    local wheelRPM = self.CurrentRPM / (gearRatio * finalDrive)
    
    -- Hız hesapla (m/s -> km/s)
    local speedMS = (wheelRPM * 2 * math.pi * wheelRadius) / 60
    local speedKMH = speedMS * 3.6
    
    return math.min(speedKMH, config.Physics.MaxSpeed)
end

-- Yakıt tüketimi
function CarEngine:ConsumeFuel(deltaTime)
    if not self.EngineRunning then return end
    
    local config = self.Config.Fuel
    local consumption
    
    if self.ThrottleInput > 0 then
        consumption = config.ConsumptionRate * self.ThrottleInput * (self.CurrentRPM / 4000)
    else
        consumption = config.IdleConsumption
    end
    
    self.CurrentFuel = math.max(0, self.CurrentFuel - consumption * deltaTime)
    
    -- Yakıt biterse motoru durdur
    if self.CurrentFuel <= 0 then
        self:StopEngine()
    end
end

-- Ana güncelleme döngüsü
function CarEngine:Update(deltaTime, throttle, brake, handbrake)
    if not self.EngineRunning then return end
    
    self.ThrottleInput = math.clamp(throttle or 0, 0, 1)
    self.BrakeInput = math.clamp(brake or 0, 0, 1)
    
    -- Vites değiştirme işlemi
    if self.IsShifting then
        self.ShiftTimer = self.ShiftTimer - deltaTime
        if self.ShiftTimer <= 0 then
            self.CurrentGear = self.TargetGear
            self.IsShifting = false
        end
    end
    
    -- RPM hesaplama
    local config = self.Config.Engine
    local targetRPM
    
    if self.CurrentGear == 0 or self.IsShifting then
        -- Boş viteste veya vites değiştirirken
        targetRPM = config.IdleRPM + (self.ThrottleInput * (config.RedlineRPM - config.IdleRPM) * 0.8)
    else
        -- Viteste
        local torque = self:CalculateTorque(self.CurrentRPM)
        local resistance = self.Config.Physics.DragCoefficient * (self.CurrentSpeed ^ 2) * 0.01
        local netTorque = torque - resistance - (self.BrakeInput * self.Config.Physics.BrakeForce * 0.1)
        
        targetRPM = self.CurrentRPM + (netTorque * deltaTime * 10)
    end
    
    -- RPM yumuşak geçiş
    self.CurrentRPM = self.CurrentRPM + (targetRPM - self.CurrentRPM) * config.ThrottleResponse
    self.CurrentRPM = math.clamp(self.CurrentRPM, config.IdleRPM, config.MaxRPM)
    
    -- Hız güncelleme
    self.CurrentSpeed = self:CalculateSpeed()
    
    -- Otomatik vites kontrolü
    self:AutomaticShiftCheck()
    
    -- Yakıt tüketimi
    self:ConsumeFuel(deltaTime)
end

-- Mevcut motor verilerini al
function CarEngine:GetEngineData()
    return {
        RPM = math.floor(self.CurrentRPM),
        Speed = math.floor(self.CurrentSpeed),
        Gear = self.CurrentGear,
        Fuel = self.CurrentFuel,
        MaxFuel = self.Config.Fuel.MaxFuel,
        FuelPercentage = (self.CurrentFuel / self.Config.Fuel.MaxFuel) * 100,
        HP = math.floor(self:CalculateHP(self.CurrentRPM, self:CalculateTorque(self.CurrentRPM))),
        Torque = math.floor(self:CalculateTorque(self.CurrentRPM)),
        IsRunning = self.EngineRunning,
        IsShifting = self.IsShifting,
        MaxRPM = self.Config.Engine.MaxRPM,
        RedlineRPM = self.Config.Engine.RedlineRPM,
    }
end

-- Konfigürasyonu güncelle
function CarEngine:UpdateConfig(newConfig)
    for category, values in pairs(newConfig) do
        if self.Config[category] then
            for key, value in pairs(values) do
                self.Config[category][key] = value
            end
        end
    end
end

-- Yakıt doldur
function CarEngine:Refuel(amount)
    self.CurrentFuel = math.min(self.Config.Fuel.MaxFuel, self.CurrentFuel + amount)
end

-- Math.clamp fonksiyonu (Roblox'ta mevcut değilse)
if not math.clamp then
    function math.clamp(value, min, max)
        return math.max(min, math.min(max, value))
    end
end

return CarEngine
