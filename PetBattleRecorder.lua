-- Create main addon table
local CA = {}
CA.frame = nil

-- Function to create the main window
function CA:CreateWindow()

    -- Avoid creating twice
    if self.frame then return end

    -- Create base frame
    local frame = CreateFrame("Frame", "PetBattleRecorder", UIParent, "BackdropTemplate")
    frame:SetSize(400, 300)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame:Hide()

    -- Title text
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("Pet Battle Recorder")

    -- Close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)

    self.frame = frame
end

-- Toggle window
function CA:ToggleWindow()
    if not self.frame then
        self:CreateWindow()
    end

    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

-- Slash command registration
SLASH_PETBATTLERECORDER1 = "/pbr"

SlashCmdList["PETBATTLERECORDER"] = function(msg)
    CA:ToggleWindow()
end

-- Print loaded message
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if addonName == "PetBattleRecorder" then
        print("|cff00ff00Pet Battle Recorder loaded. Type /pbr to open.|r")
    end
end)
