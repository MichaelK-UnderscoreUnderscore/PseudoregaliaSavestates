local UEHelpers = require("UEHelpers")
local Utils = {}
local texts = {}
local text_max = 0
Utils.hook_GameInstance = nil       ---@type UMV_GameInstance_C
Utils.hook_PlayerController = nil   ---@type AMainPlayerController_C
Utils.hook_CheatManager = nil       ---@type UCheatManager
Utils.hook_Console = nil            ---@type UKismetSystemLibrary
Utils.hook_KismetMathLibrary = nil  ---@type UKismetMathLibrary
Utils.hook_KismetTextLibrary = nil  ---@type UKismetTextLibrary
Utils.hook_GameplayStatistics = nil ---@type UGameplayStatics

RegisterCustomProperty({
    ["Name"] = "Cycle",
    ["Type"] = PropertyTypes.IntProperty,
    ["BelongsToClass"] = "/Script/UMG.UserWidget",
    ["OffsetInternal"] = 0x260
})

function Utils.print(str)
    print(str)
    local i = 1
    while texts[i] ~= nil do
        i = i + 1
    end
    if i > text_max then
        text_max = i
    end
    texts[i] = Utils.CreateUIText(Utils.FVector2D(200, 200 + i * 40), Utils.FVector2D(100, 100), str, i)
    texts[i].Cycle = 30
end

---@param str string
---@return FString
function Utils.FString(str)
    return Utils.hook_KismetTextLibrary.Conv_TextToString(FText(str))
end
---@param X double
---@param Y double
---@return FVector2D
function Utils.FVector2D(X, Y)
    return Utils.hook_KismetMathLibrary.MakeVector2D(X, Y)
end

---@param Position FVector2D
---@param Size FVector2D
---@param Text string
---@return UUserWidget
function Utils.CreateUIText(Position, Size, Text, id)
    ---@type UUserWidget : UObject
    local UIWidget = StaticConstructObject(StaticFindObject("/Script/UMG.UserWidget"), Utils.hook_GameInstance, FName("UIWidget_" .. id))
    if UIWidget == nil or not UIWidget:IsValid() then
        print("UIWidget not Created...")
        return nil
    end
    ---@type UWidgetTree : UObject
    local UITree = StaticConstructObject(StaticFindObject("/Script/UMG.WidgetTree"), UIWidget, FName("UITree_" .. id))
    if UITree == nil or not UITree:IsValid() then
        print("UITree not Created...")
        return nil
    end
    ---@type UTextBlock : UObject
    local UIText = StaticConstructObject(StaticFindObject("/Script/UMG.TextBlock"), UITree, FName("UIText_" ..  id))
    if UIText == nil or not UIText:IsValid() then
        print("UIText not Created...")
        return nil
    end
    UIText:SetText(FText(Text))
    UIText:SetShadowColorAndOpacity(Utils.hook_KismetMathLibrary:MakeColor(0, 0, 0, 1))
    UIText:SetShadowOffset(Utils.FVector2D(1, 1))
    UIText.Font.OutlineSettings.OutlineSize = 1
    UIText.Font.OutlineSettings.bSeparateFillAlpha = true
    UITree:SetPropertyValue("RootWidget", UIText)
    UIWidget:SetPropertyValue("WidgetTree", UITree)
    UIWidget:SetPositionInViewport(Position, true)
    UIWidget:SetDesiredSizeInViewport(Size)
    UIWidget:AddToViewport(99)
    return UIWidget
end
Utils.ClientRestart = {}

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function (Context)
    -- The GameInstance holds all the current game states in Pseudo
    Utils.hook_GameInstance = FindFirstOf("MV_GameInstance_C")
    if Utils.hook_GameInstance == nil or not Utils.hook_GameInstance:IsValid() then
        print("GameInstance not found")
    end
    -- Can't use GetPlayerController() it seems...
    Utils.hook_PlayerController = FindFirstOf("MainPlayerController_C")
    if Utils.hook_PlayerController == nil or not Utils.hook_PlayerController:IsValid() then
        print("PlayerController not found")
    end
    Utils.hook_CheatManager = StaticFindObject("/Script/Engine.CheatManager")
    if Utils.hook_CheatManager == nil or not Utils.hook_CheatManager:IsValid() then
        print("CheatManager not found")
    end
    Utils.hook_Console = UEHelpers.GetKismetSystemLibrary(false)
    if Utils.hook_Console == nil or not Utils.hook_Console:IsValid() then
        print("Console not found")
    end
    Utils.hook_KismetMathLibrary = UEHelpers.GetKismetMathLibrary(false)
    if Utils.hook_KismetMathLibrary == nil or not Utils.hook_KismetMathLibrary:IsValid() then
        print("KismetMathLibrary not found")
    end
    Utils.hook_GameplayStatistics = UEHelpers.GetGameplayStatics(false)
    if Utils.hook_GameplayStatistics == nil or not Utils.hook_GameplayStatistics:IsValid() then
        print("GameplayStatistics not found")
    end
    Utils.hook_KismetTextLibrary = StaticFindObject("/Script/Engine.KismetTextLibrary")
    if Utils.hook_KismetTextLibrary == nil or not Utils.hook_KismetTextLibrary:IsValid() then
        print("KismetTextLibrary not found")
    end
    for i, f in pairs(Utils.ClientRestart) do
        f()
    end
end)

LoopAsync(100, function()
    local i = 1
    local status, err = pcall(function()
        while i <= text_max do
            if texts[i] ~= nil and texts[i]:IsValid() then
                texts[i].Cycle = texts[i].Cycle - 1
                local test = texts[i]:GetFName()
                print("Test Cycle " .. texts[i].Cycle .. " for " .. test:ToString())
                if texts[i].Cycle <= 0 then
                    texts[i]:RemoveFromViewport()
                    texts[i] = nil
                end
            else
                texts[i] = nil
            end
            i = i + 1
        end
        while texts[text_max] == nil and text_max > 0 do
            text_max = text_max - 1
        end
    end)
    if not status then
        print("Error: " .. err)
    end
    return false
end)

return Utils