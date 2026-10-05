local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")
local players = game:GetService("Players")
local v1 = print

function print(...)
end

local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local v2 = {
  bg = Color3.fromRGB(20, 20, 20),
  panel = Color3.fromRGB(28, 28, 28),
  border = Color3.fromRGB(50, 50, 50),
  text = Color3.fromRGB(240, 240, 240),
  textDim = Color3.fromRGB(150, 150, 150),
  textMute = Color3.fromRGB(190, 190, 190),
  accent = Color3.fromRGB(255, 64, 64),
  accentDim = Color3.fromRGB(45, 20, 20),
  white = Color3.fromRGB(255, 255, 255),
  boss = Color3.fromRGB(255, 180, 0),
  bossDim = Color3.fromRGB(30, 20, 0),
}

local gothamMedium = Enum.Font.Code
local gothamBold = Enum.Font.Code
local f1

local function f2(parent, p1)
  return f1("UICorner", { CornerRadius = UDim.new(0, 0), Parent = parent })
end

function f1(p2, p3, p4)
  local instance = Instance.new(p2)

  for key, value in pairs(p3 or {}) do
    instance[key] = value
  end

  for index, value2 in ipairs(p4 or {}) do
    value2.Parent = instance
  end

  return instance
end

local function f3(parent2, p5, p6)
  return f1("UIStroke", {
    Color = p5 or v2.border,
    Thickness = p6 or 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = parent2,
  })
end

local function f4(parent3, p7)
  return f1("UIPadding", {
    PaddingTop = UDim.new(0, p7),
    PaddingBottom = UDim.new(0, p7),
    PaddingLeft = UDim.new(0, p7),
    PaddingRight = UDim.new(0, p7),
    Parent = parent3,
  })
end

local v3 = {
  World1 = { "Luffo", "Zorro", "Namy", "Usoop", "Sanje", "Acu", "Hawk", "Shanks" },
  World2 = { "Narutu", "Sukura", "Arachimaru", "Itacha", "Sasoke", "Obiti", "Madaro", "Kaguyi" },
  World3 = {
    "Tanjiru", "Inusoke", "Zenitsi", "Goyu", "Rengoko", "Muzen", "Yorochi", "Kokushibu",
  },
  World4 = { "Ichigi", "Orihima", "Toshoro", "Rukai", "Grimjaw", "Kenpuchi", "Aison", "Kusuke" },
}

_G.ShazeFarm = {
  Enabled = false,
  CurrentWorld = "",
  SelectedMobs = {},
  Speed = 0.1,
  WorldSpawns = {},
  RevisitSpawns = false, -- false = don't teleport to spawn points when mobs are down/not spawned
}

_G.AutoEquipPet = { Enabled = false, Interval = 5 }

_G.AutoDungeon = {
  Enabled = false,
  Interval = 3,
  Speed = 0.1,
  ReturnPending = false,
  TargetWave = 0,
  LeaveEnabled = false,
}

_G.AutoRaid = {
  Enabled = false,
  RaidType = "LeafVillageRaid",
  Speed = 0.1,
  StartMode = "wave1",
  RestartDelay = 5,
}

_G.AutoLeaveRaid = {
  Enabled = false,
  TargetWave = 100,
  AutoRearm = true,
  LeaveCooldown = 8,
}

_G.AntiAFK = { Enabled = true, Interval = 60 }
_G.SavePos = { X = nil, Y = nil, Z = nil }
_G._sonLeaveZamani = 0

local function f5(p8)
  if not _G.ShazeFarm.SelectedMobs[p8] then
    return {}
  else
    local v4 = {}

    for key2, value3 in pairs(_G.ShazeFarm.SelectedMobs[p8]) do
      table.insert(v4, key2)
    end

    return v4
  end
end

local function f6()
  return localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- Every teleport the script does goes through tpTo, so we can tell them apart from teleports
-- YOU do (other map, portal, game teleport). A big jump the script did not make = manual move:
-- the farm pauses for a while and dungeon/raid stop trying to send you back to the saved spot.
local lastScriptPos = nil
local lastScriptTime = 0
_G.RobinManualUntil = 0
_G.RobinRaidMoved = false
_G.RobinDungeonWaiting = false
_G.RobinDungeonJoinTime = 0
_G.RobinStartDungeonWait = function(pos)
  _G.RobinDungeonWaiting = true
  _G.RobinDungeonWaitStart = tick()
  _G.RobinDungeonWaitPos = pos
end

local function tpTo(root, cf)
  root.CFrame = cf
  lastScriptPos = cf.Position
  lastScriptTime = tick()
end

task.spawn(function()
  while true do
    task.wait(0.25)

    local root = f6()
    local inRun = _G.AutoDungeon.Moved or _G.RobinRaidMoved

    if lastScriptPos and not inRun and tick() - lastScriptTime > 3 then
      lastScriptPos = nil
    end

    if root and lastScriptPos and tick() - lastScriptTime > 0.4 then
      if (root.Position - lastScriptPos).Magnitude > 120 then
        _G.RobinManualUntil = tick() + 45
        lastScriptPos = nil
        _G.AutoDungeon.Moved = false
        _G.RobinRaidMoved = false
      end
    end
  end
end)

local function f7()
  local v5 = f6()

  if v5 then
    _G.SavePos.X = v5.Position.X
    _G.SavePos.Y = v5.Position.Y
    _G.SavePos.Z = v5.Position.Z

    return true
  end

  return false
end

local function f8()
  if not _G.SavePos.X then
    return false
  else
    local v6 = f6()

    if v6 then
      tpTo(v6, CFrame.new(Vector3.new(_G.SavePos.X, _G.SavePos.Y, _G.SavePos.Z)))
      return true
    end

    return false
  end
end

-- The saved spot is usually in the world where you switched the dungeon/raid on.
-- If the world farm is running (e.g. World4) it already moves you next to that
-- world's mobs, so going back to the saved spot would drag you to the wrong world.
local function farmActive()
  return _G.ShazeFarm.Enabled == true and _G.ShazeFarm.CurrentWorld ~= ""
end

local function returnToSaved()
  if farmActive() then
    return false
  end

  return f8()
end

localPlayer.Idled:Connect(function()
  pcall(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
  end)
end)

task.spawn(function()
  local v7 = 0

  while true do
    if _G.AntiAFK.Enabled then
      local v8 = tick()

      if v8 - v7 >= _G.AntiAFK.Interval then
        v7 = v8

        pcall(function()
          virtualUser:CaptureController()
          virtualUser:ClickButton2(Vector2.new())
        end)

        local character = localPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
          pcall(function() humanoid.Jump = true end)
        end
      end
    end

    task.wait(1)
  end
end)

-- remembers where selected mobs were seen, so we can go back when they stream out
local mobSpawns = {}

local function rememberMob(world, mobName, pos)
  mobSpawns[world] = mobSpawns[world] or {}

  local list = mobSpawns[world][mobName]

  if not list then
    list = {}
    mobSpawns[world][mobName] = list
  end

  local key = math.floor(pos.X / 20) .. "," .. math.floor(pos.Z / 20)

  if not list[key] then
    list[key] = pos
  end
end

local f9

local function f10(p9, p10)
  local findFirstChild = workspace:FindFirstChild(p9)

  if not findFirstChild then
    return nil
  else
    local enemy = findFirstChild:FindFirstChild("Enemy")
      or findFirstChild:FindFirstChild("Enemies") or findFirstChild:FindFirstChild("Mobs")

    if not enemy then
      return nil
    else
      local v9 = f6()

      if not v9 then
        return nil
      else
        local huge = math.huge
        local v10 = nil
        local v11 = nil

        for index2, value4 in ipairs(enemy:GetChildren()) do
          if value4:IsA("Model") then
            for index3, value5 in ipairs(p10) do
              if f9(value4.Name, value5) then
                local attackable = value4:GetAttribute("Attackable")
                local humanoidRootPart = value4:FindFirstChild("HumanoidRootPart")
                  or value4.PrimaryPart
                  or value4:FindFirstChildWhichIsA("BasePart", true)

                if humanoidRootPart then
                  rememberMob(p9, value5, humanoidRootPart.Position)
                end

                if humanoidRootPart and attackable ~= false then
                  if not v11 then
                    v11 = humanoidRootPart
                  end

                  local magnitude = (humanoidRootPart.Position - v9.Position).Magnitude

                  if magnitude < huge then
                    huge = magnitude
                    v10 = humanoidRootPart
                  end
                end

                break
              end
            end
          end
        end

        return v10 or v11
      end
    end
  end
end

local function f11()
  local easyDungeon = workspace:FindFirstChild("EasyDungeon")

  if not easyDungeon then
    return false
  else
    local enemy2 = easyDungeon:FindFirstChild("Enemy")

    if not enemy2 then
      return false
    end

    return #enemy2:GetChildren() > 0
  end
end

function f9(p11, p12)
  if p11 == p12 then
    return true
  end

  return string.lower(p11):gsub("%s+", "") == string.lower(p12):gsub("%s+", "")
end

local function f12()
  for index4, value6 in ipairs({ "LeafVillageRaid", "MundoRaid" }) do
    local findFirstChild2 = workspace:FindFirstChild(value6)

    if findFirstChild2 then
      for index5, value7 in ipairs(findFirstChild2:GetChildren()) do
        local enemy3 = value7:FindFirstChild("Enemy")

        local enemies = enemy3
        enemies = enemy3 or value7:FindFirstChild("Enemies")

        if enemies and #enemies:GetChildren() > 0 then
          return true
        end
      end
    end
  end

  return false
end

-- ===== world teleport =====
-- Used when the selected mobs can't be found, i.e. you're not in that world.
-- Order: your own hook -> a spawn you saved. It never guesses a position.
local lastWorldTp = 0

local function goToWorld(world)
  if tick() - lastWorldTp < 3 then
    return
  end

  lastWorldTp = tick()

  local root = f6()

  if not root then
    return
  end

  -- 1) your own teleport function, e.g. firing the game's world-teleport remote
  if _G.RobinWorldTeleport then
    pcall(_G.RobinWorldTeleport, world)
    return
  end

  -- 2) a spawn position you saved with _G.RobinSaveWorldSpawn("World1")
  local spawns = _G.ShazeFarm.WorldSpawns
  local saved = spawns and spawns[world]

  if saved then
    tpTo(root, CFrame.new(saved))
    return
  end
end

-- stand in a world and run _G.RobinSaveWorldSpawn("World1") to remember the spot
_G.RobinSaveWorldSpawn = function(world)
  local root = f6()

  if root and world then
    _G.ShazeFarm.WorldSpawns = _G.ShazeFarm.WorldSpawns or {}
    _G.ShazeFarm.WorldSpawns[world] = root.Position
    return true
  end

  return false
end

-- helper: lists remotes that look like world teleports so you can find the right one
_G.RobinListRemotes = function()
  for _, d in ipairs(replicatedStorage:GetDescendants()) do
    if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
      local n = string.lower(d:GetFullName())

      if n:find("tele") or n:find("world") or n:find("zone") or n:find("portal") or n:find("area") then
        warn(d.ClassName, d:GetFullName())
      end
    end
  end
end
-- ===== end world teleport =====

-- when no selected mob is loaded, go to spots where they were seen before.
-- Getting close makes the game stream them in so the farm can find them again.
local visitIndex = 0
local lastVisit = 0

