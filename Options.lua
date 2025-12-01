--------------------------------------------------------------------------------
-- Options Panel - Blizzard Interface Options integration
--------------------------------------------------------------------------------
local ZenUI = _G.ZenUI
local Config = ZenUI.Config
local Utils = ZenUI.Utils

local OptionsPanel = CreateFrame("Frame", "ZenUIOptionsPanel", UIParent)
OptionsPanel.name = "ZenUI"

-- Title
local title = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("ZenUI - Minimalist UI Automation")

-- Version
local version = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
version:SetText("Version " .. (ZenUI.version or "1.1.0"))

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
local enabledCheck = CreateCheckbox("ZenUIOptionsEnabled", OptionsPanel,
    "Enable ZenUI", "Enable or disable the addon completely")
enabledCheck:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)

enabledCheck:SetScript("OnClick", function(self)
    local enabled = self:GetChecked()
    Config:Set("enabled", enabled)
    Utils.Print(string.format("Addon %s", enabled and "enabled" or "disabled"))
    if enabled and ZenUI.StateManager then
        ZenUI.StateManager:Update()
    end
end)

--------------------------------------------------------------------------------
-- Debug Mode Checkbox
--------------------------------------------------------------------------------
local debugCheck = CreateCheckbox("ZenUIOptionsDebug", OptionsPanel,
    "Debug Mode", "Show detailed debug messages in chat")
debugCheck:SetPoint("TOPLEFT", enabledCheck, "BOTTOMLEFT", 0, -8)

debugCheck:SetScript("OnClick", function(self)
    local debug = self:GetChecked()
    Config:Set("debug", debug)
    Utils.Print(string.format("Debug mode %s", debug and "enabled" or "disabled"))
end)

--------------------------------------------------------------------------------
-- Show on Target Checkbox
--------------------------------------------------------------------------------
local targetCheck = CreateCheckbox("ZenUIOptionsTarget", OptionsPanel,
    "Show UI when targeting", "Automatically show UI when you have a living target")
targetCheck:SetPoint("TOPLEFT", debugCheck, "BOTTOMLEFT", 0, -8)

targetCheck:SetScript("OnClick", function(self)
    local showOnTarget = self:GetChecked()
    Config:Set("showOnTarget", showOnTarget)
    Utils.Print(string.format("Show on target: %s", showOnTarget and "enabled" or "disabled"))
    if ZenUI.StateManager then
        ZenUI.StateManager:Update()
    end
end)

--------------------------------------------------------------------------------
-- Fade Time Slider
--------------------------------------------------------------------------------
local fadeSlider = CreateSlider("ZenUIOptionsFadeTime", OptionsPanel,
    "Fade Animation Duration", 0.1, 2.0, 0.1)
fadeSlider:SetPoint("TOPLEFT", targetCheck, "BOTTOMLEFT", 0, -32)
fadeSlider:SetWidth(300)

-- Value label
local fadeValue = fadeSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
fadeValue:SetPoint("TOP", fadeSlider, "BOTTOM", 0, 0)

fadeSlider:SetScript("OnValueChanged", function(self, value)
    fadeValue:SetText(string.format("%.1f seconds", value))
    Config:Set("fadeTime", value)
end)

--------------------------------------------------------------------------------
-- Grace Period Sliders
--------------------------------------------------------------------------------
-- Combat Grace Period
local combatGraceSlider = CreateSlider("ZenUIOptionsCombatGrace", OptionsPanel,
    "Post-Combat Grace Period", 0, 15, 0.5)
combatGraceSlider:SetPoint("TOPLEFT", fadeSlider, "BOTTOMLEFT", 0, -32)
combatGraceSlider:SetWidth(300)

local combatGraceValue = combatGraceSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
combatGraceValue:SetPoint("TOP", combatGraceSlider, "BOTTOM", 0, 0)

combatGraceSlider:SetScript("OnValueChanged", function(self, value)
    combatGraceValue:SetText(string.format("%.1f seconds", value))
    local grace = Config:Get("gracePeriods")
    grace.combat = value
end)

