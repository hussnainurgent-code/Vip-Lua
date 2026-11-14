-- HUSSNAINxPUBG MERGED FILE
-- Embedded license system + BRPlayerCharacterBase module

-- ===== EMBEDDED HUSSNAINxPUBG KEY LOGIN SYSTEM =====
local Vector2D = import("Vector2D")
local LinearColor = import("LinearColor")
local SlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")

-- ============================================================================
-- CONFIG - HUSSNAINxPUBG BRANDING (Updated with logging.lua server)
-- ============================================================================
local CONFIG = {
    LOGIN_URL       = "https://hussnainbroluakey.pythonanywhere.com/connect",
    HEARTBEAT_URL   = "https://hussnainbroluakey.pythonanywhere.com/heartbeat",
    GAME_NAME       = "pubg",
    BRAND_NAME      = "HUSSNAINxPUBG",
    BRAND_SUB       = "PREMIUM ACCESS",
    SUPPORT_TEXT    = "Get Key / Support : @HUSSNAINxPUBG",
    TELEGRAM_URL    = "https://t.me/HUSSNAINxPUBG_Official",
    TELEGRAM_HANDLE = "@HUSSNAINxPUBG",
    DEVELOPER       = "@HUSSNAIN",
    FOOTER_LEFT     = "[+] 100% ID SAFE",
    FOOTER_MID      = ">> OWNER @HUSSNAIN",
    FOOTER_RIGHT    = "[*] PREMIUM FEATURES",
}

-- ============================================================================
-- DEVICE BASE PATH DETECTION
-- ============================================================================
local function DetectBasePath()
    local pkgs = {
        "com.tencent.ig", "com.pubg.imobile", "com.pubg.krmobile",
        "com.vng.pubgmobile", "com.rekoo.pubg", "com.rekoo.pubgm"
    }
    for _, pkg in ipairs(pkgs) do
        local p = "/storage/emulated/0/Android/data/" .. pkg .. "/files/config.ini"
        local f = io.open(p, "r")
        if f then f:close() return "/storage/emulated/0/Android/data/" .. pkg .. "/files/" end
    end
    for _, pkg in ipairs(pkgs) do
        local p = "/storage/emulated/0/Android/data/" .. pkg .. "/files/UE4Game/"
        local f = io.open(p, "r")
        if f then f:close() return "/storage/emulated/0/Android/data/" .. pkg .. "/files/" end
    end
    return "/storage/emulated/0/Android/data/com.pubg.imobile/files/"
end

local BASE_PATH = DetectBasePath()

local HUSSNAINxPUBG_KEY_PATHS = {
    BASE_PATH .. "keys.txt",
    BASE_PATH .. "HUSSNAINxPUBG_Key.txt",
    BASE_PATH .. "HUSSNAINxPUBG/keys.txt",
    BASE_PATH .. "HUSSNAINxPUBG/HUSSNAINxPUBG_Key.txt",
    BASE_PATH .. "HUSSNAINxPUBGCONFIG/keys.txt",
    BASE_PATH .. "HUSSNAINxPUBGCONFIG/key.txt",
    BASE_PATH .. "UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/keys.txt",
    BASE_PATH .. "UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/keys.txt",
    "Documents/keys.txt",
    "Documents/HUSSNAINxPUBG/keys.txt",
    "../Documents/keys.txt",
    "UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/keys.txt",
    "UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/keys.txt"
}

local UID_FILE_PATHS = {
    BASE_PATH .. "uid.txt",
    BASE_PATH .. "HUSSNAINxPUBG/uid.txt",
    BASE_PATH .. "HUSSNAINxPUBGCONFIG/uid.txt",
    BASE_PATH .. "UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/uid.txt"
}

pcall(function()
    local home = os.getenv("HOME")
    if home and home ~= "" then
        table.insert(HUSSNAINxPUBG_KEY_PATHS, home .. "/Documents/HUSSNAINxPUBG/keys.txt")
        table.insert(HUSSNAINxPUBG_KEY_PATHS, home .. "/Documents/keys.txt")
    end
end)

-- ============================================================================
-- REAL DEVICE HWID (7 SOURCES)
-- ============================================================================
local function getDeviceId()
    if _G._CURRENT_USER_HWID and _G._CURRENT_USER_HWID ~= "" and _G._CURRENT_USER_HWID ~= "UNKNOWN" then
        return _G._CURRENT_USER_HWID
    end
    local hwid = nil

    pcall(function()
        local Lib = import("STExtraBlueprintFunctionLibrary")
        if Lib and Lib.GetDeviceID then
            local did = Lib.GetDeviceID()
            if did and did ~= "" then hwid = did end
        end
    end)

    if not hwid or hwid == "" then
        pcall(function()
            local KSL = import("KismetSystemLibrary")
            if KSL and KSL.GetDeviceId then
                local did = KSL:GetDeviceId()
                if did and did ~= "" then hwid = did end
            end
            if (not hwid or hwid == "") and KSL and KSL.GetDeviceIdOS then
                local did = KSL:GetDeviceIdOS()
                if did and did ~= "" then hwid = did end
            end
        end)
    end

    if not hwid or hwid == "" then
        pcall(function()
            local GS = import("GameplayStatics")
            if GS and GS.GetDeviceId then
                local did = GS:GetDeviceId()
                if did and did ~= "" then hwid = did end
            end
        end)
    end

    if not hwid or hwid == "" then
        pcall(function()
            local aid = os.getenv("ANDROID_ID")
            if aid and aid ~= "" then hwid = aid end
        end)
    end

    if not hwid or hwid == "" then
        pcall(function()
            for _, p in ipairs(UID_FILE_PATHS) do
                local f = io.open(p, "r")
                if f then
                    local saved = f:read("*all")
                    f:close()
                    if saved then
                        saved = saved:gsub("%s+", "")
                        if #saved >= 3 then hwid = saved break end
                    end
                end
            end
        end)
    end

    if not hwid or hwid == "" then
        hwid = "DEV-" .. tostring(math.random(100000, 999999)) .. tostring(os.time())
        pcall(function()
            for _, p in ipairs(UID_FILE_PATHS) do
                local w = io.open(p, "w")
                if w then w:write(hwid) w:close() break end
            end
        end)
    end

    hwid = tostring(hwid):gsub("[^A-Za-z0-9%-_]", "")
    _G._CURRENT_USER_HWID = hwid
    return hwid
end

local function getUIDFromPC()
    local uid = nil
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD.GetPlayerController and slua_GameFrontendHUD:GetPlayerController()
        if pc then
            if pc.UID then uid = tostring(pc.UID) end
            if (not uid or uid == "" or uid == "0") and pc.PlayerState and pc.PlayerState.UID then
                uid = tostring(pc.PlayerState.UID)
            end
        end
    end)
    if uid == "" or uid == "0" then uid = nil end
    return uid
end

local function getSerial()
    local hwid = getDeviceId()
    if hwid and hwid ~= "" and not hwid:match("^DEV%-") then return hwid end
    local uid = getUIDFromPC()
    if uid and uid ~= "" then return uid end
    return hwid or "UNKNOWN"
end

-- ============================================================================
-- MULTI-PATH KEY SAVE / READ / DELETE
-- ============================================================================
local function SaveKeyToAllPaths(key)
    if not key or key == "" then return end
    key = tostring(key):gsub("%s+", ""):gsub("^@", "")

    pcall(function()
        if Client and Client.SaveStringToFile then
            Client.SaveStringToFile(key, "SaveGames/keys.txt")
            Client.SaveStringToFile(key, "keys.txt")
        end
    end)

    for _, fullPath in ipairs(HUSSNAINxPUBG_KEY_PATHS) do
        pcall(function()
            local dir = fullPath:match("(.+)/[^/]+$")
            if dir then os.execute("mkdir -p \"" .. dir .. "\" 2>/dev/null") end
            local f = io.open(fullPath, "w")
            if f then f:write(key) f:close() end
        end)
    end
end

local function ReadKeyFromAllPaths()
    local okEngine, engineKey = pcall(function()
        if Client and Client.LoadFileToString then
            local str = Client.LoadFileToString("SaveGames/keys.txt")
            if (not str or str == "") and Client.LoadFileToString then
                str = Client.LoadFileToString("keys.txt")
            end
            return str
        end
    end)
    if okEngine and engineKey and type(engineKey) == "string" then
        local trimmed = engineKey:gsub("%s+", ""):gsub("^@", "")
        if #trimmed >= 3 then return trimmed end
    end

    for _, fullPath in ipairs(HUSSNAINxPUBG_KEY_PATHS) do
        local ok, content = pcall(function()
            local f = io.open(fullPath, "r")
            if f then local c = f:read("*a") f:close() return c end
        end)
        if ok and content and type(content) == "string" then
            local trimmed = content:gsub("%s+", ""):gsub("^@", "")
            if #trimmed >= 3 then return trimmed end
        end
    end
    return nil
end

local function DeleteKeyFromAllPaths()
    pcall(function()
        if Client and Client.SaveStringToFile then
            Client.SaveStringToFile("", "SaveGames/keys.txt")
            Client.SaveStringToFile("", "keys.txt")
        end
    end)
    for _, fullPath in ipairs(HUSSNAINxPUBG_KEY_PATHS) do
        pcall(function() os.remove(fullPath) end)
    end
end

local function saveKeyToFile(key) _G._LICENSE_KEY = key SaveKeyToAllPaths(key) end
local function readKeyFromFile() return ReadKeyFromAllPaths() end
local function deleteKeyFile() _G._LICENSE_KEY = nil DeleteKeyFromAllPaths() end
local function getCurrentKey()
    if _G._LICENSE_KEY and _G._LICENSE_KEY ~= "" then return _G._LICENSE_KEY end
    return ReadKeyFromAllPaths()
end

-- ============================================================================
-- SIGN/HASH SYSTEM (ANTI-TAMPER)
-- ============================================================================
local function GenerateSign(user_key, hwid, timestamp, nonce)
    local str = tostring(user_key) .. "HUSSNAINxPUBG" .. tostring(hwid) .. "mod" .. tostring(timestamp) .. tostring(nonce)
    local hash = 5381
    for i = 1, #str do
        hash = (hash * 33 + string.byte(str, i)) % 4294967296
    end
    return tostring(math.floor(hash % 2147483647))
end

-- ============================================================================
-- MAP REASON
-- ============================================================================
local function mapReason(reason)
    if not reason then return "nonet" end
    if reason == "USER BLOCKED" then return "blocked" end
    if reason == "EXPIRED KEY" then return "expired" end
    if reason == "MAX DEVICE REACHED" then return "device_limit" end
    if reason == "USER OR GAME NOT REGISTERED" then return "invalid" end
    if reason == "INVALID SIGNATURE" then return "invalid_sign" end
    if reason == "EXPIRED REQUEST" then return "expired_request" end
    return "nonet"
end

-- ============================================================================
-- LICENSE CHECK API (WITH SIGN/HASH) - Using luakeyHUSSNAINxPUBG server
-- ============================================================================
local function checkLicense(key, serial, callback)
    local httpMgr = nil
    pcall(function()
        httpMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
    end)
    if not httpMgr or not httpMgr.Post then
        callback(false, "nonet", nil)
        return
    end

    local timestamp = os.time()
    math.randomseed(timestamp)
    local nonce = math.random(100000, 999999)
    local sign = GenerateSign(key, serial, timestamp, nonce)

    local headers = { ["Content-Type"] = "application/x-www-form-urlencoded" }
    local body = string.format(
        "game=%s&user_key=%s&serial=%s&timestamp=%d&nonce=%d&sign=%s&auth_mode=key_auth",
        CONFIG.GAME_NAME, key, serial, timestamp, nonce, sign
    )

    httpMgr:Post(CONFIG.LOGIN_URL, headers, body, nil, function(ok, response)
        if ok and response then
            if response:find("\"status\"%s*:%s*true") then
                if response:find("\"data\"%s*:") then
                    local expiry = nil
                    pcall(function()
                        expiry = response:match("\"expiry\"%s*:%s*(%d+)")
                        if not expiry then expiry = response:match("\"days\"%s*:%s*(%d+)") end
                    end)
                    callback(true, nil, expiry)
                    return
                end
            end
            local reason = nil
            pcall(function()
                if response then reason = response:match("\"reason\"%s*:%s*\"([^\"]+)\"") end
            end)
            callback(false, mapReason(reason), nil)
        else
            callback(false, "nonet", nil)
        end
    end, 15)
end

