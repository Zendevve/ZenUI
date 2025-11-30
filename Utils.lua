--------------------------------------------------------------------------------
-- ZenUI - Utils Module
-- Utility Functions for WotLK 3.3.5a
--------------------------------------------------------------------------------

local ADDON_NAME = "ZenUI"
local ZenUI = _G.ZenUI  -- Already created by Config.lua
local Config = ZenUI.Config  -- Already exported by Config.lua

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------
local Utils = {}

function Utils.Print(msg, debugOnly)
    if debugOnly and not Config:Get("debug") then return end
    DEFAULT_CHAT_FRAME:AddMessage("|cFF66C2FF[ZenUI]|r " .. msg)
end

function Utils.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils.GetTime()
    return GetTime and GetTime() or 0
end

-- WotLK-compatible timer (C_Timer doesn't exist in 3.3.5a)
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

-- Export to ZenUI namespace
ZenUI.Utils = Utils
