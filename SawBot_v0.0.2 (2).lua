script_author('Fomikus')
script_name('Leso–уб бот')
script_version('0.0.2')
script_description("Leso–уб эта бот на лесопилку, он рубит лес!")
local imgui = require 'mimgui'
local ti = require 'tabler_icons'
local encoding = require 'encoding'
local samp = require 'lib.samp.events'
encoding.default = 'CP1251'

--Shortcuts
local u8 = encoding.UTF8
local new = imgui.new
local iv2 = imgui.ImVec2
local iv4 = imgui.ImVec4
local conv_c = imgui.ColorConvertFloat4ToU32
local g_cpos = imgui.GetCursorPos

local config = {
    radar = false,
    debug = false,
    tracers = true,
    radar_size = 299,
    radar_zoom = 20,
    radar_pos = {187, 553}
}

local cVARS = {
    bot = new.bool(false),
    menu = new.bool(false),
    radar = new.bool(true),
    tracers = new.bool(false),
    debug = new.bool(true),
    radar_size = new.int(299),
    radar_zoom = new.int(20)
}

local last_fix_zabor_id = 1
local fix_zabors = {
    {-518.6240234375, -167.93728637695, 76.015960693359},
    {-506.95404052734, -163.70083618164, 75.066604614258}, 
    {-512.50921630859, -159.77796936035, 74.752792358398}
}

local bot_state = "IDLE"
local set_wait_alt = 0
-- IDLE - ничего, которое потом сразу мен€ет если бот запущен, просто дл€ хайпа создан
-- SEARCH_TREE - поиск дерева и бег к нему
-- WAIT_ALT - флуд альтом
-- RUN_CENTER - бежит к "дороге" котора€ может привести к сдаче
-- RUN_SDACHA - бег к сдаче и флуд альтом если близко
-- WAIT_TELEGA - не определено, но по сути и не надо ничего делать
-- RUN_FIX_ZABOR - фикс ебучего забора, вахуи с него

local elements = {
    radar = {
        pos = {x = 187, y = 553},
        set_pos = false,
        set_pos_offset = {x = 0, y = 0},
        draw_points = {}
    },
    custom = {
        toggle_button = {},
        slider_custom = {}
    }
}

local ignore_trees = {
    {-562, -135, 72}
}

local center_coords = {
    {-511.055786132, -169.019500732, 75.8674774},
    {-512.460205078, -148.792236328, 73.2221069},
    {-513.005432128, -135.199645996, 70.3452224},
    {-513.298828125, -123.202331548, 66.9921875},
    {-512.765991210, -104.848159790, 63.5846252},
    {-511.860595703, -86.7380676269, 62.1677665},
    {-511.542388912, -147.507537841, 73.0059661},
    {-512.583374024, -190.684219365, 78.2473602}
}
local точки_дјроги = {
    {x = -512.693359375, y = -190.7613067627, z = 78.250762939453},
    {x = -506.49435424805, y = -14.57945728302, z = 56.492931365967}
}

function lineVec(point1, point2, distance)
    local dx = point2.x - point1.x
    local dy = point2.y - point1.y

    local length = math.sqrt(dx * dx + dy * dy)
    local normalized_dx = dx / length
    local normalized_dy = dy / length
    local new_x = point1.x - normalized_dx * distance
    local new_y = point1.y - normalized_dy * distance
    return {x = new_x, y = new_y}
end

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100) end
    cMsg("”спешно загружен! »спользуй {ABABAB}/sawbot")
    sampRegisterChatCommand("sawbot", function()
        cVARS.menu[0] = not cVARS.menu[0]
        bot_state = "IDLE"
    end)
    load_cfg()
    while true do wait(0)
        if cVARS.tracers[0] then
            local x, y, z = getCharCoordinates(PLAYER_PED)
			local pX, pY = convert3DCoordsToScreen(x, y, z)
			for id = 0, 2048 do
				if sampIs3dTextDefined(id) then
					local text, color, posX, posY, posZ, distance, ignore_walls, player, veh = sampGet3dTextInfoById(id)
					local distance = getDistanceBetweenCoords3d(posX, posY, posZ, x, y, z)
                    if text:find("—рубить дерево") and isPointOnScreen(posX,posY,posZ, -1) and distance < 60 then 
						local wX, wY = convert3DCoordsToScreen(posX,posY,posZ)
						renderDrawLine(pX,pY,wX,wY, 1,0xFFFFFFFF)
                        renderDrawPolygon(wX,wY,5,5,16,0,0xFF00FFFF)
					end
				end
			end
        end
        if cVARS.bot[0] then
            local f, tree = getNearestTree()
            if bot_state == "IDLE" then
                bot_state = "RUN_FIX_ZABOR"
            elseif bot_state == "RUN_FIX_ZABOR" then 
                local point = fix_zabors[last_fix_zabor_id]
                runToPoint(point[1], point[2], point[3])
                local distance = distPoint(point[1], point[2], point[3])
                if distance < 5 then
                    bot_state = "SEARCH_TREE"
                    last_fix_zabor_id = math.random(1, 3) -- хуй знает включаемо или нет, похуй
                end
            elseif bot_state == "RUN_CENTER" then
                local nearest_c = получитьѕерпендикул€р ÷ентру()
                local center_r = получитьѕерпендикул€р ÷ентру()
                local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
                local distance_to_center = getDistanceBetweenCoords2d(center_r[1], center_r[2], pX, pY)
                local res = lineVec({x = center_r[1], y = center_r[2]}, {x = точки_дјроги[2].x, y = точки_дјроги[2].y}, (10 - distance_to_center) > 0 and (5 + 10 - distance_to_center) or 5)
                runToPoint(res.x, res.y, nearest_c[3])
                local distance = distPoint(nearest_c[1], nearest_c[2], nearest_c[3])
                if distance < 5 then
                    bot_state = "RUN_SDACHA"
                end
            elseif bot_state == "RUN_SDACHA" then
                runToPoint(-512.58337402344, -190.68421936035, 78.247360229492)
                local distance = distPoint(-512.58337402344, -190.68421936035, 78.247360229492)
                if distance < 1.5 then
                    if last_alt then 
                        local data = samp_create_sync_data('player')
                        data.keysData = data.keysData + (last_alt and 1024 or 0)
                        data.send()
                    end
                    last_alt = not last_alt
                end
            elseif bot_state == "SEARCH_TREE" then
                if f then
                    runToPoint(tree[1], tree[2], tree[3])
                    local distance = distPoint(tree[1], tree[2], tree[3])
                    if distance < 1.5 then
                        bot_state = "WAIT_ALT" -- ’з зачем еще 1 стейт, но пусть
                        set_wait_alt = os.clock()
                    end
                end
            elseif bot_state == "WAIT_ALT" then
                local mX, mY, mZ = getCharCoordinates(PLAYER_PED)
                local distance = getDistanceBetweenCoords2d(mX, mY, tree[1], tree[2])
                if os.clock() - set_wait_alt > 15 then
                    table.insert(ignore_trees, {tree[1], tree[2], tree[3]}) -- баним точку нахуй, если она сломана
                end
                if distance > 1.5 then
                    bot_state = "SEARCH_TREE" -- если испарилось дерево нахуй бл€ть
                else
                    if last_alt then 
                        local data = samp_create_sync_data('player')
                        data.keysData = data.keysData + (last_alt and 1024 or 0)
                        data.send()
                    end
                    last_alt = not last_alt -- вроде это не надо, ибо обычна€ синхра сама отправл€ет и тоже самое сделает
                end
            end
        end
    end
end

function перпендикул€тор ѕр€мой„ерез“очку(точка_пр€мой_адин, точка_пр€мой_два, наша_точка)
    local икс = (точка_пр€мой_адин.x * точка_пр€мой_адин.x * наша_точка.x - 2 * точка_пр€мой_адин.x * точка_пр€мой_два.x * наша_точка.x + точка_пр€мой_два.x * точка_пр€мой_два.x * наша_точка.x + точка_пр€мой_два.x *
    (точка_пр€мой_адин.y - точка_пр€мой_два.y) * (точка_пр€мой_адин.y - наша_точка.y) - точка_пр€мой_адин.x * (точка_пр€мой_адин.y - точка_пр€мой_два.y) * (точка_пр€мой_два.y - наша_точка.y)) / ((точка_пр€мой_адин.x - точка_пр€мой_два.x) *
            (точка_пр€мой_адин.x - точка_пр€мой_два.x) + (точка_пр€мой_адин.y - точка_пр€мой_два.y) * (точка_пр€мой_адин.y - точка_пр€мой_два.y))
    local игрек = (точка_пр€мой_два.x * точка_пр€мой_два.x * точка_пр€мой_адин.y + точка_пр€мой_адин.x * точка_пр€мой_адин.x * точка_пр€мой_два.y + точка_пр€мой_два.x * наша_точка.x * (точка_пр€мой_два.y - точка_пр€мой_адин.y) - точка_пр€мой_адин.x *
    (наша_точка.x * (точка_пр€мой_два.y - точка_пр€мой_адин.y) + точка_пр€мой_два.x * (точка_пр€мой_адин.y + точка_пр€мой_два.y)) + (точка_пр€мой_адин.y - точка_пр€мой_два.y) * (точка_пр€мой_адин.y - точка_пр€мой_два.y) * наша_точка.y) / ((
                точка_пр€мой_адин.x - точка_пр€мой_два.x) * (точка_пр€мой_адин.x - точка_пр€мой_два.x) + (точка_пр€мой_адин.y - точка_пр€мой_два.y) * (точка_пр€мой_адин.y - точка_пр€мой_два.y));
    return {икс, игрек}
end

function получитьѕерпендикул€р ÷ентру()
    local mX, mY, mZ = getCharCoordinates(PLAYER_PED)
    local –е«уЋь“а“ = перпендикул€тор ѕр€мой„ерез“очку(точки_дјроги[1], точки_дјроги[2], {x = mX, y = mY})
    return {–е«уЋь“а“[1], –е«уЋь“а“[2], mZ}
end

function getNearestCenterPoint() -- ближайша€ точка к педу из списка center_coords
    local mX, mY, mZ = getCharCoordinates(PLAYER_PED)
    local min_dist = 2 ^ 10
    local near_point = {0, 0, 0}
    for _, v in pairs(center_coords) do
        local distance = getDistanceBetweenCoords3d(mX, mY, mZ, v[1], v[2], v[3])
        if distance < min_dist then
            min_dist = distance
            near_point = {v[1], v[2], v[3]}
        end
    end
    return near_point
end

function distPoint(x, y, z) -- дистанци€ от педа до точки
    local mX, mY, mZ = getCharCoordinates(PLAYER_PED)
    local distance = getDistanceBetweenCoords3d(mX, mY, mZ, x, y, z)
    return distance
end