-- ============================================================================
-- HEARTBEAT API (WITH SIGN) - Using luakeyHUSSNAINxPUBG server
-- ============================================================================
local function sendHeartbeat(key, serial)
    pcall(function()
        if not key or not serial then return end
        local httpMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
        if not httpMgr or not httpMgr.Post then return end

        local timestamp = os.time()
        math.randomseed(timestamp)
        local nonce = math.random(100000, 999999)
        local sign = GenerateSign(key, serial, timestamp, nonce)

        local headers = { ["Content-Type"] = "application/x-www-form-urlencoded" }
        local body = string.format(
            "user_key=%s&serial=%s&timestamp=%d&nonce=%d&sign=%s",
            key, serial, timestamp, nonce, sign
        )
        httpMgr:Post(CONFIG.HEARTBEAT_URL, headers, body, nil, function(ok, response) end, 10)
    end)
end

-- ============================================================================
-- OPEN TELEGRAM
-- ============================================================================
local function openTelegram()
    pcall(function()
        local KSL = import("KismetSystemLibrary")
        if KSL and KSL.LaunchURL then KSL.LaunchURL(CONFIG.TELEGRAM_URL) end
    end)
end

-- ============================================================================
-- GET MSG BOX
-- ============================================================================
local MsgBox = nil
local function GetMsgBox()
    if MsgBox and MsgBox.Show then return MsgBox end
    local candidates = {
        "client.slua.logic.common.logic_common_msg_box",
        "client.slua.logic.message_box",
        "logic_common_msg_box",
        "message_box"
    }
    for _, p in ipairs(candidates) do
        local ok, mod = pcall(require, p)
        if ok and mod and mod.Show then MsgBox = mod return MsgBox end
        if package.loaded[p] and package.loaded[p].Show then MsgBox = package.loaded[p] return MsgBox end
    end
    return nil
end

local function showMsgBox(title, body)
    pcall(function()
        local msgBox = GetMsgBox()
        if msgBox and msgBox.Show then msgBox.Show(4, title, body) end
    end)
end

-- ============================================================================
-- POPUP 2: WELCOME DIALOG
-- ============================================================================
_G._WELCOME_SHOWN = _G._WELCOME_SHOWN or false

local function ShowWelcomeDialog(serial, expiryDays, forceShow)
    if _G._WELCOME_SHOWN and not forceShow then return end
    _G._WELCOME_SHOWN = true

    pcall(function()
        local Msg = GetMsgBox()
        if not Msg or not Msg.Show then return end

        local daysStr = "Permanent VIP"
        if expiryDays and tonumber(expiryDays) and tonumber(expiryDays) > 0 then
            daysStr = tostring(expiryDays) .. " Days Remaining"
        end

        local hwidStr = tostring(serial or "")
        if #hwidStr > 16 then hwidStr = hwidStr:sub(1, 16) .. "..." end

        local welcomeBody = table.concat({
            "Welcome to " .. CONFIG.BRAND_NAME .. " Framework",
            "----------------------------------------",
            "License Status  : Active VIP (Verified)",
            "Validity Period : " .. daysStr,
            "Build Version   : " .. CONFIG.BRAND_NAME .. " v1.0",
            "Security Shield : Memory Bypass Active",
            "Device HWID     : " .. hwidStr,
            "----------------------------------------",
            "Access menu via Settings -> " .. CONFIG.BRAND_NAME .. " tab",
            "",
            "Official Channel : " .. CONFIG.TELEGRAM_HANDLE,
            "Developer        : " .. CONFIG.DEVELOPER
        }, string.char(10))

        Msg.Show(2, CONFIG.BRAND_NAME, welcomeBody,
            function() openTelegram() end,
            function() end,
            "Telegram", "Continue")
    end)
end

-- ============================================================================
-- POPUP 1: KEY INPUT POPUP (CHAT ROOM HACK)
-- ============================================================================
local UIManager = nil
pcall(function()
    local ok, ui_mgr = pcall(require, "client.slua_ui_framework.manager")
    if ok then UIManager = ui_mgr end
end)

_G._KEY_POPUP_ACTIVE = false
_G._LICENSE_OK = _G._LICENSE_OK or false
_G._AUTH_IN_PROGRESS = _G._AUTH_IN_PROGRESS or false
_G._REJECT_DIALOG_ACTIVE = false

local ShowKeyInputPopup = nil

local function ScheduleReopenKeyPopup(onSuccessCallback)
    if _G._LICENSE_OK or _G._AUTH_IN_PROGRESS or _G._KEY_POPUP_ACTIVE or _G._REJECT_DIALOG_ACTIVE then return end
    local ticker = pcall(require, "common.time_ticker") and require("common.time_ticker")
    if ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.25, function()
            if not _G._LICENSE_OK and not _G._AUTH_IN_PROGRESS and not _G._KEY_POPUP_ACTIVE and not _G._REJECT_DIALOG_ACTIVE then
                if ShowKeyInputPopup then ShowKeyInputPopup(onSuccessCallback) end
            end
        end)
    end
end

