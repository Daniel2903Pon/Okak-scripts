script_name("Videocard Lovlya")
script_authors("@okak_scripts")
script_version("2.1")

local sampev = require("lib.samp.events")
local imgui = require "mimgui"
local encoding = require "encoding"
local ffi = require "ffi"
local faicons = require "fAwesome6"
encoding.default = "CP1251"
local u8 = encoding.UTF8
local cp = function(str) return u8:decode(str) end
local MDS = MONET_DPI_SCALE
local textDrawData = {}
local isCefOpen = false
local lastNotificationTime = 0
local menuAlpha = 0
local menuActive = false
local WinState = imgui.new.bool(false)
local WinState1 = imgui.new.bool(false)
local fps = 0
local frameCount = 0
local lastUpdateTime = os.clock()
local sizeX, sizeY = getScreenResolution()
local resX, resY = getScreenResolution()
local SET_DIR = getWorkingDirectory():gsub("\\", "/") .. "/settings"
local SET_PATH = SET_DIR .. "/videocard_lovlya.json"


local settings = {
    enable = false,
    captchaDelay = 1500,
    clickDelay = 100,
    showPayday = true,
    stats = { total = 0, solved = 0, bought = 0 }
}

local UI = {
    masterEnable = ffi.new("bool[1]", false),
    captchaDelay = ffi.new("int[1]", 1500),
    clickDelay = ffi.new("int[1]", 100),
    showPayday = ffi.new("bool[1]", true),
    stats_total = ffi.new("int[1]", 0),
    stats_solved = ffi.new("int[1]", 0),
    stats_bought = ffi.new("int[1]", 0)
}

function ensure_dir(path) 
    if not doesDirectoryExist(path) then createDirectory(path) end 
end

function load_settings()
    ensure_dir(SET_DIR)
    if doesFileExist(SET_PATH) then
        local f = io.open(SET_PATH, "r")
        if f then
            local data = f:read("*a"); f:close()
            if data ~= "" then
                local ok, tbl = pcall(require("cjson").decode, data)
                if ok and type(tbl) == "table" then
                    settings = tbl
                    settings.stats = settings.stats or { total = 0, solved = 0, bought = 0 }
                    UI.masterEnable[0] = settings.enable
                    UI.captchaDelay[0] = settings.captchaDelay
                    UI.clickDelay[0] = settings.clickDelay
                    UI.showPayday[0] = settings.showPayday
                    UI.stats_total[0] = settings.stats.total
                    UI.stats_solved[0] = settings.stats.solved
                    UI.stats_bought[0] = settings.stats.bought
                end
            end
        end
    end
end

function save_settings()
    settings.enable = UI.masterEnable[0]
    settings.captchaDelay = UI.captchaDelay[0]
    settings.clickDelay = UI.clickDelay[0]
    settings.showPayday = UI.showPayday[0]
    settings.stats.total = UI.stats_total[0]
    settings.stats.solved = UI.stats_solved[0]
    settings.stats.bought = UI.stats_bought[0]

    ensure_dir(SET_DIR)
    local f = io.open(SET_PATH, "w")
    if f then
        local ok, text = pcall(require("cjson").encode, settings)
        f:write(ok and text or ""); f:close()
    end
end

local snowflakes = {}
local max_snowflakes = 100
snowflakes_initialized = true
local lastSnowUpdate = 0
for i = 1, max_snowflakes do
    snowflakes[i] = {
        x = math.random(0, resX),
        y = math.random(-300, 1020),
        size = math.random(3, 6),
        speed = math.random(1, 4),
        sway = math.random(-2, 2),
        sway_speed = math.random(5, 15) / 100,
    }
end


local function drawSnowflake(bg, x, y, size, color)
    bg:AddRectFilled(imgui.ImVec2Up(x-1, y-size), imgui.ImVec2Up(x+1, y+size), color)
    bg:AddRectFilled(imgui.ImVec2Up(x-size, y-1), imgui.ImVec2Up(x+size, y+1), color)
end