-- Target Grace Period
local targetGraceSlider = CreateSlider("ZenUIOptionsTargetGrace", OptionsPanel,
    "Post-Target Grace Period", 0, 10, 0.5)
targetGraceSlider:SetPoint("TOPLEFT", combatGraceSlider, "BOTTOMLEFT", 0, -32)
targetGraceSlider:SetWidth(300)

local targetGraceValue = targetGraceSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
targetGraceValue:SetPoint("TOP", targetGraceSlider, "BOTTOM", 0, 0)

targetGraceSlider:SetScript("OnValueChanged", function(self, value)
    targetGraceValue:SetText(string.format("%.1f seconds", value))
    local grace = Config:Get("gracePeriods")
    grace.target = value
end)

-- Mouseover Grace Period
local mouseoverGraceSlider = CreateSlider("ZenUIOptionsMouseoverGrace", OptionsPanel,
    "Post-Mouseover Grace Period", 0, 10, 0.5)
mouseoverGraceSlider:SetPoint("TOPLEFT", targetGraceSlider, "BOTTOMLEFT", 0, -32)
mouseoverGraceSlider:SetWidth(300)

local mouseoverGraceValue = mouseoverGraceSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
mouseoverGraceValue:SetPoint("TOP", mouseoverGraceSlider, "BOTTOM", 0, 0)

mouseoverGraceSlider:SetScript("OnValueChanged", function(self, value)
    mouseoverGraceValue:SetText(string.format("%.1f seconds", value))
    local grace = Config:Get("gracePeriods")
    grace.mouseover = value
end)

--------------------------------------------------------------------------------
-- Character Settings Toggle
--------------------------------------------------------------------------------
local charSettingsBtn = CreateFrame("Button", "ZenUIOptionsCharSettings", OptionsPanel, "UIPanelButtonTemplate")
charSettingsBtn:SetSize(200, 24)
charSettingsBtn:SetPoint("TOPLEFT", mouseoverGraceSlider, "BOTTOMLEFT", 0, -32)
charSettingsBtn:SetText("Use Character-Specific Settings")

local charSettingsLabel = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
charSettingsLabel:SetPoint("LEFT", charSettingsBtn, "RIGHT", 8, 0)
charSettingsLabel:SetText("(Currently: Account-Wide)")

charSettingsBtn:SetScript("OnClick", function(self)
    local enabled = Config:ToggleCharacterSettings()
    if enabled then
        Utils.Print("Switched to character-specific settings")
        charSettingsLabel:SetText("(Currently: Character-Specific)")
    else
        Utils.Print("Switched to account-wide settings")
        charSettingsLabel:SetText("(Currently: Account-Wide)")
    end
end)

--------------------------------------------------------------------------------
-- Panel callbacks to load/save settings
--------------------------------------------------------------------------------
OptionsPanel.refresh = function()
    -- Load current settings into UI
    enabledCheck:SetChecked(Config:Get("enabled"))
    debugCheck:SetChecked(Config:Get("debug"))
    targetCheck:SetChecked(Config:Get("showOnTarget"))

    fadeSlider:SetValue(Config:Get("fadeTime"))

    local grace = Config:Get("gracePeriods")
    combatGraceSlider:SetValue(grace.combat)
    targetGraceSlider:SetValue(grace.target)
    mouseoverGraceSlider:SetValue(grace.mouseover)

    -- Update character settings label
    if Config:IsUsingCharacterSettings() then
        charSettingsLabel:SetText("(Currently: Character-Specific)")
    else
        charSettingsLabel:SetText("(Currently: Account-Wide)")
    end
end

OptionsPanel.okay = function()
    -- Settings are saved automatically via Config module
end

OptionsPanel.cancel = function()
    -- User canceled - reload from saved values
    Config:Initialize()
    OptionsPanel.refresh()
end

OptionsPanel.default = function()
    -- Reset to defaults
    Config:ResetToDefaults()
    OptionsPanel.refresh()
    Utils.Print("Settings reset to defaults")
end

-- Register the panel
InterfaceOptions_AddCategory(OptionsPanel)

ZenUI.OptionsPanel = OptionsPanel