local function visitKnownMobs(world, names)
  if tick() - lastVisit < 1.5 then
    return true -- give the game time to load the area
  end

  local root = f6()

  if not root then
    return false
  end

  local positions = {}
  local worldSpawns = mobSpawns[world]

  if worldSpawns then
    for _, name in ipairs(names) do
      for _, pos in pairs(worldSpawns[name] or {}) do
        positions[#positions + 1] = pos
      end
    end
  end

  if #positions == 0 then
    return false
  end

  table.sort(positions, function(a, b)
    if a.X ~= b.X then
      return a.X < b.X
    end

    return a.Z < b.Z
  end)

  visitIndex = visitIndex % #positions + 1
  lastVisit = tick()

  local pos = positions[visitIndex]
  tpTo(root, CFrame.new(pos + Vector3.new(0, 3, 4)))

  task.spawn(function()
    pcall(function() localPlayer:RequestStreamAroundAsync(pos) end)
  end)

  return true
end

task.spawn(function()
  while true do
    if _G.ShazeFarm.Enabled and _G.ShazeFarm.CurrentWorld ~= "" then
      -- safety: the waiting hold can never block the farm for more than 45s
      if _G.RobinDungeonWaiting and tick() - (_G.RobinDungeonWaitStart or 0) > 45 then
        _G.RobinDungeonWaiting = false
      end

      if tick() >= (_G.RobinManualUntil or 0) and not f11() and not f12() and not _G.RobinDungeonWaiting then
        local v12 = f6()

        if v12 then
          local v13 = f5(_G.ShazeFarm.CurrentWorld)

          if #v13 > 0 then
            local v14 = f10(_G.ShazeFarm.CurrentWorld, v13)

            if v14 then
              -- the game just moved us right after a dungeon join (we are NOT where the script
              -- last put us): stay in the waiting room instead of teleporting back out
              if tick() - (_G.RobinDungeonJoinTime or 0) < 20
                and lastScriptPos and tick() - lastScriptTime < 2
                and (v12.Position - lastScriptPos).Magnitude > 120 then
                _G.RobinStartDungeonWait(v12.Position)
              else
                tpTo(v12, v14.CFrame + Vector3.new(0, 3, 4))
              end
            elseif _G.ShazeFarm.RevisitSpawns then
              -- optional (off by default): no selected mob loaded, so revisit where they were seen
              if not visitKnownMobs(_G.ShazeFarm.CurrentWorld, v13) then
                goToWorld(_G.ShazeFarm.CurrentWorld)
              end
            end
            -- else: mobs are dead / not spawned yet -> stay where we are and wait
          end
        end
      end

      task.wait(_G.ShazeFarm.Speed)
    else
      task.wait(0.1)
    end
  end
end)

local function f13()
  local remotes = replicatedStorage:FindFirstChild("Remotes")

  if remotes then
    remotes = remotes:FindFirstChild("Pets")
  end

  if remotes then
    remotes = remotes:FindFirstChild("EquipBestPets")
  end

  if not remotes then
    return false
  end

  pcall(function() remotes:FireServer() end)
  return true
end

local function isShown(obj)
  local cur = obj

  while cur and cur ~= game do
    if cur:IsA("ScreenGui") then
      if cur.Enabled == false then
        return false
      end
    elseif cur:IsA("GuiObject") then
      if cur.Visible == false then
        return false
      end
    end

    cur = cur.Parent
  end

  return true
end

local function parseWave(text)
  if type(text) ~= "string" then
    return nil
  end

  text = text:gsub("<[^>]+>", "")

  local n = text:match("(%d+)%s*/%s*%d+") or text:match("(%d+)")

  return n and tonumber(n) or nil
end

local lastBadWaveText
local loggedCounter
local cachedCounter
local lastScan = 0

local function f14()
  local playerGui2 = localPlayer:FindFirstChild("PlayerGui")

  if not playerGui2 then
    return nil
  end

  local counter = cachedCounter

  if counter and not counter:IsDescendantOf(playerGui2) then
    counter = nil
  end

  if not counter then
    local main = playerGui2:FindFirstChild("Main")
    local hud = main and main:FindFirstChild("HUD")
    local dungeon = hud and hud:FindFirstChild("Dungeon")
    local stats = dungeon and dungeon:FindFirstChild("Stats")
    local wave = stats and stats:FindFirstChild("Wave")
    counter = wave and wave:FindFirstChild("Counter")

    if counter and not counter:IsA("TextLabel") then
      counter = nil
    end
  end

  -- the cached / usual label can be a hidden leftover (not the one on screen): look again
  if counter and not isShown(counter) and tick() - lastScan > 2 then
    counter = nil
  end

  -- not at the usual place: search the whole gui (at most every 2 seconds),
  -- preferring a label that is really visible and holds a readable wave number
  if not counter and tick() - lastScan > 2 then
    lastScan = tick()
    local shownHit, anyHit

    for _, v in ipairs(playerGui2:GetDescendants()) do
      if v:IsA("TextLabel") and not v:FindFirstAncestor("RobinHub") then
        local isCounter = v.Name == "Counter" and v.Parent and v.Parent.Name == "Wave"

        if not isCounter and v.Text ~= "" then
          local clean = v.Text:gsub("<[^>]+>", "")
          isCounter = clean:match("%d+%s*/%s*50%s*$") ~= nil
        end

        if isCounter and parseWave(v.Text) then
          anyHit = anyHit or v

          if isShown(v) then
            shownHit = v
            break
          end
        end
      end
    end

    counter = shownHit or anyHit
  end

  cachedCounter = counter

  if not counter then
    return nil
  end

  if loggedCounter ~= counter then
    loggedCounter = counter
    warn("[RobinHub] wave counter: " .. counter:GetFullName() .. " = '" .. tostring(counter.Text) .. "'")
  end

  local n = parseWave(counter.Text)

  if not n and lastBadWaveText ~= counter.Text then
    lastBadWaveText = counter.Text
    warn("[RobinHub] cannot read dungeon wave from text: '" .. tostring(counter.Text) .. "'")
  end

  return n
end

local function f15()
  local v15 = {}
  local easyDungeon2 = workspace:FindFirstChild("EasyDungeon")

  if not easyDungeon2 then
    return v15
  else
    local enemy4 = easyDungeon2:FindFirstChild("Enemy")

    if not enemy4 then
      return v15
    end

    for index7, value9 in ipairs(enemy4:GetChildren()) do
      if value9:IsA("Model") then
        local humanoidRootPart2 = value9:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart2 then
          table.insert(v15, humanoidRootPart2)
        end
      end
    end

    return v15
  end
end

task.spawn(function()
  local v16 = 0

  while true do
    if _G.AutoEquipPet.Enabled then
      local v17 = tick()

      if v17 - v16 >= _G.AutoEquipPet.Interval then
        v16 = v17
        f13()
      end
    end

    task.wait(1)
  end
end)

local function f16()
  local remotes2 = replicatedStorage:FindFirstChild("Remotes")

  if remotes2 then
    remotes2 = remotes2:FindFirstChild("Dungeons")
  end

  if remotes2 then
    remotes2 = remotes2:FindFirstChild("Answer")
  end

  if not remotes2 then
    return false
  end

  pcall(function() remotes2:FireServer("EasyDungeon", true) end)
  return true
end

local function f17()
  local remotes3 = replicatedStorage:FindFirstChild("Remotes")

  if remotes3 then
    remotes3 = remotes3:FindFirstChild("Dungeons")
  end

  if remotes3 then
    remotes3 = remotes3:FindFirstChild("Leave")
  end

  if not remotes3 then
    return false
  end

  local learned = _G.RobinLeaveArgs

  if learned then
    pcall(function() remotes3:FireServer(table.unpack(learned, 1, learned.n)) end)
  else
    pcall(function() remotes3:FireServer() end)
  end

  return true
end

-- ===== dungeon diagnostics =====
-- Logs every call the GAME makes to ReplicatedStorage.Remotes.Dungeons.* (e.g. when you press
-- its own Leave button). The arguments used for Leave are remembered and reused by auto leave.
do
  pcall(function()
    if not (hookmetamethod and getnamecallmethod) then
      return
    end

    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
      local method = getnamecallmethod()

      if method == "FireServer" or method == "InvokeServer" then
        local args = table.pack(...)
        pcall(function()
          if typeof(self) == "Instance" and self.Parent and (self.Parent.Name == "Dungeons" or self.Parent.Name == "Raids")
            and not (checkcaller and checkcaller()) then
            if self.Name == "Leave" and self.Parent.Name == "Dungeons" then
              _G.RobinLeaveArgs = args
            end

            local parts = {}

            for i = 1, args.n do
              parts[i] = tostring(args[i])
            end

            task.spawn(function()
              warn("[RobinHub] game called " .. self.Parent.Name .. "." .. self.Name .. "(" .. table.concat(parts, ", ") .. ")")
            end)
          end
        end)
      end

      return old(self, ...)
    end)
  end)
end

-- run _G.RobinDumpDungeonHud() while inside a dungeon: prints/copies every dungeon/wave label
_G.RobinDumpDungeonHud = function()
  local lines = {}
  local pg = localPlayer:FindFirstChild("PlayerGui")

  if pg then
    for _, v in ipairs(pg:GetDescendants()) do
      if v:IsA("TextLabel") and v.Text ~= "" then
        local path = v:GetFullName()
        local low = path:lower()

        if low:find("dungeon") or low:find("wave") or v.Text:match("%d+%s*/%s*%d+") then
          lines[#lines + 1] = path .. "  =  " .. v.Text
        end
      end
    end
  end

  local text = table.concat(lines, "\n")
  warn(text)

  if setclipboard then
    pcall(setclipboard, text)
  end

  return text
end
-- ===== end dungeon diagnostics =====

-- press the game's own exit/leave button (works even if we don't know the Leave remote args)
local function pressInGameLeave()
  local pg = localPlayer:FindFirstChild("PlayerGui")

  if not pg then
    return false
  end

  for _, v in ipairs(pg:GetDescendants()) do
    if (v:IsA("TextButton") or v:IsA("ImageButton")) and not v:FindFirstAncestor("RobinHub") and isShown(v) then
      local name = v.Name:lower()
      local txt = v:IsA("TextButton") and v.Text:lower() or ""
      local path = v:GetFullName():lower()

      if (name:find("leave") or name:find("exit") or txt:find("leave") or txt:find("exit"))
        and (path:find("dungeon") or path:find("hud")) then
        warn("[RobinHub] pressing in-game button: " .. v:GetFullName())

        local pressed = false

        if type(firesignal) == "function" then
          pressed = pcall(function() firesignal(v.MouseButton1Click) end) or pressed
          pcall(function() firesignal(v.Activated) end)
        end

        if not pressed and type(getconnections) == "function" then
          pcall(function()
            for _, c in ipairs(getconnections(v.MouseButton1Click)) do
              c:Fire()
            end

            for _, c in ipairs(getconnections(v.Activated)) do
              c:Fire()
            end
          end)
        end

        return true
      end
    end
  end

  return false
end

-- auto leave dungeon at target wave (own loop, so it also works between waves)
task.spawn(function()
  local armed = true
  local attempts = 0
  local lastLeave = 0
  local lastWarn = 0

  local function leaveRemote()
    local r = replicatedStorage:FindFirstChild("Remotes")
    r = r and r:FindFirstChild("Dungeons")
    return r and r:FindFirstChild("Leave")
  end

  while true do
    local d = _G.AutoDungeon
    local label = _G.RobinWaveLabel

    if d.Enabled then
      local wave = f14()

      if label and label.Parent then
        if wave then
          label.Text = "Current wave: " .. wave .. "   (leaves at " .. d.TargetWave .. ")"
        else
          label.Text = "Current wave: not found"
        end
      end

      if d.LeaveEnabled and d.TargetWave > 0 then
        if not wave then
          armed = true -- not in a dungeon / counter hidden, ready for next run

          if #f15() > 0 and tick() - lastWarn > 20 then
            lastWarn = tick()
            warn("[RobinHub] dungeon wave counter not found, auto leave can't work")
          end
        elseif wave < d.TargetWave then
          armed = true
        else
          local remote = leaveRemote()

          if armed then
            armed = false
            attempts = 1
            lastLeave = tick()
            warn("[RobinHub] leaving dungeon at wave " .. wave .. (remote and "" or " (Leave remote NOT found)"))
            f17()
            d.ReturnPending = true
          elseif attempts < 6 and tick() - lastLeave > 3 then
            -- still in the dungeon after leaving: try other ways, then the game's own button
            attempts += 1
            lastLeave = tick()
            warn("[RobinHub] still in dungeon, retrying leave (" .. attempts .. "/6)")

            if remote and not _G.RobinLeaveArgs and attempts <= 3 then
              pcall(function()
                if attempts == 2 then
                  remote:FireServer("EasyDungeon")
                else
                  remote:FireServer("EasyDungeon", true)
                end
              end)
            else
              pressInGameLeave()
            end
          end
        end

      end
    elseif label and label.Parent then
      label.Text = "Current wave: (auto dungeon is off)"
    end

    task.wait(0.25)
  end
end)

