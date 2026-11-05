-- ⚠️ SÉCURITÉ ANTI-BYPASS CORRIGÉE ⚠️
local SecretKey = "0652269804Xd"

if not _G[SecretKey] then
    -- Sécurité de secours : si la variable globale n'est pas définie (ex: lancement direct), on la force ou on prévient proprement au lieu de crash brutalement, ou on applique le kick si requis.
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run Koyle Admin Hub")
    end
    return
end

print("Koyle Admin Hub Loaded Successfully!")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

local states = {
    noclip = false, godmode = false, dash = false, fly = false,
    esp = false, entitiesESP = false, infjump = false, infzoom = false, xray = false, aimbot = false
}

local connections = {}
local xrayOriginals = {}
local xrayConnection = nil
local xrayAccumulator = 0
local XRAY_RADIUS = 220
local XRAY_MAX_PARTS = 450
local XRAY_UPDATE_INTERVAL = 0.45
local flyBV, flyBG = nil, nil

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local GUI_THEME = {
    Background = Color3.fromRGB(15, 15, 22),
    Header = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(0, 200, 255),
    ButtonOff = Color3.fromRGB(35, 35, 45),
    ButtonOn = Color3.fromRGB(0, 200, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Transparency = 0.1
}

local sizes = isMobile and {w = 240, h = 340, head = 40, btn = 35, txt = 11} or {w = 380, h = 550, head = 60, btn = 45, txt = 14}

-- --- BOOMBOX CORE ---
local sound = Instance.new("Sound")
sound.Name = "RelicsBoombox"
sound.Volume = 0.7
sound.Parent = Workspace

local favorites = {}
local SAVE_KEY = "relics_v41_favs"

local function saveFavs()
    local data = HttpService:JSONEncode(favorites)
    if writefile then pcall(writefile, SAVE_KEY..".json", data) end
    player:SetAttribute(SAVE_KEY, data)
end

local function loadFavs()
    local data = nil
    if readfile and isfile and isfile(SAVE_KEY..".json") then
        data = readfile(SAVE_KEY..".json")
    else
        data = player:GetAttribute(SAVE_KEY)
    end
    if data then
        local ok, tbl = pcall(HttpService.JSONDecode, HttpService, data)
        if ok and type(tbl) == "table" then favorites = tbl end
    end
end
loadFavs()

local activeDrag = nil
local DRAG_THRESHOLD = 4

local function makeDraggable(frame, handle)
    local dragState = { dragged = false }
    handle.Active = true
    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragState.dragged = false
        activeDrag = { frame = frame, handle = handle, input = input, inputType = input.UserInputType, startPointer = input.Position, startAbsolute = frame.AbsolutePosition, state = dragState }
    end)
    return dragState
end

UserInputService.InputChanged:Connect(function(input)
    local drag = activeDrag
    if not drag or not drag.frame or not drag.frame.Parent then return end
    local isMouseMove = drag.inputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
    local isTouchMove = drag.inputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch and input == drag.input
    if not isMouseMove and not isTouchMove then return end
    local delta = input.Position - drag.startPointer
    if delta.Magnitude < DRAG_THRESHOLD and not drag.state.dragged then return end
    drag.state.dragged = true
    local viewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
    local frameSize = drag.frame.AbsoluteSize
    local left = math.clamp(drag.startAbsolute.X + delta.X, 0, math.max(0, viewport.X - frameSize.X))
    local top = math.clamp(drag.startAbsolute.Y + delta.Y, 0, math.max(0, viewport.Y - frameSize.Y))
    local anchor = drag.frame.AnchorPoint
    drag.frame.Position = UDim2.fromOffset(left + frameSize.X * anchor.X, top + frameSize.Y * anchor.Y)
end)

UserInputService.InputEnded:Connect(function(input)
    local drag = activeDrag
    if drag and (input == drag.input or input.UserInputType == Enum.UserInputType.MouseButton1) then activeDrag = nil end
end)

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "UltimateAdmin_v80"
screenGui.ResetOnSpawn = false