local function drawBackground()
    if menuActive then
        menuAlpha = menuAlpha < 3 and menuAlpha + 0.05 or 3
    else
        menuAlpha = menuAlpha > 0 and menuAlpha - 0.05 or 0
        if menuAlpha <= 0 then 
            WinState[0] = false
            snowflakes = {}
            snowflakes_initialized = false
        end
    end

    local gradientTop = imgui.ImVec4(0, 0, 0.1, 0.2 * menuAlpha)
    local bg = imgui.GetBackgroundDrawList()
    bg:AddRectFilledMultiColor(imgui.ImVec2Up(0, 0), imgui.ImVec2Up(resX, resY), 
        imgui.ColorConvertFloat4ToU32(gradientTop), imgui.ColorConvertFloat4ToU32(gradientTop),
        imgui.ColorConvertFloat4ToU32(gradientTop), imgui.ColorConvertFloat4ToU32(gradientTop))
    bg:AddRectFilled(imgui.ImVec2Up(0, 0), imgui.ImVec2Up(resX, resY), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0, 0, 0, 0.7)), 0)

    local current_time = os.clock()
    if snowflakes_initialized and (current_time - lastSnowUpdate) > 0.016 then
        lastSnowUpdate = current_time
        for i = 1, max_snowflakes do
            local f = snowflakes[i]
            f.y = f.y + f.speed * 0.5
            f.x = f.x + math.sin(current_time * f.sway_speed) * f.sway
            if f.y > resY then 
                f.x, f.y = math.random(0, resX), math.random(-100, -10)
                f.speed = math.random(1, 3)
            end
            if f.x < -20 then f.x = resX + 10 end
            if f.x > resX + 20 then f.x = -10 end
            drawSnowflake(bg, f.x, f.y, f.size, imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 0.8 * menuAlpha)))
        end
    end

    imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, menuAlpha)
end

function sampev.onServerMessage(color, text)
    if settings.enable then
        local msg_lower = text:lower()
        if msg_lower:find(cp"сейчас в магазине нет обычных видеокарт") or 
            msg_lower:find(cp"ожидайте нового завоза") then
            return false
        end
    end
end

function getFPS()
    frameCount = frameCount + 1
    local currentTime = os.clock()
    local elapsed = currentTime - lastUpdateTime
    
    if elapsed >= 1.0 then
        fps = math.floor(frameCount / elapsed + 0.5)
        frameCount = 0
        lastUpdateTime = currentTime
    end
end


--Капча
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

function checkPaydayTime()
    if not UI.showPayday[0] or os.time() - lastNotificationTime < 60 then return end
    local h, m = tonumber(os.date("%H")), tonumber(os.date("%M"))
    local valid = {1,4,7,10,13,16,19,22}
    for _, hour in ipairs(valid) do
        if h == hour and m == 50 and sampIsLocalPlayerSpawned() then
            sms(cp"Через 10 минут PAYDAY! Бегите ловить видюху!")
            lastNotificationTime = os.time()
            break
        end
    end
end

function startCefClicking()
    
    if isCefOpen then return end
    isCefOpen = true
    lua_thread.create(function()
        while isCefOpen and settings.enable do
            sendFrontendClick(101, 0, 1, "0")
            UI.stats_bought[0] = UI.stats_bought[0] + 1
            save_settings()
            wait(UI.clickDelay[0])
        end
    end)
end

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

function sampev.onShowDialog(did, style, title, b1, b2, text)
    if not settings.enable then return end

    if title:find(cp"Проверка на робота") then
        local ok, ans = predictCaptcha(textDrawData)
        if ok then
            UI.stats_total[0] = UI.stats_total[0] + 1
            UI.stats_solved[0] = UI.stats_solved[0] + 1
            save_settings()
            lua_thread.create(function()
                wait(UI.captchaDelay[0])
                sampSendDialogResponse(did, 1, 0, ans)
                sms(cp"Капча решена: " .. ans)
            end)
        else
            sms(cp"Не удалось распознать капчу")
        end
        textDrawData = {}
        return false
    end

    if title:find(cp"Покупка видеокарты") then
        lua_thread.create(function()
            wait(50)
            sampSendDialogResponse(did, 1, 0, "")
            UI.stats_bought[0] = UI.stats_bought[0] + 1
            save_settings()
            sms(cp"Клик произведён!")
        end)
        return false
    end
end

function sampev.onShowTextDraw(textdrawId, data)
    if not settings.enable then return end
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

