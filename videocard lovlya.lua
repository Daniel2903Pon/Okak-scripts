script_name("Videcard lovlya")
script_author("@okak_pon_okak")
script_version("1.0")

local sampev = require("lib.samp.events")
local encoding = require("encoding")
local imgui = require("mimgui")
local inicfg = require ("inicfg")

encoding.default = "CP1251"
local u8 = encoding.UTF8

local directIni = 'auto_video_lover.ini'
local ini = inicfg.load({
    main = {
        captchaDelay = 1000,
        clickDelay = 100,
    },
}, directIni)
inicfg.save(ini, directIni)

local captchaDelay = imgui.new.int[255](ini.main.captchaDelay or 1000)
local clickDelay = imgui.new.int[255](ini.main.clickDelay or 100)

local textDrawData = {}       
local isEnabled = false     
local isCefOpen = false 
local renderWindow = imgui.new.bool(false)
local isDebugMode = false
function setCaptchaDelay(delayMs)
    if tonumber(delayMs) then
        captchaDelay = imgui.new.int[255](tonumber(delayMs))
        ini.main.captchaDelay = captchaDelay[0]
        inicfg.save(ini, directIni)
        sampAddChatMessage(string.format("[Videocard lovlya] Задержка капчи установлена: %d мс", captchaDelay[0]), 0x00FF00)
    else
        sampAddChatMessage("[Videocard lovlya] Использование: /cdelay [миллисекунды]", 0xFF0000)
    end
end

function solveCaptchaWithDelay(dialogId, captchaAnswer)
    lua_thread.create(function()
        wait(captchaDelay[0])
        sampSendDialogResponse(dialogId, 1, 0, captchaAnswer)
        sampAddChatMessage("Капча решена с задержкой " .. captchaDelay[0] .. "мс: " .. captchaAnswer, 0x00FF00)
    end)
end