ShowKeyInputPopup = function(onSuccessCallback)
    if _G._LICENSE_OK or _G._KEY_POPUP_ACTIVE or _G._AUTH_IN_PROGRESS or _G._REJECT_DIALOG_ACTIVE then return end
    _G._KEY_POPUP_ACTIVE = true

    local okChat, ChatRoom = pcall(require, "client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
    if not UIManager then
        local okUI, ui_mgr = pcall(require, "client.slua_ui_framework.manager")
        if okUI then UIManager = ui_mgr end
    end

    if not okChat or not ChatRoom or not UIManager or not UIManager.ShowUI or not UIManager.UI_Config or not UIManager.UI_Config.ui_chat_room_password then
        _G._KEY_POPUP_ACTIVE = false
        pcall(function()
            local msgBox = GetMsgBox()
            if msgBox and msgBox.Show then
                msgBox.Show(2, "Activation Required",
                    "A valid VIP license key is required to activate.\n" ..
                    "----------------------------------------\n" ..
                    "Build Version    : " .. CONFIG.BRAND_NAME .. "\n" ..
                    "----------------------------------------\n" ..
                    "To purchase an active key, contact:\n" ..
                    "Official Channel : " .. CONFIG.TELEGRAM_HANDLE .. "\n" ..
                    "Developer        : " .. CONFIG.DEVELOPER,
                    function() openTelegram() end,
                    function() ShowKeyInputPopup(onSuccessCallback) end,
                    "Telegram", "Reapply Key")
            end
        end)
        return
    end

    pcall(function()
        local okStrUtil, StringUtil = pcall(require, "common.string_util")
        if okStrUtil and StringUtil then
            if not _G._Orig_GetValidString_EnglishOrNumber then
                _G._Orig_GetValidString_EnglishOrNumber = StringUtil.GetValidString_EnglishOrNumber
            end
            StringUtil.GetValidString_EnglishOrNumber = function(orgStr, maxLen)
                if _G._KEY_POPUP_ACTIVE then
                    return tostring(orgStr or ""):gsub("[\r\n\t ]", "")
                end
                if _G._Orig_GetValidString_EnglishOrNumber then
                    return _G._Orig_GetValidString_EnglishOrNumber(orgStr, maxLen)
                end
                return orgStr
            end
        end
    end)

    pcall(function()
        local okPsw, CUIPsw = pcall(require, "client.slua.umg.lobby_chat.chatroom.ui_chat_room_password")
        if okPsw and CUIPsw then
            local impl = CUIPsw.__inner_impl or CUIPsw
            if impl then
                if not _G._Orig_OnPasswordTextChanged then
                    _G._Orig_OnPasswordTextChanged = impl.OnPasswordTextChanged
                end
                impl.OnPasswordTextChanged = function(self, txt)
                    if _G._KEY_POPUP_ACTIVE then
                        if self and self.UIRoot and self.UIRoot.InputBox_Psw and self.UIRoot.InputBox_Psw.message_input then
                            local cleanTxt = tostring(txt or ""):gsub("[\r\n\t ]", "")
                            self.UIRoot.InputBox_Psw.message_input:SetText(cleanTxt)
                        end
                    elseif _G._Orig_OnPasswordTextChanged then
                        _G._Orig_OnPasswordTextChanged(self, txt)
                    end
                end

                if not _G._Orig_OnShow_Psw then
                    _G._Orig_OnShow_Psw = impl.OnShow
                end
                impl.OnShow = function(self)
                    if _G._Orig_OnShow_Psw then _G._Orig_OnShow_Psw(self) end
                    if _G._KEY_POPUP_ACTIVE then
                        pcall(function()
                            if self.Common_Popup and self.Common_Popup.SetData then
                                self.Common_Popup:SetData(self, "ENTER VIP LICENSE KEY")
                            end
                        end)
                    end
                end
            end
        end
    end)

    if UIManager and UIManager.CloseUI and not _G._Orig_UIManager_CloseUI then
        _G._Orig_UIManager_CloseUI = UIManager.CloseUI
        UIManager.CloseUI = function(config, queueParamTable)
            if _G._Orig_UIManager_CloseUI then _G._Orig_UIManager_CloseUI(config, queueParamTable) end
            if config and UIManager.UI_Config and config == UIManager.UI_Config.ui_chat_room_password then
                _G._KEY_POPUP_ACTIVE = false
                ScheduleReopenKeyPopup(onSuccessCallback)
            end
        end
    end

    if not _G._Orig_send_join_channel_req then
        _G._Orig_send_join_channel_req = ChatRoom.send_join_channel_req
    end

    ChatRoom.send_join_channel_req = function(arg1, arg2, arg3)
        local enteredKey = (type(arg2) == "string" and arg2 ~= "") and arg2 or (type(arg1) == "string" and arg1 or "")

        pcall(function()
            local ui = UIManager.GetUI and UIManager.GetUI(UIManager.UI_Config.ui_chat_room_password)
            if ui and ui.UIRoot and ui.UIRoot.InputBox_Psw and ui.UIRoot.InputBox_Psw.message_input then
                local boxText = ui.UIRoot.InputBox_Psw.message_input:GetText()
                if boxText and #boxText > #enteredKey then enteredKey = boxText end
            end
        end)

        pcall(function()
            UIManager.CloseUI(UIManager.UI_Config.ui_chat_room_password)
        end)

        ChatRoom.send_join_channel_req = _G._Orig_send_join_channel_req
        _G._KEY_POPUP_ACTIVE = false

        if not enteredKey or enteredKey == "" then
            pcall(function()
                local msgBox = GetMsgBox()
                if msgBox and msgBox.Show then
                    msgBox.Show(1, "License Key Required",
                        "Please enter your VIP license key to activate.\n" ..
                        "----------------------------------------\n" ..
                        "Key input cannot be empty.\n\n" ..
                        "Official Channel : " .. CONFIG.TELEGRAM_HANDLE,
                        function() ShowKeyInputPopup(onSuccessCallback) end,
                        nil, "Retry", "")
                end
            end)
            return
        end

        enteredKey = enteredKey:gsub("%s+", ""):gsub("^@", ""):upper()
        saveKeyToFile(enteredKey)
        _G._AUTH_IN_PROGRESS = true

        local serial = getSerial()
        checkLicense(enteredKey, serial, function(success, reason, expiry)
            _G._AUTH_IN_PROGRESS = false
            if success then
                saveKeyToFile(enteredKey)
                _G._LICENSE_OK = true
                _G._LICENSE_UID = serial
                _G._MOD_EXPIRED = false
                _G._REJECT_DIALOG_ACTIVE = false

                ShowWelcomeDialog(serial, expiry)

                -- Local features enable karo
                pcall(function()
                    for _, feat in ipairs(_G.AK_Features or {}) do
                        if feat.type == "toggle" then feat.val = 1 end
                    end
                end)

                pcall(function()
                    _G._WHA_BYPASS_ACTIVE = true
                    if _G.WHABypass and _G.WHABypass.Init then _G.WHABypass.Init() end
                    if _G.StartNewWallhack then _G.StartNewWallhack() end
                    if _G.StartEnemyCounter then _G.StartEnemyCounter() end
                    if _G.PlayerMapMarker and _G.PlayerMapMarker.Start then
                        _G.PlayerMapMarker:Start()
                    end
                end)

                if onSuccessCallback then pcall(onSuccessCallback) end
            else
                _G._REJECT_DIALOG_ACTIVE = true
                deleteKeyFile()

                if reason == "nonet" then
                    pcall(function()
                        local Msg = GetMsgBox()
                        if Msg and Msg.Show then
                            Msg.Show(2, "Connection Error",
                                "Unable to connect to authentication server.\n" ..
                                "Check your internet or VPN connection and retry.\n" ..
                                "----------------------------------------\n" ..
                                "Official Channel : " .. CONFIG.TELEGRAM_HANDLE .. "\n" ..
                                "Developer        : " .. CONFIG.DEVELOPER,
                                function() _G._REJECT_DIALOG_ACTIVE = false ShowKeyInputPopup(onSuccessCallback) end,
                                function() _G._REJECT_DIALOG_ACTIVE = false ShowKeyInputPopup(onSuccessCallback) end,
                                "Retry", "Reapply Key")
                        else
                            _G._REJECT_DIALOG_ACTIVE = false
                            ScheduleReopenKeyPopup(onSuccessCallback)
                        end
                    end)
                else
                    local reasonText = "Invalid Key or Device Limit Reached"
                    if reason == "invalid" then reasonText = "USER OR GAME NOT REGISTERED"
                    elseif reason == "blocked" then reasonText = "USER BLOCKED"
                    elseif reason == "expired" then reasonText = "EXPIRED KEY"
                    elseif reason == "device_limit" then reasonText = "MAX DEVICE REACHED"
                    elseif reason == "invalid_sign" then reasonText = "INVALID SIGNATURE - TAMPERED"
                    elseif reason == "expired_request" then reasonText = "REQUEST EXPIRED - RETRY"
                    end

                    local rejectBody = table.concat({
                        "Your license could not be verified.",
                        "----------------------------------------",
                        "Failure Reason : " .. reasonText,
                        "License Key    : " .. tostring(enteredKey),
                        "Device HWID    : " .. tostring(serial),
                        "----------------------------------------",
                        "For assistance, device reset, or license renewal:",
                        "Official Channel : " .. CONFIG.TELEGRAM_HANDLE,
                        "Developer        : " .. CONFIG.DEVELOPER
                    }, string.char(10))

                    pcall(function()
                        local Msg = GetMsgBox()
                        if Msg and Msg.Show then
                            Msg.Show(2, "License Verification Failed", rejectBody,
                                function()
                                    _G._REJECT_DIALOG_ACTIVE = false
                                    openTelegram()
                                    ScheduleReopenKeyPopup(onSuccessCallback)
                                end,
                                function()
                                    _G._REJECT_DIALOG_ACTIVE = false
                                    ShowKeyInputPopup(onSuccessCallback)
                                end,
                                "Telegram", "Reapply Key")
                        else
                            _G._REJECT_DIALOG_ACTIVE = false
                            ScheduleReopenKeyPopup(onSuccessCallback)
                        end
                    end)
                end
            end
        end)
    end

    UIManager.ShowUI(UIManager.UI_Config.ui_chat_room_password, "999")

    pcall(function()
        local ui = UIManager.GetUI and UIManager.GetUI(UIManager.UI_Config.ui_chat_room_password)
        if ui then
            rawset(ui, "OnPasswordTextChanged", function(self, txt)
                if self and self.UIRoot and self.UIRoot.InputBox_Psw and self.UIRoot.InputBox_Psw.message_input then
                    local cleanTxt = tostring(txt or ""):gsub("[\r\n\t ]", "")
                    self.UIRoot.InputBox_Psw.message_input:SetText(cleanTxt)
                end
            end)
            if ui.Common_Popup and ui.Common_Popup.SetData then
                pcall(function() ui.Common_Popup:SetData(ui, "ENTER VIP LICENSE KEY") end)
            end
            if ui.UIRoot and ui.UIRoot.InputBox_Psw and ui.UIRoot.InputBox_Psw.message_input then
                pcall(function() ui.UIRoot.InputBox_Psw.message_input:SetMaxLength(999) end)
            end
        end
    end)
end

-- ============================================================================
-- PHONE STATS BRANDING
-- ============================================================================
local function BrandPhoneStatsWidget(ui)
    if not ui or not ui.UIRoot or not ui.UIRoot.TextBlock_quality then return false end
    pcall(function()
        local brand = CONFIG.BRAND_NAME or "HUSSNAINxPUBG"
        ui.UIRoot.TextBlock_quality:SetText(brand)
        local LC = import("LinearColor") or _G.FLinearColor
        local SC = import("SlateColor") or _G.FSlateColor
        if SC and LC then
            pcall(function() ui.UIRoot.TextBlock_quality:SetColorAndOpacity(SC(LC(1, 1, 1, 1))) end)
        end
        ui._HUSSNAINxPUBG_phone_branded = true
    end)
    return true
end

local function ApplyPhoneStatsBranding()
    local targetModules = {
        "GameLua.Mod.Library.Client.UI.IngamePhoneStateUI",
        "client.slua.umg.MainCity.Immersion.MainCity_IngameImmersion_UIBP",
        "MainCity_IngameImmersion_UIBP"
    }

    local function HookPhoneModule(modName)
        pcall(function()
            local mod = package.loaded[modName]
            if not mod then
                local ok, m = pcall(require, modName)
                if ok and m then mod = m end
            end
            local impl = mod and (mod.__inner_impl or mod)
            if impl and type(impl) == "table" and not impl._HUSSNAINxPUBG_phone_hooked then
                local origUpdate = impl.UpdateArtQualityUI
                impl.UpdateArtQualityUI = function(self, a, b)
                    if origUpdate then pcall(origUpdate, self, a, b) end
                    BrandPhoneStatsWidget(self)
                end

                local origInit = impl.InitUI
                impl.InitUI = function(self)
                    if origInit then pcall(origInit, self) end
                    BrandPhoneStatsWidget(self)
                end

                local origBattery = impl.TickRefreshBatteryInfo
                impl.TickRefreshBatteryInfo = function(self)
                    if origBattery then pcall(origBattery, self) end
                    if self._HUSSNAINxPUBG_phone_branded ~= true then
                        BrandPhoneStatsWidget(self)
                    end
                end

                impl._HUSSNAINxPUBG_phone_hooked = true
            end
        end)
    end

    for _, m in ipairs(targetModules) do HookPhoneModule(m) end

    pcall(function()
        local mgr = package.loaded["client.slua_ui_framework.manager"] or _G.UIManager
        if not mgr then
            local ok, m = pcall(require, "client.slua_ui_framework.manager")
            if ok and m then mgr = m end
        end
        if not mgr or not mgr.GetUI then return end

        local candidates = {}
        if mgr.UI_Config_InGame and mgr.UI_Config_InGame.PhoneStateUI then
            table.insert(candidates, mgr.GetUI(mgr.UI_Config_InGame.PhoneStateUI))
        end
        if mgr.UI_Config and mgr.UI_Config.MainCity_IngameImmersion_UIBP then
            table.insert(candidates, mgr.GetUI(mgr.UI_Config.MainCity_IngameImmersion_UIBP))
        end
        if mgr.GetConfigByKey then
            local c1 = mgr.GetConfigByKey("PhoneStateUI")
            if c1 then table.insert(candidates, mgr.GetUI(c1)) end
            local c2 = mgr.GetConfigByKey("MainCity_IngameImmersion_UIBP")
            if c2 then table.insert(candidates, mgr.GetUI(c2)) end
        end

        for _, ui in ipairs(candidates) do
            if ui then BrandPhoneStatsWidget(ui) end
        end
    end)
end
_G.ApplyPhoneStatsBranding = ApplyPhoneStatsBranding
pcall(ApplyPhoneStatsBranding)

-- ============================================================================
-- BOOTSTRAP AUTH
-- ============================================================================
local function BootstrapKeyAuth(character, onSuccessCallback)
    if _G._LICENSE_OK then
        if not _G._WELCOME_SHOWN then
            ShowWelcomeDialog(_G._LICENSE_UID or getSerial(), nil, true)
        end
        if onSuccessCallback then onSuccessCallback() end
        return
    end

    if _G._KEY_POPUP_ACTIVE or _G._AUTH_IN_PROGRESS or _G._REJECT_DIALOG_ACTIVE then return end

    local savedKey = getCurrentKey()
    if savedKey and savedKey ~= "" then
        _G._AUTH_IN_PROGRESS = true
        local serial = getSerial()
        checkLicense(savedKey, serial, function(success, reason, expiry)
            _G._AUTH_IN_PROGRESS = false
            if success then
                _G._LICENSE_OK = true
                _G._LICENSE_UID = serial
                _G._MOD_EXPIRED = false
                ShowWelcomeDialog(serial, expiry)
                if onSuccessCallback then pcall(onSuccessCallback) end
            else
                ShowKeyInputPopup(onSuccessCallback)
            end
        end)
    else
        ShowKeyInputPopup(onSuccessCallback)
    end
end

-- ============================================================================
-- PERIODIC CHECK & HEARTBEAT
-- ============================================================================
local function StartPeriodicCheck(character)
    if _G._PERIODIC_TIMER and _G._PERIODIC_CHAR then
        local stillRunning = false
        pcall(function() stillRunning = slua.isValid(_G._PERIODIC_CHAR.Object) end)
        if stillRunning then return _G._PERIODIC_TIMER end
    end

    local hbTimer = nil
    pcall(function()
        hbTimer = character:AddGameTimer(5, true, function()
            if not slua.isValid(character.Object) then return end
            if not _G._LICENSE_OK then return end
            local key = getCurrentKey()
            local serial = _G._LICENSE_UID or getSerial()
            sendHeartbeat(key, serial)
        end)
    end)
    _G._HEARTBEAT_TIMER = hbTimer

    local timer = nil
    pcall(function()
        timer = character:AddGameTimer(180, true, function()
            if not slua.isValid(character.Object) then return end
            if not _G._LICENSE_OK then return end

            local key = getCurrentKey()
            local serial = _G._LICENSE_UID or getSerial()
            if not key or not serial then return end

            checkLicense(key, serial, function(success, reason)
                if not success and reason ~= "nonet" then
                    _G._LICENSE_OK = false
                    _G._MOD_EXPIRED = true

                    local reasonText = "License is no longer valid"
                    if reason == "expired" then reasonText = "Your key has EXPIRED"
                    elseif reason == "blocked" then reasonText = "Your key has been BLOCKED"
                    elseif reason == "device_limit" then reasonText = "Key locked to another device"
                    end
                    showMsgBox("LICENSE REVOKED", reasonText .. "\n\nPlease restart game and re-apply key.")
                end
            end)
        end)
    end)

    _G._PERIODIC_TIMER = timer
    _G._PERIODIC_CHAR = character
    return timer
end

-- ============================================================================
-- EXPORTS
-- ============================================================================
_G.LicenseSystem = {
    Start = function(character, onSuccess)
        BootstrapKeyAuth(character, onSuccess)
        if character then StartPeriodicCheck(character) end
    end,
    ShowKeyInputPopup = ShowKeyInputPopup,
    ShowWelcomeDialog = ShowWelcomeDialog,
    StartPeriodicCheck = StartPeriodicCheck,
    CheckLicense = checkLicense,
    GetSerial = getSerial,
    GetDeviceId = getDeviceId,
    GetCurrentKey = getCurrentKey,
    SaveKey = saveKeyToFile,
    DeleteKey = deleteKeyFile,
    GenerateSign = GenerateSign,
    ApplyPhoneStatsBranding = ApplyPhoneStatsBranding,
    Config = CONFIG,
    BasePath = BASE_PATH,
    KeyPaths = HUSSNAINxPUBG_KEY_PATHS,
}

function _G.CheckExpiration()
    return not _G._MOD_EXPIRED
end

function _G.ShowExpiryPopup(isExpired)
    if isExpired then showMsgBox("EXPIRED", "License expire ho gayi.") end
end

_G.TryShowWelcome = _G.TryShowWelcome or function() end

print("HUSSNAINxPUBG - LicenseSystem Ready (luakeyHUSSNAINxPUBG server + Real HWID + Multi-Path Key + Sign/Hash)")
-- ===== END EMBEDDED KEY LOGIN SYSTEM =====

-- ============================================================================
-- BRPlayerCharacterBase MODULE
-- ============================================================================

local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {},
  LuaEventContainer = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = {
  Reliable = true,
  Params = {}
}
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Object
  }
}
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int
  }
}
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool
  }
}
local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local ESpecialMovementType = import("ESpecialMovementType")
local ESpiderSwingMoveState = import("ESpiderSwingMoveState")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EParachuteState = import("EParachuteState")
local EMovementMode = import("EMovementMode")
local EStateType = import("EStateType")
local ESTEPoseState = import("ESTEPoseState")
local EGameModeType = import("EGameModeType")
local STExtraGameStateBase = import("STExtraGameStateBase")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig")

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
  BRPlayerCharacterBase.__super._PostConstruct(self)
  self:InitAddSpecialMoveInfo()
  self.bCanNearDeathGiveup = true
  print(bWriteLog and "BRPlayerCharacterBase:_PostConstruct bCanNearDeathGiveup true")
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
  BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
  -- Start the embedded HUSSNAINxPUBG license flow once for this character.
  if _G.LicenseSystem and not _G._LICENSE_START_REQUESTED then
    _G._LICENSE_START_REQUESTED = true
    pcall(function()
      _G.LicenseSystem.Start(self)
    end)
  end
  self:AddControlEvent(self, "MovementModeChangedDelegate", self.HandleOnMovementModeChangedNew, self)
  if self:HasAuthority() and self:CheckAddCheckFallingDistanceComponent() then
    local CheckFallingDistanceComponent_C = import("CheckFallingDistanceComponent")
    if slua.isValid(CheckFallingDistanceComponent_C) and not slua.isValid(self:GetComponentByClass(CheckFallingDistanceComponent_C)) then
      print(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay Add CheckFallingDistanceComponent")
      Game:AddComponent(CheckFallingDistanceComponent_C, self, "CheckFallingDistanceComponent")
    end
  end
  if slua.isValid(self.STCharacterMovement) then
    self.STCharacterMovement.bPositiveBlowUp = true
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy then
    self:AddControlEvent(self, "OnPawnStateDisabled", self.OnPawnStateChange, self)
    self:AddControlEvent(self, "OnPawnStateEnabled", self.OnPawnStateChange, self)
    self:AddControlEventConditionOnly(self, "OnAttrChangeEventDelegate", {
      AttrName = {
        "bCanSelfRescue"
      }
    }, self.CharacterAttrChangeEvent, self)
  end
  if Client then
    printf(bWriteLog and "BRPlayerCharacterBase:ReceiveBeginPlay, PlayerKey:%u ", self.PlayerKey)
    GameplayData.AddCharacter(self.Object)
  else
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FinishedState"
    }, self.HandleFinishedState, self)
  end