task.spawn(function()
  local v18 = 1
  local v19 = 0
  local dNoEnemySince = nil
  -- Waiting room: after joining, the game moves us to the dungeon and it needs ~30s to start.
  -- While waiting we must NOT re-send the join and the world farm must not drag us away.
  local joinPos = nil
  local joinTime = 0

  while true do
    if _G.AutoDungeon.Enabled then
      local v20 = f6()

      if v20 then
        local v21 = f15()

        if #v21 > 0 then
          dNoEnemySince = nil
          _G.RobinDungeonWaiting = false -- dungeon started
          joinPos = nil

          if v18 > #v21 then
            v18 = 1
          end

          local v23 = v21[v18]

          if v23 and v23.Parent then
            tpTo(v20, v23.CFrame + Vector3.new(0, 3, 4))
            _G.AutoDungeon.Moved = true
          end

          v18 = v18 + 1
          task.wait(_G.AutoDungeon.Speed)
        else
          v18 = 1
          dNoEnemySince = dNoEnemySince or tick()

          -- Go back to the saved spot ONLY if the script took us into the dungeon,
          -- and only once it is really over (leave pressed, or no enemies for 6s).
          -- Never pull the player back while they are just walking around the map.
          if _G.AutoDungeon.Moved
            and (_G.AutoDungeon.ReturnPending or tick() - dNoEnemySince >= 6) then
            _G.AutoDungeon.ReturnPending = false
            _G.AutoDungeon.Moved = false
            returnToSaved()
          end

          local v24 = tick()

          -- Joined and the game moved us far away = we are in the dungeon waiting room.
          -- Only counts when the SCRIPT has not teleported us since the join (so the world
          -- farm's own teleports are never mistaken for it). With the world farm on, the
          -- farm loop does this check itself.
          if joinPos and not _G.RobinDungeonWaiting and v24 - joinTime < 20
            and lastScriptTime <= joinTime
            and (v20.Position - joinPos).Magnitude > 100 then
            _G.RobinStartDungeonWait(v20.Position)
            joinPos = nil
          end

          if _G.RobinDungeonWaiting then
            -- never hold for long: the countdown is ~30s
            local wp = _G.RobinDungeonWaitPos
            if v24 - (_G.RobinDungeonWaitStart or 0) > 45
              or (wp and (v20.Position - wp).Magnitude > 150) then
              _G.RobinDungeonWaiting = false
            end
          end

          -- ask to enter again only when we are not in the middle of a run or waiting to start
          if not _G.AutoDungeon.Moved and not _G.RobinDungeonWaiting
            and v24 - v19 >= _G.AutoDungeon.Interval then
            v19 = v24
            joinPos = v20.Position
            joinTime = v24
            _G.RobinDungeonJoinTime = v24
            f16()
          end

          task.wait(0.5)
        end
      else
        task.wait(0.5)
      end
    else
      v18 = 1
      _G.RobinDungeonWaiting = false
      joinPos = nil
      task.wait(0.3)
    end
  end
end)

local function f18(p13, p14)
  local raids = replicatedStorage:FindFirstChild("Remotes")
    and replicatedStorage.Remotes:FindFirstChild("Raids")

  if not raids then
    warn("[RobinHub] raid: ReplicatedStorage.Remotes.Raids not found")
    return false
  end

  if tick() - _G._sonLeaveZamani < (_G.AutoLeaveRaid.LeaveCooldown or 0) then
    return false
  end

  local function fire(name)
    local ok, err = pcall(function() raids[name]:FireServer(p13) end)

    if not ok then
      warn("[RobinHub] raid: Raids." .. name .. " failed: " .. tostring(err))
    end
  end

  if p14 == "wave1" then
    fire("Open")
  else
    fire("OpenMaxWave")
    task.wait(2)
    fire("StartRaid")
  end

  return true
end

-- true only if the gui object and all its parents are really visible on screen
local function guiShown(obj)
  local cur = obj

  while cur and cur ~= game do
    if cur:IsA("ScreenGui") then
      if cur.Enabled == false then
        return false
      end
    elseif cur:IsA("GuiObject") then
      if cur.Visible == false then
        return false
      end
    end

    cur = cur.Parent
  end

  return true
end

-- Raid enemies. Each running raid has its own folder under workspace.<RaidName>, and when
-- other players run raids too there are several. Only target the raid WE are in: lock onto
-- the raid whose enemies are closest to us and stay on it until it has no enemies left.
local lockedRaid = nil

local function raidEnemyFolder(inst)
  return inst:FindFirstChild("Enemy") or inst:FindFirstChild("Enemies")
end

local function raidEnemies(inst)
  local list = {}
  local folder = raidEnemyFolder(inst)

  if folder then
    for _, value12 in ipairs(folder:GetChildren()) do
      if value12:IsA("Model") then
        local hrp = value12:FindFirstChild("HumanoidRootPart")

        if hrp then
          table.insert(list, hrp)
        end
      end
    end
  end

  return list
end

local function f19()
  -- keep the raid we already locked on to
  if lockedRaid and lockedRaid.Parent then
    local list = raidEnemies(lockedRaid)

    if #list > 0 then
      return list
    end
  end

  lockedRaid = nil

  local myHrp = f6()
  local best, bestList, bestDist = nil, nil, math.huge

  for _, raidName in ipairs({ "LeafVillageRaid", "MundoRaid" }) do
    local root = workspace:FindFirstChild(raidName)

    if root then
      for _, inst in ipairs(root:GetChildren()) do
        local list = raidEnemies(inst)

        if #list > 0 then
          local dist = 0

          if myHrp then
            dist = math.huge

            for _, e in ipairs(list) do
              local d = (e.Position - myHrp.Position).Magnitude

              if d < dist then
                dist = d
              end
            end
          end

          if dist < bestDist then
            best, bestList, bestDist = inst, list, dist
          end
        end
      end
    end
  end

  lockedRaid = best
  return bestList or {}
end

task.spawn(function()
  local v26 = 1
  local lastOpen = 0
  local noEnemySince = nil
  local lastStatus = 0

  while true do
    if _G.AutoRaid.Enabled then
      local v27 = f6()

      if v27 then
        local v28 = f19()

        if #v28 > 0 then
          -- already inside a raid (enemies exist): no teleporting to enemies, just wait
          -- here so we don't re-open / re-join while the raid is running
          noEnemySince = nil
          v26 = 1
        else
          v26 = 1
          noEnemySince = noEnemySince or tick()

          -- Only open the raid when we are NOT already inside one (RaidHUD showing).
          -- Opening again while inside (or while joining someone else's raid) kicks you out
          -- and restarts it, which looked like "enter, leave, enter, leave".
          local pg = localPlayer:FindFirstChild("PlayerGui")
          local hud = pg and pg:FindFirstChild("RaidHUD")
          -- the HUD can stay in PlayerGui when you are NOT in a raid, so it only counts
          -- when its wave number is really visible and has a number in it
          local inRaid = false

          if hud then
            local th = hud:FindFirstChild("TopHolder")
            local wv = th and th:FindFirstChild("Wave")
            local am = wv and wv:FindFirstChild("Amount")

            if am and guiShown(am) and tostring(am.Text):match("%d") then
              inRaid = true
            end
          end

          local sinceOpen = tick() - lastOpen
          local idle = tick() - noEnemySince
          local canOpen

          -- Go back to the saved spot ONLY if the script took us into a raid and it is over
          -- (left via auto leave, or no enemies for a while). Never while just walking the map.
          if _G.RobinRaidMoved then
            local recentLeave = tick() - (_G._sonLeaveZamani or 0) < 20
            local need = recentLeave and 1.5 or (inRaid and 30 or 8)

            if idle >= need then
              _G.RobinRaidMoved = false
              returnToSaved()
            end
          end

          if _G.RobinRaidMoved then
            canOpen = false -- still in the middle of a raid
          elseif inRaid then
            -- inside a raid: never re-open, only as a last resort after a long dead time
            canOpen = idle >= 45 and sinceOpen >= 45
          else
            -- not in a raid: give the last open/join plenty of time to load
            canOpen = sinceOpen >= math.max(_G.AutoRaid.RestartDelay or 5, 15)
          end

          if not canOpen and tick() - lastStatus > 10 then
            lastStatus = tick()
            warn("[RobinHub] raid: waiting (inRaid=" .. tostring(inRaid) .. ", moved=" .. tostring(_G.RobinRaidMoved)
              .. ", sinceOpen=" .. math.floor(sinceOpen) .. "s, idle=" .. math.floor(idle) .. "s)")
          end

          if canOpen then
            warn("[RobinHub] raid: opening (inRaid=" .. tostring(inRaid) .. ", idle=" .. math.floor(idle) .. "s)")

            if f18(_G.AutoRaid.RaidType, _G.AutoRaid.StartMode) then
              lastOpen = tick()
            end
          end

          task.wait(1)
        end
      end

      task.wait(_G.AutoRaid.Speed)
    else
      v26 = 1
      noEnemySince = nil
      _G.RobinRaidMoved = false
      task.wait(0.3)
    end
  end
end)

local function f20()
  local remotes4 = replicatedStorage:FindFirstChild("Remotes")
  local leave

  if not remotes4 then
    return false
  else
    local raids2 = remotes4:FindFirstChild("Raids")

    if not raids2 then
      return false
    end

    leave = raids2:FindFirstChild("Leave")

    if not leave then
      return false
    end

    pcall(function() leave:FireServer() end)
    _G._sonLeaveZamani = tick()
    return true
  end
end

local v30 = {}

local function f21(p15)
  if not p15 or v30[p15] then
    return
  end

  v30[p15] = true

  task.spawn(function()
    local amount

    for i = 1, 50 do
      local topHolder = p15:FindFirstChild("TopHolder")

      if topHolder then
        local wave2 = topHolder:FindFirstChild("Wave")

        if wave2 then
          amount = wave2:FindFirstChild("Amount")

          if amount then
            break
          end
        end
      end

      task.wait(0.2)
    end

    local v31, v32

    if not amount then
      return
    else
      v31 = false
      v32 = 0

      local function f22()
        if not _G.AutoLeaveRaid.Enabled then
          return
        elseif not amount.Parent then
          return
        else
          local v33 = tonumber(amount.Text:match("^(%d+)"))

          if not v33 then
            return
          end

          if v33 < v32 then
            v31 = false
          end

          v32 = v33

          if v31 then
            return
          end

          if tick() - _G._sonLeaveZamani < (_G.AutoLeaveRaid.LeaveCooldown or 0) then
            return
          end

          if v33 >= _G.AutoLeaveRaid.TargetWave then
            f20()
            v31 = true
          end

          return
        end
      end

      f22()

      amount:GetPropertyChangedSignal("Text"):Connect(f22)
      return
    end
  end)
end

local v34 = false

task.spawn(function()
  local playerGui3 = localPlayer:WaitForChild("PlayerGui")
  local raidHUD = playerGui3:FindFirstChild("RaidHUD")

  if raidHUD then
    v34 = true
    f21(raidHUD)
  end

  playerGui3.ChildAdded:Connect(function(child)
    if child.Name == "RaidHUD" then
      task.wait(0.2)

      if _G.AutoLeaveRaid.AutoRearm or not v34 then
        v34 = true
        f21(child)
      end
    end
  end)
end)

-- ===== auto potion =====
-- Uses potions from your inventory with the game's own remote:
--   ReplicatedStorage.Remotes.Items.UseItem:FireServer(<item id>, <amount>)
-- UseAll = true : uses EVERY potion found in your inventory (new drops too)
-- UseAll = false: uses 1 of each potion in Potions every Interval seconds
do
  local KNOWN_POTION_IDS = {
    ["Coin Potion"] = "f53a05aa-baff-41d5-bb81-abc9cc493aa7",
    ["Damage Potion"] = "e7e5e928-407f-452b-bdc4-afa8cfc64b81",
    ["Drop Potion"] = "ec2f15be-3650-4869-9a09-eb4c27c1a70f",
    ["Energy Potion"] = "dffade9e-b5cc-4003-87e6-ec840b483638",
    ["Luck Potion"] = "485a37be-e999-451c-aab1-f5a9c070ca75",
  }

  _G.AutoPotion = {
    Enabled = false,
    UseAll = true,        -- use every potion in the inventory (including new ones)
    BatchSize = 10,       -- how many are used per call (set 1 if the game only accepts 1)
    CheckInterval = 5,    -- seconds between inventory checks
    Interval = 900,       -- UseAll = false only: seconds between uses (potions last 15 min)
    Intervals = {},       -- UseAll = false only: per-potion override, e.g. ["Luck Potion"] = 900
    Potions = { "Coin Potion", "Damage Potion", "Drop Potion", "Energy Potion", "Luck Potion" },
  }

  local function getUseItemRemote()
    local remotes = replicatedStorage:FindFirstChild("Remotes")
    local items = remotes and remotes:FindFirstChild("Items")
    return items and items:FindFirstChild("UseItem")
  end

  local function getPotionScroller()
    local node = localPlayer:FindFirstChild("PlayerGui")

    for _, name in ipairs({ "Main", "Frames", "Inventory", "Content", "Holder", "NormalContent", "Slots", "Scroller" }) do
      node = node and node:FindFirstChild(name)
    end

    return node
  end

  -- "x7" -> 7, "x1.5K" -> 1500
  local function parseAmount(text)
    local num, suffix = string.match(text, "^x([%d%.]+)([KkMm]?)$")
    local n = num and tonumber(num)

    if not n then
      return nil
    end

    if suffix == "K" or suffix == "k" then
      n = n * 1000
    elseif suffix == "M" or suffix == "m" then
      n = n * 1000000
    end

    return math.floor(n)
  end

  -- every potion slot in the inventory: { id, name, amount }
  local function readPotions(scroller)
    local list = {}

    for _, slot in ipairs(scroller:GetChildren()) do
      local name, amount

      for _, d in ipairs(slot:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
          local text = d.Text

          if text and text ~= "" then
            local n = parseAmount(text)

            if n then
              amount = n
            elseif string.find(string.lower(text), "potion", 1, true) then
              name = name or text
            end
          end
        end
      end

      if name then
        list[#list + 1] = { id = slot.Name, name = name, amount = amount or 1 }
      end
    end

    return list
  end

  -- use one named potion (qty defaults to 1)
  local function usePotion(name, qty)
    local remote = getUseItemRemote()

    if not remote then
      return false
    end

    local id, amount
    local scroller = getPotionScroller()

    if scroller then
      local wanted = string.lower(name)

      for _, p in ipairs(readPotions(scroller)) do
        if string.lower(p.name) == wanted then
          id, amount = p.id, p.amount
          break
        end
      end

      if not id or amount <= 0 then
        return false -- none in your inventory
      end
    else
      -- inventory UI isn't loaded: fall back to the last known id
      id = KNOWN_POTION_IDS[name]

      if not id then
        return false
      end
    end

    pcall(function() remote:FireServer(id, qty or 1) end)
    return true
  end

  -- test: _G.RobinUsePotion("Luck Potion")  or  _G.RobinUsePotion("Luck Potion", 3)
  _G.RobinUsePotion = usePotion

  -- UseAll mode: use everything that's in the inventory right now
  local drained = {}

  local function drainPotions()
    local remote = getUseItemRemote()
    local scroller = getPotionScroller()

    if not remote or not scroller then
      return
    end

    for _, p in ipairs(readPotions(scroller)) do
      local last = drained[p.id]

      -- skip if we just used this stack and the count hasn't gone down yet
      local waiting = last and p.amount >= last.amount and tick() - last.time < 30

      if p.amount > 0 and not waiting then
        drained[p.id] = { time = tick(), amount = p.amount }

        local remaining = p.amount
        local batch = math.max(1, math.floor(_G.AutoPotion.BatchSize or 1))

        while remaining > 0 and _G.AutoPotion.Enabled and _G.AutoPotion.UseAll do
          local n = math.min(remaining, batch)
          pcall(function() remote:FireServer(p.id, n) end)
          remaining = remaining - n
          task.wait(0.4)
        end
      end
    end
  end

  local lastUsed = {}

  task.spawn(function()
    while true do
      if _G.AutoPotion.Enabled then
        if _G.AutoPotion.UseAll then
          pcall(drainPotions)
        else
          for _, name in ipairs(_G.AutoPotion.Potions) do
            local interval = (_G.AutoPotion.Intervals and _G.AutoPotion.Intervals[name])
              or _G.AutoPotion.Interval

            if tick() - (lastUsed[name] or 0) >= interval then
              if usePotion(name) then
                lastUsed[name] = tick()
                task.wait(0.5)
              else
                -- couldn't use it (none left?): try again in 30 seconds
                lastUsed[name] = tick() - interval + 30
              end
            end
          end
        end

        task.wait(_G.AutoPotion.CheckInterval or 5)
      else
        task.wait(1)
      end
    end
  end)
end
-- ===== end auto potion =====

-- ===== auto save / load config =====
-- Settings are saved to  RobinHub/config.json  (in your executor's workspace folder)
-- and loaded again the next time you execute. Needs writefile / readfile / isfile.
--   _G.RobinSaveConfig()   save right now
--   _G.RobinResetConfig()  delete the saved file
do
  local httpService = game:GetService("HttpService")
  local FOLDER = "RobinHub"
  local FILE = FOLDER .. "/config.json"

  local canSave = type(writefile) == "function"
    and type(readfile) == "function"
    and type(isfile) == "function"

  local WORLDS = { "World1", "World2", "World3", "World4" }

  -- { table in _G, key, type, min / allowed values, max, whole number? }
  local FIELDS = {
    { "ShazeFarm", "Enabled", "boolean" },
    { "ShazeFarm", "CurrentWorld", "string", WORLDS },
    { "ShazeFarm", "Speed", "number", 0.05, 2 },

    { "AutoEquipPet", "Enabled", "boolean" },
    { "AutoEquipPet", "Interval", "number", 1, 60, true },

    { "AutoDungeon", "Enabled", "boolean" },
    { "AutoDungeon", "Interval", "number", 1, 30, true },
    { "AutoDungeon", "Speed", "number", 0.02, 0.5 },
    { "AutoDungeon", "LeaveEnabled", "boolean" },
    { "AutoDungeon", "TargetWave", "number", 0, 50, true },

    { "AutoRaid", "Enabled", "boolean" },
    { "AutoRaid", "RaidType", "string", { "LeafVillageRaid", "MundoRaid" } },
    { "AutoRaid", "StartMode", "string", { "wave1", "maxwave" } },
    { "AutoRaid", "Speed", "number", 0.02, 0.5 },

    { "AutoLeaveRaid", "Enabled", "boolean" },
    { "AutoLeaveRaid", "TargetWave", "number", 1, 1000, true },
    { "AutoLeaveRaid", "AutoRearm", "boolean" },
    { "AutoLeaveRaid", "LeaveCooldown", "number", 1, 30, true },

    { "AntiAFK", "Enabled", "boolean" },
    { "AntiAFK", "Interval", "number", 10, 300, true },

    { "AutoPotion", "Enabled", "boolean" },
    { "AutoPotion", "UseAll", "boolean" },
  }

  local function snapshot()
    local data = {}

    for _, f in ipairs(FIELDS) do
      local group = _G[f[1]]

      if group and group[f[2]] ~= nil then
        data[f[1]] = data[f[1]] or {}
        data[f[1]][f[2]] = group[f[2]]
      end
    end

    -- selected mobs: only the ones that are ticked
    local mobs = {}

    for world, list in pairs(_G.ShazeFarm.SelectedMobs) do
      for mobName, on in pairs(list) do
        if on then
          mobs[world] = mobs[world] or {}
          mobs[world][mobName] = true
        end
      end
    end

    data.ShazeFarm = data.ShazeFarm or {}
    data.ShazeFarm.SelectedMobs = mobs

    return data
  end

  -- stable text version of the data, used to detect changes
  local function signature(v)
    if type(v) ~= "table" then
      return tostring(v)
    end

    local keys = {}

    for k in pairs(v) do
      keys[#keys + 1] = tostring(k)
    end

    table.sort(keys)

    local out = {}

    for _, k in ipairs(keys) do
      out[#out + 1] = k .. "=" .. signature(v[k])
    end

    return "{" .. table.concat(out, ",") .. "}"
  end

  local lastSignature = nil

  local function loadConfig()
    if not canSave or not isfile(FILE) then
      return
    end

    local ok, data = pcall(function()
      return httpService:JSONDecode(readfile(FILE))
    end)

    if not ok or type(data) ~= "table" then
      return
    end

    for _, f in ipairs(FIELDS) do
      local group = type(data[f[1]]) == "table" and data[f[1]] or nil
      local value = group and group[f[2]]

      if value ~= nil and type(value) == f[3] and _G[f[1]] then
        local valid = true

        if f[3] == "number" then
          value = math.clamp(value, f[4], f[5])

          if f[6] then
            value = math.floor(value)
          end
        elseif f[3] == "string" and type(f[4]) == "table" then
          valid = table.find(f[4], value) ~= nil
        end

        if valid then
          _G[f[1]][f[2]] = value
        end
      end
    end

    -- selected mobs (only names that really exist in the game's lists)
    local savedFarm = type(data.ShazeFarm) == "table" and data.ShazeFarm or nil
    local savedMobs = savedFarm and savedFarm.SelectedMobs

    if type(savedMobs) == "table" then
      for world, list in pairs(savedMobs) do
        if v3[world] and type(list) == "table" then
          local chosen = {}

          for mobName, on in pairs(list) do
            if on == true and table.find(v3[world], mobName) then
              chosen[mobName] = true
            end
          end

          _G.ShazeFarm.SelectedMobs[world] = chosen
        end
      end
    end

    -- farm only stays on if its world and mobs are valid
    local world = _G.ShazeFarm.CurrentWorld
    local chosen = _G.ShazeFarm.SelectedMobs[world]

    if _G.ShazeFarm.Enabled and not (v3[world] and chosen and next(chosen) ~= nil) then
      _G.ShazeFarm.Enabled = false
      _G.ShazeFarm.CurrentWorld = ""
    end

    lastSignature = signature(snapshot())
  end

  local function saveConfig(force)
    if not canSave then
      return false
    end

    local data = snapshot()
    local sig = signature(data)

    if sig == lastSignature and not force then
      return true
    end

    local ok = pcall(function()
      if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(FOLDER) then
        makefolder(FOLDER)
      end

      writefile(FILE, httpService:JSONEncode(data))
    end)

    if ok then
      lastSignature = sig
    end

    return ok
  end

  _G.RobinSaveConfig = function()
    return saveConfig(true)
  end

  _G.RobinResetConfig = function()
    if canSave and type(delfile) == "function" and isfile(FILE) then
      pcall(delfile, FILE)
      lastSignature = signature(snapshot())
      warn("[RobinHub] saved config deleted. Run the script again to start fresh.")
    end
  end

  if not canSave then
    warn("[RobinHub] your executor has no writefile/readfile, so settings can't be saved.")
  else
    loadConfig()

    -- raid / dungeon remember where you stood, so do that again if they were left on
    task.spawn(function()
      for _ = 1, 40 do
        if f6() then
          break
        end

        task.wait(0.5)
      end

      if _G.AutoRaid.Enabled or _G.AutoDungeon.Enabled then
        f7()
      end
    end)

    -- auto save: checks every 2 seconds and writes the file only if something changed
    task.spawn(function()
      while true do
        task.wait(2)
        pcall(saveConfig)
      end
    end)
  end
end
-- ===== end auto save / load config =====

local v35 = f1("ScreenGui", {
  Name = "RobinHub",
  ResetOnSpawn = false,
  IgnoreGuiInset = true,
  ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
  Parent = playerGui,
})

local v36 = f1("Frame", {
  Name = "Main",
  Size = UDim2.fromOffset(520, 620),
  Position = UDim2.new(0.5, -260, 0.5, -310),
  BackgroundColor3 = v2.bg,
  BorderSizePixel = 0,
  Active = true,
  Parent = v35,
})

f3(v36, v2.border, 1)

local v37 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 28),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Parent = v36,
})

f1("Frame", {
  Size = UDim2.new(1, 0, 0, 1),
  Position = UDim2.new(0, 0, 1, -1),
  BackgroundColor3 = v2.border,
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Parent = v37,
})

local parent5 = f1("Frame", {
  Size = UDim2.new(0, 200, 1, 0),
  Position = UDim2.new(0, 14, 0, 0),
  BackgroundTransparency = 1,
  Parent = v37,
})

local v38 = f1("Frame", {
  Size = UDim2.fromOffset(7, 7),
  Position = UDim2.new(0, 0, 0.5, -3),
  BackgroundColor3 = v2.accent,
  BorderSizePixel = 0,
  Parent = parent5,
})

f2(v38, 4)

task.spawn(function()
  while v38.Parent do
    tweenService:Create(v38, TweenInfo.new(0.8), { BackgroundTransparency = 0.6 }):Play()
    task.wait(0.8)
    tweenService:Create(v38, TweenInfo.new(0.8), { BackgroundTransparency = 0 }):Play()
    task.wait(0.8)
  end
end)

f1("TextLabel", {
  Size = UDim2.new(0, 100, 1, 0),
  Position = UDim2.new(0, 16, 0, 0),
  BackgroundTransparency = 1,
  Text = "ROBIN",
  Font = gothamBold,
  TextSize = 15,
  TextColor3 = v2.white,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent5,
})

f1("TextLabel", {
  Size = UDim2.new(0, 70, 1, 0),
  Position = UDim2.new(0, 68, 0, 0),
  BackgroundTransparency = 1,
  Text = " HUB",
  Font = gothamBold,
  TextSize = 15,
  TextColor3 = v2.accent,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent5,
})

local parent6 = f1("Frame", {
  Size = UDim2.new(0, 50, 1, 0),
  Position = UDim2.new(1, -62, 0, 0),
  BackgroundTransparency = 1,
  Parent = v37,
})

local function f23(text, p16, p17, p18)
  local v39 = f1("TextButton", {
    Size = UDim2.fromOffset(20, 20),
    Position = UDim2.new(0, p16, 0.5, -10),
    BackgroundColor3 = v2.bg,
    BorderSizePixel = 0,
    Text = text,
    Font = gothamBold,
    TextSize = 14,
    TextColor3 = v2.textDim,
    AutoButtonColor = false,
    Parent = parent6,
  })

  f3(v39, v2.border, 1)

  v39.MouseEnter:Connect(function()
    v39.TextColor3 = p17
    v39.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
    v39.UIStroke.Color = p17
  end)

  v39.MouseLeave:Connect(function()
    v39.TextColor3 = v2.textDim
    v39.BackgroundColor3 = v2.bg
    v39.UIStroke.Color = v2.border
  end)

  v39.MouseButton1Click:Connect(p18)

  return v39
end

local v40 = f23("-", 0, v2.accent, function() end)
local v41 = f23("x", 26, v2.accent, function() end)

local parent7 = f1("Frame", {
  Size = UDim2.new(1, -12, 1, -34),
  Position = UDim2.new(0, 6, 0, 28),
  BackgroundTransparency = 1,
  Parent = v36,
})

local parent8 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 26),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Parent = parent7,
})

f1("Frame", {
  Size = UDim2.new(0, 1, 1, 0),
  Position = UDim2.new(1, -1, 0, 0),
  BackgroundColor3 = v2.border,
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Parent = parent8,
})

local v42 = f1("Frame", {
  Size = UDim2.new(1, 0, 1, 0),
  BackgroundTransparency = 1,
  Parent = parent8,
})

f1("UIListLayout", {
  Padding = UDim.new(0, 2),
  FillDirection = Enum.FillDirection.Horizontal,
  SortOrder = Enum.SortOrder.LayoutOrder,
  Parent = v42,
})

f1("UIPadding", { PaddingLeft = UDim.new(0, 2), Parent = v42 })

local parent9 = f1("Frame", {
  Size = UDim2.new(1, 0, 1, -26),
  Position = UDim2.new(0, 0, 0, 26),
  BackgroundColor3 = Color3.fromRGB(22, 22, 22),
  BorderSizePixel = 0,
  Parent = parent7,
})

f3(parent9, v2.border, 1)

local function f24(parent10, p19, p20, p21, p22, p23)
  local text2 = p23
  text2 = p23 or "Speed:"
  p20 = math.clamp(p19.Speed or p20, p21, p22)

  local v43 = f1("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = v2.panel,
    BorderSizePixel = 0,
    Parent = parent10,
  })

  f2(v43, 4)
  f3(v43, v2.border, 1)
  f4(v43, 8)

  f1("TextLabel", {
    Size = UDim2.fromOffset(90, 24),
    Position = UDim2.new(0, 0, 0.5, -12),
    BackgroundTransparency = 1,
    Text = text2,
    Font = gothamBold,
    TextSize = 12,
    TextColor3 = v2.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = v43,
  })

  local v44 = (p20 - p21) / (p22 - p21)

  local v45 = f1("Frame", {
    Size = UDim2.new(1, -160, 0, 4),
    Position = UDim2.new(0, 90, 0.5, -2),
    BackgroundColor3 = v2.border,
    BorderSizePixel = 0,
    Parent = v43,
  })

  local v46 = f1("Frame", {
    Size = UDim2.new(v44, 0, 1, 0),
    BackgroundColor3 = v2.accent,
    BorderSizePixel = 0,
    Parent = v45,
  })

  local v47 = f1("Frame", {
    Size = UDim2.fromOffset(12, 12),
    Position = UDim2.new(v44, -6, 0.5, -6),
    BackgroundColor3 = v2.accent,
    BorderSizePixel = 0,
    Parent = v45,
  })

  local v48 = f1("TextLabel", {
    Size = UDim2.fromOffset(60, 24),
    Position = UDim2.new(1, -60, 0.5, -12),
    BackgroundTransparency = 1,
    Text = string.format("%.2fs", p20),
    Font = gothamBold,
    TextSize = 12,
    TextColor3 = v2.accent,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = v43,
  })

  local v49 = false

  local function f25(p24)
    local v50 = math.clamp((p24 - v45.AbsolutePosition.X) / v45.AbsoluteSize.X, 0, 1)
    v46.Size = UDim2.new(v50, 0, 1, 0)
    v47.Position = UDim2.new(v50, -6, 0.5, -6)
    local v51 = p21 + v50 * (p22 - p21)
    p19.Speed = v51
    v48.Text = string.format("%.2fs", v51)
  end

  v45.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      v49 = true
      f25(input.Position.X)
    end
  end)

  userInputService.InputChanged:Connect(function(input2)
    if v49
      and (input2.UserInputType == Enum.UserInputType.MouseMovement
        or input2.UserInputType == Enum.UserInputType.Touch) then
      f25(input2.Position.X)
    end
  end)

  userInputService.InputEnded:Connect(function(input3)
    if input3.UserInputType == Enum.UserInputType.MouseButton1
      or input3.UserInputType == Enum.UserInputType.Touch then
      v49 = false
    end
  end)

  return v43
