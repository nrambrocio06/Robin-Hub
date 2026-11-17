-- Anime Tower Defense | Record & Playback Macro
-- Executor: Real / Delta (getgenv, task.wait, hookfunction compatible)
-- Runtime: Roblox Luau

local MacroService = {}
MacroService.__index = MacroService

-- State
local recording = false
local playing = false
local actions = {}
local startTime = nil

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MacroUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = gethui and gethui() or lp.PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 160)
Frame.Position = UDim2.new(0, 20, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "ATD Macro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Parent = Frame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = Title

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 24)
StatusLabel.Position = UDim2.new(0, 5, 0, 34)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Frame

local function makeButton(text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = Frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local RecordBtn  = makeButton("⏺  Record",  65, Color3.fromRGB(180, 50, 50))
local PlayBtn    = makeButton("▶  Play",    100, Color3.fromRGB(50, 140, 80))
local ClearBtn   = makeButton("🗑  Clear",  135, Color3.fromRGB(70, 70, 90))

-- Core: record a click action
local function recordAction(actionType, position, target)
    if not recording then return end
    local elapsed = tick() - startTime
    table.insert(actions, {
        time     = elapsed,
        type     = actionType,   -- "click" | "place"
        position = position,
        target   = target
    })
end

-- Mouse click hook
local clickConn
local function startRecording()
    if recording then return end
    recording  = true
    startTime  = tick()
    actions    = {}
    StatusLabel.Text = "Status: 🔴 Recording..."
    RecordBtn.Text   = "⏹  Stop"

    clickConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local hit = mouse.Hit
            local target = mouse.Target
            recordAction("click", hit and hit.Position or Vector3.zero, target and target:GetFullName() or "nil")
        end
    end)
end

local function stopRecording()
    recording = false
    if clickConn then clickConn:Disconnect() end
    StatusLabel.Text = "Status: ✅ Recorded " .. #actions .. " actions"
    RecordBtn.Text   = "⏺  Record"
end

-- Playback
local function playMacro(loop)
    if playing or #actions == 0 then return end
    playing = true
    StatusLabel.Text = "Status: ▶ Playing..."

    task.spawn(function()
        repeat
            local playStart = tick()
            for _, action in ipairs(actions) do
                if not playing then break end
                -- wait until action's timestamp relative to playback start
                local elapsed = tick() - playStart
                local wait_time = action.time - elapsed
                if wait_time > 0 then
                    task.wait(wait_time)
                end

                if action.type == "click" then
                    -- Simulate via VirtualInputManager if available (Real/Delta support)
                    if VirtualInputManager then
                        VirtualInputManager:SendMouseButtonEvent(
                            mouse.X, mouse.Y, 0, true, game, 0
                        )
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(
                            mouse.X, mouse.Y, 0, false, game, 0
                        )
                    end

                    -- Attempt to find and invoke the target part's click detector
                    local ok, obj = pcall(function()
                        return game:FindFirstChild(action.target, true)
                    end)
                    if ok and obj then
                        local cd = obj:FindFirstChildOfClass("ClickDetector")
                        if cd then
                            fireclickdetector(cd)
                        end
                    end
                end
            end
            if loop then task.wait(0.2) end
        until not loop or not playing

        playing = false
        StatusLabel.Text = "Status: ✅ Done"
    end)
end

local loopPlay = false

-- Button logic
RecordBtn.MouseButton1Click:Connect(function()
    if recording then
        stopRecording()
    else
        startRecording()
    end
end)

PlayBtn.MouseButton1Click:Connect(function()
    if playing then
        playing = false
        StatusLabel.Text = "Status: ⏹ Stopped"
        PlayBtn.Text = "▶  Play"
    else
        loopPlay = true   -- set false if you want single-pass
        playMacro(loopPlay)
        PlayBtn.Text = "⏹  Stop"
    end
end)

ClearBtn.MouseButton1Click:Connect(function()
    if playing then playing = false end
    if recording then stopRecording() end
    actions = {}
    StatusLabel.Text = "Status: Idle"
    PlayBtn.Text = "▶  Play"
    RecordBtn.Text = "⏺  Record"
end)

-- Keybind: F5 = record toggle, F6 = play toggle
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        if recording then stopRecording() else startRecording() end
    elseif input.KeyCode == Enum.KeyCode.F6 then
        PlayBtn.MouseButton1Click:Fire()
    end
end)
