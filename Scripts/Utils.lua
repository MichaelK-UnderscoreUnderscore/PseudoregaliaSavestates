PseudoregaliaUtils = {}
local UEHelpers = require("UEHelpers")
-- Info Variables
local version = 2
local authors = {"MichaelK__"}
local origin  = "PseudoregaliaSavestates"
-- Local Variables
local hooks = {}
local activeKeybinds = {}
local console = nil
local consoleTexts = {}
local log_file = "PR_Helper_print_" .. os.time() .. ".log"

-- Local Setting Variables
local ConsoleLines = 20

-- Meta Functions
function PseudoregaliaUtils.GetVersion() return version end ---@return int32
function PseudoregaliaUtils.GetAuthors() return authors end ---@return TArray<string>
function PseudoregaliaUtils.GetOrigin() return origin end ---@return string
function PseudoregaliaUtils.minVersion(ver--[[int32]]) return version <= ver end ---@return boolean
function PseudoregaliaUtils.hasAuthor(auth --[[string]]) return authors.Contains(auth) end ---@return boolean
function PseudoregaliaUtils.isOrigin(orig --[[string]]) return origin == orig end ---@return boolean

-- Hook Functions
---@return AMainPlayerController_C?
function PseudoregaliaUtils.hook_PlayerController()
    if hooks["PlayerController"] == nil or not hooks["PlayerController"]:IsValid() then
        hooks["PlayerController"] = FindFirstOf("MainPlayerController_C")
    end
    if hooks["PlayerController"] == nil or not hooks["PlayerController"]:IsValid() then
        print("PlayerController not found\n")
        return nil
    end
    return hooks["PlayerController"]
end
---@return UMV_GameInstance_C?
function PseudoregaliaUtils.hook_GameInstance()
    if hooks["GameInstance"] == nil or not hooks["GameInstance"]:IsValid() then
        hooks["GameInstance"] = FindFirstOf("MV_GameInstance_C")
    end
    if hooks["GameInstance"] == nil or not hooks["GameInstance"]:IsValid() then
        print("GameInstance not found\n")
        return nil
    end
    return hooks["GameInstance"]
end
---@return UKismetSystemLibrary?
function PseudoregaliaUtils.hook_KismetSystemLibrary()
    if hooks["KismetSystemLibrary"] == nil or not hooks["KismetSystemLibrary"]:IsValid() then
        hooks["KismetSystemLibrary"] = UEHelpers.GetKismetSystemLibrary()
    end
    if hooks["KismetSystemLibrary"] == nil or not hooks["KismetSystemLibrary"]:IsValid() then
        print("KismetSystemLibrary not found\n")
        return nil
    end
    return hooks["KismetSystemLibrary"]
end
---@return UKismetTextLibrary?
function PseudoregaliaUtils.hook_KismetMathLibrary()
    if hooks["KismetMathLibrary"] == nil or not hooks["KismetMathLibrary"]:IsValid() then
        hooks["KismetMathLibrary"] = UEHelpers.GetKismetMathLibrary()
    end
    if hooks["KismetMathLibrary"] == nil or not hooks["KismetMathLibrary"]:IsValid() then
        print("KismetMathLibrary not found\n")
        return nil
    end
    return hooks["KismetMathLibrary"]
end
---@return UKismetInputLibrary?
function PseudoregaliaUtils.hook_KismetInputLibrary()
    if hooks["KismetInputLibrary"] == nil or not hooks["KismetInputLibrary"]:IsValid() then
        hooks["KismetInputLibrary"] = FindFirstOf("KismetInputLibrary")
    end
    if hooks["KismetInputLibrary"] == nil or not hooks["KismetInputLibrary"]:IsValid() then
        hooks["KismetInputLibrary"] = StaticConstructObject(StaticFindObject("/Script/Engine.KismetInputLibrary"), UEHelpers.GetWorld(), FName("KismetInputLibrary"))
    end
    if hooks["KismetInputLibrary"] == nil or not hooks["KismetInputLibrary"]:IsValid() then
        print("KismetInputLibrary not found\n")
        return nil
    end
    return hooks["KismetInputLibrary"]
end
-- Helper Functions

