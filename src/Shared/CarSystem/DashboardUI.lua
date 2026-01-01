--[[
    Roblox Araç Gösterge Paneli UI
    Modern tasarım - Hız, RPM, Yakıt göstergesi
    
    Kullanım: LocalScript olarak StarterGui'ye yerleştirin
]]

local DashboardUI = {}
DashboardUI.__index = DashboardUI

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- UI Renk Paleti (Modern Tasarım)
local COLORS = {
    Background = Color3.fromRGB(15, 15, 20),
    BackgroundSecondary = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(0, 200, 255),
    AccentSecondary = Color3.fromRGB(0, 150, 200),
    Warning = Color3.fromRGB(255, 180, 0),
    Danger = Color3.fromRGB(255, 50, 50),
    Success = Color3.fromRGB(50, 255, 100),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    GaugeBackground = Color3.fromRGB(40, 40, 50),
    GaugeFill = Color3.fromRGB(0, 200, 255),
    RedZone = Color3.fromRGB(255, 50, 50),
}

-- Yeni dashboard oluştur
function DashboardUI.new(player)
    local self = setmetatable({}, DashboardUI)
    
    self.Player = player or Players.LocalPlayer
    self.ScreenGui = nil
    self.MainFrame = nil
    self.IsVisible = false
    
    -- UI Elementleri
    self.Elements = {
        SpeedGauge = nil,
        RPMGauge = nil,
        FuelGauge = nil,
        GearIndicator = nil,
        SpeedText = nil,
        RPMText = nil,
        FuelText = nil,
    }
    
    -- Animasyon değerleri
    self.CurrentValues = {
        Speed = 0,
        RPM = 0,
        Fuel = 100,
        Gear = "N",
    }
    
    return self
end

-- Ana UI'ı oluştur
function DashboardUI:Create()
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CarDashboard"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = self.Player:WaitForChild("PlayerGui")
    
    -- Ana Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "DashboardFrame"
    self.MainFrame.Size = UDim2.new(0, 600, 0, 200)
    self.MainFrame.Position = UDim2.new(0.5, -300, 1, -220)
    self.MainFrame.BackgroundColor3 = COLORS.Background
    self.MainFrame.BackgroundTransparency = 0.2
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    
    -- Köşe yuvarlatma
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = self.MainFrame
    
    -- Gölge efekti
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = -1
    shadow.Parent = self.MainFrame
    
    -- Üst çizgi (accent)
    local topLine = Instance.new("Frame")
    topLine.Name = "AccentLine"
    topLine.Size = UDim2.new(1, 0, 0, 3)
    topLine.Position = UDim2.new(0, 0, 0, 0)
    topLine.BackgroundColor3 = COLORS.Accent
    topLine.BorderSizePixel = 0
    topLine.Parent = self.MainFrame
    
    local topLineCorner = Instance.new("UICorner")
    topLineCorner.CornerRadius = UDim.new(0, 15)
    topLineCorner.Parent = topLine
    
    -- Göstergeleri oluştur
    self:CreateSpeedGauge()
    self:CreateRPMGauge()
    self:CreateFuelGauge()
    self:CreateGearIndicator()
    self:CreateInfoPanel()
    
    self.IsVisible = false
    self.MainFrame.Visible = false
    
    return self.ScreenGui
end

-- Hız göstergesi oluştur
function DashboardUI:CreateSpeedGauge()
    local container = Instance.new("Frame")
    container.Name = "SpeedGaugeContainer"
    container.Size = UDim2.new(0, 150, 0, 150)
    container.Position = UDim2.new(0, 30, 0.5, -75)
    container.BackgroundColor3 = COLORS.BackgroundSecondary
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = self.MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = container
    
    -- Dış halka
    local outerRing = Instance.new("UIStroke")
    outerRing.Color = COLORS.Accent
    outerRing.Thickness = 4
    outerRing.Transparency = 0.3
    outerRing.Parent = container
    
    -- Hız değeri
    local speedValue = Instance.new("TextLabel")
    speedValue.Name = "SpeedValue"
    speedValue.Size = UDim2.new(1, 0, 0, 50)
    speedValue.Position = UDim2.new(0, 0, 0.5, -35)
    speedValue.BackgroundTransparency = 1
    speedValue.Text = "0"
    speedValue.TextColor3 = COLORS.Text
    speedValue.TextSize = 48
    speedValue.Font = Enum.Font.GothamBold
    speedValue.Parent = container
    
    -- Birim
    local speedUnit = Instance.new("TextLabel")
    speedUnit.Name = "SpeedUnit"
    speedUnit.Size = UDim2.new(1, 0, 0, 20)
    speedUnit.Position = UDim2.new(0, 0, 0.5, 15)
    speedUnit.BackgroundTransparency = 1
    speedUnit.Text = "KM/S"
    speedUnit.TextColor3 = COLORS.TextSecondary
    speedUnit.TextSize = 14
    speedUnit.Font = Enum.Font.Gotham
    speedUnit.Parent = container
    
    -- Etiket
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = "HIZ"
    label.TextColor3 = COLORS.Accent
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.Parent = container
    
    -- İlerleme çemberi (Canvas için ImageLabel)
    local progressRing = Instance.new("Frame")
    progressRing.Name = "ProgressRing"
    progressRing.Size = UDim2.new(1, -20, 1, -20)
    progressRing.Position = UDim2.new(0, 10, 0, 10)
    progressRing.BackgroundTransparency = 1
    progressRing.Parent = container
    
    self.Elements.SpeedGauge = container
    self.Elements.SpeedText = speedValue
