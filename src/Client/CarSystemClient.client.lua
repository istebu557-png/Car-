--[[
    ============================================
    ROBLOX ARAÇ SİSTEMİ - CLIENT
    ============================================
    
    Tek komutla kurulum: Rojo ile senkronize edin
    
    KONTROLLER:
    W/S - İleri/Geri
    A/D - Sola/Sağa
    E/Q - Vites Yükselt/Düşür
    Space - El Freni
    L - Farlar
    Y - Motor Aç/Kapat
    Tab - Ayarlar Menüsü
]]

-- Servisler
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Oyuncu referansı
local player = Players.LocalPlayer

-- Modülleri yükle
local CarSystem = ReplicatedStorage:WaitForChild("CarSystem")
local CarEngine = require(CarSystem:WaitForChild("CarEngine"))
local TransmissionSystem = require(CarSystem:WaitForChild("TransmissionSystem"))
local InputController = require(CarSystem:WaitForChild("InputController"))
local VehicleLights = require(CarSystem:WaitForChild("VehicleLights"))
local DashboardUI = require(CarSystem:WaitForChild("DashboardUI"))
local SettingsUI = require(CarSystem:WaitForChild("SettingsUI"))

-- Araç Kontrolcüsü
local VehicleController = {}
VehicleController.__index = VehicleController

function VehicleController.new()
    local self = setmetatable({}, VehicleController)
    
    self.Player = player
    self.Character = nil
    self.Humanoid = nil
    
    self.CurrentVehicle = nil
    self.VehicleSeat = nil
    self.IsInVehicle = false
    
    self.Engine = nil
    self.Transmission = nil
    self.Input = nil
    self.Lights = nil
    self.Dashboard = nil
    self.Settings = nil
    
    self.Connections = {}
    
    return self
end

function VehicleController:Initialize()
    self.Input = InputController.new()
    self.Input:Enable()
    
    self.Dashboard = DashboardUI.new(self.Player)
    self.Dashboard:Create()
    
    self.Settings = SettingsUI.new(self.Player, self.Input, nil, nil)
    self.Settings:Create()
    
    self.Player.CharacterAdded:Connect(function(character)
        self:OnCharacterAdded(character)
    end)
    
    if self.Player.Character then
        self:OnCharacterAdded(self.Player.Character)
    end
    
    self.Connections.Update = RunService.RenderStepped:Connect(function(deltaTime)
        self:Update(deltaTime)
    end)
    
    self.Connections.SettingsKey = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.Escape then
            if self.IsInVehicle then
                self.Settings:Toggle()
            end
        end
    end)
    
    print("========================================")
    print("✓ Araç Sistemi Başlatıldı!")
    print("========================================")
    print("KONTROLLER:")
    print("  W/S - İleri/Geri")
    print("  A/D - Sola/Sağa")
    print("  E/Q - Vites Yükselt/Düşür")
    print("  Space - El Freni")
    print("  L - Farlar")
    print("  Y - Motor Aç/Kapat")
    print("  Tab - Ayarlar Menüsü")
    print("========================================")
end

function VehicleController:OnCharacterAdded(character)
    self.Character = character
    self.Humanoid = character:WaitForChild("Humanoid")
    
    self.Humanoid.Seated:Connect(function(isSeated, seat)
        self:OnSeatedChanged(isSeated, seat)
    end)
end

function VehicleController:OnSeatedChanged(isSeated, seat)
    if isSeated and seat and seat:IsA("VehicleSeat") then
        self:EnterVehicle(seat)
    else
        self:ExitVehicle()
    end
end

function VehicleController:EnterVehicle(seat)
    self.VehicleSeat = seat
    self.CurrentVehicle = seat.Parent
    self.IsInVehicle = true
    
    self.Engine = CarEngine.new(self.CurrentVehicle)
    self.Engine:StartEngine()
    
    self.Transmission = TransmissionSystem.new("Standard")
    self.Lights = VehicleLights.new(self.CurrentVehicle)
    
    self.Settings.CarEngine = self.Engine
    self.Settings.TransmissionSystem = self.Transmission
    
    self.Input:SetInVehicle(true)
    self.Dashboard:Show()
    
    self:SetupInputCallbacks()
    
    print("🚗 Araca binildi: " .. self.CurrentVehicle.Name)
