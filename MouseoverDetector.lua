--------------------------------------------------------------------------------
-- Mouseover Detection
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local Utils = ZenHUD.Utils
local StateManager = ZenHUD.StateManager

local MouseoverDetector = {
    checkFrame = nil,
    lastState = false,
}