end

-- RPM göstergesi oluştur
function DashboardUI:CreateRPMGauge()
    local container = Instance.new("Frame")
    container.Name = "RPMGaugeContainer"
    container.Size = UDim2.new(0, 200, 0, 80)
    container.Position = UDim2.new(0.5, -100, 0, 25)
    container.BackgroundColor3 = COLORS.BackgroundSecondary
    container.BackgroundTransparency = 0.5
    container.BorderSizePixel = 0
    container.Parent = self.MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container
    
    -- RPM etiketi
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = "RPM"
    label.TextColor3 = COLORS.Accent
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.Parent = container
    
    -- RPM bar arka planı
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBackground"
    barBg.Size = UDim2.new(1, -20, 0, 20)
    barBg.Position = UDim2.new(0, 10, 0, 30)
    barBg.BackgroundColor3 = COLORS.GaugeBackground
    barBg.BorderSizePixel = 0
    barBg.Parent = container
    
    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(0, 5)
    barBgCorner.Parent = barBg
    
    -- RPM bar dolgu
    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.Position = UDim2.new(0, 0, 0, 0)
    barFill.BackgroundColor3 = COLORS.GaugeFill
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    
    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(0, 5)
    barFillCorner.Parent = barFill
    
    -- Kırmızı bölge işareti
    local redZone = Instance.new("Frame")
    redZone.Name = "RedZone"
    redZone.Size = UDim2.new(0.15, 0, 1, 0)
    redZone.Position = UDim2.new(0.85, 0, 0, 0)
    redZone.BackgroundColor3 = COLORS.RedZone
    redZone.BackgroundTransparency = 0.5
    redZone.BorderSizePixel = 0
    redZone.Parent = barBg
    
    local redZoneCorner = Instance.new("UICorner")
    redZoneCorner.CornerRadius = UDim.new(0, 5)
    redZoneCorner.Parent = redZone
    
    -- RPM değeri
    local rpmValue = Instance.new("TextLabel")
    rpmValue.Name = "RPMValue"
    rpmValue.Size = UDim2.new(1, 0, 0, 20)
    rpmValue.Position = UDim2.new(0, 0, 0, 55)
    rpmValue.BackgroundTransparency = 1
    rpmValue.Text = "0"
    rpmValue.TextColor3 = COLORS.Text
    rpmValue.TextSize = 18
    rpmValue.Font = Enum.Font.GothamBold
    rpmValue.Parent = container
    
    self.Elements.RPMGauge = container
    self.Elements.RPMBar = barFill
    self.Elements.RPMText = rpmValue
end