function runToPoint(x, y, z) -- бег к точке со спринтом и поворотом в зависимости от дистанции и игровых обьектов перед игроков
    set_camera_direction({x, y, z})
    if not last_jump then last_jump = 0 end
    local mX, mY, mZ = getCharCoordinates(PLAYER_PED)
    local distance = getDistanceBetweenCoords3d(mX, mY, mZ, x, y, z)
    setGameKeyState(1, -255)
    if distance > 15 and os.clock() - last_jump > 1 and (bot_state == "SEARCH_TREE" or bot_state == "RUN_FIX_ZABOR") then
        setGameKeyState(14, 255)
        last_jump = os.clock()
    else
        setGameKeyState(16, distance > 8 and 255 or 0)
    end
    local random_left_right = math.random(1, 10000)
    if random_left_right > 9500 then
        setGameKeyState(0, 255)
    elseif random_left_right < 500 then
        setGameKeyState(0, -255)
    else 
        setGameKeyState(0, 0)
    end
    setGameKeyState(0, isBuildingInFront() and -255 or 0) -- Ќ” “”“ ¬ѕјƒЋ” ƒ”ћј“№  ј  ќЅ’ќƒ»“№ ќЅ№≈ “џ, ѕќ ћ”∆— » ¬Ћ≈¬ќ ƒќ  ќЌ÷ј, ћќЋ»ћ—я „“ќЅџ Ќ≈ ”ѕјЋ» — √ќ–џ
end

function isBuildingInFront() -- проверка на игровую постройку перед игроков (5 метров)
    local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
    local ped_angle = math.rad(getCharHeading(PLAYER_PED)) + math.pi / 2
    local ppX, ppY, ppZ = 5 * math.cos(ped_angle) + pX, 5 * math.sin(ped_angle) + pY, pZ + 0.8 -- плюс 0.8 по Z потому-что там в горку идЄт чел и надо вообщем +1 чтобы он в землю не тыкалс€
    local wpX, wpY = convert3DCoordsToScreen(pX, pY, pZ)
    --local wppX, wppY = convert3DCoordsToScreen(ppX, ppY, ppZ)
    --renderDrawLine(wpX, wpY, wppX, wppY, 3, 0xFFFFFFFF)
    result, colPoint = processLineOfSight(pX, pY, pZ, ppX, ppY, ppZ, true, false, true, false, false, false, false, false)
    return result and colPoint.entityType == 1
end

function samp.onApplyPlayerAnimation(player_id, anim_lib, anim_name, loop, lock_x, lock_y, freeze, time)
    local _, my_id = sampGetPlayerIdByCharHandle(PLAYER_PED) -- селект не дл€ мен€
    if player_id == my_id and anim_lib == "CHAINSAW" and anim_name == "WEAPON_csaw" then
        bot_state = 'WAIT_TELEGA'
    end
end

function samp.onSetPlayerAttachedObject(playerId, index, create, object)
    
if object.modelId == 1458 then
        bot_state = "RUN_CENTER"
        
    end
end

function samp.onSendPlayerSync(data)
    if bot_state == "RUN_SDACHA" then
        data.keysData = 0 -- возможно за это будут банить, возможно оно ни на что не вли€ет, но вроде как ломаетс€ тележка ебуча€, поэтому так
    end
    return data
end

function samp.onServerMessage(color, text)
    if cVARS.bot[0] and not text:find("говорит") and not text:find("кричит") then -- впадлу везде цвета прописывать
        if text:find("{ffffff}¬ы слишком далеко от дерева!") then
            bot_state = "SEARCH_TREE"
        elseif text:find("{ffffff}ƒл€ срубки дерева ¬ам необходимо начать") then
            cVARS.bot[0] = false
            cMsg("¬ы не работаете на лесопилке!")
        elseif color == -1347440641 and text:find("¬ы сломали тележку, отправл€йтесь и срубите дерево по новой!") then
            bot_state = "SEARCH_TREE"
        elseif text:find("¬сего спилено дерева:") then -- по мужски в хуке детача обьекта, но пох
            bot_state = "RUN_FIX_ZABOR"
            last_jump = os.clock() + 3 -- чтобы в стену не впечаталс€
        end
    end
end

function getNearestTree() -- Ѕлижайшее дерево, которого нет в ignore_trees
    if not isSampfuncsLoaded() or not isSampLoaded() or not isSampAvailable() then return false, {0, 0, 0} end
    local nearest_dist = 2 ^ 10
    local nearest_tree = {0, 0, 0}
    local mX, mY, mZ = getCharCoordinates(PLAYER_PED)
    local find = false
    for id = 0, 2048 do
        if sampIs3dTextDefined(id) then
            local text, color, posX, posY, posZ, distance, ignore_walls, player, veh = sampGet3dTextInfoById(id)
            local distance = getDistanceBetweenCoords3d(posX, posY, posZ, mX, mY, mZ)
            if text:find("—рубить дерево") then 
                if distance < nearest_dist and noPlayersAround({posX, posY, posZ}) and not coordsIn({posX, posY, posZ}, ignore_trees) then
                    find = true
                    nearest_dist = distance
                    nearest_tree = {posX, posY, posZ}
                end
            end
        end
    end
    return find, nearest_tree
end

function coordsIn(el, _table) -- провер€ет не €вл€етс€ ли точка одной из спика, с 'погрешностью' в 1 метр
    for _, v in pairs(_table) do
        local dist = getDistanceBetweenCoords2d(el[1], el[2], v[1], v[2])
        if dist < 1 then
            return true
        end
    end
    return false
end

function noPlayersAround(point, radius) -- ѕроверка на свободу дерева, скорее всего можно было сделать через муновское inSphere или как-то так, но € пь€ный наверное был когда писал
    local radius = radius or 3
    for _, player in ipairs(getAllChars()) do
        if select(1, sampGetPlayerIdByCharHandle(player)) and player ~= PLAYER_PED then
            local plX, plY, plZ = getCharCoordinates(player)
            local dist = getDistanceBetweenCoords3d(plX, plY, plZ, point[1], point[2], point[3])
            if dist < radius then return false end
        end
    end
    return true
end

function set_camera_direction(point) -- украл откуда-то
	local c_pos_x, c_pos_y, c_pos_z = getActiveCameraCoordinates()
	local vect = {x = point[1] - c_pos_x, y = point[2] - c_pos_y}
	local ax = math.atan2(vect.y, -vect.x)
	setCameraPositionUnfixed(0.0, -ax)
end

imgui.OnFrame(function() return cVARS.debug[0] end,
    function(self)
        self.HideCursor = true
    end,
    function(player)
        local b_dl = imgui.GetBackgroundDrawList()
        b_dl:AddRectFilled(iv2(40, 360), iv2(600, 435), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 0.0, 0.0, 0.6)), 6)
        imgui.PushFont(fonts[16])
        b_dl:AddText(iv2(50, 370), 0xFFFFFFFF, "BOT_STATE = " .. bot_state)
        local x, y, z = getCharCoordinates(PLAYER_PED)
        b_dl:AddText(iv2(50, 390), 0xFFFFFFFF, "PED_COORDS | " .. string.format( "X = %.3f Y = %.3f Z = %.3f", x, y, z))
        local f, tree = getNearestTree()
        b_dl:AddText(iv2(50, 410), 0xFFFFFFFF, "NEAREST_TREE | " .. (f and "TRUE" or "FALSE") .. " | " .. string.format( "X = %.3f Y = %.3f Z = %.3f", tree[1], tree[2], tree[3]))
        imgui.PopFont()
    end
)

imgui.OnFrame(function() return cVARS.radar[0] end,
    function(self)
        self.HideCursor = true

        if imgui.IsMouseDoubleClicked(0) and imgui.IsMouseHoveringRect(iv2(elements.radar.pos.x - cVARS.radar_size[0] / 2, elements.radar.pos.y - cVARS.radar_size[0] / 2), iv2(elements.radar.pos.x + cVARS.radar_size[0] / 2, elements.radar.pos.y + cVARS.radar_size[0] / 2), false) then
            elements.radar.set_pos = not elements.radar.set_pos
            local mouse_pos = imgui.GetMousePos()
            elements.radar.set_pos_offset = {
                x = mouse_pos.x - elements.radar.pos.x,
                y = mouse_pos.y - elements.radar.pos.y
            }
        end
        if elements.radar.set_pos then
            local mouse_pos = imgui.GetMousePos()
            elements.radar.pos.x = mouse_pos.x - elements.radar.set_pos_offset.x
            elements.radar.pos.y = mouse_pos.y - elements.radar.set_pos_offset.y
        end
        draw_points = {}
        local b_dl = imgui.GetBackgroundDrawList()
        local X1, Y1, Z1 = getActiveCameraCoordinates()
        local X2, Y2, Z2 = getActiveCameraPointAt()
        local cameraAngle = -math.atan2(X1 - X2, Y1 - Y2) - math.pi
        local cam_sin = math.sin(cameraAngle)
        local cam_cos = math.cos(cameraAngle)
        local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
        if not isSampfuncsLoaded() or not isSampLoaded() or not isSampAvailable() then return end
        for id = 0, 2048 do
            if sampIs3dTextDefined(id) then
                local text, color, posX, posY, posZ, distance, ignore_walls, player, veh = sampGet3dTextInfoById(id)
                if text:find("—рубить дерево") then 
                    local dps = worldToRadarCenterOffset(posX, posY, pX, pY, cVARS.radar_zoom[0], cVARS.radar_size[0])
                    dps = rotatePoint(dps, iv2(0, 0), cam_cos, cam_sin)
                    dps.x = dps.x < -cVARS.radar_size[0] / 2 and -cVARS.radar_size[0] / 2 or dps.x
                    dps.x = dps.x > cVARS.radar_size[0] / 2 and cVARS.radar_size[0] / 2 or dps.x
                    dps.y = dps.y < -cVARS.radar_size[0] / 2 and -cVARS.radar_size[0] / 2 or dps.y
                    dps.y = dps.y > cVARS.radar_size[0] / 2 and cVARS.radar_size[0] / 2 or dps.y
                    table.insert(draw_points, iv2(dps.x + elements.radar.pos.x, dps.y + elements.radar.pos.y))
                end
            end
        end 

    end,
    function (player)
        local b_dl = imgui.GetBackgroundDrawList()
        b_dl:AddRectFilled(
            iv2(elements.radar.pos.x - cVARS.radar_size[0] / 2, elements.radar.pos.y - cVARS.radar_size[0] / 2),
            iv2(elements.radar.pos.x + cVARS.radar_size[0] / 2, elements.radar.pos.y + cVARS.radar_size[0] / 2),
            imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 0.0, 0.0, 0.5)), 10
        )
        b_dl:AddLine(iv2(elements.radar.pos.x, elements.radar.pos.y - cVARS.radar_size[0] / 2), iv2(elements.radar.pos.x, elements.radar.pos.y + cVARS.radar_size[0] / 2), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 0.5)), 1)
        b_dl:AddLine(iv2(elements.radar.pos.x - cVARS.radar_size[0] / 2, elements.radar.pos.y), iv2(elements.radar.pos.x + cVARS.radar_size[0] / 2, elements.radar.pos.y), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 1, 1, 0.5)), 1)
        if elements.radar.set_pos then
            imgui.PushFont(fonts[48])
            local text_size = imgui.CalcTextSize(ti.ICON_ARROWS_MOVE)
            b_dl:AddText(iv2(elements.radar.pos.x - text_size.x / 2, elements.radar.pos.y - text_size.y / 3), 0xFFFFFFFF, ti.ICON_ARROWS_MOVE)
            imgui.PopFont()
        end

        for k, v in pairs(draw_points) do
            b_dl:AddCircleFilled(v, 4, imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.21, 0.21, 0.21, 1)), 16)
            b_dl:AddCircleFilled(v, 3, imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.37, 1, 0.27, 1)), 16)
        end
    end
)

