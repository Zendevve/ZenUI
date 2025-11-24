--------------------------------------------------------------------------------
-- Options Panel - Blizzard Interface Options integration
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local Config = ZenHUD.Config
local Utils = ZenHUD.Utils

local OptionsPanel = CreateFrame("Frame", "ZenHUDOptionsPanel", UIParent)
OptionsPanel.name = "ZenHUD"

-- Title
local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("ZenHUD - Minimalist UI Automation")

-- Version
local version = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
version:SetText("Version " .. (ZenHUD.version or "1.1.0"))

-- Subtitle
local subtitle = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
subtitle:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Configure UI automation behavior")

--------------------------------------------------------------------------------
-- Helper functions for creating UI elements
--------------------------------------------------------------------------------
local function CreateCheckbox(name, parent, label, tooltip)
    local check = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
    check.label = _G[name .. "Text"]
    check.label:SetText(label)
    check.tooltipText = tooltip
    return check
end

local function CreateSlider(name, parent, label, minVal, maxVal, step)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    -- Note: SetObeyStepOnDrag() not available in WotLK 3.3.5a

    -- Labels
    _G[name .. "Text"]:SetText(label)
    _G[name .. "Low"]:SetText(minVal)
    _G[name .. "High"]:SetText(maxVal)

    return slider
end

--------------------------------------------------------------------------------
-- Enable/Disable Checkbox
--------------------------------------------------------------------------------
local enabledCheck = CreateCheckbox("ZenHUDOptionsEnabled", OptionsPanel,
    "Enable ZenHUD", "Enable or disable the addon completely")
enabledCheck:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)

enabledCheck:SetScript("OnClick", function(self)
    local enabled = self:GetChecked()
    Config:Set("enabled", enabled)
    Utils.Print(string.format("Addon %s", enabled and "enabled" or "disabled"))
    if enabled and ZenHUD.StateManager then
        ZenHUD.StateManager:Update()
    end
end)

--------------------------------------------------------------------------------
-- Debug Mode Checkbox
--------------------------------------------------------------------------------
local debugCheck = CreateCheckbox("ZenHUDOptionsDebug", OptionsPanel,
    "Debug Mode", "Show detailed debug messages in chat")
debugCheck:SetPoint("TOPLEFT", enabledCheck, "BOTTOMLEFT", 0, -8)

debugCheck:SetScript("OnClick", function(self)
    local debug = self:GetChecked()
    Config:Set("debug", debug)
    Utils.Print(string.format("Debug mode %s", debug and "enabled" or "disabled"))
