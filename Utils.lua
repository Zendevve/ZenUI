--------------------------------------------------------------------------------
-- ZenHUD - Utils Module
-- Utility Functions for WotLK 3.3.5a
--------------------------------------------------------------------------------

local ADDON_NAME = "ZenHUD"
local ZenHUD = _G.ZenHUD  -- Already created by Config.lua
local Config = ZenHUD.Config  -- Already exported by Config.lua

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------
local Utils = {}

function Utils.Print(msg, debugOnly)
    if debugOnly and not Config:Get("debug") then return end
    DEFAULT_CHAT_FRAME:AddMessage("|cFF66C2FF[ZenHUD]|r " .. msg)
end

function Utils.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils.GetTime()
    return GetTime and GetTime() or 0
end

-- WotLK-compatible timer (C_Timer doesn't exist in 3.3.5a)
-- Creates a temporary frame for delayed callback execution
function Utils.After(delay, callback)
    local frame = CreateFrame("Frame")
    local elapsed = 0
    frame:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        if elapsed >= delay then
            self:SetScript("OnUpdate", nil)
            callback()
        end
    end)
end

-- Export to ZenHUD namespace
ZenHUD.Utils = Utils