end

local function f26(parent11, p25, p26, p27, p28)
  p26 = math.clamp(p25.Interval or p26, p27, p28)
  local parent12 = f1("Frame", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    Parent = parent11,
  })

  f1("TextLabel", {
    Size = UDim2.fromOffset(90, 24),
    BackgroundTransparency = 1,
    Text = "Interval:",
    Font = gothamMedium,
    TextSize = 11,
    TextColor3 = v2.textMute,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = parent12,
  })

  local v52 = f1("Frame", {
    Size = UDim2.new(1, -160, 0, 4),
    Position = UDim2.new(0, 90, 0.5, -2),
    BackgroundColor3 = v2.border,
    BorderSizePixel = 0,
    Parent = parent12,
  })

  local v53 = (p26 - p27) / (p28 - p27)

  local v54 = f1("Frame", {
    Size = UDim2.new(v53, 0, 1, 0),
    BackgroundColor3 = v2.accent,
    BorderSizePixel = 0,
    Parent = v52,
  })

  local v55 = f1("Frame", {
    Size = UDim2.fromOffset(12, 12),
    Position = UDim2.new(v53, -6, 0.5, -6),
    BackgroundColor3 = v2.accent,
    BorderSizePixel = 0,
    Parent = v52,
  })

  local v56 = f1("TextLabel", {
    Size = UDim2.fromOffset(60, 24),
    Position = UDim2.new(1, -60, 0, 0),
    BackgroundTransparency = 1,
    Text = p26 .. "s",
    Font = gothamBold,
    TextSize = 11,
    TextColor3 = v2.accent,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = parent12,
  })

  local v57 = false

  local function f27(p29)
    local v58 = math.clamp((p29 - v52.AbsolutePosition.X) / v52.AbsoluteSize.X, 0, 1)
    v54.Size = UDim2.new(v58, 0, 1, 0)
    v55.Position = UDim2.new(v58, -6, 0.5, -6)
    local v59 = math.floor(p27 + v58 * (p28 - p27))
    p25.Interval = v59
    v56.Text = v59 .. "s"
  end

  v52.InputBegan:Connect(function(input4)
    if input4.UserInputType == Enum.UserInputType.MouseButton1
      or input4.UserInputType == Enum.UserInputType.Touch then
      v57 = true
      f27(input4.Position.X)
    end
  end)

  userInputService.InputChanged:Connect(function(input5)
    if v57
      and (input5.UserInputType == Enum.UserInputType.MouseMovement
        or input5.UserInputType == Enum.UserInputType.Touch) then
      f27(input5.Position.X)
    end
  end)

  userInputService.InputEnded:Connect(function(input6)
    if input6.UserInputType == Enum.UserInputType.MouseButton1
      or input6.UserInputType == Enum.UserInputType.Touch then
      v57 = false
    end
  end)