addEventHandler("onReceivePacket", function(id, bs)
    if id == 220 and settings.enable then
        raknetBitStreamIgnoreBits(bs, 8)
        local packetType = raknetBitStreamReadInt8(bs)

        if packetType == 84 then
            local interfaceid = raknetBitStreamReadInt8(bs)
            local subid = raknetBitStreamReadInt8(bs)
            local len = raknetBitStreamReadInt16(bs)
            local encoded = raknetBitStreamReadInt8(bs)
            local json = (encoded ~= 0) and raknetBitStreamDecodeString(bs, len + encoded) or raknetBitStreamReadString(bs, len)

            if tonumber(interfaceid) == 101 then
                sms(cp"Интерфейс открыт - автокликер запущен")
                startCefClicking()
            end
        end

        if packetType == 62 then
            local interfaceid = raknetBitStreamReadInt8(bs)
            local toggle = raknetBitStreamReadBool(bs)

            if tonumber(interfaceid) == 101 and not toggle then
                sms(cp"Интерфейс закрыт - автокликер остановлен")
                isCefOpen = false
            end
        end
    end
end)

imgui.OnInitialize(function()
    SoftMyTheme()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 20, config, iconRanges)
end)

local menu = {
    opened = imgui.new.bool(true),
    selected = {[0] = ' Настройки'},
    tabs = {
        [faicons("GEAR")] = ' Настройки',
        [faicons("COMPUTER_MOUSE")] = ' Автокликер',
        [faicons("CLOCK")] = ' PayDay',
        [faicons("CHART_LINE")] = ' Статистика',
        [faicons("INFO")] = ' Информация',
    }
}