local bubble = Instance.new("TextButton", screenGui)
bubble.Name = "Bubble"
bubble.Size = UDim2.new(0, 50, 0, 50)
bubble.Position = UDim2.new(0, 20, 0.5, -25)
bubble.BackgroundColor3 = GUI_THEME.Background
bubble.Text = "⚡"
bubble.TextColor3 = GUI_THEME.Accent
bubble.Font = Enum.Font.GothamBold; bubble.TextSize = 24
bubble.Visible = false
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", bubble).Color = GUI_THEME.Accent

local main = Instance.new("Frame", screenGui)
main.Name = "MainFrame"
main.Size = UDim2.new(0, sizes.w, 0, sizes.h)
main.Position = UDim2.new(0.5, -sizes.w/2, 0.5, -sizes.h/2)
main.BackgroundColor3 = GUI_THEME.Background
main.BackgroundTransparency = GUI_THEME.Transparency
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
Instance.new("UIStroke", main).Color = GUI_THEME.Accent

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, sizes.head)
header.BackgroundColor3 = GUI_THEME.Header
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", header)
title.Text = "ULTIMATE ADMIN v8.0"
title.Size = UDim2.new(1, -90, 1, 0); title.Position = UDim2.new(0, 50, 0, 0)
title.TextColor3 = GUI_THEME.Text; title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold; title.TextSize = sizes.txt + 2
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 40, 1, 0); minBtn.Position = UDim2.new(1, -80, 0, 0)
minBtn.BackgroundTransparency = 1; minBtn.Text = "-"
minBtn.TextColor3 = GUI_THEME.Text; minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 22

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 40, 1, 0); closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundTransparency = 1; closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 95, 105); closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 20

local closeConfirm = Instance.new("Frame", screenGui)
closeConfirm.Size = UDim2.new(0, 320, 0, 150)
closeConfirm.Position = UDim2.new(0.5, -160, 0.5, -75)
closeConfirm.BackgroundColor3 = Color3.fromRGB(20, 22, 31)
closeConfirm.Visible = false
closeConfirm.ZIndex = 50
Instance.new("UICorner", closeConfirm).CornerRadius = UDim.new(0, 12)

local confirmTitle = Instance.new("TextLabel", closeConfirm)
confirmTitle.Size = UDim2.new(1, 0, 0, 40); confirmTitle.Position = UDim2.new(0, 0, 0, 10)
confirmTitle.Text = "Close Panel?"
confirmTitle.TextColor3 = Color3.new(1,1,1); confirmTitle.Font = Enum.Font.GothamBold; confirmTitle.TextSize = 16
confirmTitle.BackgroundTransparency = 1; confirmTitle.ZIndex = 51

local cancelCloseBtn = Instance.new("TextButton", closeConfirm)
cancelCloseBtn.Size = UDim2.new(0.4, 0, 0, 35); cancelCloseBtn.Position = UDim2.new(0.08, 0, 1, -45)
cancelCloseBtn.Text = "Cancel"; cancelCloseBtn.BackgroundColor3 = Color3.fromRGB(55, 59, 72)
cancelCloseBtn.TextColor3 = Color3.new(1,1,1); cancelCloseBtn.Font = Enum.Font.GothamSemibold; cancelCloseBtn.ZIndex = 51
Instance.new("UICorner", cancelCloseBtn)

local confirmCloseBtn = Instance.new("TextButton", closeConfirm)
confirmCloseBtn.Size = UDim2.new(0.4, 0, 0, 35); confirmCloseBtn.Position = UDim2.new(0.52, 0, 1, -45)
confirmCloseBtn.Text = "Close"; confirmCloseBtn.BackgroundColor3 = Color3.fromRGB(170, 45, 55)
confirmCloseBtn.TextColor3 = Color3.new(1,1,1); confirmCloseBtn.Font = Enum.Font.GothamBold; confirmCloseBtn.ZIndex = 51
Instance.new("UICorner", confirmCloseBtn)

