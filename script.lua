-- [[ SOUND SYSTEM SIMULATOR GUI & AUTO JOB BYPASS V6 ]] --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local SAFE_SPEED = 180 -- Batas kecepatan meluncur fisika agar aman dari anti-cheat

-- ====================================================================
-- [1. PEMBUATAN GUI MENGAMBANG DI LAYAR]
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
-- Deteksi Delta Executor CoreGui agar aman dari reset karakter
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- Main Frame (Kotak Utama Menu)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "DeltaFloatingMenu"
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0) -- Posisi default kiri layar
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Membuat menu bisa digeser/digerakkan di layar
MainFrame.Parent = ScreenGui

-- Efek Sudut Bulat Menu
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Efek Stroke Garis Tepi
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 170, 0) -- Warna oranye/kuning emas
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Judul Menu Utama
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Text = "  AUTO JOB UTAMA"
TitleLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = MainFrame

-- Garis Pembatas
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.9, 0, 0, 1)
Line.Position = UDim2.new(0.05, 0, 0, 30)
Line.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- Teks Informasi Informasi
local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(0.9, 0, 0, 75)
InfoText.Position = UDim2.new(0.05, 0, 0, 35)
InfoText.Text = "Owner: bruk×ontop⁸⁷\nVersi: 1.0.0\nMap: igr"
InfoText.TextColor3 = Color3.fromRGB(220, 220, 220)
InfoText.TextSize = 14
InfoText.Font = Enum.Font.SourceSans
InfoText.LineHeight = 1.3
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.BackgroundTransparency = 1
InfoText.Parent = MainFrame

-- Tombol Eksekusi
local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(0.9, 0, 0, 40)
StartButton.Position = UDim2.new(0.05, 0, 0, 120)
StartButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
StartButton.Text = "START AUTO JOB"
StartButton.TextColor3 = Color3.fromRGB(15, 15, 15)
StartButton.TextSize = 15
StartButton.Font = Enum.Font.SourceSansBold
StartButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = StartButton

-- ====================================================================
-- [2. LOGIKA SKRIP AUTO JOB & BYPASS FISIKA]
-- ====================================================================
local function takeActiveJob()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local jobRemote = remotes and remotes:FindFirstChild("Job") or ReplicatedStorage:FindFirstChild("Job")
    
    if jobRemote then
        if jobRemote:IsA("RemoteEvent") then
            jobRemote:FireServer("TakeJob")
            jobRemote:FireServer() 
        elseif jobRemote:IsA("RemoteFunction") then
            pcall(function() jobRemote:InvokeServer("TakeJob") end)
            pcall(function() jobRemote:InvokeServer() end)
        end
    end
end

local function getActivePoint()
    local lokasi = ReplicatedStorage:FindFirstChild("LOKASI")
    if lokasi then
        local point = lokasi:FindFirstChild("POINT")
        if point then
            if point:IsA("BasePart") or point:IsA("SpawnLocation") or point:IsA("Part") then
                return point.Position
            elseif point:IsA("Vector3Value") or point:IsA("CFrameValue") then
                return point.Value
            end
        end
    end
    return nil
end

local function bypassPhysicsFly(targetPos)
    local character = localPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local seat = humanoid and humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        local carRoot = seat.Parent:IsA("Model") and seat.Parent.PrimaryPart or seat
        
        -- Bypass Network Ownership
        pcall(function() settings().Physics.AllowSleep = false end)
        
        -- Membuat komponen fisika linier buatan
        local attachment = Instance.new("Attachment")
        attachment.Parent = carRoot
        
        local linVel = Instance.new("LinearVelocity")
        linVel.MaxForce = 9999999
        linVel.VectorVelocity = Vector3.new(0, 0, 0)
        linVel.RelativeTo = Enum.ActuatorRelativeTo.World
        linVel.Attachment0 = attachment
        linVel.Parent = carRoot
        
        -- A. Mengangkat mobil ke udara ke atas langit
        local targetAirHeight = carRoot.Position.Y + 130
        while carRoot.Position.Y < targetAirHeight do
            linVel.VectorVelocity = Vector3.new(0, 50, 0)
            RunService.Heartbeat:Wait()
        end
        linVel.VectorVelocity = Vector3.new(0, 0, 0)
        task.wait(0.2)
        
        -- B. Meluncur horizontal ke arah kordinat POINT panah kuning
        local airTarget = Vector3.new(targetPos.X, carRoot.Position.Y, targetPos.Z)
        while (Vector3.new(carRoot.Position.X, 0, carRoot.Position.Z) - Vector3.new(airTarget.X, 0, airTarget.Z)).Magnitude > 15 do
            local direction = (airTarget - carRoot.Position).Unit
            linVel.VectorVelocity = direction * SAFE_SPEED
            RunService.Heartbeat:Wait()
        end
        linVel.VectorVelocity = Vector3.new(0, 0, 0)
        task.wait(0.2)
        
        -- C. Turun perlahan ke tanah pas di titik lokasi finish
        while (carRoot.Position - targetPos).Magnitude > 5 do
            local direction = (targetPos - carRoot.Position).Unit
            linVel.VectorVelocity = direction * 40
            RunService.Heartbeat:Wait()
        end
        
        -- Bersihkan alat bantu dorong
        linVel:Destroy()
        attachment:Destroy()
        
        -- Kunci posisi akhir untuk ambil reward checkpoint
        carRoot.CFrame = CFrame.new(targetPos)
    else
        StartButton.Text = "SILAKAN DUDUK DI MOBIL!"
        StartButton.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
        task.wait(2)
        StartButton.Text = "START AUTO JOB"
        StartButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    end
end

-- ====================================================================
-- [3. EVENT TOMBOL KLIK]
-- ====================================================================
StartButton.MouseButton1Click:Connect(function()
    StartButton.Text = "PROCESSING..."
    StartButton.BackgroundColor3 = Color3.fromRGB(150, 110, 0)
    
    takeActiveJob()
    task.wait(1.5) -- Beri waktu sistem mendeteksi tanda
    
    local target = getActivePoint()
    if target then
        StartButton.Text = "FLYING TO JOB..."
        bypassPhysicsFly(target)
        StartButton.Text = "SUCCESS!"
        StartButton.BackgroundColor3 = Color3.fromRGB(60, 220, 60)
        task.wait(1.5)
    else
        StartButton.Text = "POINT TIDAK DITEMUKAN"
        StartButton.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
        task.wait(2)
    end
    
    -- Kembalikan tombol ke setelan awal
    StartButton.Text = "START AUTO JOB"
    StartButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
end)