imgui.OnFrame(function() return WinState[0] end, function()
    imgui.SetNextWindowPos(imgui.ImVec2Up(sizeX / 2, sizeY / 1.9), imgui.Cond.FirstUseEver, imgui.ImVec2Up(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2Up(500, 350), imgui.Cond.FirstUseEver)
    drawBackground()
    imgui.BeginWin11Menu('Ловля видеокарт by @okak_scripts', WinState, true, menu.tabs, menu.selected, menu.opened, 40, 100)

    if menu.selected[0] == ' Настройки' then
        imgui.Text("Основные настройки автоловли")
        imgui.Dummy(imgui.ImVec2Up(0, 10))

        local btn_text = settings.enable and "ВЫКЛЮЧИТЬ" or "ВКЛЮЧИТЬ"
        local btn_col = settings.enable and imgui.ImVec4(0.15, 0.65, 0.25, 1.0) or imgui.ImVec4(0.75, 0.20, 0.20, 1.0)
        imgui.PushStyleColor(imgui.Col.Button, btn_col)
        imgui.PushStyleColor(imgui.Col.ButtonHovered, btn_col)
        imgui.PushStyleColor(imgui.Col.ButtonActive, btn_col)
        if imgui.Button(btn_text, imgui.ImVec2Up(240, 50)) then
            settings.enable = not settings.enable
            UI.masterEnable[0] = settings.enable
            save_settings()
            sms(settings.enable and cp"Автоловля включена" or cp"Автоловля выключена")
            if not settings.enable then isCefOpen = false end
        end
        imgui.PopStyleColor(3)

        imgui.Dummy(imgui.ImVec2Up(0, 10))
        imgui.Text("Задержка капчи:")
        imgui.PushItemWidth(400)
        if imgui.SliderInt("##cap", UI.captchaDelay, 500, 3000, "%d мс") then 
            settings.captchaDelay = UI.captchaDelay[0]
            save_settings()
        end
        imgui.PopItemWidth()
        imgui.TextColored(imgui.ImVec4(0.6,0.6,0.6,1), "  Рекомендуется: 1000-2500")

        imgui.Dummy(imgui.ImVec2Up(0, 10))
        imgui.Text("Скорость кликов:")
        imgui.PushItemWidth(400)
        if imgui.SliderInt("##clk", UI.clickDelay, 50, 500, "%d мс") then 
            settings.clickDelay = UI.clickDelay[0]
            save_settings()
        end
        imgui.PopItemWidth()

        imgui.Dummy(imgui.ImVec2Up(0, 10))
        if imgui.Checkbox("Уведомления о PayDay", UI.showPayday) then 
            settings.showPayday = UI.showPayday[0]
            save_settings()
        end

    elseif menu.selected[0] == ' Автокликер' then
        imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.5, 1.0), "АВТОКЛИКЕР")
        imgui.Separator()
        imgui.Dummy(imgui.ImVec2Up(0, 10))
        
        local status_text = isCefOpen and "АКТИВЕН" or "НЕАКТИВЕН"
        local status_color = isCefOpen and imgui.ImVec4(0.2, 1.0, 0.2, 1.0) or imgui.ImVec4(1.0, 0.3, 0.3, 1.0)
        imgui.Text("Статус: ")
        imgui.SameLine()
        imgui.TextColored(status_color, status_text)
        imgui.Text("Кликает каждые: " .. UI.clickDelay[0] .. "мс")
        imgui.Dummy(imgui.ImVec2Up(0, 10))
        imgui.TextWrapped("Автокликер автоматически активируется при открытии интерфейса ловли и отключается при закрытии.")

    elseif menu.selected[0] == ' PayDay' then
        imgui.TextColored(imgui.ImVec4(1.0, 0.3, 0.3, 1.0), "PAYDAY УВЕДОМЛЕНИЯ")
        imgui.Separator()
        imgui.Dummy(imgui.ImVec2Up(0, 10))
        
        local payday_status = UI.showPayday[0] and "ВКЛЮЧЕНЫ" or "ВЫКЛЮЧЕНЫ"
        local payday_color = UI.showPayday[0] and imgui.ImVec4(0.2, 1.0, 0.2, 1.0) or imgui.ImVec4(1.0, 0.3, 0.3, 1.0)
        imgui.Text("Уведомления: ")
        imgui.SameLine()
        imgui.TextColored(payday_color, payday_status)
        
        imgui.Dummy(imgui.ImVec2Up(0, 10))
        imgui.TextWrapped("Скрипт будет напоминать вам за 10 минут до PayDay в следующие часы:")
        imgui.Dummy(imgui.ImVec2Up(0, 5))
        imgui.BulletText("01:50, 04:50, 07:50, 10:50")
        imgui.BulletText("13:50, 16:50, 19:50, 22:50")

    elseif menu.selected[0] == ' Статистика' then
        imgui.TextColored(imgui.ImVec4(0.85, 0.50, 0.70, 1.00), "СТАТИСТИКА")
        imgui.Separator()
        imgui.Dummy(imgui.ImVec2Up(0, 15))

        local function stat(label, value, color)
            imgui.Text(u8(label))
            imgui.SameLine()
            
            imgui.TextColored(color, tostring(value))
        end

        stat(cp"Всего капч:", UI.stats_total[0], imgui.ImVec4(1.0, 0.8, 0.0, 1.0))
        stat(cp"Решено:", UI.stats_solved[0], imgui.ImVec4(0.2, 0.8, 0.4, 1.0))
        stat(cp"Кликов:", UI.stats_bought[0], imgui.ImVec4(0.4, 0.7, 1.0, 1.0))

        imgui.Dummy(imgui.ImVec2Up(0, 10))

        if UI.stats_total[0] > 0 then
            local rate = math.floor(UI.stats_solved[0] / UI.stats_total[0] * 100)
            imgui.Text("Успешность:")
            imgui.SameLine()
            
            imgui.TextColored(imgui.ImVec4(1.0, 0.6, 1.0, 1.0), rate .. "%")
        end

        imgui.Dummy(imgui.ImVec2Up(0, 20))
        
        if imgui.Button("Очистить статистику", imgui.ImVec2Up(200, 40)) then
            UI.stats_total[0] = 0
            UI.stats_solved[0] = 0
            UI.stats_bought[0] = 0
            save_settings()
            sms(cp"Статистика очищена")
        end

    elseif menu.selected[0] == ' Информация' then
        imgui.TextColored(imgui.ImVec4(0.1, 0.9, 0.9, 1), "ИНФОРМАЦИЯ")
        imgui.Separator()
        imgui.Dummy(imgui.ImVec2Up(0, 10))
        
        imgui.Text("Скрипт: Videocard Lovlya")
        imgui.Text("Автор: @okak_scripts")
        imgui.Text("Версия: 2.0.3")
        imgui.Dummy(imgui.ImVec2Up(0, 10))
        
        imgui.TextColored(imgui.ImVec4(1, 0.8, 0.2, 1), "Функции скрипта:")
        imgui.BulletText("Автоматическая ловля видеокарт")
        imgui.BulletText("Распознавание капчи")
        imgui.BulletText("Автокликер в интерфейсе")
        imgui.BulletText("Статистика и уведомления PayDay")
        imgui.BulletText("Красивый снежный фон")
        imgui.Dummy(imgui.ImVec2Up(0, 10))
        
        imgui.TextColored(imgui.ImVec4(0.7, 1, 0.7, 1), "Поддержка:")
        imgui.Text("@okak_scripts")
    end
    

    imgui.EndWin11Menu()    
    imgui.PopStyleVar()