closeBtn.MouseButton1Click:Connect(function() closeConfirm.Visible = true end)
cancelCloseBtn.MouseButton1Click:Connect(function() closeConfirm.Visible = false end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -sizes.head - 16)
scroll.Position = UDim2.new(0, 8, 0, sizes.head + 8)
scroll.BackgroundTransparency = 1; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local isOpen = true
local function toggleUI()
    isOpen = not isOpen
    main.Visible = isOpen
    bubble.Visible = not isOpen
    if not isOpen then
        bubble.Position = UDim2.new(0, main.AbsolutePosition.X, 0, main.AbsolutePosition.Y)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.G then toggleUI() end
end)

makeDraggable(main, header)
makeDraggable(bubble, bubble)
bubble.MouseButton1Click:Connect(toggleUI)
minBtn.MouseButton1Click:Connect(toggleUI)

local function getChar() return player.Character end
local function getHum() return getChar() and getChar():FindFirstChild("Humanoid") end
local function getRoot() return getChar() and getChar():FindFirstChild("HumanoidRootPart") end

local function addToggle(txt, cb)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -10, 0, sizes.btn)
    b.BackgroundColor3 = GUI_THEME.ButtonOff
    b.Text = "  " .. txt
    b.TextColor3 = GUI_THEME.Text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = sizes.txt
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(25, 60, 80) or GUI_THEME.ButtonOff
        cb(active)
    end)
end

local function closeAdminPanelPermanently()
    for key in pairs(states) do states[key] = false end
    if xrayConnection then xrayConnection:Disconnect() end
    for name, connection in pairs(connections) do
        if connection then pcall(function() connection:Disconnect() end) end
    end
    if flyBG then flyBG:Destroy() end
    if flyBV then flyBV:Destroy() end
    pcall(function() sound:Stop(); sound:Destroy() end)
    screenGui:Destroy()
end

confirmCloseBtn.MouseButton1Click:Connect(closeAdminPanelPermanently)

-- --- FONCTIONS ADMIN ---
addToggle("1. 👻 NoClip", function(a)
    states.noclip = a
    if a then
        connections["NoClip"] = RunService.Stepped:Connect(function()
            if getChar() then
                for _, v in pairs(getChar():GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
            end
        end)
    else
        if connections["NoClip"] then connections["NoClip"]:Disconnect() end
    end
end)

addToggle("2. 🦸 Fly Mode", function(a)
    states.fly = a
    if a and getRoot() then
        flyBG = Instance.new("BodyGyro", getRoot()); flyBG.maxTorque = Vector3.new(9e9,9e9,9e9)
        flyBV = Instance.new("BodyVelocity", getRoot()); flyBV.maxForce = Vector3.new(9e9,9e9,9e9)
        connections["Fly"] = RunService.RenderStepped:Connect(function()
            if not getRoot() then return end
            local cf = camera.CFrame
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
            flyBG.cframe = cf; flyBV.velocity = dir * 50
        end)
    else
        if connections["Fly"] then connections["Fly"]:Disconnect() end
        if flyBG then flyBG:Destroy() end; if flyBV then flyBV:Destroy() end
    end
end)

addToggle("3. 🛡️ God Mode", function(a)
    states.godmode = a
    connections["God"] = RunService.Heartbeat:Connect(function() if states.godmode and getHum() then getHum().Health = 100 end end)
end)

addToggle("4. ⚡ Speed Boost", function(a) if getHum() then getHum().WalkSpeed = a and 70 or 16 end end)

addToggle("5. 🦘 Infinite Jump", function(a)
    states.infjump = a
    connections["Jump"] = UserInputService.JumpRequest:Connect(function() if states.infjump and getHum() then getHum():ChangeState(3) end end)
end)

addToggle("6. 💡 Full Bright", function(a)
    Lighting.Ambient = a and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
end)

-- --- OPTION 7 : RESET SAVED KEY & EXIT ---
addToggle("7. 🗑️ Reset Saved Key & Exit", function(active)
    if active then
        if delfile and isfile and isfile("Mykey.txt") then
            pcall(function() delfile("Mykey.txt") end)
        end
        closeAdminPanelPermanently()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/loris05nav-byte/Koyle-Admin-Hub/refs/heads/main/Koyle%20Key%20system.lua"))()
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "ADMIN v8.0", Text = "Hub loaded successfully!", Duration = 3
})