end

function VehicleController:ExitVehicle()
    if not self.IsInVehicle then return end
    
    if self.Engine then self.Engine:StopEngine() end
    if self.Lights then self.Lights:TurnOffAll() end
    
    self.Input:SetInVehicle(false)
    self.Dashboard:Hide()
    
    if self.Settings.IsVisible then
        self.Settings:Hide()
    end
    
    self.VehicleSeat = nil
    self.CurrentVehicle = nil
    self.Engine = nil
    self.Transmission = nil
    self.Lights = nil
    self.IsInVehicle = false
    
    print("🚶 Araçtan inildi")
end

function VehicleController:SetupInputCallbacks()
    self.Input:OnAction("ShiftUp", function(pressed)
        if pressed and self.Transmission then
            self.Transmission:ShiftUp()
            self.Engine.CurrentGear = self.Transmission.CurrentGear
        end
    end)
    
    self.Input:OnAction("ShiftDown", function(pressed)
        if pressed and self.Transmission then
            self.Transmission:ShiftDown()
            self.Engine.CurrentGear = self.Transmission.CurrentGear
        end
    end)
    
    self.Input:OnAction("Headlights", function(pressed)
        if pressed and self.Lights then
            self.Lights:ToggleHeadlights()
        end
    end)
    
    self.Input:OnAction("EngineToggle", function(pressed)
        if pressed and self.Engine then
            if self.Engine.EngineRunning then
                self.Engine:StopEngine()
            else
                self.Engine:StartEngine()
            end
        end
    end)
    
    self.Input:OnAction("Neutral", function(pressed)
        if pressed and self.Transmission then
            self.Transmission:ShiftToGear(0)
            self.Engine.CurrentGear = 0
        end
    end)
    
    self.Input:OnAction("Reverse", function(pressed)
        if pressed and self.Transmission then
            self.Transmission:ShiftToGear(-1)
            self.Engine.CurrentGear = -1
        end
    end)
end

function VehicleController:Update(deltaTime)
    if not self.IsInVehicle then return end
    if not self.Engine or not self.Engine.EngineRunning then return end
    
    local throttle = self.Input:GetAnalogInput("Throttle")
    local brake = self.Input:GetAnalogInput("Brake")
    local steering = self.Input:GetAnalogInput("Steering")
    local handbrake = self.Input:GetInputState("Handbrake")
    
    self.Engine:Update(deltaTime, throttle, brake, handbrake)
    
    if self.Transmission then
        self.Transmission:Update(deltaTime, self.Engine.CurrentRPM)
        if self.Transmission.TransmissionType == "Automatic" then
            self.Engine.CurrentGear = self.Transmission.CurrentGear
        end
    end
    
    if self.Lights then
        self.Lights:Update(deltaTime, {
            IsBraking = brake > 0.1,
            Gear = self.Engine.CurrentGear,
        })
    end
    
    if self.VehicleSeat then
        local throttleValue = throttle - brake
        if self.Engine.CurrentGear == -1 then
            throttleValue = -throttleValue
        elseif self.Engine.CurrentGear == 0 then
            throttleValue = 0
        end
        
        self.VehicleSeat.ThrottleFloat = throttleValue
        self.VehicleSeat.SteerFloat = steering
    end
    
    local engineData = self.Engine:GetEngineData()
    self.Dashboard:Update(engineData)
end

function VehicleController:Cleanup()
    for _, connection in pairs(self.Connections) do
        if connection then connection:Disconnect() end
    end
    
    if self.Dashboard then self.Dashboard:Destroy() end
    if self.Settings then self.Settings:Destroy() end
    if self.Input then self.Input:Disable() end
end

-- Başlat
local controller = VehicleController.new()
controller:Initialize()

game:BindToClose(function()
    controller:Cleanup()
end)
