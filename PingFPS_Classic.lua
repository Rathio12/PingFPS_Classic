-- Create Frame with modern Backdrop support (essential for 1.15.8 and 2.05.05)
local frame = CreateFrame("Frame", "PingFPSClassicFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

-- 1. Configuration & Visuals
frame:SetSize(130, 26)
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
frame:SetBackdropColor(0, 0, 0, 0.7)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
text:SetPoint("CENTER", 0, 1)

-- 2. Shift + Left Click Drag Logic
frame:SetScript("OnDragStart", function(self)
    if IsShiftKeyDown() then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save position immediately
    local point, _, _, x, y = self:GetPoint()
    if not PingFPSClassicDB then PingFPSClassicDB = {} end
    PingFPSClassicDB.point = point
    PingFPSClassicDB.x = x
    PingFPSClassicDB.y = y
end)

-- 3. Update Logic (FPS & Ping)
local timer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer < 1 then return end
    timer = 0

    local fps = floor(GetFramerate())
    local _, _, _, worldPing = GetNetStats()
    text:SetFormattedText("FPS: |cffffffff%d|r  MS: |cffffffff%d|r", fps, worldPing or 0)
end)

-- 4. Initialization (Loading Saved Position)
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon ~= "PingFPS_Classic" then return end
    
    -- Load DB or set defaults
    if not PingFPSClassicDB then 
        PingFPSClassicDB = { point = "CENTER", x = 0, y = 0 } 
    end

    -- Apply Saved Position
    self:ClearAllPoints()
    self:SetPoint(PingFPSClassicDB.point, UIParent, PingFPSClassicDB.point, PingFPSClassicDB.x, PingFPSClassicDB.y)
    
    print("|cff00ff00PingFPS Loaded!|r Shift + Left Click to drag.")
end)