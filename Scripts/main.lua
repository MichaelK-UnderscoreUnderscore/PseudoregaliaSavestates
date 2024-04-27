-- Namespaces
local PseudoregaliaSavestates = {}
local UEHelpers = require("UEHelpers")

-- Config
local config_Keybinds = require "config_keybinds"
local SaveFile = "Mods/PseudoregaliaSavestates/Saves/SavedPositions.txt"

-- BaseGame hooks
local hook_GameInstance = nil
local hook_PlayerController = nil
local hook_Console = nil

-- Local variables
local var_SavedPositions = {}
local var_ReloadTeleport_bool = false
local var_ReloadTeleport_ID = 0

-- Local defines for readability
local MapName = "mapName_4_423D13C74469858B6E9893BEB6ABFBBB"

local function Test()
---@diagnostic disable: need-check-nil, undefined-field
    hook_Console:ExecuteConsoleCommand(hook_PlayerController, "open ZONE_Exterior", nil)
    hook_Console:ExecuteConsoleCommand(hook_PlayerController, "bugitgo 0 0 0", nil)
---@diagnostic enable: need-check-nil, undefined-field
end

function PseudoregaliaSavestates.LoadSavedPositionsFromFile()
    local File = io.open(SaveFile, "r")
    if File == nil then
        print("No saved positions file found")
        return
    end
    for line in File:lines() do
        local ID = tonumber(string.match(line, "ID=(%d+)"))
        local Area = string.match(line, "Area=([A-Za-z0-9_]+)")
        local X = tonumber(string.match(line, "X=(-?%d+%.?%d*)"))
        local Y = tonumber(string.match(line, "Y=(-?%d+%.?%d*)"))
        local Z = tonumber(string.match(line, "Z=(-?%d+%.?%d*)"))
        local Pitch = tonumber(string.match(line, "Pitch=(-?%d+%.?%d*)"))
        local Yaw = tonumber(string.match(line, "Yaw=(-?%d+%.?%d*)"))
        local Roll = tonumber(string.match(line, "Roll=(-?%d+%.?%d*)"))
        if ID == nil or Area == nil or X == nil or Y == nil or Z == nil or Pitch == nil or Yaw == nil or Roll == nil then
            print("Error parsing line: " .. line)
            goto continue       
        end
        var_SavedPositions[ID] = {
            ["Area"] = Area,
            ["X"] = X,
            ["Y"] = Y,
            ["Z"] = Z,
            ["Pitch"] = Pitch,
            ["Yaw"] = Yaw,
            ["Roll"] = Roll,
        }
        ::continue::
    end
end

function PseudoregaliaSavestates.SavePositionsToFile()
    local text = ""
    for ID, Position in pairs(var_SavedPositions) do
        text = text .. "ID=" .. tostring(ID) .. " :: Area=" .. Position.Area .. " :: X=" .. tostring(Position.X) .. " :: Y=" .. tostring(Position.Y) .. " :: Z=" .. tostring(Position.Z) .. " :: Pitch=" .. tostring(Position.Pitch) .. " :: Yaw=" .. tostring(Position.Yaw) .. " :: Roll=" .. tostring(Position.Roll) .. "\n"
    end
    local File = io.open(SaveFile, "w")
    if File == nil then
        print("Error opening file for writing")
        return
    end
    File:write(text)
    File:close()
end

function PseudoregaliaSavestates.LoadPosition(ID --[[int]])
    if not var_SavedPositions[ID] then
        print("No saved position for ID " .. ID)
        return
    end
    if hook_GameInstance == nil or not hook_GameInstance:IsValid() then
        print("GameInstance not found")
        return
    end
    if hook_Console == nil or not hook_Console:IsValid() then
        print("Console not found")
        return
    end
    if hook_PlayerController == nil or not hook_PlayerController:IsValid() then
        print("PlayerController not found")
        return
    end
    Area = hook_GameInstance.activeZoneStr[MapName]:ToString()
    if Area == nil or type(Area) ~= "string" then
        print("Area not found")
        return
    end
    if Area ~= var_SavedPositions[ID].Area then
        var_ReloadTeleport_bool = true
        var_ReloadTeleport_ID = ID
        
        hook_Console:ExecuteConsoleCommand(hook_PlayerController, "open " .. var_SavedPositions[ID].Area, nil)
        return
    end
    hook_Console:ExecuteConsoleCommand(hook_PlayerController, "bugitgo " .. var_SavedPositions[ID].X .. " " .. var_SavedPositions[ID].Y .. " " .. var_SavedPositions[ID].Z .. " " .. var_SavedPositions[ID].Pitch .. " " .. var_SavedPositions[ID].Yaw .. " " .. var_SavedPositions[ID].Roll, nil)
