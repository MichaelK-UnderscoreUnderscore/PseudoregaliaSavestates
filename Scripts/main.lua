local PseudoregaliaSavestates = {}
local UEHelpers = require("UEHelpers")

local GameInstance = nil
local PlayerController = nil
local Console = nil

local SavedPositions = {}
local teleport_on_reload = false
local teleport_on_reload_id = 0

local function Test()
    Console:ExecuteConsoleCommand(PlayerController, "open ZONE_Exterior", nil)
    Console:ExecuteConsoleCommand(PlayerController, "bugitgo 0 0 0", nil)
end

function PseudoregaliaSavestates.LoadPosition(ID --[[int]])
    if not SavedPositions[ID] then
        print("No saved position for ID " .. ID)
        return
    end
    Area = GameInstance.activeZoneStr["mapName_4_423D13C74469858B6E9893BEB6ABFBBB"]:ToString()
    if Area ~= SavedPositions[ID].Area then
        teleport_on_reload = true
        teleport_on_reload_id = ID
        
        Console:ExecuteConsoleCommand(PlayerController, "open " .. SavedPositions[ID].Area, nil)
        return
    end
    Console:ExecuteConsoleCommand(PlayerController, "bugitgo " .. SavedPositions[ID].X .. " " .. SavedPositions[ID].Y .. " " .. SavedPositions[ID].Z .. " " .. SavedPositions[ID].Pitch .. " " .. SavedPositions[ID].Yaw .. " " .. SavedPositions[ID].Roll, nil)
end

function PseudoregaliaSavestates.SavePosition(ID --[[int]])
    local Area = GameInstance.activeZoneStr["mapName_4_423D13C74469858B6E9893BEB6ABFBBB"]:ToString()
    local Position = PlayerController.Pawn:K2_GetActorLocation()
    local Rotation = PlayerController.Pawn:K2_GetActorRotation()

    SavedPositions[ID] = {
        ["Area"] = Area,
        ["X"] = Position.X,
        ["Y"] = Position.Y,
        ["Z"] = Position.Z,
        ["Pitch"] = Rotation.Pitch,
        ["Yaw"] = Rotation.Yaw,
        ["Roll"] = Rotation.Roll,
    }
    print("Saved position " .. ID)
end

-- Init
-- Reload
RegisterHook("/Script/Engine.PlayerController:ClientRestart", function (Context)
    -- The GameInstance holds all the current game states in Pseudo
    GameInstance = FindFirstOf("MV_GameInstance_C")
    if GameInstance == nil or not GameInstance:IsValid() then
        print("GameInstance not found")
        return
    end
    -- Pseudo doesn't mark the used PlayerController as PlayerControlled,
    ---- can't use GetPlayerController()
    PlayerController = FindFirstOf("MainPlayerController_C")
    if PlayerController == nil or not PlayerController:IsValid() then
        print("PlayerController not found")
        return
    end
    Console = UEHelpers.GetKismetSystemLibrary(false)
    if Console == nil or not Console:IsValid() then
        print("Console not found")
        return
    end
    if teleport_on_reload then
        teleport_on_reload = false
        PseudoregaliaSavestates.LoadPosition(teleport_on_reload_id)
    end
end)


local Keybinds = {
    ["Test"] = {["Key"] = Key.F4, ["ModifierKeys"] = {}},
    ["LoadPosition 1"] = {["Key"] = Key.F5, ["ModifierKeys"] = {}},
    ["LoadPosition 2"] = {["Key"] = Key.F6, ["ModifierKeys"] = {}},
    ["LoadPosition 3"] = {["Key"] = Key.F7, ["ModifierKeys"] = {}},
    ["LoadPosition 4"] = {["Key"] = Key.F8, ["ModifierKeys"] = {}},
    ["SavePosition 1"] = {["Key"] = Key.F5, ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["SavePosition 2"] = {["Key"] = Key.F6, ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["SavePosition 3"] = {["Key"] = Key.F7, ["ModifierKeys"] = {ModifierKey.CONTROL}},
    ["SavePosition 4"] = {["Key"] = Key.F8, ["ModifierKeys"] = {ModifierKey.CONTROL}}
}
local function RegisterKey(KeyBindName, Callable)
    if (Keybinds[KeyBindName] and not IsKeyBindRegistered(Keybinds[KeyBindName].Key, Keybinds[KeyBindName].ModifierKeys)) then
        RegisterKeyBind(Keybinds[KeyBindName].Key, Keybinds[KeyBindName].ModifierKeys, Callable)
    end
end

RegisterKey("Test", function() Test() end)
RegisterKey("LoadPosition 1", function() PseudoregaliaSavestates.LoadPosition(1) end)
RegisterKey("LoadPosition 2", function() PseudoregaliaSavestates.LoadPosition(2) end)
RegisterKey("LoadPosition 3", function() PseudoregaliaSavestates.LoadPosition(3) end)
RegisterKey("LoadPosition 4", function() PseudoregaliaSavestates.LoadPosition(4) end)
RegisterKey("SavePosition 1", function() PseudoregaliaSavestates.SavePosition(1) end)
RegisterKey("SavePosition 2", function() PseudoregaliaSavestates.SavePosition(2) end)
RegisterKey("SavePosition 3", function() PseudoregaliaSavestates.SavePosition(3) end)
RegisterKey("SavePosition 4", function() PseudoregaliaSavestates.SavePosition(4) end)