end

local v60 = {}

local function f28(parent13, p30, p31)
  local v61 = p30 or false

  local v62 = f1("TextButton", {
    Size = UDim2.fromOffset(16, 16),
    Position = UDim2.new(1, -16, 0.5, -8),
    BackgroundColor3 = v61 and v2.accent or Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Parent = parent13,
  })

  f3(v62, v61 and v2.accent or v2.border, 1)

  local v63 = f1("Frame", {
    Visible = false,
    Size = UDim2.fromOffset(14, 14),
    Position = v61 and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
    BackgroundColor3 = v61 and v2.accent or Color3.fromRGB(51, 51, 51),
    BorderSizePixel = 0,
    Parent = v62,
  })

  local function f29(p32)
    v61 = p32
    v62.BackgroundColor3 = v61 and v2.accent or Color3.fromRGB(20, 20, 20)

    v63.Position = v61 and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    v63.BackgroundColor3 = v61 and v2.accent or Color3.fromRGB(51, 51, 51)

    local uiStroke = v62.UIStroke
    uiStroke.Color = v61 and v2.accent or v2.border

    if p31 then
      p31(v61)
    end
  end

  v62.MouseButton1Click:Connect(function() f29(not v61) end)
  return v62, function() return v61 end, f29
end

local v64 = {}
local v65

local function f30(p33, p34)
  local v66 = f1("TextButton", {
    Size = UDim2.new(0, 86, 1, 0),
    BackgroundColor3 = v2.bg,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Parent = v42,
  })

  local v67 = f1("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = v2.border,
    BorderSizePixel = 0,
    Parent = v66,
  })

  local v68 = f1("Frame", {
    Visible = false,
    Size = UDim2.fromOffset(5, 5),
    Position = UDim2.new(0, 16, 0.5, -2),
    BackgroundColor3 = v2.border,
    BorderSizePixel = 0,
    Parent = v66,
  })

  f2(v68, 3)

  local v69 = f1("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = p34,
    Font = gothamBold,
    TextSize = 11,
    TextColor3 = v2.textMute,
    TextXAlignment = Enum.TextXAlignment.Center,
    Parent = v66,
  })

  local v70 = f1("ScrollingFrame", {
    Name = p33 .. "Page",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = v2.border,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Visible = false,
    Parent = parent9,
  })

  f4(v70, 14)

  f1("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = v70,
  })

  v60[p33] = v70

  table.insert(v64, {
    name = p33,
    tab = v66,
    line = v67,
    dot = v68,
    label = v69,
    page = v70,
  })

  v66.MouseEnter:Connect(function()
    if v65 ~= p33 then
      v69.TextColor3 = Color3.fromRGB(160, 160, 160)
      v66.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    end
  end)

  v66.MouseLeave:Connect(function()
    if v65 ~= p33 then
      v69.TextColor3 = v2.textMute
      v66.BackgroundColor3 = v2.bg
    end
  end)

  v66.MouseButton1Click:Connect(function()
    for index11, value13 in ipairs(v64) do
      value13.label.TextColor3 = v2.textMute
      value13.tab.BackgroundColor3 = v2.bg
      value13.line.BackgroundColor3 = v2.border
      value13.dot.BackgroundColor3 = v2.border
      value13.page.Visible = false
    end

    v69.TextColor3 = v2.white
    v66.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    v67.BackgroundColor3 = v2.accent
    v68.BackgroundColor3 = v2.accent
    v70.Visible = true
    v65 = p33
  end)

  return v70
end

local function f31(parent14, p35, p36)
  local v71 = f1("TextButton", {
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Text = "  " .. p35,
    Font = gothamBold,
    TextSize = 12,
    TextColor3 = v2.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    AutoButtonColor = false,
    Parent = parent14,
  })

  local v72 = f3(v71, Color3.fromRGB(20, 20, 20), 1)
  f4(v71, 6)

  if _G.ShazeFarm.SelectedMobs[p36] and _G.ShazeFarm.SelectedMobs[p36][p35] then
    v71.BackgroundColor3 = v2.accentDim
    v71.TextColor3 = v2.white
    v72.Color = v2.accent
  end

  v71.MouseEnter:Connect(function()
    if not _G.ShazeFarm.SelectedMobs[p36][p35] then
      v71.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
      v71.TextColor3 = v2.white
    end
  end)

  v71.MouseLeave:Connect(function()
    if not _G.ShazeFarm.SelectedMobs[p36][p35] then
      v71.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
      v71.TextColor3 = v2.text
    end
  end)

  v71.MouseButton1Click:Connect(function()
    local v73 = _G.ShazeFarm.SelectedMobs[p36]

    if v73[p35] then
      v73[p35] = nil

      v71.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
      v71.TextColor3 = v2.text

      v72.Color = Color3.fromRGB(20, 20, 20)
    else
      v73[p35] = true

      v71.BackgroundColor3 = v2.accentDim
      v71.TextColor3 = v2.white

      v72.Color = v2.accent
    end
  end)

  return v71
end

local worldOff = {} -- resets the switch of each world card

local function f32(parent15, p37)
  if not _G.ShazeFarm.SelectedMobs[p37] then
    _G.ShazeFarm.SelectedMobs[p37] = {}
  end

  local v74 = f1("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
    BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = parent15,
  })

  f2(v74, 6)
  f3(v74, v2.border, 1)

  f1("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = v74,
  })

  f4(v74, 10)

  local parent16 = f1("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Parent = v74,
  })

  f1("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0),
    BackgroundTransparency = 1,
    Text = p37 .. "  Auto Farm",
    Font = gothamBold,
    TextSize = 13,
    TextColor3 = v2.white,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = parent16,
  })

  local v75 = f1("TextButton", {
    Size = UDim2.fromOffset(16, 16),
    Position = UDim2.new(1, -16, 0.5, -8),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Parent = parent16,
  })

  f3(v75, v2.border, 1)

  local v76 = f1("Frame", {
    Visible = false,
    Size = UDim2.fromOffset(14, 14),
    Position = UDim2.new(0, 2, 0.5, -7),
    BackgroundColor3 = Color3.fromRGB(51, 51, 51),
    BorderSizePixel = 0,
    Parent = v75,
  })

  if _G.ShazeFarm.Enabled and _G.ShazeFarm.CurrentWorld == p37 then
    v75.BackgroundColor3 = v2.accent
    v76.Position = UDim2.new(1, -16, 0.5, -7)
    v76.BackgroundColor3 = v2.accent
    v75.UIStroke.Color = v2.accent
  end

  local v77 = f1("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 30 * #v3[p37] + 8),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = v74,
  })

  f2(v77, 4)
  f3(v77, v2.border, 1)
  f4(v77, 4)

  f1("UIListLayout", {
    Padding = UDim.new(0, 2),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = v77,
  })

  for index12, value14 in ipairs(v3[p37]) do
    f31(v77, value14, p37)
  end

  f24(v74, _G.ShazeFarm, 0.1, 0.05, 2, "Speed:")

  worldOff[p37] = function()
    v75.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    v76.Position = UDim2.new(0, 2, 0.5, -7)
    v76.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
    v75.UIStroke.Color = v2.border
  end

  v75.MouseButton1Click:Connect(function()
    if _G.ShazeFarm.Enabled and _G.ShazeFarm.CurrentWorld == p37 then
      _G.ShazeFarm.Enabled = false
      _G.ShazeFarm.CurrentWorld = ""

      v75.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

      v76.Position = UDim2.new(0, 2, 0.5, -7)
      v76.BackgroundColor3 = Color3.fromRGB(51, 51, 51)

      v75.UIStroke.Color = v2.border
      return
    else
      local count = 0

      for key3, value15 in pairs(_G.ShazeFarm.SelectedMobs[p37]) do
        if value15 then
          count = count + 1
        end
      end

      if count == 0 then
        return
      end

      _G.ShazeFarm.Enabled = true
      _G.ShazeFarm.CurrentWorld = p37

      for otherWorld, resetSwitch in pairs(worldOff) do
        if otherWorld ~= p37 then
          resetSwitch()
        end
      end

      v75.BackgroundColor3 = v2.accent

      v76.Position = UDim2.new(1, -16, 0.5, -7)
      v76.BackgroundColor3 = v2.accent

      v75.UIStroke.Color = v2.accent
      return
    end
  end)

  return v74