end

function PseudoregaliaSavestates.SavePosition(ID --[[int]])
    if type(ID) ~= "number" then
        print("ID not number")
        return
    end
    if hook_GameInstance == nil or not hook_GameInstance:IsValid() then
        print("GameInstance not found")
        return
    end
    if hook_PlayerController == nil or not hook_PlayerController:IsValid() then
        print("PlayerController not found")
        return
    end
    local Area = hook_GameInstance.activeZoneStr[MapName]:ToString()
    local Position = hook_PlayerController.Pawn:K2_GetActorLocation()
    local Rotation = hook_PlayerController.Pawn:K2_GetActorRotation()
    if Area == nil or type(Area) ~= "string" then
        print("Area not found")
        return
    end
    if Position == nil then
        print("Position not found")
        return
    end
    if Rotation == nil then
        print("Rotation not found")
        return
    end
    var_SavedPositions[ID] = {
        ["Area"] = Area,
        ["X"] = Position.X,
        ["Y"] = Position.Y,
        ["Z"] = Position.Z,
        ["Pitch"] = Rotation.Pitch,
        ["Yaw"] = Rotation.Yaw,
        ["Roll"] = Rotation.Roll,
    }
    PseudoregaliaSavestates.SavePositionsToFile()
    print("Saved position " .. ID)
end


-- Init
-- Reload
RegisterHook("/Script/Engine.PlayerController:ClientRestart", function (Context)
    -- The GameInstance holds all the current game states in Pseudo
    hook_GameInstance = FindFirstOf("MV_GameInstance_C")
    if hook_GameInstance == nil or not hook_GameInstance:IsValid() then
        print("GameInstance not found")
        return
    end
    -- Pseudo doesn't mark the used PlayerController as PlayerControlled,
    ---- can't use GetPlayerController()
    hook_PlayerController = FindFirstOf("MainPlayerController_C")
    if hook_PlayerController == nil or not hook_PlayerController:IsValid() then
        print("PlayerController not found")
        return
    end
    hook_Console = UEHelpers.GetKismetSystemLibrary(false)
    if hook_Console == nil or not hook_Console:IsValid() then
        print("Console not found")
        return
    end
    PseudoregaliaSavestates.LoadSavedPositionsFromFile()
    if var_ReloadTeleport_bool then
        var_ReloadTeleport_bool = false
        PseudoregaliaSavestates.LoadPosition(var_ReloadTeleport_ID)
    end
end)

-- Keybinds
local function RegisterKey(KeyBindName, Callable)
    if (config_Keybinds[KeyBindName] and not IsKeyBindRegistered(config_Keybinds[KeyBindName].Key, config_Keybinds[KeyBindName].ModifierKeys)) then
        RegisterKeyBind(config_Keybinds[KeyBindName].Key, config_Keybinds[KeyBindName].ModifierKeys, Callable)
    end
end

RegisterKey("Test", function() Test() end)
for i = 1, config_Keybinds["PositionSaveCount"] do
    if not config_Keybinds["LoadPosition " .. i] then
        print("LoadPosition " .. i .. " not found in config_keybinds.lua")
        goto SavePosition
    end
    RegisterKey("LoadPosition " .. i, function() PseudoregaliaSavestates.LoadPosition(i) end)
    ::SavePosition::
    if not config_Keybinds["SavePosition " .. i] then
        print("SavePosition " .. i .. " not found in config_keybinds.lua")
        goto continue
    end
    RegisterKey("SavePosition " .. i, function() PseudoregaliaSavestates.SavePosition(i) end)
    ::continue::
end