end

function BRPlayerCharacterBase:CharacterAttrChangeEvent(uPawn, AttrName, AttrVal)
  BRPlayerCharacterBase.__super.CharacterAttrChangeEvent(self, uPawn, AttrName, AttrVal)
  if self.Object ~= uPawn then
    return
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and AttrName == "bCanSelfRescue" then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_CanSelfRescue", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:OnPawnStateChange(PawnState)
  print("BRPlayerCharacterBase:OnPawnStateChange:", PawnState)
  if PawnState == EPawnState.SwitchPP then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:BroadcastUIMessage("UIMsg_FPPModeChange", 0, "", "")
    end
  end
end

function BRPlayerCharacterBase:HandleFinishedState()
  print(bWriteLog and "BRPlayerCharacterBase:HandleFinishedState", self.STCharacterMovement)
  if slua.isValid(self.STCharacterMovement) and self.STCharacterMovement.SetDynamicSimpleQueryConfigDisable then
    local EDynamicSimpleQueryConfigDisableMask = import("EDynamicSimpleQueryConfigDisableMask")
    self.STCharacterMovement:SetDynamicSimpleQueryConfigDisable(EDynamicSimpleQueryConfigDisableMask.Bit0, true)
  end
end

function BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent()
  if CGameMode and CGameMode.GameModeType and CGameState and CGameState.GameModeID then
    local GameModeType = CGameMode.GameModeType
    local GameModeID = tonumber(CGameState.GameModeID)
    local bModeTypeSatisfy = GameModeType == EGameModeType.ETypicalGameMode or GameModeType == EGameModeType.EFourInOneGameMode or GameModeType == EGameModeType.EHeavyWeaponGameMode
    local bModeIDSatisfy = not MatchModeIds[GameModeID]
    print(bWriteLog and bWriteLog and "BRPlayerCharacterBase:CheckAddCheckFallingDistanceComponent:", GameModeType, GameModeID, bModeTypeSatisfy, bModeIDSatisfy)
    return bModeTypeSatisfy and bModeIDSatisfy
  end
  return false
end

function BRPlayerCharacterBase:LuaHandleParachuteStateChanged(LastParachuteState, NewParachuteState)
  BRPlayerCharacterBase.__super.LuaHandleParachuteStateChanged(self, LastParachuteState, NewParachuteState)
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if NewParachuteState == EParachuteState.PS_Opening then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.SatrtCheckShowParachuteCloseUI then
          uCurrentPlayerControl.CheckParachuteOpenFeature:SatrtCheckShowParachuteCloseUI()
        end
      elseif NewParachuteState == EParachuteState.PS_None then
        if uCurrentPlayerControl.CheckParachuteOpenFeature.RecoverParachuteOpenParam then
          uCurrentPlayerControl.CheckParachuteOpenFeature:RecoverParachuteOpenParam()
        end
        if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
          uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
        end
      end
    end
  end
end

function BRPlayerCharacterBase:OnLanded()
  printf("BRPlayerCharacterBase:OnLanded PlayerKey:%d", self.PlayerKey)
  if self.HandleOnLanded then
    self:HandleOnLanded(-1)
  end
  if not Client then
    local uCurrentPlayerControl = self:GetPlayerControllerSafety()
    if slua.isValid(uCurrentPlayerControl) and uCurrentPlayerControl.CheckParachuteOpenFeature then
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ClearTimerAndState then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ClearTimerAndState()
      end
      if uCurrentPlayerControl.CheckParachuteOpenFeature.ResetCheckShowUI then
        uCurrentPlayerControl.CheckParachuteOpenFeature:ResetCheckShowUI()
      end
    end
  end
end

function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason)
  BRPlayerCharacterBase.__super.ReceiveEndPlay(self, EndPlayReason)
  if Client then
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:IsWarGameMode()
  local uGameState = GameplayData:GetGameState()
  if slua.isValid(uGameState) and Game:IsClassOf(uGameState, STExtraGameStateBase) then
    return uGameState.GameModeType == EGameModeType.EWarGameMode
  else
    return false
  end
end