end)

imgui.OnFrame(function() return WinState1[0] end, function()
    getFPS()
    
    imgui.SetNextWindowPos(imgui.ImVec2Up(500, 500), imgui.Cond.FirstUseEver, imgui.ImVec2Up(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2Up(200, 50), imgui.Cond.Always)
    imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.118, 0.118, 0.118, 0.50))
    imgui.Begin("##Watermark", WinState1, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
    
    imgui.TextColoredRGB("{00BBFF}Videocard Lovlya ||")
    if imgui.IsItemClicked() then
        WinState[0] = not WinState[0]
        menuActive = WinState[0]
        menuAlpha = WinState[0] and 0 or 1
        sampSendChat("/hidehud")
    end
    imgui.SameLine()
    imgui.Text("FPS: " .. fps)
    
    imgui.PopStyleColor()
    imgui.End()
end)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end

    textDrawData = {}
    nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) or "Player"
    
    load_settings()

    sampRegisterChatCommand("vl", function()
        WinState[0] = not WinState[0]
        menuActive = WinState[0]
        sampSendChat("/hidehud")
    end)

    sampRegisterChatCommand("vlwm", function()
        WinState1[0] = not WinState1[0]
    end)

    repeat wait(0) until sampIsLocalPlayerSpawned()
    wait(1000)

    sms(cp"================================")
    sms(cp"Videocard Lovlya v2.0.3 загружен!")
    sms(cp"Добро пожаловать")
    sms(cp"Команды: /vl, /vlwm")
    sms(cp"================================")
    WinState1[0] = true

    while true do
        wait(100)
        checkPaydayTime()
    end
end

function sms(text)
    sampAddChatMessage("[Videocard Lovlya] {FFFFFF}" .. text, 0x1E90FF)
end

function imgui.ImVec2Up(x, y)
    return imgui.ImVec2(x * MDS, y * MDS)
end

--Menu by Chapo
function imgui.BeginWin11Menu(title, var, stateButton, tabs, selected, isOpened, sizeClosed, sizeOpened, windowFlags)
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2Up(0, 0))
    imgui.Begin(title, var, imgui.WindowFlags.NoTitleBar + (windowFlags or 0))

    local size = imgui.GetWindowSize()
    local pos = imgui.GetWindowPos()
    local dl = imgui.GetWindowDrawList()

    local tabSize = sizeClosed - 10

    imgui.SetCursorPos(imgui.ImVec2Up(size.x - tabSize - 5, 5))
    if imgui.Button('X##'..title..'::closebutton', imgui.ImVec2Up(tabSize, tabSize)) then if var then var[0] = false end end

    --==[ MAIN BG ]==--
    imgui.SetCursorPos(imgui.ImVec2Up(sizeClosed, sizeClosed))
    local p = imgui.GetCursorScreenPos()
    dl:AddRectFilled(p, imgui.ImVec2Up(p.x + size.x - sizeClosed, p.y + size.y - sizeClosed), imgui.GetColorU32Vec4(imgui.ImVec4(0.263, 0.263, 0.263, 1.0)), imgui.GetStyle().WindowRounding, 1 + 8)
   
    --==[ TITLEBAR ]==--
    imgui.SetCursorPos(imgui.ImVec2Up(0, 0))
    local p = imgui.GetCursorScreenPos()
    dl:AddRectFilled(p, imgui.ImVec2Up(p.x + (isOpened[0] and sizeOpened or sizeClosed), p.y + size.y), imgui.GetColorU32Vec4(imgui.ImVec4(0.188, 0.188, 0.188, 0.80)), imgui.GetStyle().WindowRounding, 1 + 4)
    
    -- Заголовок по центру
    local titleWidth = imgui.CalcTextSize(title).x
    imgui.SetCursorPosX((imgui.GetWindowWidth()+(sizeClosed + 65))/2-imgui.CalcTextSize(title).x/2)
    imgui.SetCursorPosY(30)
    imgui.TextColored(imgui.ImVec4(0.318, 0.808, 1.0, 1.0), title)

    --==[ TABS BUTTONS ]==--
    imgui.SetCursorPosY(5)
    if stateButton then
        imgui.SetCursorPosX(5)
        imgui.SetCursorPosY(sizeClosed + 60)
    else
        imgui.SetCursorPosY(5 + tabSize + 5)
    end
    for k, v in pairs(tabs) do
        imgui.SetCursorPosX(5)
        
        local btnColor = selected[0] == v and imgui.ImVec4(0.474, 0.474, 0.474, 0.80) or imgui.ImVec4(0.188, 0.188, 0.188, 0.80)
        imgui.PushStyleColor(imgui.Col.Button, btnColor)
        imgui.PushStyleVarVec2(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2Up(isOpened[0] and 0.1 or 0.5, 0.5))
        if imgui.Button(isOpened[0] and k..' '..v or k, imgui.ImVec2Up(isOpened[0] and sizeOpened or tabSize, tabSize)) then selected[0] = v end
        
        imgui.PopStyleVar()
        imgui.PopStyleColor()
    end

    --==[ CHILD ]==--
    imgui.SetCursorPos(imgui.ImVec2Up(sizeClosed + 65, (sizeClosed + 65)/2.3))
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2Up(15, 15))
    imgui.BeginChild(title..'::mainchild', imgui.ImVec2Up(size.x - sizeClosed + 50, size.y - sizeClosed - 5), true)
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.00, 0.00, 0.00, 1.00))
end