-- Yakıt göstergesi oluştur
function DashboardUI:CreateFuelGauge()
    local container = Instance.new("Frame")
    container.Name = "FuelGaugeContainer"
    container.Size = UDim2.new(0, 100, 0, 150)
    container.Position = UDim2.new(1, -130, 0.5, -75)
    container.BackgroundColor3 = COLORS.BackgroundSecondary
    container.BackgroundTransparency = 0.5
    container.BorderSizePixel = 0
    container.Parent = self.MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container
    
    -- Yakıt etiketi
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "YAKIT"
    label.TextColor3 = COLORS.Accent
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.Parent = container
    
    -- Yakıt ikonu
    local fuelIcon = Instance.new("TextLabel")
    fuelIcon.Name = "FuelIcon"
    fuelIcon.Size = UDim2.new(1, 0, 0, 30)
    fuelIcon.Position = UDim2.new(0, 0, 0, 30)
    fuelIcon.BackgroundTransparency = 1
    fuelIcon.Text = "⛽"
    fuelIcon.TextSize = 24
    fuelIcon.Parent = container
    
    -- Dikey bar arka planı
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBackground"
    barBg.Size = UDim2.new(0, 30, 0, 70)
    barBg.Position = UDim2.new(0.5, -15, 0, 60)
    barBg.BackgroundColor3 = COLORS.GaugeBackground
    barBg.BorderSizePixel = 0
    barBg.Parent = container
    
    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(0, 5)
    barBgCorner.Parent = barBg
    
    -- Dikey bar dolgu
    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.Position = UDim2.new(0, 0, 0, 0)
    barFill.AnchorPoint = Vector2.new(0, 1)
    barFill.BackgroundColor3 = COLORS.Success
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    
    -- Dolguyu alttan başlat
    barFill.Position = UDim2.new(0, 0, 1, 0)
    
    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(0, 5)
    barFillCorner.Parent = barFill
    
    -- Yakıt yüzdesi
    local fuelPercent = Instance.new("TextLabel")
    fuelPercent.Name = "FuelPercent"
    fuelPercent.Size = UDim2.new(1, 0, 0, 20)
    fuelPercent.Position = UDim2.new(0, 0, 1, -25)
    fuelPercent.BackgroundTransparency = 1
    fuelPercent.Text = "100%"
    fuelPercent.TextColor3 = COLORS.Text
    fuelPercent.TextSize = 14
    fuelPercent.Font = Enum.Font.GothamBold
    fuelPercent.Parent = container
    
    self.Elements.FuelGauge = container
    self.Elements.FuelBar = barFill
    self.Elements.FuelText = fuelPercent
end