function BRPlayerCharacterBase:BPOnRecycled()
  print(bWriteLog and string.format("%s BPOnRecycled()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:BPOnRespawned()
  print(bWriteLog and string.format("%s BPOnRespawned()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
  end
end

function BRPlayerCharacterBase:ReceiveOnRecycle()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnRecycle()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.RemoveCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ReceiveOnSpawn()
  print(bWriteLog and string.format("%s IReusable:ReceiveOnSpawn()", Game:GetPlainName(self.Object)))
  if Client then
    self:ResetMeshRelativeLocationAndRotation()
    GameplayData.AddCharacter(self.Object)
  end
end

function BRPlayerCharacterBase:ResetMeshRelativeLocationAndRotation()
  if Game:IsValid(self.Object) and Game:IsValid(self.Mesh) then
    local uDefaultMeshRot = FRotator(0, -90, 0)
    local uDefaultMeshRelativeLoc = FVector(0, 0, 0)
    if self.Mesh.K2_SetRelativeRotation then
      self.Mesh:K2_SetRelativeRotation(uDefaultMeshRot, false, nil, false)
    end
    self:CacheInitialMeshOffset(uDefaultMeshRelativeLoc, uDefaultMeshRot)
    local vRelativeRot = self.Mesh.RelativeRotation
    local vBaseRotationOffset = self.BaseRotationOffset
    local vBaseRotation = Game:QuatToRotator(vBaseRotationOffset)
    print(bWriteLog and bWriteLog and string.format("%s ResetMeshRelativeLocationAndRotation() Mesh.RelativeRotation: %s %s %s   Pawn.BaseRotationOffset:%s %s %s ", Game:GetPlainName(self.Object), tostring(vRelativeRot.Pitch), tostring(vRelativeRot.Yaw), tostring(vRelativeRot.Roll), tostring(vBaseRotation.Pitch), tostring(vBaseRotation.Yaw), tostring(vBaseRotation.Roll)))
  end
end

function BRPlayerCharacterBase:HandleOnMovementModeChangedNew()
  print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged11")
  if Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Swimming and self:CheckBaseIsMoveable() then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChanged22")
    self.CharacterMovement:SetBase(nil, "", true)
  end
  if self.Role == ENetRole.ROLE_AutonomousProxy and Game:IsValid(self.STCharacterMovement) and self.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking and UIManager.UI_Config_InGame.ParachuteOpenUI then
    print(bWriteLog and "BRPlayerCharacterBase:HandleOnMovementModeChangedNew CloseUI")
    UIManager.CloseUI(UIManager.UI_Config_InGame.ParachuteOpenUI)
  end
end

function BRPlayerCharacterBase:BPOnMissPlayerDamageRecord()
end

function BRPlayerCharacterBase:PreAttachedToVehicle()
  local IsDS = UKismetSystemLibrary.IsDedicatedServer(self)
  if not IsDS then
    return
  end
  local MainPlayerController = self:GetPlayerControllerSafety()
  if not slua.isValid(MainPlayerController) then
    return
  end
  local CharacterAvatarComp2_BP = self.CharacterAvatarComp2_BP
  if not slua.isValid(CharacterAvatarComp2_BP) then
    return
  end
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local changedVehicleId = CommerAvatarDataUtil:ChangeVehicleSkinByClothes(MainPlayerController, CharacterAvatarComp2_BP)
  local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
  if changedVehicleId then
    local UAvatarUtils = import("AvatarUtils")
    if UAvatarUtils.GetVehicleShapeBySkinID(changedVehicleId) == ESTExtraVehicleShapeType.VST_Horse then
      local uCurPlayerState = self:GetPlayerStateSafety()
      if slua.isValid(uCurPlayerState) then
        print(bWriteLog and "  BRPlayerCharacterBase:PreAttachedToVehicle. changedVehicleId: " .. tostring(changedVehicleId))
        uCurPlayerState:AddGeneralCount(468, 1, false)
      end
    end
  end
end

function BRPlayerCharacterBase:ParachuteJump()
  local uPlayerController = self:GetControllerSafety()
  if slua.isValid(uPlayerController) then
    if not self:GetEnsure() then
      if uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteJump and uPlayerController:GetCurrentStateType() ~= EStateType.State_ParachuteOpen then
        self:SwitchPoseState(ESTEPoseState.Stand, true, true, true, false)
        uPlayerController:ReInitParachuteItem()
        uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
      end
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump over")
    else
      EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_AI_CALL_PARACHUTE_JUMP, self.Object)
      print(bWriteLog and "BRPlayerCharacterBase:ParachuteJump AI JUMP over, Loc=", tostring(self:K2_GetActorLocation():ToString()))
    end
  end
end

function BRPlayerCharacterBase:OnMovementBaseChangedEvent(uCharacter, uNewMovementBase, uOldMovementBase)
  if uCharacter ~= self.Object then
    return
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase:OnMovementBaseChangedEvent %s, Base: %s -> %s", uCharacter, uOldMovementBase, uNewMovementBase))
  local MedievalCrane = self:GetMedievalCraneFromBase(uNewMovementBase)
  if MedievalCrane and MedievalCrane.AddCharacter then
    MedievalCrane:AddCharacter(self.Object)
  else
    MedievalCrane = self:GetMedievalCraneFromBase(uOldMovementBase)
    if MedievalCrane and MedievalCrane.RemoveCharacter then
      MedievalCrane:RemoveCharacter(self.Object)
    end
  end
end

function BRPlayerCharacterBase:GetMedievalCraneFromBase(Base)
  if not slua.isValid(Base) or not Base.GetOwner then
    return
  end
  local Lifter = Base:GetOwner()
  if not slua.isValid(Lifter) then
    return
  end
  if not Lifter.AddCharacter then
    return
  end
  return Lifter
end

function BRPlayerCharacterBase:CheckForbidFlaregun()
  local uPlayerState = self:GetPlayerStateSafety()
  if not slua.isValid(uPlayerState) then
    return false
  end
  if uPlayerState.CanUseFlaregun == false and self:IsLocallyControlled() then
    local uPlayerController = self:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      uPlayerController:DisplayGameTipWithMsgID(48532)
    end
  end
  return not uPlayerState.CanUseFlaregun
end

function BRPlayerCharacterBase:ServerRPC_NearDeathGiveupRescue()
  self:HandleNearDeathGiveupRescue()
end

function BRPlayerCharacterBase:HandleNearDeathGiveupRescue()
  local uNearDeathComp = self.NearDeatchComponent
  if self:IsNearDeath() and slua.isValid(uNearDeathComp) and self.bCanNearDeathGiveup == true then
    local uPlayerState = self:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      uPlayerState:AddGeneralCount(1613, 1, false)
    end
    uNearDeathComp:TriggerGotoDieExplictly(self.Object)
  end
end

function BRPlayerCharacterBase:RPC_Server_GmPlayAction(actionId)
  log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction.  actionId: " .. tostring(actionId))
  if USTExtraBlueprintFunctionLibrary.IsDevelopment() then
    log(bWriteLog and "  BRPlayerCharacterBase:RPC_Server_GmPlayAction. IsDevelopment actionId: " .. tostring(actionId))
    self:MulticastRPC_GmPlayAction(actionId)
  end
end

function BRPlayerCharacterBase:MulticastRPC_GmPlayAction(actionId)
  if not Client then
    return
  end
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction.  actionId: " .. tostring(actionId))
  local uPlayEmoteComp = self:GetPlayEmoteComponent()
  if not slua.isValid(uPlayEmoteComp) then
    return
  end
  local LogFilter = require("common.log_filter")
  LogFilter.SetLogTreeEnable(true)
  local animCfg = CDataTable.GetTableData("EmoteBPTable", actionId)
  if not animCfg then
    return
  end
  local handlePath = animCfg.Path
  local EmoteHandleAsset = slua.loadObject(handlePath)
  local assetsArray = slua.Array(UEnums.EPropertyClass.Struct, import("/Script/CoreUObject.SoftObjectPath"))
  local handle = EmoteHandleAsset()
  uPlayEmoteComp:OnLoadEmoteAssetBegin(handle, actionId, assetsArray, "")
  log(bWriteLog and "  BRPlayerCharacterBase:MulticastRPC_GmPlayAction. assetsArray:Num(): " .. tostring(assetsArray:Num()))
  local tb = FuncUtil.LuaArrayToTable(assetsArray)
  local asset_util = require("common.asset_util")
  
  local function loadLater()
    uPlayEmoteComp:OnLoadEmoteAssetEnd(handle, actionId, 0)
  end
  
  asset_util.GetAssetsArrayAsyncParallel(tb, loadLater)
end

function BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall(bServerSyncShouldCheckPassWall)
  print(bWriteLog and "BRPlayerCharacterBase:RPC_Client_SetShouldCheckPassWall " .. tostring(bServerSyncShouldCheckPassWall))
  if slua.isValid(self.ParachuteComponent) then
    self.ParachuteComponent.bServerSyncShouldCheckPassWall = bServerSyncShouldCheckPassWall
  end
end

function BRPlayerCharacterBase:OnPlayerEnterCarryBoxState()
  self.Super:OnPlayerEnterCarryBoxState()
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerEnterCarryBoxState Role:%s PlayerKey:%s Name:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerEnterCarryBoxState()
  end
end

function BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  self.Super:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  local CharName = self:GetPlayerNameSafety()
  print(bWriteLog and string.format("DeadBoxLog BRPlayerCharacterBase:OnPlayerLeaveCarryBoxState Role:%s PlayerKey:%s Name:%s bInIsInterrupt:%s", tostring(self.Role), tostring(self.PlayerKey), tostring(CharName), tostring(bInIsInterrupt)))
  if self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  end
end

function BRPlayerCharacterBase:ServerRPC_CarryDeadBox(uInDeadBox)
  if slua.isValid(uInDeadBox) and Game:IsClassOf(uInDeadBox, import("/Script/ShadowTrackerExtra.PlayerTombBox")) and self.CarryDeadBoxFeature then
    self.CarryDeadBoxFeature:CarryDeadBox(uInDeadBox)
  end
end

function BRPlayerCharacterBase:SetAreaID(AreaID)
  self:SetAttrValue("AreaID", AreaID, -1)
end

function BRPlayerCharacterBase:GetAreaID()
  return math.floor(self:GetAttrValue("AreaID") + 0.5)
end

function BRPlayerCharacterBase:CannotChangeIntoPetSpectator()
  print(bWriteLog and "BRPlayerCharacterBase:CannotChangeIntoPetSpectator")
  return self.bCannotChangeIntoPetSpectator
end

function BRPlayerCharacterBase:DoModChangeToBT()
  print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s", tostring(self.PlayerKey)))
  if self:HasState(EPawnState.SpecialSuit) then
    self:TriggerEntrySkillWithID(4301101, true)
    print(bWriteLog and string.format("BRPlayerCharacterBase:DoModChangeToBT, PlayerKey=%s, HasState(EPawnState.SpecialSuit)", tostring(self.PlayerKey)))
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteOpening()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening")
  self.Super:SwitchCameraToParachuteOpening()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteOpening - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToParachuteFalling()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling")
  self.Super:SwitchCameraToParachuteFalling()
  if self.ParachuteFormation and self.ParachuteFormation.ShouldApplyFormationCamera and self.ParachuteFormation:ShouldApplyFormationCamera() then
    self.ParachuteFormation:OverlayFormationCameraParams()
    print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToParachuteFalling - Formation camera overlaid")
  end
end

function BRPlayerCharacterBase:SwitchCameraToNormal()
  print(bWriteLog and "BRPlayerCharacterBase:SwitchCameraToNormal")
  self.Super:SwitchCameraToNormal()
  if self.ParachuteFormation and self.ParachuteFormation.OnLandingClearFormationCamera then
    self.ParachuteFormation:OnLandingClearFormationCamera()
  end
end

function BRPlayerCharacterBase:SwitchWeaponCheck(Slot, IgnoreState)
  if self:HasState(EPawnState.AttachToOther) then
    local Weapon = self:GetWeaponBySlot(Slot)
    if slua.isValid(Weapon) then
      local WeaponID = Weapon:GetWeaponID()
      local AttachToOtherConfig = GamePlayTools.GetCurrentConfig("AttachToOtherConfig")
      if AttachToOtherConfig and AttachToOtherConfig.CheckIsWeaponInBlackList and AttachToOtherConfig.CheckIsWeaponInBlackList(WeaponID) then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck not allow switch weapon in AttachToOther, WeaponID: " .. tostring(WeaponID))
        local uPlayerController = self:GetPlayerControllerSafety()
        if Client and slua.isValid(uPlayerController) and uPlayerController.Role == ENetRole.ROLE_AutonomousProxy then
          uPlayerController:DisplayGameTipWithMsgID(47306)
        end
        return false
      end
    end
  end
  if self:HasState(EPawnState.WebSwing) and Slot ~= ESurviveWeaponPropSlot.SWPS_None and slua.isValid(self.STCharacterMovement) then
    local SpiderSwingObj = self.STCharacterMovement:GetSpecialMoveObjBySpecialMoveType(ESpecialMovementType.SPECIAL_MOVE_SpiderSwing)
    if slua.isValid(SpiderSwingObj) then
      local nCurState = SpiderSwingObj:GetCurMoveState()
      if nCurState == ESpiderSwingMoveState.Launching or nCurState == ESpiderSwingMoveState.Swinging then
        print(bWriteLog and "BRPlayerCharacterBase:SwitchWeaponCheck blocked by SpiderSwing state: " .. tostring(nCurState))
        return false
      end
    end
  end
  return self.Super:SwitchWeaponCheck(Slot, IgnoreState)
end

local VICTORY_DANCE_FX_MAP = {
  [12219601] = 22010089
}

local function ResolveEmoteResID(ItemID)
  local FxID = VICTORY_DANCE_FX_MAP[ItemID]
  if not FxID or FxID == ItemID then
    return ItemID
  end
  local model_util = require("client.common.model_util")
  local FxBPID = model_util.GetBPID(FxID)
  local ResID = ItemID
  if FxBPID and 0 < FxBPID and model_util.IsBattleItemHandleExist("Emote", FxBPID, false, false) then
    ResID = FxID
  end
  print(bWriteLog and string.format("BRPlayerCharacterBase 11 ResolveEmoteResID ItemID:%s, FxID:%s, FxBPID:%s, ResID:%s", tostring(ItemID), tostring(FxID), tostring(FxBPID), tostring(ResID)))
  return ResID
end

function BRPlayerCharacterBase:GetEmoteHandlePath(ItemID)
  local ResID = ResolveEmoteResID(ItemID)
  if self.Super then
    return self.Super:GetEmoteHandlePath(ResID)
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ResID)
  if not BPID or BPID <= 0 then
    return ""
  end
  return model_util.GetPath("Emote", BPID, false, false) or ""
end

function BRPlayerCharacterBase:GetEmoteHandle(ItemID)
  local ResID = ResolveEmoteResID(ItemID)
  if self.Super then
    return self.Super:GetEmoteHandle(ResID)
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ResID)
  if not BPID or BPID <= 0 then
    return nil
  end
  local HandleClass = model_util.GetClass("Emote", BPID, false, false)
  if not HandleClass then
    return nil
  end
  local Handle = HandleClass()
  if not slua.isValid(Handle) then
    return nil
  end
  return Handle
end

local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")

local _slua = rawget(_G, "slua")

local function Around(obj)
  if not obj then return false end
  if _slua and _slua.isValid then
    local ok, v = pcall(_slua.isValid, obj)
    if not ok or not v then return false end
  end
  return true
end

local tick = nil
pcall(function() tick = require("common.time_ticker") end)
local function Later(seconds, fn, allowSync)
  if tick and tick.AddTimerOnce then
    tick.AddTimerOnce(seconds, fn)
  elseif allowSync then
    fn()
  end
end

_G.Aegis = _G.Aegis or {}
_G.Aegis.Up = _G.Aegis.Up or {}
local A = _G.Aegis

local function NoOp() return true end
local function NoFalse() return false end
local function NoZero() return 0 end
local function NoNil() return nil end
local function NoList() return {} end
local function NoString() return "" end

local function MuteObject(obj)
  if type(obj) ~= "table" then return end
  for k, v in pairs(obj) do
    if type(v) == "function" and type(k) == "string" and
      (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or
       k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect") or
       k:find("Collect") or k:find("Flow") or k:find("Heartbeat") or k:find("Record") or
       k:find("Trace") or k:find("Replay") or k:find("Save")) then
      pcall(function() obj[k] = NoOp end)
    end
  end
end

-- ============================================================================
-- BAN BYPASS — COMPLETE
-- ============================================================================
local BanShield = {}

function BanShield.KillBanFunctions()
  pcall(function()
    local banFuncs = {
      "BanPlayer", "BanUser", "ReportBan", "SendBanReport",
      "DetectBan", "CheckBan", "ValidateBan", "ProcessBan",
      "BanKick", "KickPlayer", "ForceLogout", "DisconnectPlayer",
      "ReportSuspicious", "ReportCheat", "ReportHack",
      "OnCheatDetected", "OnHackDetected", "OnViolationDetected",
      "AntiCheatReport", "CheatDetection", "ViolationReport",
      "SecurityViolation", "IntegrityCheck", "SignatureVerify",
      "TssSdkReport", "TssSdkBan", "TssSdkKick",
      "ReportModifierException", "ReportMemoryException",
      "ReportAvatarException", "ReportSpeedHack",
      "ReportWallHack", "ReportAimBot", "ReportESP",
      "ReportModdedFiles", "DetectCheat", "OnBanNotice", "OnKickNotice",
      "ProcessBanNotice", "HandleBanNotice", "ShowBanUI", "ShowKickUI"
    }
    for _, fn in ipairs(banFuncs) do
      if _G[fn] then _G[fn] = function() return true end end
      if _G.GameplayCallbacks and _G.GameplayCallbacks[fn] then
        _G.GameplayCallbacks[fn] = function() return true end
      end
    end
  end)
end

function BanShield.SpoofSubsystems()
  pcall(function()
    local mgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if not mgr then return end
    local banSubs = {
      "AntiCheatSubsystem", "BanSubsystem", "PlayerBanSubsystem",
      "CheatDetectionSubsystem", "SecuritySubsystem",
      "BanManagerSubsystem", "KickBanSubsystem",
      "TssSdkSubsystem", "HiggsBosonSubsystem",
      "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
      "PlayerSecurityInfoSubsystem", "OperationalStatsSubsystem",
      "ModifierExceptionSubsystem", "MemoryCheckSubsystem"
    }
    for _, name in ipairs(banSubs) do
      local sub = mgr:Get(name)
      if sub then
        pcall(function()
          for k, v in pairs(sub) do
            if type(v) == "function" and type(k) == "string" then
              if k:find("Ban") or k:find("Kick") or k:find("Report") or
                 k:find("Detect") or k:find("Check") or k:find("Verify") or
                 k:find("Validate") or k:find("Process") or k:find("Send") or
                 k:find("Upload") or k:find("Notify") or k:find("Warn") then
                sub[k] = function() return true end
              end
            end
          end
          sub.bBanned = false
          sub.bKicked = false
          sub.bSuspended = false
          sub.BanCount = 0
          sub.WarningCount = 0
          sub.SuspicionScore = 0
        end)
      end
    end
  end)
end

function BanShield.BlockNet()
  pcall(function()
    if NetUtil and NetUtil.SendPacket then
      local orig = NetUtil.SendPacket
      local banPackets = {
        ["ReportCheat"]=1, ["ReportHack"]=1, ["ReportSuspicious"]=1,
        ["ReportBan"]=1, ["SendBanReport"]=1, ["BanPlayer"]=1,
        ["KickPlayer"]=1, ["CheatDetection"]=1, ["AntiCheatReport"]=1,
        ["ViolationReport"]=1, ["SecurityViolation"]=1,
        ["IntegrityCheck"]=1, ["SignatureVerify"]=1,
        ["TssSdkReport"]=1, ["TssSdkBan"]=1, ["TssSdkKick"]=1,
        ["tss_sdk_report"]=1, ["tss_sdk_ban"]=1, ["tss_sdk_kick"]=1,
        ["detect_cheat"]=1, ["ban_player"]=1, ["kick_player"]=1,
        ["report_aim_bot"]=1, ["report_esp"]=1, ["report_speed_hack"]=1,
        ["report_wall_hack"]=1, ["report_modded_files"]=1,
        ["client_anti_cheat_report"]=1, ["report_memory_exception"]=1,
        ["report_avatar_exception"]=1, ["report_script_exception"]=1,
        ["report_lua_violation"]=1, ["report_pak_modified"]=1,
        ["report_signature_fail"]=1, ["report_integrity_fail"]=1,
        ["OperationalStats"]=1, ["ReportOperationalStats"]=1,
        ["on_tss_sdk_anti_data"]=1, ["on_ban_notice"]=1, ["on_kick_notice"]=1,
        ["report_players_ping"]=1, ["report_player_ip"]=1,
        ["report_net_saturate"]=1, ["report_unrealnet_exception"]=1
      }
      NetUtil.SendPacket = function(packetName, ...)
        if banPackets[packetName] then return nil end
        return orig(packetName, ...)
      end
    end

    if _G.SendRPC then
      local origRpc = _G.SendRPC
      _G.SendRPC = function(rpcName, ...)
        if not rpcName then return origRpc(rpcName, ...) end
        local lower = string.lower(tostring(rpcName))
        if lower:find("ban") or lower:find("kick") or lower:find("report")
          or lower:find("cheat") or lower:find("hack") or lower:find("violation")
          or lower:find("verify") or lower:find("integrity") then
          return nil
        end
        return origRpc(rpcName, ...)
      end
    end
  end)
end

function BanShield.KillTssSdk()
  pcall(function()
    local tss = package.loaded["TssSdk"] or _G.TssSdk
    if tss then
      tss.GetFileMD5 = function() return "00000000000000000000000000000000" end
      tss.VerifyFileSignature = function() return true end
      tss.SendReportInfo = function() return true end
      tss.ScanMemory = function() return true end
      tss.IsEmulator = function() return false end
      tss.GetTssSdkReportInfo = function() return "" end
      tss.CheckEnvironment = function() return true end
      tss.VerifyProcess = function() return true end
      tss.ReportBan = function() return true end
      tss.ReportCheat = function() return true end
      tss.BanPlayer = function() return true end
      tss.KickPlayer = function() return true end
      tss.OnRecvData = function() return end
    end
  end)
end

function BanShield.KillGameState()
  pcall(function()
    local GD = require("GameLua.GameCore.Data.GameplayData")
    if not GD then return end
    local gs = GD.GetGameState and GD.GetGameState()
    if not gs then return end
    pcall(function()
      gs.BanPlayer = function() return true end
      gs.KickPlayer = function() return true end
      gs.ReportCheat = function() return true end
      gs.ReportHack = function() return true end
      gs.OnCheatDetected = function() return true end
      gs.OnHackDetected = function() return true end
      gs.AntiCheatReport = function() return true end
      gs.ShowBanNotice = function() return end
      gs.ShowKickNotice = function() return end
      gs.ProcessBanNotice = function() return end
    end)
  end)
end

function BanShield.SpoofBanStatus()
  pcall(function()
    local GD = require("GameLua.GameCore.Data.GameplayData")
    if not GD then return end
    local pc = GD.GetPlayerController and GD.GetPlayerController()
    if not pc then return end
    pcall(function()
      pc.bBanned = false
      pc.bKicked = false
      pc.bSuspended = false
      pc.BanReason = nil
      pc.BanTime = 0
      pc.BanCount = 0
      pc.WarningCount = 0
      pc.SuspicionScore = 0
    end)
    pcall(function()
      local ps = pc.GetPlayerStateSafety and pc:GetPlayerStateSafety()
      if ps then
        ps.bBanned = false
        ps.bKicked = false
        ps.bSuspended = false
        ps.BanCount = 0
        ps.WarningCount = 0
        ps.SuspicionScore = 0
      end
    end)
  end)
end

function BanShield.Install()
  if A.Up.BanShielded then return end
  A.Up.BanShielded = true
  BanShield.KillBanFunctions()
  BanShield.SpoofSubsystems()
  BanShield.BlockNet()
  BanShield.KillTssSdk()
  BanShield.KillGameState()
  BanShield.SpoofBanStatus()
  print("[BAN BYPASS 4.6] All ban systems neutralized")
end

-- ============================================================================
-- SHIELD — anti-detection
-- ============================================================================
local Shield = {}

function Shield.NeutralizeLoaders()
  pcall(function()
    if slua and slua.getSignature then slua.getSignature = NoZero end
    local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
    if loader then
      loader.verifyBytecode = NoOp
      loader.checkIntegrity = NoOp
      if loader.disableSignatureCheck then loader.disableSignatureCheck = NoOp end
    end
    local ser = package.loaded["slua.serialize"]
    if ser then ser.check = NoOp; ser.verify = NoOp end
    if jit and jit.attach then jit.attach(function() end, "bc") end
    if _G.slua_verify then _G.slua_verify = NoOp end
    if _G.check_slua_integrity then _G.check_slua_integrity = NoOp end
  end)
end

function Shield.NeutralizeHashes()
  pcall(function()
    local console = import("KismetSystemLibrary")
    if console then
      console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
      console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
      console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
      console.ExecuteConsoleCommand(nil, "sig.Check 0")
      console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
    end
    local CMode = import("CreativeModeBlueprintLibrary")
    if CMode then
      CMode.MD5HashByteArray = NoString
      CMode.MD5HashFile = NoString
      CMode.GetContentDiffData = function() return true, "OK" end
      CMode.VerifyFileIntegrity = NoOp
    end
    if _G.MD5Hash then _G.MD5Hash = NoString end
    if _G.CRC32 then _G.CRC32 = NoZero end
    if _G.SHA1 then _G.SHA1 = NoString end
    local fhc = package.loaded["common.file_hash_checker"]
    if fhc then
      fhc.CheckFileMD5 = NoOp
      fhc.VerifyAll = NoOp
      fhc.GetHash = NoString
    end
    local tss = package.loaded["TssSdk"] or _G.TssSdk
    if tss then
      tss.GetFileMD5 = NoString
      tss.VerifyFileSignature = NoOp
      tss.OnRecvData = function(data)
        if type(data) ~= "string" then return end
        local lower = string.lower(data)
        if lower:find("report", 1, true) or lower:find("exception", 1, true) or lower:find("cheat", 1, true) or lower:find("violation", 1, true) or lower:find("hack", 1, true) or lower:find("verify", 1, true) then return end
      end
      tss.SendReportInfo = NoNil
      tss.ScanMemory = NoOp
      tss.IsEmulator = NoFalse
      tss.GetTssSdkReportInfo = NoString
      tss.CheckEnvironment = NoOp
      tss.VerifyProcess = NoOp
    end
    local stx = import("STExtraBlueprintFunctionLibrary")
    if stx then
      stx.CheckMD5 = NoOp
      stx.GetMD5 = NoString
      stx.VerifyFile = NoOp
    end
  end)
end

function Shield.NeutralizeLogs()
  pcall(function()
    local SMTD = import("ScreenshotMTDer")
    if SMTD then
      SMTD.MTDePicture = NoString
      SMTD.ReMTDePicture = NoString
      SMTD.HasCaptured = NoOp
      SMTD.TakeScreenshot = NoNil
    end
    local tl = package.loaded["TLog"] or _G.TLog
    if tl then
      tl.Info, tl.Warning, tl.Error, tl.Debug = NoOp, NoOp, NoOp, NoOp
      tl.Report, tl.Send, tl.Flush = NoOp, NoOp, NoOp
    end
    local cs = package.loaded["CrashSight"] or _G.CrashSight
    if cs then
      cs.ReportException, cs.SetCustomData, cs.Log = NoOp, NoOp, NoOp
      cs.SendCrash, cs.ReportUserException = NoOp, NoOp
    end
    local gr = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
    if gr then
      gr.BugglyPostExceptionFull = NoFalse
      gr.CheckCanBugglyPostException = NoFalse
      gr.ReplayReportData, gr.ReportGameException, gr.PostException = NoOp, NoOp, NoOp
    end
    local ctr = package.loaded["client.slua.logic.report.ClientToolsReport"]
    if ctr then ctr.SendReport, ctr.SendException, ctr.UploadLog = NoOp, NoOp, NoOp end
    for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
      local s = _G[sdk]
      if s then
        s.logEvent, s.trackEvent = NoOp, NoOp
        s.setEnabled = NoFalse
        s.sendEvent, s.report = NoOp, NoOp
      end
    end
  end)
end

function Shield.NeutralizeSkins()
  pcall(function()
    local pt = package.loaded["client.slua.logic.download.report.puffer_tlog"]
    if pt then
      pt.ReportEvent, pt.ReportDownloadResult = NoOp, NoOp
      pt.ReportODPTDError, pt.ReportSkinError = NoOp, NoOp
    end
    local av = package.loaded["AvatarUtils"]
    if av then
      av.CheckIsWeaponInBlackList = NoFalse
      av.IsValidAvatar = NoOp
      av.CheckAvatarIntegrity = NoOp
      av.ReportInvalidAvatar = NoNil
    end
    local eq = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
    if eq then eq.Report, eq.SendException = NoOp, NoOp end
  end)
end

function Shield.NeutralizeSubSystems()
  pcall(function()
    local mgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if mgr then
      local KillSubSystems = {
        "AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem",
        "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem",
        "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem",
        "CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem",
        "ModifierExceptionSubsystem", "SimulateCharacterSubsystem",
        "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem",
        "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem",
        "GameReportSubsystem", "ReplaySubsystem", "SwiftHawkSubsystem",
        "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem",
        "MD5CheckSubsystem", "PakVerifySubsystem", "OperationalStatsSubsystem",
        "MrpcsFlowSubsystem", "CircleFlowSubsystem",
        "ClientESPDetectionSubsystem", "ClientAimTrackingSubsystem",
        "ClientRenderCheckSubsystem", "ClientMemoryGuardSubsystem",
        "ClientKernelCheckSubsystem", "ClientWallhackDetectionSubsystem",
        "ClientAntiCheatSubsystem", "ClientSecMrpcsFlowSubsystem",
        "ShootVerifySubSystemClient"
      }
      for _, name in ipairs(KillSubSystems) do
        local sub = mgr:Get(name)
        if sub then
          MuteObject(sub)
          for _, tm in ipairs({"timer", "heartbeatTimer", "reportTimer"}) do
            if sub[tm] then pcall(function() sub:RemoveGameTimer(sub[tm]) end) end
          end
        end
      end
    end
    local flowRunner = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
    if flowRunner then
      flowRunner.CheckAvatarException, flowRunner.CheckAvatarExceptionOnce = NoOp, NoOp
      flowRunner.ReportAvatarException = NoNil
      flowRunner.CheckSlotMeshVisible, flowRunner.CheckPawnVisible = NoFalse, NoFalse
      flowRunner.CheckCanBugglyPostException = NoFalse
    end
    local rep = package.loaded["client.slua.logic.replay.logic_report_replay"]
    if rep then rep.ReportReplay, rep.SendReportReq, rep.UploadReplay = NoOp, NoOp, NoOp end
  end)
end

local ReportFlowNames = {
  "ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow",
  "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior",
  "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick",
  "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow",
  "ReportSecTgameMovingFlow", "ReportParachuteData", "ReportEquipmentFlow",
  "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord",
  "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate",
  "ReportCircleFlow", "ReportSecMrpcsFlow", "SendTssSdkAntiDataToLobby",
  "SendClientStats", "SendServerAvgTickDelta", "SwiftHawk", "ClientSwiftHawk",
  "ClientSwiftHawkWithParams", "ClientSecMrpcsFlow", "MrpcsData"
}

function Shield.NeutralizeGlobalFlows()
  pcall(function()
    if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
    local GC = _G.GameplayCallbacks
    for _, f in ipairs(ReportFlowNames) do
      if _G[f] then _G[f] = NoOp end
      GC[f] = NoOp
    end
    GC.CheckReportSecAttackFlowWithAttackFlow = NoFalse
    GC.CheckReportSecAttackFlow = NoFalse
    for _, f in ipairs({"IsEnableReportMrpcsInCircleFlow", "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow", "IsEnableReportAttackFlow", "IsEnableReportHitFlow", "IsEnableReportCircleFlow"}) do
      if _G[f] then _G[f] = NoFalse end
    end
    local origState = GC.OnDSPlayerStateChanged
    GC.OnDSPlayerStateChanged = function(UID, State, bPure, bSafe, Param)
      local s = State and string.lower(tostring(State)) or ""
      local danger = {
        ["cheatdetected"]=1, ["connectionlost"]=1, ["connectiontimeout"]=1,
        ["connectionexception"]=1, ["netdrivererror"]=1, ["banned"]=1, ["kicked"]=1,
        ["suspended"]=1, ["violationdetected"]=1, ["integrityfailure"]=1, ["securityviolation"]=1
      }
      if danger[s] then return end
      if origState and type(origState) == "function" then
        return origState(UID, State, bPure, bSafe, Param)
      end
    end
    GC.OnPlayerNetConnectionClosed = NoNil
    GC.OnPlayerActorChannelError = NoNil
    GC.OnPlayerRPCValidateFailed = NoNil
    GC.OnPlayerSpectateException = NoNil
    GC.OnShutdownAfterError = NoNil
  end)
end

local _NetShielded = false
function Shield.NeutralizeNet()
  if _NetShielded then return end
  pcall(function()
    local BlockPacketNames = {
      ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportFireArms"]=1,
      ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1, ["ReportPlayerBehavior"]=1,
      ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["ReportCircleFlow"]=1,
      ["report_parachute_data"]=1, ["on_tss_sdk_anti_data"]=1,
      ["SwiftHawk"]=1, ["ClientSwiftHawk"]=1, ["ClientSwiftHawkWithParams"]=1
    }
    if NetUtil and NetUtil.SendPacket then
      local original = NetUtil.SendPacket
      NetUtil.SendPacket = function(packetName, ...)
        if BlockPacketNames[packetName] then return nil end
        return original(packetName, ...)
      end
    end
    if _G.SendRPC then
      local originalRpc = _G.SendRPC
      _G.SendRPC = function(rpcName, ...)
        local BlockRpcNames = {
          "RPC_Server_ClientSecMrpcsFlow", "RPC_Server_SwiftHawk",
          "RPC_Server_ClientSwiftHawkWithParams", "RPC_Server_ReportSimulateCharacterLocation",
          "RPC_Client_ShootVertifyRes", "RPC_ClientCoronaLab", "RPC_OperationalStats"
        }
        for _, b in ipairs(BlockRpcNames) do
          if rpcName == b then return nil end
        end
        return originalRpc(rpcName, ...)
      end
    end
    _NetShielded = true
  end)
end

function Shield.NeutralizeHiggs()
  pcall(function()
    local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
    if Higgs then
      local methods = {
        "ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck",
        "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord",
        "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar", "SendHisarData",
        "ValidateSecurityData", "StaticShowSecurityAlertInDev", "RPC_Client_ShootVertifyRes",
        "RPC_Server_ReportSimulateCharacterLocation", "DisableHiggsBoson", "CheckMHActive",
        "ReportViolation", "ProcessSecurityEvent", "ValidatePlayer", "CheckIntegrity"
      }
      for _, m in ipairs(methods) do if Higgs[m] then Higgs[m] = NoNil end end
      Higgs.GetNetAvatarItemIDs = NoList
      Higgs.GetCurWeaponSkinID = NoZero
      Higgs.IsMHActive = NoFalse
      Higgs.bMHActive = false
      Higgs.bCallPreReplication = false
      if Higgs.BlackList then
        local keys = {}
        for k in pairs(Higgs.BlackList) do table.insert(keys, k) end
        for _, k in ipairs(keys) do Higgs.BlackList[k] = nil end
      end
    end
    _G.BlackList = {}
    if _G.AvatarCheckCallback then
      _G.AvatarCheckCallback.StartAvatarCheck = NoNil
      _G.AvatarCheckCallback.OnReportItemID = NoNil
      _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(pc)
        if Around(pc) then
          if pc.HiggsBosonComponent then
            pcall(function() pc.HiggsBosonComponent:ControlMHActive(0) end)
            pc.HiggsBosonComponent.bMHActive = false
          end
          if pc.HiggsBoson then
            pcall(function() pc.HiggsBoson:ControlMHActive(0) end)
            pc.HiggsBoson.bMHActive = false
          end
        end
      end
    end
  end)
end

function Shield.NeutralizePlayers()
  pcall(function()
    for _, c in ipairs({"PlayerSecurityInfoCollector", "PlayerSecurityInfo", "SecurityInfoCollector", "ClientSecurityCollector", "PlayerAntiCheatCollector"}) do
      if _G[c] then MuteObject(_G[c]) end
    end
    local mgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if mgr then
      local sec = mgr:Get("PlayerSecurityInfoSubsystem")
      if sec then
        sec.ReportData, sec.CollectData, sec.SendToServer = NoNil, NoNil, NoNil
        sec.CheckCheat = NoFalse
        sec.ValidatePlayer = NoOp
      end
      local sw = mgr:Get("SwiftHawkSubsystem")
      if sw then sw.ReportData, sw.SendReport, sw.CollectTelemetry = NoNil, NoNil, NoNil end
      local cr = mgr:Get("ModifierExceptionSubsystem")
      if cr then
        cr.ReportException, cr.ReportModifierError = NoNil, NoNil
        cr.CheckModifier, cr.ValidateModifier = NoOp, NoOp
      end
      local sm = mgr:Get("SimulateCharacterSubsystem")
      if sm then sm.ReportLocation, sm.SendLocationData = NoNil, NoNil; sm.VerifyLocation = NoOp end
      local sv = mgr:Get("ShootVerifySubSystemClient")
      if sv then
        sv.OnShootVerifyFailed, sv.SendVerifyData, sv.ReportBulletHit, sv.UploadHitInfo = NoNil, NoNil, NoNil, NoNil
        sv.VerifyShot = NoOp
      end
    end
    if _G.bReportedModifierException then _G.bReportedModifierException = false end
    if _G.BulletHitInfoUploadData then MuteObject(_G.BulletHitInfoUploadData) end
  end)
end

function Shield.NeutralizeStats()
  pcall(function()
    local mgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    local ops = (mgr and mgr:Get("OperationalStatsSubsystem")) or _G.OperationalStatsSubsystem
    if ops then
      ops.ReportOperationalStats, ops.AddOperationalStats = NoNil, NoNil
      ops.HandleTouchBegin, ops.HandleTouchEnd = NoNil, NoNil
      ops.OnInit, ops.HandleEnterFighting, ops.OnBattleResult = NoNil, NoNil, NoNil
      ops.StatsData = {}
    end
  end)
end

function Shield.NeutralizeLoading()
  pcall(function()
    local flags = {"ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"}
    for _, f in ipairs(flags) do if _G[f] then _G[f] = false end end
    local realRequire = require
    local poisoned = {"HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "OperationalStatsSubsystem"}
    _G.require = function(moduleName)
      for _, bad in ipairs(poisoned) do
        if moduleName:find(bad, 1, true) then return {} end
      end
      return realRequire(moduleName)
    end
  end)
end

function Shield.NeutralizeSweep()
  local needle = {"verify", "integrity", "signature", "filecheck", "file_check", "hashcheck", "hash_check", "tss", "security", "report"}
  local seen = {}
  pcall(function()
    local function Watch(mod)
      if type(mod) ~= "table" or seen[mod] then return end
      seen[mod] = true
      MuteObject(mod)
    end
    for key, mod in pairs(package.loaded) do
      if type(key) == "string" then
        local low = string.lower(key)
        for _, n in ipairs(needle) do
          if string.find(low, n, 1, true) then Watch(mod) break end
        end
      end
    end
    for key, mod in pairs(_G) do
      if type(key) == "string" then
        local low = string.lower(key)
        for _, n in ipairs(needle) do
          if string.find(low, n, 1, true) then Watch(mod) break end
        end
      end
    end
  end)
end

function Shield.Hum()
  A.Up.Heartbeat = math.random(15, 45)
  A.Up.PingJitter = math.random(-12, 18)
  A.Up.FakeKd = 0.9 + math.random() * 1.9
  A.Up.FakeHead = 9 + math.random() * 22
  pcall(function()
    if debug and debug.getinfo then
      local origin = debug.getinfo
      debug.getinfo = function(level, what)
        local info = origin(level, what)
        if info and info.source then
          local src = info.source
          if string.find(src, "BRPlayerCharacterBase", 1, true) or string.find(src, "AegisShell", 1, true) then
            info.source = "ProtectedSource"
            info.short_src = "ProtectedSource"
          end
        end
        return info
      end
    end
  end)
  pcall(function()
    if debug then
      if debug.sethook then debug.sethook = function() end end
      if debug.getlocal then debug.getlocal = function() end end
      if debug.setupvalue then debug.setupvalue = function() end end
    end
    if string and string.dump then
      string.dump = function() return "" end
    end
  end)
end
-- ============================================================================
-- BAN SHIELD UPGRADE — UI-layer ban popup suppression
-- ============================================================================
local BanShieldUpgrade = {}
local _Hooked_UI, _Hooked_Msg, _Hooked_Login = false, false, false
local _BanPopupBlocked = 0

local BanKeyPatterns = {
  "ban", "notice", "kick", "cheat", "violation", "suspicious",
  "punish", "restrict", "forbid", "antiaddict", "anticheat",
  "security", "integrity", "blockade", "seal", "freeze",
  "warning", "warningtips", "strongtips", "credit", "creditnotice"
}
local BanTextPatterns = {
  "banned", "ban for", "cheating", "unauthorized", "unusual",
  "violation", "account has been", "end time", "appeal",
  "anti-addiction", "restricted", "suspended", "kick",
  "封号", "违规", "作弊", "限制", "禁止"
}

local function IsBanKey(name)
  if type(name) ~= "string" then return false end
  local low = name:lower()
  for _, p in ipairs(BanKeyPatterns) do
    if low:find(p, 1, true) then return true end
  end
  return false
end
local function ContainsBanText(text)
  if type(text) ~= "string" then return false end
  local low = text:lower()
  for _, p in ipairs(BanTextPatterns) do
    if low:find(p, 1, true) then return true end
  end
  return false
end
local function ReadWidgetText(widget)
  if widget == nil then return nil end
  local ok, txt = pcall(function()
    if type(widget.GetText) == "function" then return widget:GetText() end
  end)
  if ok and type(txt) == "string" then return txt end
  ok, txt = pcall(function() return widget.Text end)
  if ok and type(txt) == "string" then return txt end
  ok, txt = pcall(function() return widget.Content end)
  if ok and type(txt) == "string" then return txt end
  return nil
end
local function WidgetTreeHasBanText(widget, depth)
  depth = depth or 0
  if depth > 8 or widget == nil then return false end
  local txt = ReadWidgetText(widget)
  if txt and ContainsBanText(txt) then return true end
  local ok, children = pcall(function()
    if type(widget.GetAllChildren) == "function" then
      local arr = widget:GetAllChildren()
      if arr then
        local out = {}
        local n = type(arr.Num) == "function" and arr:Num() or #arr
        for i = 1, n do
          local c = type(arr.Get) == "function" and arr:Get(i - 1) or arr[i]
          if c then out[#out + 1] = c end
        end
        return out
      end
    end
    if type(widget.GetChildren) == "function" then
      local arr = widget:GetChildren()
      if arr then
        local out = {}
        local n = type(arr.Num) == "function" and arr:Num() or #arr
        for i = 1, n do
          local c = type(arr.Get) == "function" and arr:Get(i - 1) or arr[i]
          if c then out[#out + 1] = c end
        end
        return out
      end
    end
  end)
  if ok and type(children) == "table" then
    for _, c in ipairs(children) do
      if WidgetTreeHasBanText(c, depth + 1) then return true end
    end
  end
  return false
end
local function _BLog(msg)
  pcall(print, "[BAN-SHIELD-UP] " .. tostring(msg))
end

local function HookUIManager()
  if _Hooked_UI then return true end
  local UM = _G.UIManager
  if not UM or type(UM.ShowUI) ~= "function" then return false end
  local origShow = UM.ShowUI
  UM.ShowUI = function(self, config, params, ...)
    local keyName
    pcall(function()
      if type(config) == "table" then
        keyName = config.keyName or config.Key or config.Name or config.UIPathName
      elseif type(config) == "string" then
        keyName = config
      end
    end)
    if IsBanKey(keyName) then
      _BanPopupBlocked = _BanPopupBlocked + 1
      _BLog("Blocked UI: " .. tostring(keyName))
      return { Close = function() end, SetVisibility = function() end, UIRoot = nil }
    end
    local args = {...}
    local n = select("#", ...)
    local ok, result = pcall(function()
      local unpack = table.unpack or unpack
      return origShow(self, config, params, unpack(args, 1, n))
    end)
    if not ok then return nil end
    pcall(function()
      local view = result
      local root = view and view.UIRoot or view
      if root and WidgetTreeHasBanText(root, 0) then
        _BanPopupBlocked = _BanPopupBlocked + 1
        _BLog("Post-show ban text detected: " .. tostring(keyName) .. " -> closing")
        pcall(function() if type(view.Close) == "function" then view:Close() end end)
        pcall(function() if type(view.SetVisibility) == "function" then view:SetVisibility(2) end end)
        pcall(function() if type(UM.CloseUI) == "function" and config then UM.CloseUI(config) end end)
      end
    end)
    return result
  end
  _Hooked_UI = true
  _BLog("UIManager.ShowUI hooked")
  return true
end

local function HookMsgBox()
  if _Hooked_Msg then return true end
  local paths = {
    "client.slua.logic.common.logic_common_msg_box",
    "client.logic.common.logic_common_msg_box",
  }
  local hooked = false
  for _, path in ipairs(paths) do
    local mod = package.loaded[path]
    if not mod then
      local ok, m = pcall(require, path)
      if ok and m then mod = m end
    end
    if mod and type(mod.Show) == "function" and not mod.__BanShieldPatched then
      local origShow = mod.Show
      mod.Show = function(mode, title, body, onYes, onNo, yesText, noText, ...)
        local full = tostring(title or "") .. " " .. tostring(body or "")
        if ContainsBanText(full) then
          _BanPopupBlocked = _BanPopupBlocked + 1
          _BLog("Blocked msg_box: " .. full:sub(1, 60))
          if type(onNo) == "function" then pcall(onNo) end
          if type(onYes) == "function" then pcall(onYes) end
          return
        end
        return origShow(mode, title, body, onYes, onNo, yesText, noText, ...)
      end
      mod.__BanShieldPatched = true
      hooked = true
    end
  end
  _Hooked_Msg = hooked
  if hooked then _BLog("msg_box hooked") end
  return hooked
end

local function HookLoginNotices()
  if _Hooked_Login then return true end
  local hooked = false
  local targets = {
    "client.logic.login.logic_login_notice",
    "client.slua.logic.login.logic_login_notice",
    "client.logic.login.logic_ban_notice",
    "client.logic.lobby.logic_lobby_notice",
    "client.network.Protocol.AccessRestrictionHandler",
  }
  for _, path in ipairs(targets) do
    local mod = package.loaded[path]
    if not mod then
      local ok, m = pcall(require, path)
      if ok and m then mod = m end
    end
    if mod and type(mod) == "table" then
      for k, v in pairs(mod) do
        if type(v) == "function" and type(k) == "string" then
          local low = k:lower()
          if low:find("ban") or low:find("notice") or low:find("restrict")
             or low:find("kick") or low:find("cheat") or low:find("violation") then
            pcall(function() mod[k] = function() return true end end)
            hooked = true
          end
        end
      end
    end
  end
  _Hooked_Login = hooked
  if hooked then _BLog("login notice handlers muted") end
  return hooked
end

local function _BanTick()
  pcall(HookUIManager)
  pcall(HookMsgBox)
  pcall(HookLoginNotices)
  pcall(function()
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerOnce then
      ticker.AddTimerOnce(0.5, _BanTick)
    end
  end)
end

function BanShieldUpgrade.Install()
  HookUIManager()
  HookMsgBox()
  HookLoginNotices()
  pcall(function()
    local ticker = require("common.time_ticker")
    if ticker and ticker.AddTimerOnce then
      ticker.AddTimerOnce(0.5, _BanTick)
    end
  end)
  _BLog("Installed. Blocked so far: " .. tostring(_BanPopupBlocked))
end

_G.BanShieldUpgrade = BanShieldUpgrade

function Shield.InstallAll()
  if A.Up.Shielded then return end
  A.Up.Shielded = true
  BanShield.Install()
  Shield.NeutralizeLoaders()
  Shield.NeutralizeHashes()
  Shield.NeutralizeLogs()
  Shield.NeutralizeSkins()
  Shield.NeutralizeSubSystems()
  Shield.NeutralizeGlobalFlows()
  Shield.NeutralizeNet()
  Shield.NeutralizeHiggs()
  Shield.NeutralizePlayers()
  Shield.NeutralizeStats()
  Shield.NeutralizeSweep()
  Shield.NeutralizeLoading()
  Shield.Hum()
  pcall(function() import("KismetSystemLibrary").ExecuteConsoleCommand(nil, "r.ShaderPipelineCache 0") end)
  print("[SAMEER VIP] ALL PROTECTION + BAN BYPASS 4.6 ACTIVE")
end

-- ============================================================================
-- ONLY MARKS — name mark only
-- ============================================================================
local Marks = {}
local _MarkRetryCount = 0
local _MarkRetryDelay = 0.5

function Marks.PrimeConfig()
  if A.Up.NativeReady then
    A.Up.NativePriming = false
    return
  end
  if _MarkRetryCount > 20 then
    A.Up.NativePriming = false
    return
  end
  local ok, result = pcall(function()
    local tools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local cfg = tools.GetCurrentConfig("ScreenMarkConfig")
    if not cfg then
      _MarkRetryCount = _MarkRetryCount + 1
      _MarkRetryDelay = math.min(_MarkRetryDelay * 1.5, 5.0)
      Later(_MarkRetryDelay, function()
        A.Up.NativePriming = false
        Marks.PrimeConfig()
      end, true)
      return false
    end
    local function Blend(t)
      if not t then return end
      t[9999] = {
        UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
        MaxWidgetNum = 99, MaxShowDistance = 6000000, bBindOutScreen = true,
        bBindBlocked = true, bIsBindingActor = true, BindSocketName = "head",
        bUseLuaWorldSocketName = true, WorldPositionOffset = {X=0, Y=0, Z=50},
        bNeedPreLoad = true, Priority = 2
      }
    end
    Blend(cfg)
    for key, mod in pairs(package.loaded) do
      if type(key) == "string" and string.find(key, "ScreenMarkConfig") and type(mod) == "table" then
        Blend(mod)
      end
    end
    _MarkRetryCount = 0
    _MarkRetryDelay = 0.5
    return true
  end)
  if ok and result then
    A.Up.NativeReady = true
    A.Up.NativePriming = false
  end
end

local function PlaceMark(id, pos, z, str, size, actor)
  local mark = nil
  pcall(function()
    local marks = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
    if marks and marks.ClientAddMapMark then
      mark = marks.ClientAddMapMark(id, pos, z, str, size, actor)
      if mark then A.Up.TrackedMarks[mark] = true end
    end
  end)
  return mark
end

local function LiftMark(mark)
  if not mark then return end
  pcall(function()
    local marks = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
    if marks then
      if marks.HideMapMark then marks.HideMapMark(mark) end
      if marks.RemoveMapMark then marks.RemoveMapMark(mark) end
    end
  end)
  A.Up.TrackedMarks[mark] = nil
end

local function EnemyId(enemy)
  if Around(enemy) then
    if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
    if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
  end
  return tostring(enemy)
end

-- ============================================================================
-- EXPIRY LOCK — same timestamps as BRPlayerCharacterBase
-- ============================================================================
local _expNow = os.time(os.date("!*t"))
local _expEnd = os.time({ year = 2027, month = 10, day = 29, hour = 6, min = 45, sec = 0 })
local function IsExpired()
  return os.time(os.date("!*t")) > _expEnd
end

-- ============================================================================
-- MAIN LOOP — name mark only (EXPIRY-LOCKED)
-- ============================================================================
A.Up.Pulse = (A.Up.Pulse or 0) + 1
local myPulse = A.Up.Pulse
A.Up.TrackedMarks = A.Up.TrackedMarks or {}
A.Up.Targets = A.Up.Targets or {}

local function WipeAll()
  for mark in pairs(A.Up.TrackedMarks) do LiftMark(mark) end
  A.Up.TrackedMarks = {}
  for key, stamp in pairs(A.Up.Targets) do
    if stamp.nameMark then LiftMark(stamp.nameMark); stamp.nameMark = nil end
    A.Up.Targets[key] = nil
  end
  A.Up.Targets = {}
end

local function Beat()
  if myPulse ~= A.Up.Pulse then return end

  -- EXPIRY LOCK: hack dead
  if IsExpired() then
    WipeAll()
    A.Up.Pulse = A.Up.Pulse + 1
    return
  end

  pcall(function()
    if not A.Up.NativeReady and not A.Up.NativePriming then
      A.Up.NativePriming = true
      Marks.PrimeConfig()
    end
  end)

  local okData, GD = pcall(require, "GameLua.GameCore.Data.GameplayData")
  if not okData or not GD then return end
  local pc = GD.GetPlayerController()
  local me = nil
  if Around(pc) then me = pc:GetPlayerCharacterSafety() end

  if not Around(me) then
    for mark in pairs(A.Up.TrackedMarks) do LiftMark(mark) end
    A.Up.Targets = {}
    return
  end

  local squad = {}
  pcall(function()
    if GD.GetAllPlayerCharacters then
      squad = GD.GetAllPlayerCharacters() or {}
    end
  end)
  local myTeam = me.TeamID or (type(me.GetTeamID) == "function" and me:GetTeamID()) or 0

  local aliveKeys = {}
  for _, foe in pairs(squad) do
    if Around(foe) and foe ~= me then aliveKeys[EnemyId(foe)] = true end
  end
  for key, stamp in pairs(A.Up.Targets) do
    if not aliveKeys[key] then
      if stamp.enemy then
        if stamp.nameMark then LiftMark(stamp.nameMark); stamp.nameMark = nil end
      end
      A.Up.Targets[key] = nil
    end
  end

  for _, foe in pairs(squad) do
    if Around(foe) and foe ~= me and foe.TeamID ~= myTeam then
      local gone = false
      pcall(function() if foe.HealthStatus ~= nil and foe.HealthStatus == 2 then gone = true end end)
      local key = EnemyId(foe)
      A.Up.Targets[key] = A.Up.Targets[key] or { enemy = foe }
      local stamp = A.Up.Targets[key]
      stamp.enemy = foe
      if not gone then
        if not stamp.nameMark then
          stamp.nameMark = PlaceMark(9999, {X=0,Y=0,Z=0}, 0, "", 4, foe)
        end
      else
        if stamp.nameMark then LiftMark(stamp.nameMark); stamp.nameMark = nil end
      end
    end
  end
end

local function Pulse()
  if myPulse ~= A.Up.Pulse then return end
  -- EXPIRY LOCK: no reschedule
  if IsExpired() then
    WipeAll()
    return
  end
  pcall(Beat)
  Later(0.05, Pulse)
end

pcall(function()
  BanShieldUpgrade.Install()
  Shield.InstallAll()
  Later(2.0, Pulse, true)
end)

local CBRPlayerCharacterBase = class(CCharacterBase, nil, BRPlayerCharacterBase)
return require("combine_class").DeclareFeature(CBRPlayerCharacterBase, {
  { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
  { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
  { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
  { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
  { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
  { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
  { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
  { BuildAircraftVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature" },
  { UnifiedBuildVehicleFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.UnifiedBuildVehicleFeature" },
  { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" },
  { ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature" },
  { ParachuteSprint = "GameLua.Mod.BaseMod.GamePlay.Feature.Parachute.ParachuteSprintFeature" },
  { GeneralShowSpotFeature = "GameLua.Mod.BRMod.Gameplay.Feature.PlayerCharacterGeneralShowSpotFeature" },
  { FPPAnimMonitor = "GameLua.Mod.BaseMod.GamePlay.Feature.FPPAnimMonitorFeature" }
}, "BRPlayerCharacterBase")