function rotatePoint(p, o, c, s) -- покс, крутит точку p, вокруг точки o, C и S - cos и sin угла
    return iv2(
        (c * (p.x - o.x) - s * (p.y - o.y)) + o.x,
        (s * (p.x - o.x) + c * (p.y - o.y)) + o.y
    )
end

function worldToRadarCenterOffset(pos_x, pos_y, pX, pY, zoom, radar_radius) -- World to radar on screen
    return iv2(((pos_x - pX) / (3000 / zoom)) * radar_radius, ((pY - pos_y) / (3000 / zoom)) * radar_radius)
end

imgui.OnFrame(function() return cVARS.menu[0] end,
    function (self) 
        
    end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(500, 280), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(400, 273), imgui.Cond.Always)
        imgui.Begin(u8'##main_window', cVARS.menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
            imgui.PushFont(fonts[48])
            imgui.SetCursorPosX(14) -- (200 - imgui.CalcTextSize(ti.ICON_WOOD .. u8"Ѕот - лесоруб").x / 2)
            imgui.Text(ti.ICON_WOOD .. u8"Ѕот - лесоруб")
            imgui.PopFont()
            imgui.SetCursorPosY(70)
            imgui.PushFont(fonts[16])
            imgui.SetCursorPosX(10)
            imgui.ToggleButton(ti.ICON_TREES .. u8" Ѕот говна", cVARS.bot, 0.15)
            imgui.ToggleButton(ti.ICON_RADAR .. u8" –адар", cVARS.radar, 0.15)
            imgui.ToggleButton(ti.ICON_VECTOR_OFF .. u8" “расеры", cVARS.tracers, 0.15)
            imgui.ToggleButton(ti.ICON_BUG .. u8" Debug", cVARS.debug, 0.15)
            imgui.PushItemWidth(150)
            imgui.SetCursorPosX(10) -- Ќ” ЅЋя“№, Ќ” Ќј—–јЋ я ¬  ј—“ќћЌџ… „≈ Ѕќ —, ‘» —»“№ ƒЋя Ё“»’ —јћџ’
            imgui.SliderInt(" " .. ti.ICON_RULER_2 .. u8" –азмер радара", cVARS.radar_size, 100, 500) -- Ќасрано
            imgui.SetCursorPosX(10)
            imgui.SliderInt(" " .. ti.ICON_RULER_2 .. u8" «ум радара", cVARS.radar_zoom, 5, 100) -- Ќасрано
            imgui.SetCursorPos(iv2(290, 70))
            if imgui.Button(ti.ICON_DEVICE_FLOPPY .. u8" Save", iv2(90, 25)) then save_cfg() end
            imgui.SetCursorPos(iv2(290, 100))
            if imgui.Button(ti.ICON_DOWNLOAD .. u8" Load", iv2(90, 25)) then load_cfg() end

            imgui.SetCursorPos(iv2(365, 240))
            imgui.PushStyleColor(imgui.Col.Button, iv4(1.0, 0.27, 0.27, 1.00))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, iv4(0.90, 0.22, 0.22, 1.00))
            imgui.PushStyleColor(imgui.Col.ButtonActive, iv4(0.80, 0.15, 0.15, 1.00))
            if imgui.Button(ti.ICON_X, iv2(27, 25)) then cVARS.menu[0] = false end
            imgui.PopStyleColor(3)
        imgui.PopFont()
        imgui.End() 
    end
)

function cMsg(text) -- чтобы делать 5 строк при загрузке
    sampAddChatMessage("[{7208fc}Leso{6207d9}–уб{FFFFFF}] " .. text, -1)
end


imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil

    local my_font_compressed_data_base85 = "7])#######d?fma'/###[),##2(V$#Q6>##u@;*>vo>Z)7KMiK6f>11fY;996He8#CD2MK]sEn/(RdL<#)'McY5S>-FqEn/NFxF>milS;Z4S>-+B^01kZn42Vm:H%x.>>#fWN$5aNV=B%U$8ncPUV$77YY#_`(*H>*>>#M>:@-ud5&5#-0%JIv<7eN)35&<7h(E?/d<BoL3NPcq.>-r@pV-TT$=(k8nO$],>>#gqEn/<_[FHZiaWs9euH2T@uu#G4JuBN4*SU8mQS%F3kn/`K[^I*Tj)#vfG<-T)NU/+>00F<eeZgF&O>HJx?U2<%S+HL0a5Nnsp4J2H:;$>>N+2]slx4k)-UAeI1=#G<5)MRZ<igKQP?MSF(VGS8'DE6S7&4n.[w'OMYY#0]Wh#Ys%_#[/;,#NR)8ve_nI-TbW3M<DT;-,b@U.jE,+#8eIU.%####1F;=-s.g,MN_vY#W#juLke)Z#DY2uLf.BrM0oU%kP:c@t`^W1#rP'##bkLEN%hO`<xfo+#KFBv-bWn*.FkUxL;xSfLLLZY#keJ(MoPG&#*s/kL%8gV-M@2I$tIbA#,xkA#S@@I->LE/1`>uu#'5YY#7;uu#ss:T..%###^Z`=-L#iP/LKMigEk^oes2>PpceL]lWc8GjYjUJDHpI&GMiefLMpFD<j,ZS@@Q^_&..(B#L2KWN&rJfL[f1p.f@C>#u,2_A-p=xt_dS-H)LF_&I*2^#@N#<-$sG<-.p8gLZghlL^3IA4Ud62BnIhumGRt-$'Af-HfK'9AHR@/1Dg_k4M2V7n:]$YlUnL+iUcpI_C)5;nt/QD-498ZM'</#M[;X'M'4DhLIxRiLHcCH-*hLtL8a]rQ-]F&#J.#'#te'f#?mm*Mr^GVd?I(^#W-u-$5P*rLnaSwuo*T,M-Tpwuahk*v*>-$vF=W%v6,h#v8]gwMh(Vp.=wV:v:BCwK+#q-$TDa-6lrFkO1PLJ:jefS8f=OkknEo^f<Rd--%206vEp57vCxj5vcgG<-#>/SRp?$'vCd+;.<^Np#=ec/$AF0Gn]xQjLhr>8%IQ*REnhm7RBw_G%oQN;)nJT:v.YjfLihr7[mp@)=(S_`b*nxP/```%XMN*##5iGd<M^ouGRPpe<94CGDE:*#>1E&2^,'b`<T<Kkb]<bSA9CY&#)?jp'5G;:%P8a-62>Q+`Xr5f_W^j9;ukL+i^Ab8&v2QD-sTG-M>Fw/vi5?;#r$a..dx6qLTZ]#M0g>oLd6>xuilF?-F(m<-x4T;->=DiLQlD;?P4_S.Y%tV.?:t-$D5?F%rh+;dP%$F@T1Xk4%n>_/W3vW.H^H;6md8/1UL#l+m)Ow9'uT^#/YFm#_dEB--=K$.FPoVM8G5gLBrJfL?.*$#M%###%2/vLf?jZ#<OI@#jbO_.3.>>#5AT;-4$T,MemsmL+SMpL@Y%iLu4$##1lA,Me2#&#)(MT.sQ>+#-.MT.DDc>#ekw6/$:F&#k?hhLt3L7'CPDcV/Jc._dr*Pf.'S%kNI=ipoSf=uGjKSIvKI`j,qWD<jb_VQMp9v-gaDj(0on34RC/2'LFQk4oLwCah4b1g3HOxkRbtIq0.tk4--k>#7H9&=@CP/)ar)<-tPf9vxo64v6(>uu$-S1vvv@1vpd%1vlWi0vCl9BuabpS1fL(##)B&##nA)i]#`p?^CCt-$L8:I$VRc8/:qTq)RAl-$]`l-$3=0jCmj]b%5Rae$[.LcDSuh'&<I#AXxUX&#RYPe$Dnu=YB64F%1rsOogd+poWkX.qG&/C&h/hiqI?Se$@nhFro]+##g;Ig<8nw6/&)###`*v=P[aEL#.xHs$Ew/6&UjlN'f]Rh(vO9+*0CvC+@6]],P)Cv-ar)9/qefQ0+XLk1;K3.3K>pF4[1V`5l$=#7&n#<86a`T9FSFn:VF-1<g9jI=w,Pc>1v6&@Ais>AQ[YWBgbR.GW2SvK>_anNOQP1P`D7JQp7tcR*+Q&T<*S?UsJUfCOPr+swUb&#u`U6M4=f6M*SpV-0@(`&UsuXK[OJdqJUFErXTk9WDunF3rNmlEP3$aIc5/?KOH_9MC&$7X2bjcWLudYP:K.m.jM7YY0vHS@E*^xbKU@/1JxR`Wlwh(jw_V5&k$^S@dDRfqeNvfC[x+/hu(Q;H)PQG`s_Rm&/rrSIqe<N'Qj6gLbX?)j&rPm8.%:aN2PJ/q2@Zm8FS%HVkkog(vg4NT4&.Tn6XMN9ZROaWT$)Hr*sma3^9=<H7I4BbUhnN0*n86SHU:HrJ'R68_w,$YN6<BtV2lH;aqTBXu3Ph(G(iBFMsiTenHSn/P@gBXZ##%#5<r6AudQ$YuG+bs%<ShCDUQ*s@@ZtZHvcb<B7Lhqdc++N-`i=$9aaOB8=Vbsj]&iLUB_+37J-o]*#Jc3E6v[cR&-J;.jrUnTLuCXVuW]>]#1]u#>3J`W&N2(p&vuHCK7j(X4KJVco%d<^5A>dsn'^>Bv-&lWeJ&Gb6K2_L?Xp8E^R,WO?69&,,OpJ:E1dj3N=QBa14^lCNnv?l;*Eb.bS?-(-$'GB_%9fw6Q??*xdpfHAwQ0ww93U$Co?-9vK?Z*=a',])$_Po*dWn&2Y3L2n4@-5k?kUfP44(v-SkCftj9].cuk(J<g'P/$j9o7D;:8h0^q]Jm:x-Q7/:]q=F.<0Zik_:I[.*0:3rAOW@4U?G).sSCa:8cU>xHSue+M,jwQKd`>8%6]###@d%H)+,Bf3L]B.*d.Ls-cNeF4PDes.f^T,5Tat]#d52s%_=gK1]EV`NLm)A+$xe7nNQrB8K)###hm#DW)1eU&:i###wlqB#cc``3Qh%i)HCD9.LJ4Q',u<2C*xK^#iY&nJp(;b7q3n0#5MwqL,IL*#=sgo.=66N'iQGw.W$<8.=lZq;$P1gMf]Zx6$^iA.'$CD3`&T,3-BAqD1(nW_+@Qv$hnGI61sUD30)JS@6f7^#X?':%b2kMC_>G$GxEl0(q'ZJ(P'Xp%/c@p,<IlA#X<kR/#&`'%VWA#G[D1PUFPF&)j'&k'X(g.&$^.tdb/W?YP-O9%(UGs-jN7#M*RH/&YNOp%F*MB#M0*##Qle+MGdhsLQv'*#kg*iMcd6lLft+G43`<9/ko&T/O(;9.x<7f3O7oA,@g=t_JTvv-=@[s$;xs9):i^F*U9Gj'8+P?g=#JaJQv(4'1D8A,`$r%,QxTN2$sB8.nM/iL'#38(E?ZpMVfv40T?;O1x+iT/khl3+$Qtx%YMI-)Pu.60jQHL2D=T60#LQ4(3`j0(5BR.M[Ofi1OA422ZBp]=8AP##tR0^#m,`g%fQ_c)nZai0]$%##sbLs-<)'J31E.H)*)TF4+87<.(Ot(3?RYn*qxpI*JAHg)8qLhLA+p+M.fWa4(m]npYrjT9>^Xacl=+j1l@4j1]K$X976oZI[X=X(%iNX.7M>YuRLhW-/L$C#5+iZ#J-iT9EfH03),Yj1Td.k2:Y3B-@f:T0H8h9%xFRN'1gcI8g_b&#r&eiL+tI(#e,>>#+Q0W-lI[?TE4vr-gc``3d^s/Mh:U%6uW2B%pBFA#4(XD##.(:)uT4x#-/7#Nrb623kiW%;8<=h:)xZP;]6t%,Fcv6LoJ,$Gjb6k2#>M0(AabVfj_6k2IhhE#T0l;-L.4LEb^Dp9nC,`4)t6LEcD.h()NV)3nuJ-)IYZ@b<Z@=7e8umL[pM...82mL9&RQ8<0%w%u/0s$O),##$.A5#Dud(#hD?9/Kp?d)=9..Mx?,gLh6<9//W8f3LhwLM$*>>%llBF+Mfe.2oKx8%n>1q%(0jLFaWgm&gUw8%c=4h8ZdERDH2XW/fKgq%6kGhm7<MG*fOu;-s4pr-Pf[+MmQ2AN=[,5M-Qo'.+x4gLRZfF-Zu0@/O29f3G`8ZRWo=sLE$Kfhh+qumeoDE-jn-E.Z1X#A1s7&ugwpo7O)cH3:E-)*B.i?#G+i5/*e75/.Mo+M7h'E#er%@'G)l3+e?lD##Dd8.lf/+*W5q58'ix]$:^Xv#t1wj'-^HE3j,q`3_Gik'h?<v#<V?X$?8D_=DnE9%V$'q%=cQX$MFRX$O=R<$<eYN'3wlB$UA*hLfS0k9OAa]+bxeL(LkI8%=c;Q&=&4&%LNKY$&VdL-%lL5/_1N`#M_?iLN@7^$Ig,BZ.9j'%2+j5/krvN'qf3jL'V5W-It/`&#;t3+fYi9;_dh7#]P`S%[P###G@3Q/7x<=.*W8f3*^B.*`<$R&s6)D+,kn=-O(:B+'/fh(4oJfLlTqLpIPLJ1WRS70Sg'u$ZVd8/lPi63k&B.*/DmT%i[em&]1US.Q/*&+K7p,Mw-,GMT.,GMfov##>`x<CTR(f)_M0E+T#S.MBv7RM<gQ:vkLGM9j@72'#5;x-o$258>?qB#d/1U%1DcY#-aEjLO:-uuCqN9%rU6I$UrllLCGZY#r+TV-[JMk4tiou,7xH)4mm9h$Bb:hLe&2s-,r:T.RJ))3pBtR/OINO@Ff'K++?_s-_XB^77V;^@B-*H#V4BtL]s1O@QEt*A')Sk7us2E#nea5MDat[tPSs+j?090)l^;P(?W]88Wu_3='4FW-cn'mTY3v7&j(npI)qm4(sri0(j1>#&OEpm&U8D?u1.$I6FJXGMGW?LMKCR#%Xl-F%-HW'8viWI)K.De$.#nA,1U@q.iUYV-O8`$'NiJ5'Qe&7CjbH03ifZ3)'I1hL_o7LE_VPh2BXO>'e5)4''VI=9&?Oe-8B4m'i8x21R$J03>ekKMHY[;#ap3$Mx]WmLkDPA#Lp--X?/B.*:'ihL@t_.Q;x/o8N`ptUwcAZ/1ts'/cG7h(gNPwTd%g-)#48r8'F]M3(M39%h*e)E*l9LEKMN]'p$O2Mgma0(fCRR9cP^/3@*m3'_r,++p6Nh3?hjp%+nm---Fc&>fwpxuW=^;-8-NM-&cmM&W:%T.oaVa4bWw*.>dO59,WD^4NE/M^@^[w%X3aZuOuvr%S<^F*3.9AXEd14'Cu:?#xIF2(`V(0(.D#A#VMtT%`8ZA';iwcV)]Z<-2bBH%m'mo7iBdAmpMGA#,39Z-?:^k$,++m^OOPk'svwKumR[r.mo;MKQv(4'5g>CMui[R;r`P??/g0E+Igpq%tu=O/fL5C?sg*58.r(T/T$Gp^?r0@/BKc8/5>PjL[H]s$,Y8a#?x>[KZstP9B.p,3wc``3tTw*.SjLnLSHRV%Gv:1;Jvh>$Q@d2Ca7,gLpxon9SB]R;ODW+GCWI/(Y7[R97EL%Q3d<JMV]1DNxl25MFi:p.$,>>#`(6I$df$>l8c###IwAv-%3<gLc1Ej9^O1E4^MCoI2O0T6.vR[#4HHH)d>***&^Qk'dD24'`PP>u*^M$#lNp$.$]m&M[N,&#8>N)#mp@.*[M:9.g18C#*OWW-fHRpKml@d)-i+%OL[jr?Ah(w8IIsm;oWpIEYM8LEuL0e9Ub]R9,H$9.-@H03@OpZ78<9X7Y+OS:&S=<BX08b>dG7#%=G_R;4G?kMLE@v$)(L^uhOTR9hc9R1idb2M#&;'#S(jI.dZ'u$##q;-Y#vp%H77]6gt9DNLgN1)iP&gL/_'%1j#-J;<124;@279%dNLV%>?.]E[Xpm=NM,($FwaT%>==9/k)Ig(?L0:9gVg=PeN03M^?#k2Cw9lMPVaG##LRg:Y`l8/a<c4:,Vu'&$4Es-Sp7iL5K0D9R';Dbt4)F7^dh7#m7Hm'dW-Elk.)697+=WoB9u99[XIAGl$TT%n/>>#3l1v#b:3/(Ia9B#ak4D#:N.)*Ja-)*:Su>#F;8Q(VcfI&UQ^m&$p)AXUd>7&+UH8'@gru5bf.5'T(tpu+1>$,]3n0#Q)###NeXfLlH42'd=Hq;UCwP/r&+Z6[B9u.>XqB#Yfjp%%C#_'vRsNNDS,m%ZTOp%b,E?Y/n(R<F^8xt-;g=u0;Lu%ZY?C#5_<?#k%AA4f`aI)O#<S7h*-B#Q:L5MF5E?#F)=D<^fUwTr&_B#;G)e.S=:G'PE;U3)L+m#bOc##1=t(3+dfF4Q?TR/U2Cp.A3ed3V@A,tZ<j?#Y*DM%g5uh:WeZp.+HHu.UGt8ACnd:7Q6ti0'@H<6cMk.)SlXv>M7PY>s6s<-+$Ee-wi31`FF1L1Daio0@P9s&Wg:,)dK*>JU.vaGYb.9(%,<K1q6.DjOH%29gsAv-Ja=L#75Dm/Rq@.*dZ'u$d*2.MA@;X-88hd4nALh$KBIIMAK=:.bl@d)#=oT%m@3AF'AC32:0GA#^PlU8+C>D@kA;ZuV^d(5C)0D5h-$k'4qF[Ic2fP1._x@#q]ZjNGEkt$Is*^?V3aK,>L&r8_EXsDe^7MLZr$-'KAni;@98S'I&IS#s$cL++2GC55vW_AQ7=t$l&LA7?,if1mx;+&(>PV-cSs8/#'pS80IGBZ[toe%EVYV-+87<.M:O-)Dl74'5vQ#8jOt8(]Cga4,#@V/Fl(v#?j6h(TS1u7saZDuPqn(WHB4rl:ut&HN1qt#oH.%#fWt&#5g02:e7nwB5V'f)eS(I;8o5Q8(,Bf31EQJ(q@2V8BGQ@tb;)4'+^FY7>3fo5vHYA-FD7D6^^$5+C3,>J=o3DWOH`*4[W*qu:nv(5T*vN>$Ps[kmaA<-i#B%)qg/<-a%Cl%#-#9.,r?Z@s]%$-*jZpS``CI$n`1W@:]L=MH7a0(L3ia41si7@gg29/4PsB4d'CW]`9W$#[U(d-q,os&Ift/Mc8V-Ml7+/M.V.)*'-$,sUb<B-?hU]2C^^q@T9H#8s9?V/*Qna4<))P-CED=/[*'u$P0;hL/#6<-NMKS1K7)4'-=rl/S$xs$c4mNM#(^fLwDj0(@P,uuY6Xt$8USCMX[=?/tWp%4wH7lL0]T4MD?mk0fl)4'-#&#/sri0(QZ`Qs&f8;[g,pq7@kG,*?:;p7$Ws6hg1kZ%s'tn/vH%1(FN9U@,&iE%p/i0(K7I'&1V/4'd;24'Okk,#nwD<-cP#E(C6Bg)#<^3MqL]L(OdnJ&$$d3'Ix$5)`Ai0(Lfe88+'=hG5N'%M%m6xkZlQEnY4;mLO$TfLXP$##Fx#;#eWp%4=XER<1mqB#*cj>.sri0(Nt5AuB31[-VBV0P<GZw0oTVKan>GA#Qj+W-1shweJq+[$N/>Z@M9'b4Awda42`gq%cg-XqskKh($jaa43(jV$Y?t9%JF)?uF,$aM&<Huu#>`5/;;.$$d_LP8Uj[$TH*YO:PAZ0)dg'B#<LqDjCebRMXw%$4.t*qefcD8&oKZruGB53'qMT[u>h$.18[:8.H+mYu'_wd%&$0<-B]@Q-hbNvN)5dp%:deB#?K%1(LKw4](i)M-2>rn;f%sc<C<mv-WKBD3B6:h$ap*P(XAqB#Nk9x^(k4A#Fq]r.)';=/uPWU.*N'[M6/%0):fp0&krK?unVtv/(34^(/U>Fu9#>g.X[?K#mDiF8GD0Z-m+?N)ipf@#9GZT.16mYu;c;a-IXw'&VQ^]=u5IAuXgwv7C7xJjkZP2.U'AW-F$$w7T3>V/O-Xp.pS=Z@I$f^6^IUp$r+vs-A0JS8GgpTT:+&Z$(rE4::O9j(b;@#%f?T;772/a3Iv%E'Yo(NMi'jXuOx&2B.vl$0r`oZ2=m.MgvW(&+Vh$##`uUv-rf9L&.Tkwnr6Sr8WZ'=Sx-h`$<^[tdW;dt$lO#61Y6Xt$2[a69CO:a4bZDhL`r2?>Y7qk.<epq%wcGl$w'2=(QOLKaKlcd$rC$##;;.$$6qAo%EON:8KdM<%LW1,)dg'B#k.BB#o7j>P&>H&N+dSA,Z>hI$d74cM+'0N(I:cZIojWV$'+Bq/7dN@t)Ip&$VUHuuq.>>#%$$;#A6r:)J=[/:J-KaY+Pj/%8a,F%W:W;RFadd2[%v)8F60TKFaXw,g.KQKo6cX(sT3H4$XN6/@n0NCvCS#8A3nU&D&ba4i@P$8W4n0#WgO+`d+?H.rjP]4o@Z29i_Ove)fb,WrI%1(5KQh(_G(t$cQ(0(,j-4'1Y15/Y3*]F+1Zm8ag[A,SX.n8@,,d3kVQX$b?hMUUbN0)VF'U@Y)Wa#TF/j-1ZnE['#x5'g*(oeh-$B#(iDwTpG(>ldeIk=@XI5/x0oG*9-X7%dN8s$9oe:%ZTNT%m[w`am-0f)Z<q4fYTx[#[UWE*$`x(NLiP>u.p>>#Z#+##vq3dtgna^-%)V/sU'N?#J(v]O2ECK*`%Bm$c<Xp%:SsD*O=4)WPE>(+:r%l#cCpF*[njh$lptX$Sf]>*#P>i9+'lc2q,7+*F26Q&94ol##(s?u$6n0#wdI+ir8nCs]re#-_tu,*VUx3Fa8t1)^Zr,2$f2T%f2:U%t6WN'[IRW$TLMp%f8_6&t<&0(ZCIW$5pPj'ZsK^us;k9%0q08@*ob]uRo&kLKXb@XAT.2_[Q(2hHNgG*-F6$$#mqB#]p*P(Do0C#fn#=-w;8T$d:bM(B0B)6dNFT%4<Rl8Cw39%7/Lc`FIVZu4.Uv'2,Guu^Cj20c`08.cc``3%N$xe<=S;%'.c)3Mh%@#YxcC'':-AOQ_`ZuC2'sL2gg309Q-&4Of$T.oN/@ul^n'&P.A5#qtd(#O$(,)kC@xe&Csi-#r]@'eWeNBru@I,RS:JD]trW'rbn.(qI4Q'kxp=uJPHb%MW>Y&@>_;.Y@lo7kF$C#w#?A4TPGYu5RET%1X6C#9Xap%ScZm&mnX>%qt,YSQ?I*.,N<%?8qG,*&k2gL5HII-'VI*.O5.'NoDv:$*5PwKQGY>#taN1#L)MP-mK>w.k%AA4wdCwK5,<Q/+K;<%NtgD3H3&#Gtfp#Gag^D3xjHs&>4IW$S0J]&SuhS%'/`Q&b'Q'#ih/*#r(V$#$U.M3OnUP8qI%rmK-kT%Tg^m&3QR:&GfsDtwob._],MfL22ut$aaf;-bK0b%PbEs$0J#n&SWp6&;NVfU$l<a&QK53'pvYY#GEW:v9ZLA4dnho.8Gr_=v`6#6k]M&='4r4)8mSc$A6gIE_[T#8Y*:HW]cgQ]7%54'a.Gc41elo@q7;Z@aC8V8qtd_uvr@@#ZA0*+Y-m9#%&>uu5BCn#8*kW8'@$a$`rUs-8Fo79VS$9.O^c3']8^v@b89(sx%9.0A,IdjRGW1%,<a^OT%Z48u?HV/8>J&#rCbA#(@PS]ZMoP0i:H,3N0OW-F=Tet:6wA%GXR,;sawQKd:pP'YFCW-3:_x5l55`1MSlq&[Y2W%_L_<-3@6$g=;CZ@>ME<%Rs3c4vVl&5pm,3'MpAwPv:*;&NmIElSVCI;[l`L)1vQJ(fT2^@bL04'ST(0(.kcp00>b;0,`gq%v&j5(Twk'A2Q,tN*,f(#Rl$bO$.uo$kv849_8jedT$+kk&H8f3vh#h/7%54''tBV/1hG3ke&kc4tOKK/LVW?'DNSdNl;[E.@vba4Fh&6/5x#;#4Yu.:cA]'J_:tV?wEtM(&O4U%s:S#8re_g(VXca4'ADO'&LF2(]d<Z@Oal3'OFDNCcG7h(^jl0(Nk>-05@Cn#tke%#:(5*:<9cD4^n[6%&%x[-]B&(%CEK&ZxdvO(?oBEWLK?18tv;E#3&[#8SVhW/A/[)kCF.h(hf#u@.tAZ@@A`/8]Bjn4+8pa4c4(##LFS/1ksp:#frgo.e*gm00$ArNs.E.3iuOo$OMRj4[Z*b[X#8gLfTs?#a5o_uH_d68`XX]u?ca9`6a387aoUP&1hr+;KbR_8lm7f3Wjhh$>4vr-ldYh#uJI-)Ilmo']Yi0(sXH[#g0Jh(P_`$#%2Puu8(2,#`RGw.]Qk&#o0p&$sWtO:F5?v$s_M/)<M-<-EnN30Tv-4']<mu%wA4-v2E%bWp-1hLt,@v$v&tV$7G]=%^3C4fqXfY>+fb,MF$g(%S2YY#osp:#HPUV$CI;8.80g0N+q8V-.*.#%$g&+*-t-AOp3UkHMk'H2XB.0(^IIW$`L:T%+?i/qdlG9%d,nVqF+mYu(rmo%%%u];mcn92,XTD31EFM0CUH=J^he'M%XOjL;ICp7Xv?@'=[8Q/l/^I*(pcoR^'MgLb**j$thWP&u6q-<PF]#8e)m0(cNma4io;(&3L-iLrTS1(&RfI4vqJfLTl,J_TsgG*#bK*<vpBwKIJ4gLFDfRMreaNMExVf:W?bM__7*;?(wFoLvu_#$TNb<-1UP)%o80TK5w>V/80Gc4;T?)uBC0I$x?pw47YFR*Lbe8.%&>uuR+@p.S'+&#mPA_m5g](%XnR29lD_B#*cV#AbO94'<P;:%R4/AbkW(CAGmM-)dPvD-4[?YPo1Ds-W&l[&,)]L(1xD9.283h(m8Bm8Ah'#Z>?ab$aPqs$rSB[#qR2a-pa'dt[Exo%s@AD*f]/E>*8I.%RkvDc35FW@&dm5&bvQX/4,Yv,CLr?#fjrU%lwV)%Y+@p.`2+##<MTw9wb$##qIMW-_2Qd5Au;9/BI?)Nc/s<%`&PA#S$]I*L@[s$ZVd8/W:d#u10Y]#.sgr.<CMO11L>L2Lv_p%5uFG0xw*_553WN2^=g020-`*MF6n3'DG250US@i1Vr0N2>uB)Nh)nL2.M4O1A:39.)cV4#=EBN9uQRm0`@0+*d1:HM1pYA';iwcV0/::'MPwS@e5C7%GlsPAX6Xt$On8c/MaGb%<uwKs0#5$M`Ro?(Nn[D4/iA01hf`#&YJI-)(Q5$0HFp?.'gZ#8`nbEOQv(4']Bda4RD%5JCuF^u7jk,#$,GuuB=^;-W$^5;u<*wZZ2I4$b1B+*bAF>Mjm&w#lwaI)GE#3']aBB#(NtT%Vk^hLgLu9#]OFgL/?+jL2flA+b=X)3HD<1%n,C:%OOV)*m=7)adX=gLZG/-W66gb*m2M7W`;$;%OBFAu<6J@#7Z<Q)Ots9%+>4S7NXTI)9Q^%b-Ua9`mZ*RE^n@K*>ACv-a1[s$hDQ/;spE#-u_x('Q0Yq%...0([Xns$a7Up%?btx'fuf?jI:2?#0%eS%:oG<-q.TV-w2.[B/@v7vvDH&MpkA%#gQKl:n@mQqPId)O2dMZ.cH+5&a?bp%r@1&4dbrs-hOugLWWmuu>v5D->#tnLVbZY#Ii08.&ufg2?mkT`Qah1;nF6.4<f2u$ex],3d:l.:LU[S%TM?xbQqns$`j1h(jM,N#9UYH2QV$gu<_jQ/+pl.UY6Xt$2+D9.FrxICV,N*IX),##%7]P#0sd(#g$(,)YsHd)sS%_Qc%Tn$%BOZ6PX<9/JS5W-s'7s0Zju[$/lAd)drc31%/AM1K<%b4&qTr.G-ia46FvQ'L`HS/u#Ot7n40p7fRNS/[MC*<]rv?-PU&m&[+iV$w-np4)P`X-rG3:MD3.87]k32'+'fO9>CN;7T>BX%ZN4T%'jIw#:hjp%it.CP,+ih$,726:#4_F*(M)I.=@[s$0d/dMlb6lLgu=c4[(=MKcb[a45=3q.?76F[>WrA#]Nsi-gbl-ZVlI21JYIPg^b8_]aD:;$YVm$$PXt&#&dTv-CV>c43Y7%-J^D.3[GO,MhHUv-GH5<.[dCE3w6x8%lHr%,6IM%,[5`0(@17W$E)(n';[mc*o,qQ&M;g]$<X3t$r#?R&Hhjp%EbE9%rv>R&FR39%cN@*Hhbx<?[gB#$*j,*4ao^I*`bP/C41T;.6(1E37YSd3Ji7CuXv(?#x6;ZuMu($#lGa^#%V0^#2<@*H>]d8/vmO9`1DXI)Gb8`&NR$(+&`5C++o@TLkA>]#@6x-)B+bt(&PF&#m8*B#i>dgBINF&#:vkG3ER,@.2m@d)hk,E3jsjT9D=H?ImCI[-Kx7C#[v-t9VF72LL:k>-?Slw9nBbA#o(x%#s)xpAt=L/)KRxQ/7I9^'KC0^'B4g;.h2XSUr1%5Jo]WVRMnp*%6'+m%ZN4T%nZ+T.`l53#S:J3%Vq'E#*b0T%]7%s$da@hCSKK6&0v^pR3B7X)/nX6&/pBTR*),##SG6(#qQ;e.VH?D*SRl_$GG>c4TMrB#TekD#fFuw5Qrun%g(^iB?NiZ>RKPJ(m.4e),&uV-RF@qffMM0(boNe)2%l?%l4fM19xxV?A$qj(0k'u$SxP:A7V2<%l[KF*13Dx.wc``3q=9#]Ex;9/l#l7%/sTm?Ei1^#`OfO.).'N0Cppl&v/^f1r6[c;JeT/)6um>-`JO=&.'_e?5<1^#B*Gs%7F4q?E3G&#7(n;-/DOJ-&#sb&FN-5gU0J<-j=t(8(N4Au7xToNg0P1#[?O&#%NOV-@S]-Fe]jm$BM4I)JtC.3#VYV-OM>c4PkWX-wqAv8u(e3'Ix$5)/]da/=##p4mJ^@)f&'EN<krr?e<tiC9/uaNFts,#0>N)#f[a`/_PiMi#'j#9qblA#dJ2n)lD:Y-$Hd)GeIH##'1qB#].S-#EXI%#diPlLH<H:*^0b>-lkNc'.doJZoLFgjG)ACs9[IRWuorQW2C&/151'SWDDRv$^^D.3%46XVHr^a44t`a4b#U$-9_@x,b83I.)oEV/6f'<RY5Y>-%_,#U%B_l8Sr9B#/$$;#qlP<-9WvX(lTX1DakSm_*A*f%JLgv>X'4B,];(B#WOw2(];AalWV,p8ev<#-9@Ns-aB2W@krw21EDc>-ZSMU%7-0<-_PSn$?S9dtZ^Gx'gV_%eL&F?)AO*W-kBt,ODm;+riL.&exY,;HAwDn8J&i52[=6##klc8.@n:$#PlajMH=AGV/,'%'sg*6O<NupRiS?M9MoUPgu<IQLQUw[-sc``3ICuM(r6KZ$NC^;.r;am$r0EQL'*[V@hD['5S)24'q'3;HQ_`Zuk&qK-7iCU)$KI-)UKos$1Gp;-8Q3b$Zx:<'J)Ys'Hk.Q8t:>^ZaC&l-D_3X-Z<n)5KI_P8hp`#7lnZY#e@(##6$x+`H)w%+A8(`dY+]S@jJjV7aBJ<-l=`5%lt`W-uQtlr$rJfLj>a*M-<UsNvVSc&TbF$@v(N0(cJ%1(P>9]t7)C<-CQQD-[C2&.3PvtLp_P&#RQvw5:APD%mDps76(Hq;w22k'h5F&dY?-1%Ot[E5UIZuui6J'.?oMuLo$T%#)kP]4BJC<-Ik45*D^x2)(9:99IGmv&.pq`3DK*hLtG9@%u5ko.L>kjV<R+<+KT>?-NMr*)%1Vr@rQH&mbSv6#Kww%#uQ6Q'3D5jB1Oj?oqJ;B'6(]E,iS7U&dr+q@7I^'-.aS%9I2RmO+VQ<-h#kC8BhrS&GO'3)/vF1#Q3=&#Kc:J:0uxc3%d>W-hQ^f+Rx%W?TZLk)9D7'TA5rDc$NoI-[&He'q3n0##5B6$PXt&#5oE<8@]L/)-fV<-[da((r$4?-7]wJ8tB9Zh>q$@%$v1'#isb<'jk;68`5-'?UThLRr+Fo(2_d'#v]8xto_h._;d`]+EYMH*O7%s$QUwG;])VT/k%AA4R`>lLsuU:%26Hc&ZT'q%3`,q%#0g*%*0g*%M*N4Y:X%u-%'<fMMT.JM?*/YMh*eN9X^K/`YnDM02S678Z$okrxO]L(;K3X&@;ADAE;3EGf#eI)4D^jD:Hw^8x`k2(cN7LCtc*Htdn06Ad#AKsn8,&#W*s^%Ua+Q8tQP8/+NB9r?S)3r9D7'T;TQm2@sJw92FLWJd[_p$Lr<^Qba@G*H7`q7x0_dkGTh[1Gb9oec[*SnHg?D*;aR#St:Vm9AlkA#qa(x(ppR@<w_0^[jm`>9iZO&#p-;p$Vd%-#Wj9'#W0or'f[/?-#P:]&5&t)$RvAZ&B:ww@o8P&#<4`>:NXCIR;EV^$0C(XS_kcp%NYDkWhmC`jhg=G2.hN)dkkpiBM076Mt&.Z?j[g/)j>0gMj4AZ9o`%T&C0ON&Ns(M'3n'W]Y:O9@dDP)kA.Gc44ZkK*cq5fCjJ$5JQ_+K1vNt,+-Vkc)sF0*+OCMd4/c(Dj44co7=$eK3hqTk$a&S5AsPnY6SJ)?-b(84**8-8(,>nLKo[@>-d,Uh$16Ts-,GnV8WSd0dq<xmqJwBHSbOE3(Ui6vT$stC0ChNP&jsXc2>e>lX<eWs-'(D58?7W`bE0X<-c>eL-%Y)Y&>(L+*?-QTWS&###^f4P]NK[i9%ro,3Ss]q$a&ur7iq+-5<reC#?K*u$o(jX87[c,MJ=UL*17xT%1.BH<R>op&E_?q7'Zv&@W7$##e-N9`Ya4J_;Vml&po%^=Oua)>3kHA%#rEY-2;)?[26)$B[Xp2`a+c'BGcXlXDg<q@mN;W^oX8,9Ct/g22+1k$beu@>:Z=AuMcW#AqQSZ*%qm^#jH.%#5iWs8lSia4Bhp:/#3m;%Sp,W-^m:CZ8heq.[5MG)%Vu42)C<v:>2Sf3)Wr?-F[WT%`n/m&i#p^/nfc;'S80TKn(Tp/d/i+9kn.U/%<$3'Eq(&5t'54'DR#&uYp`gO>FL585#>3)0=4)##?U='fj8q7UI_VI,:*78qpC</`J'a+W####R9<-vgnf&$7g1$#c.HP/2$<JuZxB-'8<LE6dCv98+:E?8AMEk>66%O=H/5##vm,D-i',M<)DSW9MbW$'&S[k=Gr(?@R8Rr9iIRk=X)&vLNk#m#jH.%#F>uu#X'==-PGS3%?4vr-SmsZ)Krq0GkS)O0fr@[#Z_`$#;//vLF_k,885T;.c'7=]mw.f$2^Q88;@e<-:[@$8i3KGNHDV,;bN'N_&^oo.ljS-+$`^iB0T7*-XNMu9u`lA#/D@e%f[EpL.jmi9GF%^P92pmBoulG*Odna$Rr:m8iru'Z]c^-'F2?n8NfpvJRVB-'(9DKOc?Pw$pXZj;PINv'A22Hb8KEC8iL4Au?_*(8^2h^#jH.%#ko6r8>pYD4<rHm8f/+vK%rp9*'+Yv86ftU($ut%(,.oDSRu:W-IXMLWnS$7,^=3?-h/Go(V]$>-t^Ml-E[It''l4_$#C-2Uv;wJ*NGcQ8pV^VIvk^&#CXwZTUpVfLK>62'[=PV-XT^`3Z2Cv-3mDF375^+45a1,d,<^'&>cM*I5=H;[_H-pM/FwM0`m4T%k)(U%8$Dr@&?1Al@l-[BW1r8.;Vml&b9JPBxLYjDJeY@(T2l<-PMBW*<]^jDXRa6&>]^jD9da_8b;c8N3)'586qfcj9TYjD6MO;&bk/J+b>rX%mEU.2Pdl3'i.KQKL]34'IY<T@#qg6Sqhx_%evcA=O9`s/.rBx(8bn68eb6^TT2Puu$3MG#mf%-#RKb&#)X_E'hsK=-l^*_&7+0tB]DXg&#A3*Ct6C#$MNH'6l-4O:]I#WMaNuT9]8<JS_sN0(cJo4R(6$##?0Hl$0*'2#^Kb&#-P@V+`*ub<e<@>Q'soqgf5,*?dUUB#'H(v>sCC`j#Fp98>rX&#TKNh#Xq[+`t^8W-)K#r`rZ8<-7Y(E'-l>UTU7$##6DK-QNRjf1)P'hFtSA@+um;t?kUv'#v6YY#)#$;#0jd(#_rBfb.U%I'w_>2t3+ce),39Z-m&B.*:D>H$/DEO'5vQ#8/aYYux`.='/5B$,0gd<(/gf2)KHmSIV2-sKE2w=lG5c;-lQ%V-D?R://`($#RlIfLR6gq$NIcI):`TqDAM>c4@N*.3LC<A&jmgs-Ja:^JMxe5'Z6n0#Q,no@*x);n$PpD3fH=GJ=o3DWBrY>#cD.h(klqFVi*2mJ&l4B#MHDigf-sM(7d,g)[Dau'W_w[-<n8')wU/>(r5)4':T7^#ITAj-j^a;KPF$##FG*5v/g?iLY>M'#wrgo.SjQW%=fXI)f2qM:[^A<7jr/+4rkCI3_(<v6k+J^$xuXV-?7&M'1?v`-2md'Axh6X7Z$E?#<3*a*Y74h(8Q:87&n9*<Ln#12IJK:'$ViA#_<oA#Iu%h(k`2iK$',fUa;MfL1^CL.L?)Mg(i@CRLimI+YnlX.2>uu#`8x#/(NOV-6ZV/YBcd8/Y^Tv-w^uVHS;Q0)1vQJ(+gB.*,:<p`fSH$$)3Uq%O>'v-/hRX-6$81&e^kp%kv[5%f:XM((TA[,&MXi(8s*qe4D]>gx_n5JG;sl(/dtf*btoK(?G=I#<nu3'o[v@#)j*.)9hjGm+h&'&YIO7Wq3n0#x+'q#vsn%#I8nSJ0]bA#*K$K:GE$C#m(j0(cJI-)-x&-)q'b8.RI=H)EVm8.Fe:S(wvh/15Bo$#%)>>#N.96$pn,D-bv?D-.+cR':H*XCjn7@#a6j'O[jir?_e:wIWqlc-:Bl`@Q=-##Bg732ocl&#C7B0/dKVvgp(8h(n4=@-m>&n.9$$;#f41Q8#5T;.<.Jm/vw?=7v-R=75&pc$?<TF(KA&'f_D?V%*l568mZD?54,:`<-3frQ[dYk'@OkQ-_9fA#Jx.h(d3n0#Epi&#Gn)uJ^IPjtK[LW/tb9b*-jApJv1mA#<a@N%%*:dOYA9s7sl:e35IL,3sTNE(SeuUZ6^^j((osA'KS:a%4[n;-xIl8KA]A:V6(tkD0Re902U)##3Q'>ltr,F%.hBd2T?A#G(Y&g2)sKs6Ao8C4Rq@.*7HZ+0or<K(T.iv#I<)T%d/CU%3*V%Mp78X%NGeouST4mNH+)?#9dvg%a-1oeE-Uv'5G:;$-A###acY8%p##,2DLKV6aJ#-3t(4I)d6c^AB$lD#ikkj1IUFb3[uJL(#,GgL4gZx6`<E:.b@Fj0&$nO(VT<Z@lN)e3>WZ20wocB,/tF/sL>L9;p'Yu%Xq`EO<9M0(]Li>7g4a#84a498UAO9'Fjl>>lK1</pOUv@0afY#7*Zr/*Xha4b+3`#2Sp--Di.P##X&*#SYU(.$7`j9B%/t%QPW]+rgai0=BcW-rmVNt,IL,3aWPJ(rPB%67?;)NP,#1:[AqB#tNDZu[uR[#N8(:8Jp0^ukZWw,K>J;M+rL5/vi*.)iQjMMZDx4]$RirQxG^e$A/E/2so$(#dA$i$4kf;->,sE-6?kV$%`nR9R^#<.U0m:&%N(T.I52k';:rp.e'Ld#`S?tLPRha4O91h(qw%T.pMQ#8wAm`-iBMQE_/QJ(mxlP9a#^G3DJ)UD.+L^#]O?1g?r2ZdY,?v$1]x?Br]wSu/r@[#J3ZT13*jrQC_39%ku%,MwQ#F@`p?o#ierA.qrgo.g8)jT)j]L(KQ#]#QKF2(-emuC4v.h([Uk0(#x?=0^dp7)%5YY#^x5I$/e<kF4+.5/%Pg?[QSK(%iJ))3&V9+*>HjL)DM%[[ku0t:Ba&wQK-kT%HH2?#rMcBZ=ui$'VZ^m&gu[fLMe;v#SsGw[O:$##Ur[fLUrOrL%f8%#L`L*Obkrm$3Jke)_rBCOk8W$>i1RLauKnl//L*8ox;:d*V,lS2e&59%Zkjp%XD7h(APsGZ41*U-e?7E.Jn7`<CqC^##hb,ME_;;$x9+_JE9%RNh=NP&nN*20iYv*3?X1N(QXkD#:cko7PLi'SHFS30hnRs$mSIh(O@ULP975B$6Fw=lmuo:-=SmmSef_E'R;7A45x^=)Ct=d;H<YD46<hm/7%x[-LVd8/:rXGkov>V/*xw4(EvQ#8aT2^@p$:4'j.k@O7t;r7]TND#a0Gc4%Bi0(.cV#AT9H#8dKh?'/Nps$+4c3`Ur8d#%<F&#pp[j%B4vr-Ut;8.7r5dM.FA+4n8ct-g]&=<u0N;7w.r;-s-iI&QLO`#uN_%/uv6muWWEe+s8.lftaXGuu-Z)/0iba4eNrQN2A'gLFO,&#(F9D3a8t1)I^/gL;cSUJ6$;9/:E_#$fle`*AH*?5OF@<$tjLC,6v;E#iG%1(bF%L_#jI@#U&Eh>:C'.(>_8Q&emmH3Yq#6)88Y7(Fl(v#%rQ[#TgCKMqLsYKoF;9&=iD]b:,^v^n%`oI71Hv$EVj]$M@?m8'J(E4?p;%$;k+T.b@.@#xBR-&`E^0K_r0^#5]<e&rS1u7jI]g4+8pa4h]MfLGC?##tGYE4Ui8>,JC$##R@'fFq[K%%AV'f)O4OF3;X^:/ns7f3NLp+MsLND#CbNW@,k?h(]7IY4*(kFV'%#G4#;AV/=Iga4g(_O9Y@Vv@=j3`s1pu40?+$pWrba^uAM`a4+aO*Idk<m/?mLA4<o###[di.0_SQ$$$_Aj0*,6X$8_t`#Oh)>PCr:v#QUg#&Yv>3'Bi1LJ]XZP/RnR[#A?Tu$KK>R&-P>s%mT=@/%&>uuas3$MFWb;IV8###xnj]4e<%##I^7<CncM]$l4NT/&lA:/R7#WI[scH3xKeF4St@.*B_gsLvh/a#c:qQ&p2eY#U#6v$+5G>##CLI&edkp%][4k$iLk2(hQL:&Fw82'qi@G&iptp%^KZ2%kFn/p3x-W$Uu2:/_:aGqww=gLeZoS%em3?kBqNp%vrT%k9<**3,V1vu7NUn#O=#+#t*(f)0*NbNTi;E4S$]I*udJe$@P,G42$ZvK]%>o$D7[x6[O:U'U+M&MwLF02@EWL)OKOA#6eM>#kQJG5h0)'4Mv2PK,@n>#&^P14F#I-)_08s$@^xU7@m@v71pn:/,KDJ%?F[s$'/s</&B6N';fei1[R3T%6)*L5%E.h(-1BO10Q=r7$%a<@9)uX&j3%##.+35&&U8a4*``$'^5GW-T#MnWiei8.a'/@#3WEC#SGPj'v(U@k==@s$2o'HM$+;8.=:.W$.7L^#2F`o$NOlB#wgbu%3(@W$*f@['>A0P8+qO['G5YY#;I=>ZiWaG3,GpS/j8dp.gc``3VUqZLR;MQ&iV9%kK-kT%BP6pJpLO[Re5[UMV^oo#$:F&#G0+KNaVSa$SZQ#B4sb[&s?kj-rDd=-?Zap$o6Op%h(q)5'%g+M4`YgLLH^l#wV)K;mD^;.suQ.%>2K+4&eaC5SZbA=axdC#bKF2(=1CC#]5$;%t0rs-'r%'=Uom_#B:fI(rBdru+2(j'9PcY#nHK4&E>5REWYvU7BHZ8&jx,abxhX]+Bm(Z6c_1p$rUFb3YZTC,ShH1Mfq<]bK#W]uG_sfL-Msu5(.h^#B/)H(m-TjAB/,F%glXa*c>W`-W]s-Z0sZeOV=w[-P%<..SZ2eM%s+Sna;HqVkBB`&<Slo;*WCFIIfhs-,PYi9t_A6(?u;Y$PIw[-,cQ%)4w89%FYR,VSn%@#KmZP/Q[rZuTkjp%&AM))P_`$#j4[,<nvV]+O_(Jh*^88.mN#]>3m^99jrM#RN[fDZpMGA#IOFb3.1P<%k;n)4TMrB#eGId)k_+D#TV2^@?Ixs$s:1<-]R9^7s+Yv,^J@E-/8l(53@br/4K(p/EZ+Y@T;CZ@:94R-*;001joRV6+8.j4POha4,d1p.93Av#>rC9r^2?X0Dld@ba&d]470Sc;A:Hg)vv`0CGRcH3p.mY#b0aZuh<Ke$XxclL@CJr%+Zi0($R+Sn5QT/)<Mfo7%FlD4<r7W]>;Uv-2^7&.YF_^%iq<]bX]b*kl/uu-O^c3's.[)kX6Xt$?+sY$Wa*g)?6D/%>4JKU5-uL'7IrJ:ca0^#BXVU%,:as-YOMIN-$;T.HaJ?u8M&N-1>)6Mtp#D-8-<#MZj;;$Dld@bKS1R<qj?D*od&/1j,KZ-ipC=%:I-AOjkaG<53Z<.)^B.*:#wu5NPo9D;82YNqilrHWv^p.6G$:7m:3IHUvM*I9ZbA<]S,=785YY#(=V:vlAHA4^Ilr-OaAv&1nsj&iX`V$Tl<H29T2^@,nQ-)+G,n&S),@#W.h%%NF^#8Bp#6)lTn-'VZ^m&+p0t*<(a95SxefL+Lmu#d#jE-gsUX%KIs;-+Xb,%B_N/):7*9.u3YD#$>X8/J$AQ'e8M0(Jg%Q^Y,?v$+A^;-Gq_).n)wENt38S[qb`p%LjQD*vIF&#v%cq9JI^n*]SdsQYhx7RZm/F-d:'w%&o$##1@6&%%A0T/Uv-U99XkD#Z&Gr$7oiM:F5JT&dMO$6C0oQ'QZk',T5o_u&p57&Vb8P:$$1B#ZLHS/A*DH2b'>V/X<M0(hI#[/EaHr%q)<Q.J:f]4QF[/:FIR@%/9j'%-Hc,*DWN=&jxnA.8U.+8t+@p.<,Yv,g)BI$%YS#88UcjL?+Xf-pRcd=?YR#8hru--5O-.MI8MjA'0xFDa.Gc4G>^;-]r:]0+2YY#uqd(#d+/-<QatWS5e'E#h[]V%h:j=.uiWI)wl4P]6q84(xadHJcMZr%t$$H-(G'F*&>t(k,:+<-k2ps$qb`p%e51Ip4nK5olb5C+bOlo7mrUq4R4f(#pH^Gaf^'Q/oqd(#'sgo.La0aE4a=x>7kQnrbuGf_Q++11u.q^/;8F6'E`YYu9ND>&CB3E>sn`:8V6C^#;Tm%+_7FNDPdkB#.D###%HW;-so,F%&h'u$I4ww-rpL#?'EG3`:DcI'05G>#x6xoq.DM;(fKG/(;rew#)EOR%2ha$#f3UhL(2ej#7fHiLnJGA#?1[s$RxR7(A;,f*I'Pm/w#ui'28>Yukt2u$)Wis%YQXp%/4^F#RkE.+n[`q8K&pE@j3.lBxWQPpoG/lBS#7_#YrlYuHE,n&@?H%+UNYq.wdt1K_VAwgcRNE,&DgF4>gQv$Y12w&?b;39X#Nm1^v'&=^0/3M`L[t1'qa)+IAW+M2OJs8^YkL:1Ol)4u?lD#*fwA-wrwA-_U<^-@ZUwKK_$QUVkvv&P3@*.AMre;KXCS*;0sbNmllq&0rg=CQoN7WKvFwPD4<YPuSSw>$m*B,bkh8.JHm;.(GeF<+i]m(^IwnS'cF<Un]-##MxW9#YD*1#ca5A4j?:K1Pd0f3R8qZ3*K/f3h5'F.l?I1C9:<_Auf[fLmJ12'N$'6/r&+Z6Nx,f*><B<-@aA32P=$##ca''#(DoHH9+^*#lA`T.+Mc##pB`T.-V(?#1@`T.VG?C#DA`T.71r?#?B`T.6%`?#lB`T.::7[#C@`T.l[Aa#)B`T.J<tx#IrG<-/fG<-OA`T.]GZ$$sK%q.HLn<$MdX3F)SFgL<-kuL0=`T.2xL$#hg`=-(fG<-xB`T.0d@H#9@`T.F6OA#uA`T.Ct*A#KtG<-8X`=-$C`T.U-*h#S@`T.f1W`#jB`T.h:s%$k@`T.3Q@)$1-#t6WQK>$+c/*#Xst.#e)1/#I<x-#U5C/#lj9'#2_jjL-o@(#/K6(#ZY5<-Ow^8/<O>+#7tarLVe=rL?QG&#QZhpLlwXrLSWG&#x/f-#t]W#.n)eQMt/^NM@fipL>+m<-5V3B-hfG<-MYL&OM:CSM8(8qL')8qL6:(sLc.<5CQX$##k^T%J$'4RDCKlmB$eZL2cS^PBJBYwnB(8fGXWmmDjF/p8iEv<B_b+m9xAkjEEU0@-^meF-xq($H9CM*H,,lVCvC^$.))trL^*B-#9Nkv/=NSiB+RZWB@T,<--NSF-Hr.>-PH<+0=`/A='DvlE/T,<-aq5=OG8)UP,'[lLKO/b-,X(G@MxXs8DHo(<XQDnaYEv6a%P1,N.X0,N68<MM.sK5PUkiMN'1Rx-QmXoLf#YrLua5.#.T3rLjd7(#[D5LMR`HY>->hoDRB*g273IL2Y4hM1HFme?vkr,+&B@5./5[qL0LG&#GA1).7mWrL1x.qLhY+rLj92/#FSrt-&$@qL5XVD5C.P@-,YD5B6J/>BgTV=B;kl`F]QKA,>2a5_i.(589BLq>h>$U8A[t#7*dxd-v(+GMQJtL^7uZb%&ji(txcc/C'8P>#)8>##*;G##.GY##2Sl##6`($#:l:$#>xL$#B.`$#F:r$#JF.%#NR@%#R_R%#Vke%#Zww%#_-4&#c9F&#gEX&#kQk&#o^''#sj9'#wvK'#%-_'#)9q'#-E-(#`QK'&w?V`39V7A4=onx4A1OY5EI0;6Ibgr6M$HS7Q<)58UT`l8Ym@M9^/x.:bGXf:f`9G;jxp(<n:Q`<rR2A=vkix=$.JY>(F+;?,_br?0wBS@49$5A8QZlA(a$DW5rj+MD0%>PO&d(WEH1VdDMSrZ>vViBS(f7eQfi:di++PfiuIoeX,WfCsOFlfOuo7[&+T.q$(_.hbS8GD$Sp(EM(1DER=L`EV[H]FZndxF_6auGcH&;Hggx7Il2u4Jn>:PJsSUlJ[wSiKx%n.L<U=loDF`+`/*S%kW2K;$0o$s$41[S%8I<5&<bsl&@$TM'D<5/(HTlf(LmLG)P/.)*TGe`*X`EA+]x&#,a:^Y,eR>;-ikur-m-VS.qE75/u^nl/#wNM0'90/1+Qgf1/jGG23,))37D``3;]@A4?uwx4C7XY5GO9;6Khpr6O*QS7SB258WZil8[sIM9`5+/:dMbf:hfBG;$Vg4]8Y,M^:SKl]aa-DN%#<ipmj?P;]N<H=x':oD>Heh2Z&#d3]8YD4^Au`4Wg/g2hIP)N$t2.3b5^G3oSkk41_E.NnUwA-;YwA-oe`=-`Y#<-hY#<-iY#<-jY#<-kY#<-lY#<-m`>W-irQF%WuQF%&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3&*F,3(9kG3rX:d-kuQF%'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3'3bG3)B0d3rX:d-luQF%(<'d3(<'d3(<'d3(<'d3(<'d3(<'d3(<'d3(<'d3(<'d3(<'d3(<'d3(<'d3(<'d3*KK)4rOuG-gG8F-_mDE-`v`a-1E+.-N?lk:=k9^#Z2c'&*tj-$4<k-$'LSDXS]%:).m6@'Mfv--x>sx+B1?>#Ner*>/`:;$31lxu.i&gLuwSfL(XPgLsNX?QX64V.h$2eGia$]-``6@'YZ2^#+7`T.,),##9K<$5&5>##^vK'#YGY##N)d3#jkF6#.W*9#aM#<-N6T;-t).m/^%*)#gMc###Y`=-O6T;-P6T;-Q6T;-R6T;-S6T;-T6T;-hH,[.<>N)#('HpLU['(i-D=G17S>:12%###=s)/,,u)1^t=R4#"
    -- Ќј—–јЋ ¬ ќ„ ќ, Ќ” ƒј
    fonts = {}
    local config = imgui.ImFontConfig()
    local iconfig = imgui.ImFontConfig()
	iconfig.MergeMode = false
    config.MergeMode = true
    config.PixelSnapH = true

    local list = {
        "ARROWS_MOVE",
        "WOOD",
        "TREES",
        "RADAR",
        "VECTOR_OFF",
        "BUG",
        "RULER_2",
        "DEVICE_FLOPPY",
        "DOWNLOAD",
        "X"
    }
    local builder = imgui.ImFontGlyphRangesBuilder()
	local range = imgui.ImVector_ImWchar()
    local defaultGlyphRanges = imgui.ImVector_ImWchar()
    for _, icon in pairs(list) do
        builder:AddText(ti(icon))
    end
    builder:BuildRanges(defaultGlyphRanges)
    local iconRanges = imgui.new.ImWchar[3](ti.min_range, ti.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(ti.get_font_data_base85(), 14, config, defaultGlyphRanges[0].Data) -- ќб€зательно
    fonts[16] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(my_font_compressed_data_base85, 17, iconfig, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(ti.get_font_data_base85(), 17, config, defaultGlyphRanges[0].Data)
    fonts[48] = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(my_font_compressed_data_base85, 42, iconfig, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(ti.get_font_data_base85(), 49, config, defaultGlyphRanges[0].Data)
    apply_custom_style()
end)

function apply_custom_style()
    imgui.SwitchContext()
    imgui.GetStyle().WindowPadding = imgui.ImVec2(15, 15)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)

    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    imgui.GetStyle().WindowBorderSize = 0
    imgui.GetStyle().ChildBorderSize = 0
    imgui.GetStyle().PopupBorderSize = 0
    imgui.GetStyle().FrameBorderSize = 0
    imgui.GetStyle().TabBorderSize = 0


    imgui.GetStyle().WindowRounding = 8
    imgui.GetStyle().ChildRounding = 2
    imgui.GetStyle().FrameRounding = 4
    imgui.GetStyle().PopupRounding = 2
    imgui.GetStyle().ScrollbarRounding = 2
    imgui.GetStyle().GrabRounding = 2
    imgui.GetStyle().TabRounding = 2

    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.21, 0.21, 0.21, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.00)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.15, 0.15, 0.15, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.43, 0.43, 0.43, 0.8)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.35, 0.35, 0.35, 0.8)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.15, 0.15, 0.15, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.16, 0.16, 0.16, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.18, 0.18, 0.18, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end