---@param X number
---@param Y number
---@return FVector2D?
function PseudoregaliaUtils.FVector2D(X, Y)
    local MathLib = PseudoregaliaUtils.hook_KismetMathLibrary()
    if MathLib == nil then
        print("KismetMathLibrary not found\n")
        return nil
    end
    return MathLib.MakeVector2D(X, Y)
end



---Print to both the UE4SS Console, a log file and to the in game screen.
---@param str string
function PseudoregaliaUtils.print(str)
    -- when str ends with \n, remove it.
    if string.sub(str, -2) ~= "\n" then
        str = str .. "\n"
    end

    print(str)

    local file = io.open(log_file, "a")
    if file ~= nil then
        file:write("[" .. os.clock() .. "] " .. str)
        file:close()
    else
        print("Error opening file\n")
    end

    local GameInstance = PseudoregaliaUtils.hook_GameInstance()
    if GameInstance == nil then
        return
    end
    if console == nil then
        ---@type UUserWidget
        console = FindFirstOf("PseudoregaliaUtils_Console_Display")
    end
    if not console:IsValid() then
        console = StaticConstructObject(StaticFindObject("/Script/UMG.UserWidget"), GameInstance, FName("PseudoregaliaUtils_Console_Display"))
        if not console:IsValid() then
            print("Error creating Display Console...\n")
            return
        end
    end
    if console.WidgetTree == nil or not console.WidgetTree:IsValid() then
        console.WidgetTree = StaticConstructObject(StaticFindObject("/Script/UMG.WidgetTree"), console, FName("PseudoregaliaUtils_Console_Display_Tree"))
        if not console.WidgetTree:IsValid() then
            print("Error creating Display Console Tree...\n")
            return
        end
    end
    if console.WidgetTree.RootWidget == nil or not console.WidgetTree.RootWidget:IsValid() then
        console.WidgetTree.RootWidget = StaticConstructObject(StaticFindObject("/Script/UMG.TextBlock"), console.WidgetTree, FName("PseudoregaliaUtils_Console_Display_Text"))
        if not console.WidgetTree.RootWidget:IsValid() then
            print("Error creating Display Console Text...\n")
            return
        end
    end
    local text = console.WidgetTree.RootWidget:GetText()
    text = text:ToString()
    text = text .. str
    local tmp_text = text
    local count = 0
    while tmp_text ~= nil do
        count = count + 1
        tmp_text = string.match(tmp_text, "\n(.*)")
    end
    while count > ConsoleLines do
        text = string.match(text, "\n(.*)")
        count = count - 1
    end
    while count < ConsoleLines do
        text = "\n" .. text
        count = count + 1
    end
    console.WidgetTree.RootWidget:SetText(FText(text))
    console:SetPositionInViewport(PseudoregaliaUtils.FVector2D(200, 200), true)
    while count > 1 do
        consoleTexts[count] = consoleTexts[count - 1]
        count = count - 1
    end
    consoleTexts[1] = { creation = os.time(), text = str }
    console:AddToViewport(99)
end

---@param KeyBindName string -- required
---@param f_Callable function -- required
---@param Key Key -- required
---@param ModifierKey TArray<ModifierKey> -- required
---@param OverwriteMode boolean -- default = false
function PseudoregaliaUtils.RegisterKey(KeyBindName, f_Callable, Key, ModifierKey, OverwriteMode)
    if KeyBindName == nil or f_Callable == nil or Key == nil or ModifierKey == nil then
        print("KeyBindName, Callable, Key, and ModifierKey are required\n")
        return
    end
    if OverwriteMode == nil then OverwriteMode = false end
    if (activeKeybinds[KeyBindName] and not OverwriteMode) then
        print("KeyBindName already registered\n")
        return
    end
    activeKeybinds[KeyBindName] = RegisterKeyBind(Key, ModifierKey, f_Callable)
end

LoopAsync(100, function ()
    if console ~= nil and console:IsValid() then
        for i = 0, ConsoleLines do
            if consoleTexts[i] ~= nil and os.difftime(os.time(), consoleTexts[i].creation) > 3 then
                local text = console.WidgetTree.RootWidget:GetText():ToString()
                text = string.gsub(text, consoleTexts[i].text, "\n", 1)
                console.WidgetTree.RootWidget:SetText(FText(text))
                consoleTexts[i] = nil
            end
        end
    end
    return false
end)

return PseudoregaliaUtils  