-- Vites göstergesi oluştur
function DashboardUI:CreateGearIndicator()
    local container = Instance.new("Frame")
    container.Name = "GearIndicator"
    container.Size = UDim2.new(0, 80, 0, 80)
    container.Position = UDim2.new(0.5, -40, 0.5, -10)
    container.BackgroundColor3 = COLORS.BackgroundSecondary
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = self.MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = container
    
    -- Vites çerçevesi
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Accent
    stroke.Thickness = 2
    stroke.Parent = container
    
    -- Vites değeri
    local gearValue = Instance.new("TextLabel")
    gearValue.Name = "GearValue"
    gearValue.Size = UDim2.new(1, 0, 0, 50)
    gearValue.Position = UDim2.new(0, 0, 0.5, -25)
    gearValue.BackgroundTransparency = 1
    gearValue.Text = "N"
    gearValue.TextColor3 = COLORS.Accent
    gearValue.TextSize = 42
    gearValue.Font = Enum.Font.GothamBold
    gearValue.Parent = container
    
    -- Etiket
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Position = UDim2.new(0, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = "VİTES"
    label.TextColor3 = COLORS.TextSecondary
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.Parent = container
    
    self.Elements.GearIndicator = container
    self.Elements.GearText = gearValue
end

-- Bilgi paneli oluştur
function DashboardUI:CreateInfoPanel()
    local container = Instance.new("Frame")
    container.Name = "InfoPanel"
    container.Size = UDim2.new(0, 120, 0, 60)
    container.Position = UDim2.new(0.5, -60, 1, -75)
    container.BackgroundTransparency = 1
    container.Parent = self.MainFrame
    
    -- HP göstergesi
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Name = "HPLabel"
    hpLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
    hpLabel.Position = UDim2.new(0, 0, 0, 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Text = "HP"
    hpLabel.TextColor3 = COLORS.TextSecondary
    hpLabel.TextSize = 10
    hpLabel.Font = Enum.Font.Gotham
    hpLabel.Parent = container
    
    local hpValue = Instance.new("TextLabel")
    hpValue.Name = "HPValue"
    hpValue.Size = UDim2.new(0.5, 0, 0.5, 0)
    hpValue.Position = UDim2.new(0.5, 0, 0, 0)
    hpValue.BackgroundTransparency = 1
    hpValue.Text = "0"
    hpValue.TextColor3 = COLORS.Text
    hpValue.TextSize = 12
    hpValue.Font = Enum.Font.GothamBold
    hpValue.TextXAlignment = Enum.TextXAlignment.Left
    hpValue.Parent = container
    
    -- Tork göstergesi
    local torqueLabel = Instance.new("TextLabel")
    torqueLabel.Name = "TorqueLabel"
    torqueLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
    torqueLabel.Position = UDim2.new(0, 0, 0.5, 0)
    torqueLabel.BackgroundTransparency = 1
    torqueLabel.Text = "TORK"
    torqueLabel.TextColor3 = COLORS.TextSecondary
    torqueLabel.TextSize = 10
    torqueLabel.Font = Enum.Font.Gotham
    torqueLabel.Parent = container
    
    local torqueValue = Instance.new("TextLabel")
    torqueValue.Name = "TorqueValue"
    torqueValue.Size = UDim2.new(0.5, 0, 0.5, 0)
    torqueValue.Position = UDim2.new(0.5, 0, 0.5, 0)
    torqueValue.BackgroundTransparency = 1
    torqueValue.Text = "0 Nm"
    torqueValue.TextColor3 = COLORS.Text
    torqueValue.TextSize = 12
    torqueValue.Font = Enum.Font.GothamBold
    torqueValue.TextXAlignment = Enum.TextXAlignment.Left
    torqueValue.Parent = container
    
    self.Elements.InfoPanel = container
    self.Elements.HPText = hpValue
    self.Elements.TorqueText = torqueValue
end

-- Göstergeleri güncelle
function DashboardUI:Update(data)
    if not self.IsVisible then return end
    
    -- Hız güncelle
    if data.Speed then
        self.Elements.SpeedText.Text = tostring(math.floor(data.Speed))
    end
    
    -- RPM güncelle
    if data.RPM and data.MaxRPM then
        self.Elements.RPMText.Text = tostring(math.floor(data.RPM))
        
        local rpmPercent = data.RPM / data.MaxRPM
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(self.Elements.RPMBar, tweenInfo, {
            Size = UDim2.new(math.min(rpmPercent, 1), 0, 1, 0)
        })
        tween:Play()
        
        -- Kırmızı bölgede renk değiştir
        if data.RedlineRPM and data.RPM >= data.RedlineRPM * 0.9 then
            self.Elements.RPMBar.BackgroundColor3 = COLORS.RedZone
        else
            self.Elements.RPMBar.BackgroundColor3 = COLORS.GaugeFill
        end
    end
    
    -- Yakıt güncelle
    if data.FuelPercentage then
        local fuelPercent = data.FuelPercentage / 100
        self.Elements.FuelText.Text = math.floor(data.FuelPercentage) .. "%"
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(self.Elements.FuelBar, tweenInfo, {
            Size = UDim2.new(1, 0, math.max(fuelPercent, 0.01), 0)
        })
        tween:Play()
        
        -- Düşük yakıt uyarısı
        if data.FuelPercentage <= 20 then
            self.Elements.FuelBar.BackgroundColor3 = COLORS.Danger
        elseif data.FuelPercentage <= 40 then
            self.Elements.FuelBar.BackgroundColor3 = COLORS.Warning
        else
            self.Elements.FuelBar.BackgroundColor3 = COLORS.Success
        end
    end
    
    -- Vites güncelle
    if data.Gear ~= nil then
        local gearText
        if data.Gear == -1 then
            gearText = "R"
            self.Elements.GearText.TextColor3 = COLORS.Warning
        elseif data.Gear == 0 then
            gearText = "N"
            self.Elements.GearText.TextColor3 = COLORS.TextSecondary
        else
            gearText = tostring(data.Gear)
            self.Elements.GearText.TextColor3 = COLORS.Accent
        end
        
        if data.IsShifting then
            gearText = "-"
            self.Elements.GearText.TextColor3 = COLORS.Warning
        end
        
        self.Elements.GearText.Text = gearText
    end
    
    -- HP ve Tork güncelle
    if data.HP then
        self.Elements.HPText.Text = tostring(math.floor(data.HP))
    end
    
    if data.Torque then
        self.Elements.TorqueText.Text = tostring(math.floor(data.Torque)) .. " Nm"
    end
end

-- Dashboard'u göster
function DashboardUI:Show()
    if not self.MainFrame then return end
    
    self.IsVisible = true
    self.MainFrame.Visible = true
    
    -- Giriş animasyonu
    self.MainFrame.Position = UDim2.new(0.5, -300, 1, 0)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self.MainFrame, tweenInfo, {
        Position = UDim2.new(0.5, -300, 1, -220)
    })
    tween:Play()
end

-- Dashboard'u gizle
function DashboardUI:Hide()
    if not self.MainFrame then return end
    
    -- Çıkış animasyonu
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    local tween = TweenService:Create(self.MainFrame, tweenInfo, {
        Position = UDim2.new(0.5, -300, 1, 50)
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        self.IsVisible = false
        self.MainFrame.Visible = false
    end)
end

-- Dashboard'u yok et
function DashboardUI:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- Görünürlük durumunu al
function DashboardUI:IsShowing()
    return self.IsVisible
end

return DashboardUI