function imgui.ToggleButton(str_id, bool, anim_speed) -- вроде сам писал, а вроде спиздил, анимаци€ точно мо€, в своих проектах лучше не юзать, держитс€ на сопл€х
    local p = imgui.GetCursorScreenPos()
    local cp = g_cpos()
    local DL = imgui.GetWindowDrawList()
    local h = imgui.GetTextLineHeightWithSpacing()
    local w = math.floor(h * 1.8)
    local r = h - 6
    local s = a_speed or 0.2
    local clicked = false

    if elements.custom.toggle_button[str_id] == nil then
        elements.custom.toggle_button[str_id] = {
            anim = false,
            anim_speed = anim_speed,
            back = bool[0],
            progress = 0,
            start_time = 0
        }
    end
    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end

    if imgui.InvisibleButton("##" .. str_id .. "tglbtn", iv2(w + 4, h + 2)) then
        if not elements.custom.toggle_button[str_id].anim then --≈сли вы тут ищите вдохновение, то это можно убрать и будет плавно назад уезжат если уже в анимации, но не работает при низком времени анимации (на 0.5-1 секунде уже норм€лЄк)
            clicked = true
            bool[0] = not bool[0]
            if elements.custom.toggle_button[str_id].anim then
                elements.custom.toggle_button[str_id].back = not elements.custom.toggle_button[str_id].back
            else
                elements.custom.toggle_button[str_id].anim = true
                elements.custom.toggle_button[str_id].start_time = os.clock()
            end
        end
    end
    if elements.custom.toggle_button[str_id].anim then
        if elements.custom.toggle_button[str_id].back then
            elements.custom.toggle_button[str_id].progress = 1 - ((os.clock() - elements.custom.toggle_button[str_id].start_time) / elements.custom.toggle_button[str_id].anim_speed)
        else 
            elements.custom.toggle_button[str_id].progress = (os.clock() - elements.custom.toggle_button[str_id].start_time) / elements.custom.toggle_button[str_id].anim_speed
        end
        if elements.custom.toggle_button[str_id].progress > 1 then
            elements.custom.toggle_button[str_id].progress = 1
            elements.custom.toggle_button[str_id].anim = false
            elements.custom.toggle_button[str_id].back = true
        elseif elements.custom.toggle_button[str_id].progress < 0 then
            elements.custom.toggle_button[str_id].progress = 0
            elements.custom.toggle_button[str_id].anim = false
            elements.custom.toggle_button[str_id].back = false
        end
    end
    imgui.SameLine()
    imgui.SetCursorPosY(cp.y + 4)
    imgui.SetCursorPosX(g_cpos().x + 3)
    imgui.Text(str_id)
    local color_true = iv4(0.43, 1, 0.43, 1)
    local color_false = iv4(1, 0.43, 0.43, 1)
    DL:AddRect(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + w + 4, p.y + h + 2), conv_c(iv4(0.5, 0.5, 0.5, 1.00)), 3, 15, 1.5)
    if elements.custom.toggle_button[str_id].anim then
        offset = math.floor(h * 0.9) * elements.custom.toggle_button[str_id].progress
        local box_color = bringVec4To(elements.custom.toggle_button[str_id].back and color_true or color_false, elements.custom.toggle_button[str_id].back and color_false or color_true, elements.custom.toggle_button[str_id].start_time, anim_speed)
        if elements.custom.toggle_button[str_id].progress < 0.5 then
            DL:AddRectFilled(imgui.ImVec2(p.x + 3, p.y + 3), imgui.ImVec2(p.x + w / 2 + 1 + (offset / 0.5), p.y + h - 1), conv_c(box_color), 3, 15, 1.5)
        else 
            offset = math.floor(h * 0.9) * ((elements.custom.toggle_button[str_id].progress - 0.5) / 0.5)
            DL:AddRectFilled(imgui.ImVec2(p.x + 3 + offset, p.y + 3), imgui.ImVec2(p.x + w / 2 + 1 + math.floor(h * 0.9), p.y + h - 1), conv_c(box_color), 3, 15, 1.5)
        end
    else
        offset = elements.custom.toggle_button[str_id].back and math.floor(h * 0.9) or 0
        DL:AddRectFilled(imgui.ImVec2(p.x + 3 + offset, p.y + 3), imgui.ImVec2(p.x + w / 2 + 1 + offset, p.y + h - 1), conv_c(bool[0] and color_true or color_false), 3, 15, 1.5)
    end
    imgui.SetCursorPosX(10)
    return clicked
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function load_cfg()
    if  doesFileExist(getWorkingDirectory().."\\config\\lesorub_fomikus.json") then 
        local f = io.open(getWorkingDirectory().."\\config\\lesorub_fomikus.json", "r")
        config = decodeJson(f:read('*a'))
        f:close()
        elements.radar.pos = config.radar_pos
        cVARS.radar[0] = config.radar
        cVARS.debug[0] = config.debug
        cVARS.tracers[0] = config.tracers
        cVARS.radar_size[0] = config.radar_size
        cVARS.radar_zoom[0] = config.radar_zoom
    else
        config = {
            radar = false,
            debug = false,
            tracers = false,
            radar_size = 299,
            radar_zoom = 20,
            radar_pos = {187, 553}
        }
    end
end

function save_cfg()
    config.radar = cVARS.radar[0]
    config.debug = cVARS.debug[0]
    config.tracers = cVARS.tracers[0]
    config.radar_size = cVARS.radar_size[0]
    config.radar_zoom = cVARS.radar_zoom[0]
    config.radar_pos = elements.radar.pos
    local f = io.open(getWorkingDirectory().."\\config\\lesorub_fomikus.json", "w")
    f:write(encodeJson(config))
    f:close()
end