end

local v78 = f30("farm", "Farm")
local parent17 = f30("raid", "Raid")
local parent18 = f30("auto", "Auto")
v65 = "farm"

local v79 = v64[1]
v79.label.TextColor3 = v2.white
v79.tab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
v79.line.BackgroundColor3 = v2.accent
v79.dot.BackgroundColor3 = v2.accent
v79.page.Visible = true

for index13, value16 in ipairs({ "World1", "World2", "World3", "World4" }) do
  f32(v78, value16)
end

f1("TextLabel", {
  Size = UDim2.new(1, 0, 0, 22),
  BackgroundTransparency = 1,
  Text = "RAID WORLD",
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.textDim,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent17,
})

local v80 = _G.AutoRaid.RaidType or "LeafVillageRaid"
local v81 = {}

local function f33()
  for key4, value17 in pairs(v81) do
    if key4 == v80 then
      value17.tik.Visible = true
      value17.box.BackgroundColor3 = v2.accentDim
      value17.box.UIStroke.Color = v2.accent
      value17.row.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
      value17.txt.TextColor3 = v2.accent
    else
      value17.tik.Visible = false
      value17.box.BackgroundColor3 = v2.bg
      value17.box.UIStroke.Color = v2.border
      value17.row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
      value17.txt.TextColor3 = v2.text
    end
  end
end

for index14, value18 in ipairs({ "LeafVillageRaid", "MundoRaid" }) do
  local v82 = value18

  local v83 = f1("TextButton", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Parent = parent17,
  })

  f2(v83, 4)
  f3(v83, v2.border, 1)

  local v84 = f1("Frame", {
    Size = UDim2.fromOffset(14, 14),
    Position = UDim2.new(0, 12, 0.5, -7),
    BackgroundColor3 = v2.bg,
    BorderSizePixel = 0,
    Parent = v83,
  })

  f3(v84, v2.border, 1)

  v81[v82] = {
    row = v83,
    box = v84,
    tik = f1("TextLabel", {
      Size = UDim2.fromOffset(14, 14),
      Position = UDim2.new(0, 0, 0, -3),
      BackgroundTransparency = 1,
      Text = "âœ“",
      Font = gothamBold,
      TextSize = 12,
      TextColor3 = v2.accent,
      Visible = false,
      Parent = v84,
    }),
    txt = f1("TextLabel", {
      Size = UDim2.new(1, -50, 1, 0),
      Position = UDim2.new(0, 34, 0, 0),
      BackgroundTransparency = 1,
      Text = v82,
      Font = gothamMedium,
      TextSize = 12,
      TextColor3 = v2.text,
      TextXAlignment = Enum.TextXAlignment.Left,
      Parent = v83,
    }),
  }

  v83.MouseButton1Click:Connect(function()
    v80 = v82
    _G.AutoRaid.RaidType = v82
    f33()
  end)
end

f33()

f1("TextLabel", {
  Size = UDim2.new(1, 0, 0, 22),
  BackgroundTransparency = 1,
  Text = "START MODE",
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.textDim,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent17,
})

local id = _G.AutoRaid.StartMode or "wave1"
local v85 = {}

local function f34()
  for key5, value19 in pairs(v85) do
    if key5 == id then
      value19.tik.Visible = true
      value19.box.BackgroundColor3 = v2.accentDim
      value19.box.UIStroke.Color = v2.accent
      value19.row.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
      value19.txt.TextColor3 = v2.accent
    else
      value19.tik.Visible = false
      value19.box.BackgroundColor3 = v2.bg
      value19.box.UIStroke.Color = v2.border
      value19.row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
      value19.txt.TextColor3 = v2.text
    end
  end
end

for index15, value20 in ipairs({
  { id = "wave1", text = "Create New" }, { id = "maxwave", text = "Max Wave" },
}) do
  local v86 = value20

  local v87 = f1("TextButton", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Parent = parent17,
  })

  f2(v87, 4)
  f3(v87, v2.border, 1)

  local v88 = f1("Frame", {
    Size = UDim2.fromOffset(14, 14),
    Position = UDim2.new(0, 12, 0.5, -7),
    BackgroundColor3 = v2.bg,
    BorderSizePixel = 0,
    Parent = v87,
  })

  f3(v88, v2.border, 1)

  local tik = f1("TextLabel", {
    Size = UDim2.fromOffset(14, 14),
    Position = UDim2.new(0, 0, 0, -3),
    BackgroundTransparency = 1,
    Text = "âœ“",
    Font = gothamBold,
    TextSize = 12,
    TextColor3 = v2.accent,
    Visible = false,
    Parent = v88,
  })

  local txt = f1("TextLabel", {
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 34, 0, 0),
    BackgroundTransparency = 1,
    Text = v86.text,
    Font = gothamMedium,
    TextSize = 12,
    TextColor3 = v2.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = v87,
  })

  v85[v86.id] = {
    row = v87,
    box = v88,
    tik = tik,
    txt = txt,
  }

  v87.MouseButton1Click:Connect(function()
    id = v86.id
    _G.AutoRaid.StartMode = v86.id
    f34()
  end)
end

f34()

local v89 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 0),
  BackgroundColor3 = Color3.fromRGB(28, 28, 28),
  BorderSizePixel = 0,
  AutomaticSize = Enum.AutomaticSize.Y,
  Parent = parent17,
})

f2(v89, 6)
f3(v89, v2.border, 1)

f1("UIListLayout", {
  Padding = UDim.new(0, 8),
  SortOrder = Enum.SortOrder.LayoutOrder,
  Parent = v89,
})

f4(v89, 12)

local parent19 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 30),
  BackgroundTransparency = 1,
  Parent = v89,
})

f1("TextLabel", {
  Size = UDim2.new(1, -80, 1, 0),
  BackgroundTransparency = 1,
  Text = "Auto Join Raid",
  Font = gothamBold,
  TextSize = 13,
  TextColor3 = v2.white,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent19,
})

f28(f1("Frame", {
  Size = UDim2.new(0, 50, 1, 0),
  Position = UDim2.new(1, -50, 0, 0),
  BackgroundTransparency = 1,
  Parent = parent19,
}), _G.AutoRaid.Enabled == true, function(p38)
  _G.AutoRaid.Enabled = p38

  if p38 then
    f7()
  end
end)

f24(v89, _G.AutoRaid, 0.05, 0.02, 0.5, "Check Speed:")

f1("TextLabel", {
  Size = UDim2.new(1, 0, 0, 22),
  BackgroundTransparency = 1,
  Text = "AUTO LEAVE RAID",
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.textDim,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent17,
})

local v90 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 0),
  BackgroundColor3 = Color3.fromRGB(28, 28, 28),
  BorderSizePixel = 0,
  AutomaticSize = Enum.AutomaticSize.Y,
  Parent = parent17,
})

f2(v90, 6)
f3(v90, v2.border, 1)

f1("UIListLayout", {
  Padding = UDim.new(0, 8),
  SortOrder = Enum.SortOrder.LayoutOrder,
  Parent = v90,
})

f4(v90, 12)

local parent20 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 30),
  BackgroundTransparency = 1,
  Parent = v90,
})

f1("TextLabel", {
  Size = UDim2.new(1, -80, 1, 0),
  BackgroundTransparency = 1,
  Text = "Auto Leave at Wave",
  Font = gothamBold,
  TextSize = 13,
  TextColor3 = v2.white,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent20,
})

f28(f1("Frame", {
  Size = UDim2.new(0, 50, 1, 0),
  Position = UDim2.new(1, -50, 0, 0),
  BackgroundTransparency = 1,
  Parent = parent20,
}), _G.AutoLeaveRaid.Enabled == true, function(enabled) _G.AutoLeaveRaid.Enabled = enabled end)

local parent21 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 30),
  BackgroundTransparency = 1,
  Parent = v90,
})

f1("TextLabel", {
  Size = UDim2.new(1, -80, 1, 0),
  BackgroundTransparency = 1,
  Text = "Auto Re-arm (must use for auto leave)",
  Font = gothamBold,
  TextSize = 12,
  TextColor3 = v2.textMute,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent21,
})

f28(f1("Frame", {
  Size = UDim2.new(0, 50, 1, 0),
  Position = UDim2.new(1, -50, 0, 0),
  BackgroundTransparency = 1,
  Parent = parent21,
}), _G.AutoLeaveRaid.AutoRearm ~= false, function(autoRearm) _G.AutoLeaveRaid.AutoRearm = autoRearm end)

local parent22 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 24),
  BackgroundTransparency = 1,
  Parent = v90,
})

f1("TextLabel", {
  Size = UDim2.fromOffset(90, 24),
  BackgroundTransparency = 1,
  Text = "Target Wave:",
  Font = gothamMedium,
  TextSize = 11,
  TextColor3 = v2.textMute,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent22,
})

local v91 = f1("Frame", {
  Size = UDim2.new(1, -160, 0, 4),
  Position = UDim2.new(0, 90, 0.5, -2),
  BackgroundColor3 = v2.border,
  BorderSizePixel = 0,
  Parent = parent22,
})

local v92 = (_G.AutoLeaveRaid.TargetWave - 1) / 999

local v93 = f1("Frame", {
  Size = UDim2.new(v92, 0, 1, 0),
  BackgroundColor3 = v2.accent,
  BorderSizePixel = 0,
  Parent = v91,
})

local v94 = f1("Frame", {
  Size = UDim2.fromOffset(12, 12),
  Position = UDim2.new(v92, -6, 0.5, -6),
  BackgroundColor3 = v2.accent,
  BorderSizePixel = 0,
  Parent = v91,
})

local v95 = f1("TextLabel", {
  Size = UDim2.fromOffset(60, 24),
  Position = UDim2.new(1, -60, 0, 0),
  BackgroundTransparency = 1,
  Text = tostring(_G.AutoLeaveRaid.TargetWave),
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.accent,
  TextXAlignment = Enum.TextXAlignment.Right,
  Parent = parent22,
})

local v96 = false

local function f35(p39)
  local v97 = math.clamp((p39 - v91.AbsolutePosition.X) / v91.AbsoluteSize.X, 0, 1)
  v93.Size = UDim2.new(v97, 0, 1, 0)
  v94.Position = UDim2.new(v97, -6, 0.5, -6)
  local v98 = math.floor(1 + v97 * 999)
  _G.AutoLeaveRaid.TargetWave = v98
  v95.Text = tostring(v98)
end

v91.InputBegan:Connect(function(input7)
  if input7.UserInputType == Enum.UserInputType.MouseButton1
    or input7.UserInputType == Enum.UserInputType.Touch then
    v96 = true
    f35(input7.Position.X)
  end
end)

userInputService.InputChanged:Connect(function(input8)
  if v96
    and (input8.UserInputType == Enum.UserInputType.MouseMovement
      or input8.UserInputType == Enum.UserInputType.Touch) then
    f35(input8.Position.X)
  end
end)

userInputService.InputEnded:Connect(function(input9)
  if input9.UserInputType == Enum.UserInputType.MouseButton1
    or input9.UserInputType == Enum.UserInputType.Touch then
    v96 = false
  end
end)

local parent23 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 24),
  BackgroundTransparency = 1,
  Parent = v90,
})

f1("TextLabel", {
  Size = UDim2.fromOffset(90, 24),
  BackgroundTransparency = 1,
  Text = "Leave Cooldown:",
  Font = gothamMedium,
  TextSize = 11,
  TextColor3 = v2.textMute,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent23,
})

local v99 = f1("Frame", {
  Size = UDim2.new(1, -160, 0, 4),
  Position = UDim2.new(0, 90, 0.5, -2),
  BackgroundColor3 = v2.border,
  BorderSizePixel = 0,
  Parent = parent23,
})

local v100 = (_G.AutoLeaveRaid.LeaveCooldown - 1) / 29

local v101 = f1("Frame", {
  Size = UDim2.new(v100, 0, 1, 0),
  BackgroundColor3 = v2.accent,
  BorderSizePixel = 0,
  Parent = v99,
})

local v102 = f1("Frame", {
  Size = UDim2.fromOffset(12, 12),
  Position = UDim2.new(v100, -6, 0.5, -6),
  BackgroundColor3 = v2.accent,
  BorderSizePixel = 0,
  Parent = v99,
})

local v103 = f1("TextLabel", {
  Size = UDim2.fromOffset(60, 24),
  Position = UDim2.new(1, -60, 0, 0),
  BackgroundTransparency = 1,
  Text = _G.AutoLeaveRaid.LeaveCooldown .. "s",
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.accent,
  TextXAlignment = Enum.TextXAlignment.Right,
  Parent = parent23,
})

local function f36(p40)
  local v104 = math.clamp((p40 - v99.AbsolutePosition.X) / v99.AbsoluteSize.X, 0, 1)
  v101.Size = UDim2.new(v104, 0, 1, 0)
  v102.Position = UDim2.new(v104, -6, 0.5, -6)
  local v105 = math.floor(1 + v104 * 29)
  _G.AutoLeaveRaid.LeaveCooldown = v105
  v103.Text = v105 .. "s"
end

local v106 = false

v99.InputBegan:Connect(function(input10)
  if input10.UserInputType == Enum.UserInputType.MouseButton1
    or input10.UserInputType == Enum.UserInputType.Touch then
    v106 = true
    f36(input10.Position.X)
  end
end)

