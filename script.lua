--- [[ GAME SYSTEM AUTO JOB & AUTO BYPASS IGR V2 ]] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local SAFE_SPEED = 180 -- Batas kecepatan maksimal kendaraan agar aman dari anti-cheat

-- [[ PENGATURAN GUI/ANTARMUKA LAYAR ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScreenGui"

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:CoreGui
end

-- Main Frame (Kotak Utama Menu)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0) -- Posisi default kiri layar
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Menu bisa digeser/dipindahkan di layar
MainFrame.Parent = ScreenGui

-- Efek Sudut Bulat Menu
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Efek Stroke Garis Tepi
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 170, 0) -- Warna oranye/kuning khas
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Judul Menu Utama
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Text = "AUTO JOB UTAMA"
TitleLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 16
TitleLabel.Parent = MainFrame

-- Garis Pembatas
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.9, 0, 0, 2)
Line.Position = UDim2.new(0.05, 0, 0, 35)
Line.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- Teks Informasi Internas
local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(0.9, 0, 0, 70)
InfoText.Position = UDim2.new(0.05, 0, 0, 45)
InfoText.Text = "Owner: brukkxontop87\nVersi: 2.0.0 (Fixed)\nMap: igr"
InfoText.TextColor3 = Color3.fromRGB(220, 220, 220)
InfoText.BackgroundTransparency = 1
InfoText.Font = Enum.Font.SourceSans
InfoText.TextSize = 14
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Parent = MainFrame

-- Tombol Eksekusi
local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(0.9, 0, 0, 40)
StartButton.Position = UDim2.new(0.05, 0, 0, 125)
StartButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
StartButton.Text = "START AUTO JOB"
StartButton.TextColor3 = Color3.fromRGB(15, 15, 15)
StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 14
StartButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = StartButton

-- [[ LOGIKA PASIF AUTO JOB & BYPASS FISIKA ]] --
local function getVehicle()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local seat = character.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            return seat.Occupant and seat.Parent
        end
    end
    return nil
end

-- =================================================================
-- KODE YANG SUDAH DIPERBAIKI (Membaca folder Workspace langsung)
-- =================================================================
local function getActivePoint()
    -- Mengubah pencarian langsung ke Workspace karena folder LOKASI ada di sana berdasarkan Dex Explorer terbaru
    local lokasiFolder = workspace:FindFirstChild("LOKASI")
    if lokasiFolder then
        -- Mencari objek bernama "POINT" yang ada di dalam folder LOKASI
        local pointObject = lokasiFolder:FindFirstChild("POINT")
        if pointObject then
            -- Memeriksa jika POINT berupa Value Object yang menyimpan data koordinat/objek target
            if pointObject:IsA("ObjectValue") and pointObject.Value then
                return pointObject.Value
            elseif pointObject:IsA("CFrameValue") or pointObject:IsA("Vector3Value") then
                return pointObject.Value
            else
                -- Jika POINT itu sendiri adalah objek fisiknya (Part/MeshPart)
                return pointObject
            end
        end
    end
    return nil
end
-- =================================================================

local function bypassPhysics(targetPos)
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    local carRoot = seat.Parent.PrimaryPart or seat
    
    -- Bypass Network Ownership
    pcall(function() settings().Physics.AllowSleep = false end)
    
    -- Membuat pergerakan melayang secara mulus
    local attachment = Instance.new("Attachment")
    attachment.Parent = carRoot
    
    local linVel = Instance.new("LinearVelocity")
    linVel.MaxForce = 9999999
    linVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector3
    linVel.RelativeTo = Enum.ActuatorRelativeTo.World
    linVel.Attachment0 = attachment
    linVel.Parent = carRoot
    
    -- Mengatur tinggi udara ke titik target
    local targetAirHeight = targetPos.Y + 120
    while carRoot.Position.Y < targetAirHeight do
        linVel.VectorVelocity = Vector3.new(0, 50, 0)
        RunService.Heartbeat:Wait()
    end
    
    linVel.VectorVelocity = Vector3.new(0, 0, 0)
    task.wait(0.2)
    
    -- Meluncur ke arah koordinat POINT tujuan baru
    local airTarget = Vector3.new(targetPos.X, targetAirHeight, targetPos.Z)
    while (Vector3.new(carRoot.Position.X, 0, carRoot.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude > 15 do
        local direction = (airTarget - carRoot.Position).Unit
        linVel.VectorVelocity = direction * SAFE_SPEED
        RunService.Heartbeat:Wait()
    end
    
    linVel.VectorVelocity = Vector3.new(0, 0, 0)
    task.wait(0.2)
    
    -- Turun perlahan tepat ke lokasi finish pekerjaan
    while (carRoot.Position - targetPos).Magnitude > 5 do
        local direction = (targetPos - carRoot.Position).Unit
        linVel.VectorVelocity = direction * 40
        RunService.Heartbeat:Wait()
    end
    
    -- Hancurkan efek bantu terbang setelah sampai
    linVel:Destroy()
    attachment:Destroy()
    
    -- Reset posisi kendaraan untuk memicu checkpoint selesai
    carRoot.CFrame = CFrame.new(targetPos)
end

-- [[ EVENT TOMBOL KLIK ]] --
local isRunning = false
StartButton.MouseButton1Click:Connect(function()
    if isRunning then return end
    isRunning = true
    
    StartButton.Text = "PROCESSING..."
    StartButton.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
    
    local target = getActivePoint()
    task.wait(0.5) -- Beri waktu sistem mendeteksi titik koordinat
    
    if target then
        StartButton.Text = "FLYING TO JOB..."
        
        -- Deteksi apakah target berupa posisi koordinat (Vector3/CFrame) atau Aset Objek Part
        local targetPos
        if typeof(target) == "Vector3" then
            targetPos = target
        elseif typeof(target) == "CFrame" then
            targetPos = target.Position
        elseif target:IsA("BasePart") then
            targetPos = target.Position
        end
        
        if targetPos then
            bypassPhysics(targetPos)
            StartButton.Text = "START AUTO JOB"
            StartButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        else
            StartButton.Text = "POINT TIDAK VALID"
            StartButton.BackgroundColor3 = Color3.fromRGB(235, 50, 60)
            task.wait(2)
            StartButton.Text = "START AUTO JOB"
            StartButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        end
    else
        StartButton.Text = "POINT TIDAK DITEMUKAN"
        StartButton.BackgroundColor3 = Color3.fromRGB(235, 50, 60)
        task.wait(2)
        StartButton.Text = "START AUTO JOB"
        StartButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    end
    
    isRunning = false
end)