function imgui.EndWin11Menu()
    imgui.PopStyleColor()
    imgui.EndChild()
    imgui.End()
    imgui.PopStyleVar(2)
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4
    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end
    local getcolor = function(color)
        if color:sub(1, 6):upper() == "SSSSSS" then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == "string" and tonumber(color, 16) or color
        if type(color) ~= "number" then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end
    local render_text = function(text_)
        for w in text_:gmatch("[^\r\n]+") do
            local text, colors_, m = {}, {}, 1
            w = w:gsub("{(......)}", "{%1FF}")
            while w:find("{........}") do
                local n, k = w:find("{........}")
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end

function imgui.ColSeparator(hex,trans)
    local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
    if tonumber(trans) ~= nil and tonumber(trans) < 101 and tonumber(trans) > 0 then a = trans else a = 100 end
    imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(r/255, g/255, b/255, a/100))
    local colsep = imgui.Separator()
    imgui.PopStyleColor(1)
    return colsep
end

function imgui.LinkText(link)
    imgui.Text(link)
    if imgui.IsItemClicked(0) then os.execute(("start %s"):format(link)) end
end

function SoftMyTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    style.WindowPadding = imgui.ImVec2Up(15, 15)
    style.WindowRounding = 15.0
    style.ChildRounding = 15.0
    style.FramePadding = imgui.ImVec2Up(8, 7)
    style.FrameRounding = 8.0
    style.ItemSpacing = imgui.ImVec2Up(8, 8)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 20.0
    style.GrabMinSize = 10.0
    style.GrabRounding = 6.0
    style.WindowBorderSize = 0

    local c = style.Colors
    c[imgui.Col.Text] = imgui.ImVec4(0.90, 0.90, 0.93, 1.00)
    c[imgui.Col.WindowBg] = imgui.ImVec4(0.188, 0.188, 0.188, 0.80)
    c[imgui.Col.ChildBg] = imgui.ImVec4(0.851, 0.851, 0.851, 1.00)
    c[imgui.Col.FrameBg] = imgui.ImVec4(0.651, 0.651, 0.651, 1.00)
    c[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.70, 0.70, 0.70, 1.00)
    c[imgui.Col.FrameBgActive] = imgui.ImVec4(0.75, 0.75, 0.75, 1.00)
    c[imgui.Col.Button] = imgui.ImVec4(0.188, 0.188, 0.188, 0.80)
    c[imgui.Col.ButtonHovered] = imgui.ImVec4(0.474, 0.474, 0.474, 0.80)
    c[imgui.Col.ButtonActive] = imgui.ImVec4(0.474, 0.474, 0.474, 0.80)
    c[imgui.Col.CheckMark] = imgui.ImVec4(0.70, 0.70, 0.90, 1.00)
    c[imgui.Col.SliderGrab] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    c[imgui.Col.SliderGrabActive] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    c[imgui.Col.Header] = imgui.ImVec4(0.20, 0.20, 0.23, 1.00)
    c[imgui.Col.HeaderHovered] = imgui.ImVec4(0.25, 0.25, 0.28, 1.00)
    c[imgui.Col.HeaderActive] = imgui.ImVec4(0.30, 0.30, 0.34, 1.00)
end