userInputService.InputChanged:Connect(function(input11)
  if v106
    and (input11.UserInputType == Enum.UserInputType.MouseMovement
      or input11.UserInputType == Enum.UserInputType.Touch) then
    f36(input11.Position.X)
  end
end)

userInputService.InputEnded:Connect(function(input12)
  if input12.UserInputType == Enum.UserInputType.MouseButton1
    or input12.UserInputType == Enum.UserInputType.Touch then
    v106 = false
  end
end)

local v107 = f1("TextButton", {
  Size = UDim2.new(1, 0, 0, 26),
  BackgroundColor3 = v2.panel,
  BorderSizePixel = 0,
  Text = "LEAVE NOW",
  Font = gothamBold,
  TextSize = 12,
  TextColor3 = v2.white,
  AutoButtonColor = false,
  Parent = parent17,
})

f2(v107, 4)
f3(v107, v2.border, 1)

v107.MouseEnter:Connect(function()
  v107.BackgroundColor3 = v2.accentDim
  v107.UIStroke.Color = v2.accent
end)

v107.MouseLeave:Connect(function()
  v107.BackgroundColor3 = v2.panel
  v107.UIStroke.Color = v2.border
end)

v107.MouseButton1Click:Connect(function() f20() end)

f1("TextLabel", {
  Size = UDim2.new(1, 0, 0, 22),
  BackgroundTransparency = 1,
  Text = "ANTI-AFK",
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.textDim,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent18,
})

local v108 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 0),
  BackgroundColor3 = Color3.fromRGB(28, 28, 28),
  BorderSizePixel = 0,
  AutomaticSize = Enum.AutomaticSize.Y,
  Parent = parent18,
})

f2(v108, 6)
f3(v108, v2.border, 1)

f1("UIListLayout", {
  Padding = UDim.new(0, 8),
  SortOrder = Enum.SortOrder.LayoutOrder,
  Parent = v108,
})

f4(v108, 12)

local parent24 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 30),
  BackgroundTransparency = 1,
  Parent = v108,
})

f1("TextLabel", {
  Size = UDim2.new(1, -80, 1, 0),
  BackgroundTransparency = 1,
  Text = "Anti-AFK",
  Font = gothamBold,
  TextSize = 13,
  TextColor3 = v2.white,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent24,
})

f28(f1("Frame", {
  Size = UDim2.new(0, 50, 1, 0),
  Position = UDim2.new(1, -50, 0, 0),
  BackgroundTransparency = 1,
  Parent = parent24,
}), _G.AntiAFK.Enabled ~= false, function(enabled2) _G.AntiAFK.Enabled = enabled2 end)

f26(v108, _G.AntiAFK, 60, 10, 300)

f1("TextLabel", {
  Size = UDim2.new(1, 0, 0, 22),
  BackgroundTransparency = 1,
  Text = "AUTO EQUIP",
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.textDim,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent18,
})

local v109 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 0),
  BackgroundColor3 = Color3.fromRGB(28, 28, 28),
  BorderSizePixel = 0,
  AutomaticSize = Enum.AutomaticSize.Y,
  Parent = parent18,
})

f2(v109, 6)
f3(v109, v2.border, 1)

f1("UIListLayout", {
  Padding = UDim.new(0, 8),
  SortOrder = Enum.SortOrder.LayoutOrder,
  Parent = v109,
})

f4(v109, 12)

local parent25 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 30),
  BackgroundTransparency = 1,
  Parent = v109,
})

f1("TextLabel", {
  Size = UDim2.new(1, -80, 1, 0),
  BackgroundTransparency = 1,
  Text = "Auto Equip Best Pet",
  Font = gothamBold,
  TextSize = 13,
  TextColor3 = v2.white,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent25,
})

f28(f1("Frame", {
  Size = UDim2.new(0, 50, 1, 0),
  Position = UDim2.new(1, -50, 0, 0),
  BackgroundTransparency = 1,
  Parent = parent25,
}), _G.AutoEquipPet.Enabled == true, function(enabled3) _G.AutoEquipPet.Enabled = enabled3 end)

f26(v109, _G.AutoEquipPet, 5, 1, 60)

local v110 = f1("TextButton", {
  Size = UDim2.new(1, 0, 0, 26),
  BackgroundColor3 = v2.panel,
  BorderSizePixel = 0,
  Text = "EQUIP NOW",
  Font = gothamBold,
  TextSize = 12,
  TextColor3 = v2.white,
  AutoButtonColor = false,
  Parent = parent18,
})

f2(v110, 4)
f3(v110, v2.border, 1)

v110.MouseEnter:Connect(function()
  v110.BackgroundColor3 = v2.accentDim
  v110.UIStroke.Color = v2.accent
end)

v110.MouseLeave:Connect(function()
  v110.BackgroundColor3 = v2.panel
  v110.UIStroke.Color = v2.border
end)

v110.MouseButton1Click:Connect(function() f13() end)

do
  f1("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    Text = "AUTO POTION",
    Font = gothamBold,
    TextSize = 11,
    TextColor3 = v2.textDim,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = parent18,
  })

  local potionCard = f1("Frame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
    BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = parent18,
  })

  f2(potionCard, 6)
  f3(potionCard, v2.border, 1)

  f1("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = potionCard,
  })

  f4(potionCard, 12)

  local potionRow = f1("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Parent = potionCard,
  })

  f1("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0),
    BackgroundTransparency = 1,
    Text = "Auto Use Potions",
    Font = gothamBold,
    TextSize = 13,
    TextColor3 = v2.white,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = potionRow,
  })

  f28(f1("Frame", {
    Size = UDim2.new(0, 50, 1, 0),
    Position = UDim2.new(1, -50, 0, 0),
    BackgroundTransparency = 1,
    Parent = potionRow,
  }), _G.AutoPotion.Enabled == true, function(enabled) _G.AutoPotion.Enabled = enabled end)

  local useAllRow = f1("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Parent = potionCard,
  })

  f1("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0),
    BackgroundTransparency = 1,
    Text = "Use All In Inventory",
    Font = gothamBold,
    TextSize = 13,
    TextColor3 = v2.white,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = useAllRow,
  })

  f28(f1("Frame", {
    Size = UDim2.new(0, 50, 1, 0),
    Position = UDim2.new(1, -50, 0, 0),
    BackgroundTransparency = 1,
    Parent = useAllRow,
  }), _G.AutoPotion.UseAll ~= false, function(useAll) _G.AutoPotion.UseAll = useAll end)

  f1("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
    Text = "On: uses every potion you own, including new drops. Off: uses 1 of each every 15 minutes.",
    Font = gothamMedium,
    TextSize = 10,
    TextColor3 = v2.textMute,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Parent = potionCard,
  })
end

f1("TextLabel", {
  Size = UDim2.new(1, 0, 0, 22),
  BackgroundTransparency = 1,
  Text = "DUNGEON",
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.textDim,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent18,
})

local v111 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 0),
  BackgroundColor3 = Color3.fromRGB(28, 28, 28),
  BorderSizePixel = 0,
  AutomaticSize = Enum.AutomaticSize.Y,
  Parent = parent18,
})

f2(v111, 6)
f3(v111, v2.border, 1)

f1("UIListLayout", {
  Padding = UDim.new(0, 8),
  SortOrder = Enum.SortOrder.LayoutOrder,
  Parent = v111,
})

f4(v111, 12)

local parent26 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 30),
  BackgroundTransparency = 1,
  Parent = v111,
})

f1("TextLabel", {
  Size = UDim2.new(1, -80, 1, 0),
  BackgroundTransparency = 1,
  Text = "Auto Easy Dungeon + Kill",
  Font = gothamBold,
  TextSize = 13,
  TextColor3 = v2.white,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent26,
})

f28(f1("Frame", {
  Size = UDim2.new(0, 50, 1, 0),
  Position = UDim2.new(1, -50, 0, 0),
  BackgroundTransparency = 1,
  Parent = parent26,
}), _G.AutoDungeon.Enabled == true, function(p41)
  _G.AutoDungeon.Enabled = p41

  if p41 then
    -- only remember this spot if we are NOT already inside the dungeon,
    -- otherwise the "saved spot" would be a dungeon position
    if #f15() == 0 then
      f7()
    end
  else
    -- only go back if the script actually teleported us to dungeon enemies
    if _G.AutoDungeon.Moved then
      returnToSaved()
    end

    _G.AutoDungeon.Moved = false
    _G.AutoDungeon.ReturnPending = false
  end
end)

f26(v111, _G.AutoDungeon, 3, 1, 30)
f24(v111, _G.AutoDungeon, 0.1, 0.02, 0.5, "TP Speed:")

local parent27 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 30),
  BackgroundTransparency = 1,
  Parent = v111,
})

f1("TextLabel", {
  Size = UDim2.new(1, -80, 1, 0),
  BackgroundTransparency = 1,
  Text = "Auto Leave at Target Wave",
  Font = gothamBold,
  TextSize = 13,
  TextColor3 = v2.white,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent27,
})

f28(f1("Frame", {
  Size = UDim2.new(0, 50, 1, 0),
  Position = UDim2.new(1, -50, 0, 0),
  BackgroundTransparency = 1,
  Parent = parent27,
}), _G.AutoDungeon.LeaveEnabled == true, function(leaveEnabled) _G.AutoDungeon.LeaveEnabled = leaveEnabled end)

local parent28 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 24),
  BackgroundTransparency = 1,
  Parent = v111,
})

_G.RobinWaveLabel = f1("TextLabel", {
  Size = UDim2.new(1, 0, 0, 18),
  BackgroundTransparency = 1,
  Text = "Current wave: -",
  Font = gothamMedium,
  TextSize = 11,
  TextColor3 = v2.textMute,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = v111,
})

f1("TextLabel", {
  Size = UDim2.fromOffset(90, 24),
  BackgroundTransparency = 1,
  Text = "Target Wave:",
  Font = gothamMedium,
  TextSize = 11,
  TextColor3 = v2.textMute,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent28,
})

local v112 = f1("Frame", {
  Size = UDim2.new(1, -160, 0, 4),
  Position = UDim2.new(0, 90, 0.5, -2),
  BackgroundColor3 = v2.border,
  BorderSizePixel = 0,
  Parent = parent28,
})

local v113 = f1("Frame", {
  Size = UDim2.new(math.clamp(_G.AutoDungeon.TargetWave / 50, 0, 1), 0, 1, 0),
  BackgroundColor3 = v2.accent,
  BorderSizePixel = 0,
  Parent = v112,
})

local v114 = f1("Frame", {
  Size = UDim2.fromOffset(12, 12),
  Position = UDim2.new(math.clamp(_G.AutoDungeon.TargetWave / 50, 0, 1), -6, 0.5, -6),
  BackgroundColor3 = v2.accent,
  BorderSizePixel = 0,
  Parent = v112,
})

local v115 = f1("TextLabel", {
  Size = UDim2.fromOffset(60, 24),
  Position = UDim2.new(1, -60, 0, 0),
  BackgroundTransparency = 1,
  Text = tostring(_G.AutoDungeon.TargetWave),
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.accent,
  TextXAlignment = Enum.TextXAlignment.Right,
  Parent = parent28,
})

local v116 = false

local function f37(p42)
  local v117 = math.clamp((p42 - v112.AbsolutePosition.X) / v112.AbsoluteSize.X, 0, 1)
  v113.Size = UDim2.new(v117, 0, 1, 0)
  v114.Position = UDim2.new(v117, -6, 0.5, -6)
  local v118 = math.floor(v117 * 50)
  _G.AutoDungeon.TargetWave = v118
  v115.Text = tostring(v118)
end

v112.InputBegan:Connect(function(input13)
  if input13.UserInputType == Enum.UserInputType.MouseButton1
    or input13.UserInputType == Enum.UserInputType.Touch then
    v116 = true
    f37(input13.Position.X)
  end
end)

userInputService.InputChanged:Connect(function(input14)
  if v116
    and (input14.UserInputType == Enum.UserInputType.MouseMovement
      or input14.UserInputType == Enum.UserInputType.Touch) then
    f37(input14.Position.X)
  end
end)

userInputService.InputEnded:Connect(function(input15)
  if input15.UserInputType == Enum.UserInputType.MouseButton1
    or input15.UserInputType == Enum.UserInputType.Touch then
    v116 = false
  end
end)

local v119 = f1("TextButton", {
  Size = UDim2.new(1, 0, 0, 26),
  BackgroundColor3 = v2.panel,
  BorderSizePixel = 0,
  Text = "LEAVE DUNGEON NOW",
  Font = gothamBold,
  TextSize = 12,
  TextColor3 = v2.white,
  AutoButtonColor = false,
  Parent = parent18,
})

f2(v119, 4)
f3(v119, v2.border, 1)

v119.MouseEnter:Connect(function()
  v119.BackgroundColor3 = v2.accentDim
  v119.UIStroke.Color = v2.accent
end)

v119.MouseLeave:Connect(function()
  v119.BackgroundColor3 = v2.panel
  v119.UIStroke.Color = v2.border
end)

v119.MouseButton1Click:Connect(function() f17() end)

f1("TextLabel", {
  Size = UDim2.new(1, 0, 0, 22),
  BackgroundTransparency = 1,
  Text = "POSITION",
  Font = gothamBold,
  TextSize = 11,
  TextColor3 = v2.textDim,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = parent18,
})

