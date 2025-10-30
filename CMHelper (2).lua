script_author("@okak_pon_okak and @lua_builder")
script_name("Central market helper")
script_description("Помощник для центрального рынка")

--Библиотеки
local imgui = require("mimgui")
local encoding = require("encoding")
local events = require('samp.events')
local inicfg = require('inicfg')
local ffi = require('ffi')

--Кодировка
encoding.default = 'CP1251'
local u8 = encoding.UTF8
function getInputText(buffer)
    return u8:decode(ffi.string(buffer))
end

--INI
local directIni = 'CMHelper.ini'
local ini = inicfg.load({
    main = {
        radius = false,
        catching = false,
        render = false
    },
}, directIni)
inicfg.save(ini, directIni)

--Переменные
local main_window = imgui.new.bool(false)
local radius_bool = imgui.new.bool(ini.main.radius)
local catchig_bool = imgui.new.bool(ini.main.catching)
local render_bool = imgui.new.bool(ini.main.render)

--MIMGUI
imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    SoftBlueTheme()
end)

local newFrame = imgui.OnFrame(
    function() return main_window[0] end,
    function(player)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 300, 300
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'ЦР Хелпер', main_window)
        if imgui.Checkbox(u8"Радиус лавок", radius_bool) then
            saveIni()
        end
        if imgui.Checkbox(u8"Авто ловля", catchig_bool) then
            saveIni()
        end
        if imgui.Checkbox(u8"Рендер на свободные лавки", render_bool) then
            saveIni()
        end
        imgui.End()
    end
)

function main()
    while not isSampAvailable() do wait(0) end
        

    sampRegisterChatCommand("cmhelper", function ()
        main_window[0] = not main_window[0]
    end)
    while true do
        wait(0)
        if radius_bool[0] then
	        for IDTEXT = 0, 2048 do
	            if sampIs3dTextDefined(IDTEXT) then
	                local text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(IDTEXT)
	                if text ==  "Управления товарами." and not isCentralMarket(posX, posY) then
						local myPos = {getCharCoordinates(1)}
	                    drawCircleIn3d(posX,posY,posZ-1.3,5,36,1.5,	getDistanceBetweenCoords3d(posX,posY,0,myPos[1],myPos[2],0) > 5 and 0xFFFFFFFF or 0xFFFF0000)
	                end
	            end
	        end
	    end
        if catchig_bool[0] or render_bool[0] then
            checkLavki()
        end
    end
end

--SAMP events
function events.onShowDialog(dialogId)
    if dialogId == 3010 and catchig_bool[0] then
        sampSendDialogResponse(dialogId, 1, 0, "")
        msg("Вы поймали {ffb400}лавку!")
    end
end

function events.onSetObjectMaterialText(ev, data)
    local Object = sampGetObjectHandleBySampId(ev)
    if doesObjectExist(Object) and getObjectModel(Object) == 18663 and string.find(data.text, "(.-) {30A332}Свободна!") then
        if get_distance(Object) and catchig_bool[0] then
            msg("Нашел лавку, жму альт")
            setGameKeyState(19, 255)
            wait(100)
            setGameKeyState(19, 0)
            sendFrontendClick(8,7,-1, {})
        end
    end
end

--Функции
function msg(text)
    sampAddChatMessage("{FF0000}[CMHelper]{FFFFFF} "..text, -1)
end
function saveIni()
    ini.main.catching = catchig_bool[0]
    ini.main.radius = radius_bool[0]
    ini.main.render = render_bool[0]

    inicfg.save(ini, directIni)
end

function drawCircleIn3d(x, y, z, radius, polygons,width,color)
    local step = math.floor(360 / (polygons or 36))
    local sX_old, sY_old
    for angle = 0, 360, step do
        local lX = radius * math.cos(math.rad(angle)) + x
        local lY = radius * math.sin(math.rad(angle)) + y
        local lZ = z
        local _, sX, sY, sZ, _, _ = convert3DCoordsToScreenEx(lX, lY, lZ)
        if sZ > 1 then
            if sX_old and sY_old then
                renderDrawLine(sX, sY, sX_old, sY_old, width, color)
            end
            sX_old, sY_old = sX, sY
        end
    end
end

function isCentralMarket(x, y)
	return (x > 1090 and x < 1180 and y > -1550 and y < -1429)
end

function checkLavki()
    for id = 0, 2304 do
        if sampIs3dTextDefined(id) then
            local text, _, posX, posY, posZ, _, _, _, _ = sampGet3dTextInfoById(id)
            if math.floor(posZ) == 17 and text == '' then
                if isPointOnScreen(posX, posY, posZ, 100000) then
                    local pX, pY = convert3DCoordsToScreen(getCharCoordinates(PLAYER_PED))
                    local lX, lY = convert3DCoordsToScreen(posX, posY, posZ)
                    if render_bool[0] then
                        renderDrawLine(pX, pY, lX, lY, 1, 0xFF52FF4D)
                        renderDrawPolygon(pX, pY, 10, 10, 10, 0, 0xFFFFFFFF)
                        renderDrawPolygon(lX, lY, 10, 10, 10, 0, 0xFFFFFFFF)
                    end
                    if get_distance(id) then
                        msg("Нашел лавку, жму альт")
                        setGameKeyState(19, 255)
                        wait(100)
                        setGameKeyState(19, 0)
                        sendFrontendClick(8,7,-1, {})
                        wait(1000)
                        break
                    end
                end
            end
        end
    end
    
end
function get_distance(id)
    text, _, posX, posY, posZ, _, _, _, _ = sampGet3dTextInfoById(id)
    
        
            local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
            local distance = (math.abs(posX - pPosX)^2 + math.abs(posY - pPosY)^2)^0.5
            if round(distance, 2) <= 2.0 then
                return true
            end
        

    
    return false
end

function round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
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