function splitCaptchaDigits(textdraws)
    local firstTextdraw = nil
    local minX = math.huge

    for _, textdraw in ipairs(textdraws) do
        if minX > textdraw.position[1] then
            minX = textdraw.position[1]
            firstTextdraw = textdraw
        end
    end

    if not firstTextdraw then
        return false, ""
    end

    firstTextdraw.position[1] = firstTextdraw.position[1] + 3
    firstTextdraw.lineWidth = firstTextdraw.lineWidth - 7

    local baseY = firstTextdraw.position[2] + firstTextdraw.lineHeight
    local uniqueTextdraws = {}

    for _, textdraw in ipairs(textdraws) do
        local positionKey = textdraw.position[1] .. ":" .. textdraw.position[2]
        if not uniqueTextdraws[positionKey] or uniqueTextdraws[positionKey].textdrawId < textdraw.textdrawId then
            uniqueTextdraws[positionKey] = textdraw
        end
    end

    local textdrawArray = {}
    for _, textdraw in pairs(uniqueTextdraws) do
        textdrawArray[#textdrawArray + 1] = textdraw
    end

    local digitBackgrounds = {}
    for _, textdraw in ipairs(textdrawArray) do
        if textdraw.boxColor == -13491174 then
            digitBackgrounds[#digitBackgrounds + 1] = textdraw
        end
    end

    if #digitBackgrounds ~= 5 then
        return false, ""
    end

    table.sort(digitBackgrounds, function(a, b)
        return a.position[1] < b.position[1]
    end)

    local digitGroups = {}
    for i = 1, 5 do
        digitGroups[i] = { digitBackgrounds[i] }
    end

    local tolerance = 3

    for _, textdraw in ipairs(textdrawArray) do
        if textdraw.modelId == 19201 then  
            for digitIndex = 1, 5 do
                local prevBackground = digitBackgrounds[digitIndex - 1] or firstTextdraw
                local currentBackground = digitBackgrounds[digitIndex]
                
                local leftBound = (prevBackground == firstTextdraw and prevBackground.position[1] or prevBackground.position[1] - textdraw.lineWidth / 4)
                local rightBound = currentBackground.position[1] + tolerance
                
                if leftBound < textdraw.position[1] and 
                   textdraw.position[1] + textdraw.lineWidth <= rightBound and
                   baseY > textdraw.position[2] and
                   textdraw.textdrawId > currentBackground.textdrawId then
                    digitGroups[digitIndex][#digitGroups[digitIndex] + 1] = textdraw
                end
            end
        end
    end

    return true, digitGroups
end

function recognizeDigit(digitElements)
    local background = nil
    local segments = {}

    for _, element in ipairs(digitElements) do
        if element.boxColor == -13491174 then
            background = element
        elseif element.modelId == 19201 then
            segments[#segments + 1] = element
        end
    end

    local bottomY = background.position[2] + background.letterHeight * 7.75

    table.sort(segments, function(a, b)
        return a.position[2] < b.position[2]
    end)

    local toleranceX = 3
    local toleranceY = 3

    local function getSegmentPosition(segment)
        return {
            R = segment.position[1] + segment.lineWidth >= background.position[1] - toleranceX,
            L = segment.position[1] <= background.lineWidth + toleranceX,
            T = segment.position[2] <= background.position[2],
            B = segment.position[2] + segment.lineHeight >= bottomY - toleranceY
        }
    end

    local singleSegmentPatterns = {
        [0] = { L = false, R = false },
        [1] = { B = true, T = true },
        [7] = { T = false, L = true, R = false }
    }

    if #segments == 1 then
        local segmentPos = getSegmentPosition(segments[1])
        
        for digit, pattern in pairs(singleSegmentPatterns) do
            local matches = true
            
            for position, expected in pairs(pattern) do
                if expected ~= nil and segmentPos[position] ~= expected then
                    matches = false
                    break
                end
            end
            
            if matches then
                return digit
            end
        end
    end

    local doubleSegmentPatterns = {
        [1] = {
            { T = true, B = true },
            { T = true, B = true }
        },
        [2] = {
            { T = false, L = true, B = false, R = false },
            { T = false, L = false, R = true }
        },
        [3] = {
            { T = false, L = true, B = false, R = false },
            { T = false, L = true, R = false }
        },
        [4] = {
            { R = false, L = false, B = false, T = true },
            { R = false, L = true, T = false, B = true }
        },
        [5] = {
            { B = false, L = false, R = true },
            { T = false, L = true, R = false }
        },
        [6] = {
            { T = false, L = false, B = false, R = true },
            { T = false, L = false, R = false }
        },
        [8] = {
            { T = false, L = false, B = false, R = false },
            { T = false, L = false, R = false }
        },
        [9] = {
            { T = false, L = false, B = false, R = false },
            { L = true }
        }
    }

    if #segments == 2 then
        local firstSegment = getSegmentPosition(segments[1])
        local secondSegment = getSegmentPosition(segments[2])

        for digit, patterns in pairs(doubleSegmentPatterns) do
            local matches = true

            for segmentIndex, pattern in ipairs(patterns) do
                local currentSegment = segmentIndex == 1 and firstSegment or secondSegment

                for position, expected in pairs(pattern) do
                    if expected ~= nil and currentSegment[position] ~= expected then
                        matches = false
                        break
                    end
                end

                if not matches then
                    break
                end
            end

            if matches then
                return digit
            end
        end
    end

    return -1 
end

function predictCaptcha(textdraws)
    local success, digitGroups = splitCaptchaDigits(textdraws)

    if success then
        local result = ""

        for _, digitGroup in ipairs(digitGroups) do
            local digit = recognizeDigit(digitGroup)
            result = result .. tostring(digit)
        end

        return true, result
    else
        return false, digitGroups
    end
end

function main()
    while not isSampAvailable() do
        wait(0)
    end

    sampRegisterChatCommand("vcards", function()
        renderWindow[0] = not renderWindow[0]
    end)

    sampRegisterChatCommand("cdelay", function(delay)
        setCaptchaDelay(delay)
    end)

    sampAddChatMessage("[Videocard lovlya] Скрипт загружен. Команды: /vcards, /cdelay", 0x00FF00)

    while true do
        wait(0)
    end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if not isEnabled then
        return
    end

    
    if title:find("Проверка на робота") then
        local success, captchaAnswer = predictCaptcha(textDrawData)
        if success then
            solveCaptchaWithDelay(dialogId, captchaAnswer)
            return false  
        else
            sampAddChatMessage("[Videocard lovlya] Не удалось решить капчу", 0xFF0000)
        end
        return false
    end
    
    
    if title:find("Покупка видеокарты") then
        lua_thread.create(function()
            wait(50) 
            sampSendDialogResponse(dialogId, 1, 0, "")
            debugPrint("[Videocard lovlya] Автоматически ответили 'Да' на покупку")
        end)
        return false
    end
end

function sampev.onShowTextDraw(textdrawId, data)
    local textdrawInfo = {
        textdrawId = textdrawId,
        flags = data.flags,
        letterWidth = data.letterWidth,
        letterHeight = data.letterHeight,
        letterColor = data.letterColor,
        lineWidth = data.lineWidth,
        lineHeight = data.lineHeight,
        boxColor = data.boxColor,
        shadow = data.shadow,
        outline = data.outline,
        backgroundColor = data.backgroundColor,
        style = data.style,
        selectable = data.selectable,
        position = { data.position.x, data.position.y },
        modelId = data.modelId,
        rotation = { data.rotation.x, data.rotation.y, data.rotation.z },
        zoom = data.zoom,
        color = data.color,
        text = data.text
    }
    table.insert(textDrawData, textdrawInfo)
end


function startCefClicking()
    if not isCefOpen then
        isCefOpen = true
        lua_thread.create(function()
            while isCefOpen and isEnabled do
                sendFrontendClick(101, 0, 1, "0")
                wait(clickDelay[0])
            end
        end)
    end
end


function stopCefClicking()
    isCefOpen = false
end

addEventHandler('onReceivePacket', function(id, bs, ...) 
    if id == 220 and isEnabled then
        raknetBitStreamIgnoreBits(bs, 8) 
        local packetType = raknetBitStreamReadInt8(bs)
        
        
        if packetType == 84 then
            local interfaceid = raknetBitStreamReadInt8(bs)
            local subid = raknetBitStreamReadInt8(bs)
            local len = raknetBitStreamReadInt16(bs) 
            local encoded = raknetBitStreamReadInt8(bs)
            local json = (encoded ~= 0) and raknetBitStreamDecodeString(bs, len + encoded) or raknetBitStreamReadString(bs, len)
            
            if tonumber(interfaceid) == 101 then
                debugPrint("[Videocard lovlya] CEF интерфейс 101 открыт, начинаем автокликер")
                startCefClicking()
            end 
        end
        
       
        if packetType == 62 then
            local interfaceid = raknetBitStreamReadInt8(bs)
            local toggle = raknetBitStreamReadBool(bs)
            
            if tonumber(interfaceid) == 101 and not toggle then
                sampAddChatMessage("[Videocard lovlya] CEF интерфейс 101 закрыт, останавливаем автокликер", 0x00FFFF)
                stopCefClicking()
            end 
        end
    end
end)

function sendFrontendClick(interfaceid, id, subid, json_str)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 63)
    raknetBitStreamWriteInt8(bs, interfaceid)
    raknetBitStreamWriteInt32(bs, id)
    raknetBitStreamWriteInt32(bs, subid)
    raknetBitStreamWriteInt16(bs, #json_str)
    raknetBitStreamWriteString(bs, json_str)
    raknetSendBitStreamEx(bs, 1, 10, 1)
    raknetDeleteBitStream(bs)
end


local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 400, 300
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Ловля видеокарт', renderWindow)
        if imgui.Button(u8'Включить/Выключить ловлю') then
            isEnabled = not isEnabled
            local status = isEnabled and "включена" or "выключена"
            sampAddChatMessage("[Videocard lovlya] Авто ловля видео карт " .. status, 0x00FF00)
        end
        if imgui.Button(u8'Включить/Выключить дебаг') then
            idDebugMode = not idDebugMode
            local status = idDebugMode and "включен" or "выключен"
            sampAddChatMessage("[Videocard lovlya] Дебаг " .. status, 0x00FF00)
        end
        imgui.SliderInt(u8'Задержка решения капчи (мс)', captchaDelay, 10, 5000)
        imgui.SliderInt(u8'Задержка клика во видеокарте (мс)', clickDelay, 10, 5000)
        if imgui.Button(u8'Сохранить настройки') then
            ini.main.captchaDelay = captchaDelay[0]
            ini.main.clickDelay = clickDelay[0]
            inicfg.save(ini, directIni)
            sampAddChatMessage("[Videocard lovlya] Настройки сохранены", 0x00FF00)
        end
        imgui.End()
    end
)

function debugPrint(text)
    if isDebugMode then
        sampAddChatMessage("[Videocard lovlya DEBUG]: " .. text, 0xFF0000)
    end
end
imgui.OnInitialize(function()
    SoftBlueTheme()
end)

function SoftBlueTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
  
    style.WindowPadding = imgui.ImVec2(15, 15)
    style.WindowRounding = 10.0
    style.ChildRounding = 6.0
    style.FramePadding = imgui.ImVec2(8, 7)
    style.FrameRounding = 8.0
    style.ItemSpacing = imgui.ImVec2(8, 8)
    style.ItemInnerSpacing = imgui.ImVec2(10, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 12.0
    style.GrabMinSize = 10.0
    style.GrabRounding = 6.0
    style.PopupRounding = 8
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    style.Colors[imgui.Col.Text]                   = imgui.ImVec4(0.90, 0.90, 0.93, 1.00)
    style.Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
    style.Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
    style.Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.18, 0.20, 0.22, 0.30)
    style.Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.13, 0.13, 0.15, 1.00)
    style.Colors[imgui.Col.Border]                 = imgui.ImVec4(0.30, 0.30, 0.35, 1.00)
    style.Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    style.Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.18, 0.18, 0.20, 1.00)
    style.Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
    style.Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
    style.Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
    style.Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.10, 0.10, 0.12, 1.00)
    style.Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.15, 0.15, 0.17, 1.00)
    style.Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
    style.Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.14, 1.00)
    style.Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.30, 0.30, 0.35, 1.00)
    style.Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
    style.Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
    style.Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.70, 0.70, 0.90, 1.00)
    style.Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.70, 0.70, 0.90, 1.00)
    style.Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.80, 0.80, 0.90, 1.00)
    style.Colors[imgui.Col.Button]                 = imgui.ImVec4(0.18, 0.18, 0.20, 1.00)
    style.Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.60, 0.60, 0.90, 1.00)
    style.Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.28, 0.56, 0.96, 1.00)
    style.Colors[imgui.Col.Header]                 = imgui.ImVec4(0.20, 0.20, 0.23, 1.00)
    style.Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
    style.Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
    style.Colors[imgui.Col.Separator]              = imgui.ImVec4(0.40, 0.40, 0.45, 1.00)
    style.Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.50, 0.50, 0.55, 1.00)
    style.Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.60, 0.60, 0.65, 1.00)
    style.Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.20, 0.20, 0.23, 1.00)
    style.Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
    style.Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
    style.Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.64, 1.00)
    style.Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.70, 0.70, 0.75, 1.00)
    style.Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.61, 0.61, 0.64, 1.00)
    style.Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.70, 0.70, 0.75, 1.00)
    style.Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
    style.Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.10, 0.10, 0.12, 0.80)
    style.Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.18, 0.20, 0.22, 1.00)
    style.Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.60, 0.60, 0.90, 1.00)
    style.Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.28, 0.56, 0.96, 1.00)
end