local v120 = f1("Frame", {
  Size = UDim2.new(1, 0, 0, 0),
  BackgroundColor3 = Color3.fromRGB(28, 28, 28),
  BorderSizePixel = 0,
  AutomaticSize = Enum.AutomaticSize.Y,
  Parent = parent18,
})

f2(v120, 6)
f3(v120, v2.border, 1)

f1("UIListLayout", {
  Padding = UDim.new(0, 8),
  SortOrder = Enum.SortOrder.LayoutOrder,
  Parent = v120,
})

f4(v120, 12)

local v121 = f1("TextButton", {
  Size = UDim2.new(1, 0, 0, 26),
  BackgroundColor3 = v2.panel,
  BorderSizePixel = 0,
  Text = "SAVE POSITION",
  Font = gothamBold,
  TextSize = 12,
  TextColor3 = v2.white,
  AutoButtonColor = false,
  Parent = v120,
})

f2(v121, 4)
f3(v121, v2.border, 1)

v121.MouseEnter:Connect(function()
  v121.BackgroundColor3 = v2.accentDim
  v121.UIStroke.Color = v2.accent
end)

v121.MouseLeave:Connect(function()
  v121.BackgroundColor3 = v2.panel
  v121.UIStroke.Color = v2.border
end)

v121.MouseButton1Click:Connect(function() f7() end)

local v122 = f1("TextButton", {
  Size = UDim2.new(1, 0, 0, 26),
  BackgroundColor3 = v2.panel,
  BorderSizePixel = 0,
  Text = "GO TO SAVED",
  Font = gothamBold,
  TextSize = 12,
  TextColor3 = v2.white,
  AutoButtonColor = false,
  Parent = v120,
})

f2(v122, 4)
f3(v122, v2.border, 1)

v122.MouseEnter:Connect(function()
  v122.BackgroundColor3 = v2.accentDim
  v122.UIStroke.Color = v2.accent
end)

v122.MouseLeave:Connect(function()
  v122.BackgroundColor3 = v2.panel
  v122.UIStroke.Color = v2.border
end)

v122.MouseButton1Click:Connect(function() f8() end)

-- ===== UI polish pass (visual only) =====
-- slider tracks -> thick bars (knob hidden)
for _, d in ipairs(v35:GetDescendants()) do
  if d:IsA("Frame") and d.Size.Y.Scale == 0 and d.Size.Y.Offset == 4 then
    d.Size = UDim2.new(d.Size.X.Scale, d.Size.X.Offset, 0, 14)
    d.Position = UDim2.new(d.Position.X.Scale, d.Position.X.Offset, 0.5, -7)
    d.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    f3(d, v2.border, 1)

    for _, c in ipairs(d:GetChildren()) do
      if c:IsA("Frame") and c.Size.X.Offset == 12 then
        c.Visible = false
      end
    end
  end
end

-- groupboxes get a 2px accent line on top
for _, page in pairs(v60) do
  local order = 0

  for _, child in ipairs(page:GetChildren()) do
    if child:IsA("GuiObject") then
      order = order + 1
      child.LayoutOrder = order
    end
  end

  for _, child in ipairs(page:GetChildren()) do
    if child:IsA("Frame") and child.AutomaticSize == Enum.AutomaticSize.Y then
      local wrap = f1("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = child.LayoutOrder,
        Parent = page,
      })

      f1("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0), Parent = wrap })

      f1("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = v2.accent,
        BorderSizePixel = 0,
        LayoutOrder = 0,
        Parent = wrap,
      })

      child.LayoutOrder = 1
      child.Parent = wrap
    end
  end
end
-- ===== end UI polish pass =====

local v123 = false
local position, position2

v37.InputBegan:Connect(function(input16)
  if input16.UserInputType == Enum.UserInputType.MouseButton1
    or input16.UserInputType == Enum.UserInputType.Touch then
    v123 = true
    position = input16.Position
    position2 = v36.Position

    input16.Changed:Connect(function()
      if input16.UserInputState == Enum.UserInputState.End then
        v123 = false
      end
    end)
  end
end)

userInputService.InputChanged:Connect(function(input17)
  if v123
    and (input17.UserInputType == Enum.UserInputType.MouseMovement
      or input17.UserInputType == Enum.UserInputType.Touch) then
    local v124 = input17.Position - position

    v36.Position = UDim2.new(
      position2.X.Scale, position2.X.Offset + v124.X, position2.Y.Scale,
      position2.Y.Offset + v124.Y
    )
  end
end)

-- ===== Resizable window + mobile support =====
local MIN_W, MIN_H = 380, 300
local isTouch = userInputService.TouchEnabled
local PAD_SIDE, PAD_TOP, PAD_BOTTOM = 8, (isTouch and 36 or 8), 8
local resizing, resizeMode, resizeStart, startSize = false, nil, nil, nil

local function getScreen()
  local s = v35.AbsoluteSize
  if s.X < 1 or s.Y < 1 then
    local cam = workspace.CurrentCamera
    s = cam and cam.ViewportSize or Vector2.new(1280, 720)
  end
  return s
end

local function getWindowSize()
  return Vector2.new(v36.Size.X.Offset, v36.Size.Y.Offset)
end

local function getWindowPos(screen)
  local p = v36.Position
  return Vector2.new(p.X.Scale * screen.X + p.X.Offset, p.Y.Scale * screen.Y + p.Y.Offset)
end

-- narrower sidebar when the window is narrow (phones in portrait)
local function applyLayout()
  parent8.Size = UDim2.new(1, 0, 0, 26)
  parent9.Position = UDim2.new(0, 0, 0, 26)
  parent9.Size = UDim2.new(1, 0, 1, -26)
end

-- keep the main window fully on screen (also handles rotation / small screens)
local function fitWindow()
  local screen = getScreen()
  local size = getWindowSize()
  local pos = getWindowPos(screen)
  local w = math.min(size.X, screen.X - PAD_SIDE * 2)
  local h = math.min(size.Y, screen.Y - PAD_TOP - PAD_BOTTOM)
  local x = math.clamp(pos.X, PAD_SIDE, math.max(PAD_SIDE, screen.X - w - PAD_SIDE))
  local y = math.clamp(pos.Y, PAD_TOP, math.max(PAD_TOP, screen.Y - h - PAD_BOTTOM))
  v36.Size = UDim2.fromOffset(w, h)
  v36.Position = UDim2.fromOffset(x, y)
  applyLayout()
end

local function makeResizeHandle(name, size, pos, mode)
  local handle = f1("TextButton", {
    Name = name,
    Size = size,
    Position = pos,
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 50,
    Parent = v36,
  })

  handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      resizing = true
      resizeMode = mode
      resizeStart = input.Position
      startSize = getWindowSize()

      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
          resizing = false
        end
      end)
    end
  end)

  return handle
end

-- bigger touch targets on mobile
local EDGE = isTouch and 16 or 6
local GRIP = isTouch and 34 or 18

makeResizeHandle("ResizeR", UDim2.new(0, EDGE, 1, -(28 + GRIP)), UDim2.new(1, -EDGE, 0, 28), "x")
makeResizeHandle("ResizeB", UDim2.new(1, -GRIP, 0, EDGE), UDim2.new(0, 0, 1, -EDGE), "y")
makeResizeHandle("ResizeXY", UDim2.fromOffset(GRIP, GRIP), UDim2.new(1, -GRIP, 1, -GRIP), "xy")

-- small visible grip in the corner so people know where to drag
for i = 1, 3 do
  f1("Frame", {
    Size = UDim2.fromOffset(i * 4, 1),
    Position = UDim2.new(1, -3 - i * 4, 1, -3 - (4 - i) * 4),
    BackgroundColor3 = v2.textDim,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = v36,
  })
end

userInputService.InputChanged:Connect(function(input)
  if resizing
    and (input.UserInputType == Enum.UserInputType.MouseMovement
      or input.UserInputType == Enum.UserInputType.Touch) then
    local delta = input.Position - resizeStart
    local screen = getScreen()
    local pos = getWindowPos(screen)
    local minW = math.min(MIN_W, screen.X - PAD_SIDE * 2)
    local minH = math.min(MIN_H, screen.Y - PAD_TOP - PAD_BOTTOM)
    local newW, newH = startSize.X, startSize.Y

    if resizeMode == "x" or resizeMode == "xy" then
      newW = math.clamp(startSize.X + delta.X, minW, math.max(minW, screen.X - pos.X - PAD_SIDE))
    end

    if resizeMode == "y" or resizeMode == "xy" then
      newH = math.clamp(startSize.Y + delta.Y, minH, math.max(minH, screen.Y - pos.Y - PAD_BOTTOM))
    end

    v36.Size = UDim2.fromOffset(newW, newH)
    applyLayout()
  end
end)

-- on touch devices keep the window from being dragged off screen
userInputService.InputEnded:Connect(function(input)
  if isTouch and v36.Visible
    and (input.UserInputType == Enum.UserInputType.Touch
      or input.UserInputType == Enum.UserInputType.MouseButton1) then
    fitWindow()
  end
end)

-- fit to the screen now, and again when the screen changes (rotation etc.)
fitWindow()
v35:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
  if v36.Visible then fitWindow() end
end)
pcall(function()
  local cam = workspace.CurrentCamera
  if cam then
    cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
      if v36.Visible then fitWindow() end
    end)
  end
end)
-- ===== end resizable window + mobile support =====

local v125 = f1("TextButton", {
  Name = "Mini",
  Size = UDim2.fromOffset(190, 46),
  Position = UDim2.new(0, 200, 0, 200),
  BackgroundColor3 = v2.bg,
  BorderSizePixel = 0,
  Text = "",
  AutoButtonColor = false,
  Visible = false,
  Parent = v35,
})

f3(v125, v2.border, 1)

local v126 = f1("Frame", {
  Size = UDim2.fromOffset(7, 7),
  Position = UDim2.new(0, 42, 0.5, -3),
  BackgroundColor3 = v2.accent,
  BorderSizePixel = 0,
  Parent = v125,
})

f2(v126, 4)

f1("TextLabel", {
  Size = UDim2.new(0, 60, 1, 0),
  Position = UDim2.new(0, 56, 0, 0),
  BackgroundTransparency = 1,
  Text = "ROBIN",
  Font = gothamBold,
  TextSize = 15,
  TextColor3 = v2.white,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = v125,
})

f1("TextLabel", {
  Size = UDim2.new(0, 70, 1, 0),
  Position = UDim2.new(0, 108, 0, 0),
  BackgroundTransparency = 1,
  Text = " HUB",
  Font = gothamBold,
  TextSize = 15,
  TextColor3 = v2.accent,
  TextXAlignment = Enum.TextXAlignment.Left,
  Parent = v125,
})

task.spawn(function()
  while v126.Parent do
    tweenService:Create(v126, TweenInfo.new(0.8), { BackgroundTransparency = 0.6 }):Play()
    task.wait(0.8)
    tweenService:Create(v126, TweenInfo.new(0.8), { BackgroundTransparency = 0 }):Play()
    task.wait(0.8)
  end
end)

local v127 = false
local v128 = false
local miniStart, miniPos

v125.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
    v127 = true
    v128 = false
    miniStart = input.Position
    miniPos = v125.Position
  end
end)

userInputService.InputChanged:Connect(function(input18)
  if v127
    and (input18.UserInputType == Enum.UserInputType.MouseMovement
      or input18.UserInputType == Enum.UserInputType.Touch) then
    local v129 = input18.Position - miniStart
    local threshold = isTouch and 8 or 3

    if math.abs(v129.X) > threshold or math.abs(v129.Y) > threshold then
      v128 = true
    end

    v125.Position = UDim2.new(
      miniPos.X.Scale, miniPos.X.Offset + v129.X, miniPos.Y.Scale,
      miniPos.Y.Offset + v129.Y
    )
  end
end)

userInputService.InputEnded:Connect(function(input19)
  if input19.UserInputType == Enum.UserInputType.MouseButton1
    or input19.UserInputType == Enum.UserInputType.Touch then
    if v127 then
      if not v128 then
        v36.Visible = true
        v125.Visible = false
        fitWindow()
      else
        -- keep the mini button on screen
        local screen = getScreen()
        local p = v125.Position
        local x = p.X.Scale * screen.X + p.X.Offset
        local y = p.Y.Scale * screen.Y + p.Y.Offset
        v125.Position = UDim2.fromOffset(
          math.clamp(x, 0, math.max(0, screen.X - v125.Size.X.Offset)),
          math.clamp(y, 0, math.max(0, screen.Y - v125.Size.Y.Offset))
        )
      end
    end

    v127 = false
  end
end)

v40.MouseButton1Click:Connect(function()
  v36.Visible = false
  v125.Visible = true
end)

v41.MouseButton1Click:Connect(function()
  v36.Visible = false
  v125.Visible = false
  task.wait(1.5)
  v35:Destroy()
end)

userInputService.InputBegan:Connect(function(input20, p43)
  if p43 then
    return
  end

  if input20.KeyCode == Enum.KeyCode.RightShift then
    if v36.Visible then
      v36.Visible = false
      v125.Visible = true
    else
      v36.Visible = true
      v125.Visible = false
    end
  end
end)

task.spawn(function()
  task.wait(0.5)
  v1("ROBIN is Ready")
end)
