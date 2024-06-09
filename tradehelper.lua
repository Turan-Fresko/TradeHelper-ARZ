script_name("Trade Helper")
script_author("Turan_")
script_version("1.0.0")
script_description("Скрипт, помогающий при обмене/общении с игроком в людных местах, путем вывода сообщений в отдельное диалоговое окно.")

require 'lib.moonloader'
local dlstatus = require('moonloader').download_status
local ev = require "lib.samp.events"
local ffi = require 'ffi'
local imgui = require 'mimgui'
local inicfg = require 'inicfg'
local requests = require 'requests'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

-- ini
if not doesFileExist('moonloader/TradeHelper') then
    createDirectory('moonloader/TradeHelper')
end
local IniFilename = "../TradeHelper/Config.ini"
local ini = inicfg.load({
    settings = {
        pos1 = 1049,
        pos2 = 145,
        size1 = 575,
        size2 = 289,
        NewDialog = false
        }
    }, IniFilename)
inicfg.save(ini,IniFilename)
--

-- mimgui
local new = imgui.new
local MainWindow = new.bool()
local DialogWindow = new.bool()
local UpdateWindow = new.bool()
local ItemWindow = new.bool()
local inputDialog = new.char[108]()
local sizeX, sizeY = getScreenResolution()
local EditedMenu = false
local posX, posY, size1, size2 = ini.settings.pos1,ini.settings.pos2,ini.settings.size1,ini.settings.size2
--

local tag = '[ Trade Helper ] {e6e6e6}'
local colour = 0xe4ee5a

local onTrade = false
local onUserTrade, onPlayerTrade = false, false
local NewItemDialog = ini.settings.NewDialog
local ItemDialog = {}
local tradePlayer = {}
local DialogText = {}
local newUpdate = {version = script.this.version, updates = "Релиз."}

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage(tag .. "Скрипт успешно загружен! Используйте /tmenu",colour)
    sampRegisterChatCommand('tr',tr)
    sampRegisterChatCommand('tmenu',tmenu)
    sampRegisterChatCommand('test',test)
    
    -- Установка шрифта
    if not doesFileExist('moonloader/TradeHelper/EagleSans-Reg.ttf') then
        downloadUrlToFile('https://github.com/Turan-Fresko/TradeHelper-ARZ/raw/5148b22a26b9b9506b30c8287595c0ec2be5e6c2/TradeHelper/EagleSans-Reg.ttf', 'moonloader/TradeHelper/EagleSans-Reg.ttf', function (id, status, p1, p2)
            if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                sampAddChatMessage(tag..'Шрифт был успешно установлен!', colour)
            end
        end)
    end
    --
    checkUpdates()

    while true do
        wait(0)
    end
end

function white_style()
    imgui.SwitchContext()
    imgui.GetStyle().WindowTitleAlign        = imgui.ImVec2(0.50,0.50)
    imgui.GetStyle().WindowRounding        = 7.0
    imgui.GetStyle().ChildRounding        = 7.0
    imgui.GetStyle().FrameRounding        = 3
    imgui.GetStyle().FramePadding        = imgui.ImVec2(5, 3)
    imgui.GetStyle().WindowPadding        = imgui.ImVec2(8, 8)
    imgui.GetStyle().ButtonTextAlign    = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().GrabMinSize        = 7
    imgui.GetStyle().GrabRounding        = 15

    imgui.GetStyle().Colors[imgui.Col.Text]                    = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]            = imgui.ImVec4(1.00, 1.00, 1.00, 0.20)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.40, 0.39, 0.39, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                = imgui.ImVec4(1, 1, 1, 0.25)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]            = imgui.ImVec4(0.90, 0.90, 0.90, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]        = imgui.ImVec4(0.70, 0.70, 0.70, 1.00)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]            = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.60, 0.60, 0.60, 0.90)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]        = imgui.ImVec4(0.90, 0.90, 0.90, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]    = imgui.ImVec4(0.80, 0.80, 0.80, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.70, 0.70, 0.70, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]        = imgui.ImVec4(0.20, 0.20, 0.20, 0.80)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]        = imgui.ImVec4(0.20, 0.20, 0.20, 0.60)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]            = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]        = imgui.ImVec4(0.15, 0.15, 0.15, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]            = imgui.ImVec4(0.10, 0.10, 0.10, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]        = imgui.ImVec4(0.80, 0.80, 0.80, 0.80)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]        = imgui.ImVec4(0.37, 0.34, 0.34, 1)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]        = imgui.ImVec4(0.37, 0.34, 0.34, 1)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]        = imgui.ImVec4(0.63, 0.63, 0.63, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]        = imgui.ImVec4(1, 1, 1, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]        = imgui.ImVec4(0.37, 0.37, 0.37, 0.92)

    local but_orig = imgui.Button
    imgui.Button = function(...)
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1.00))
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.20, 0.20, 0.20, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.18, 0.18, 0.18, 1.00))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.70, 0.70, 0.70, 1.00))
        local result = but_orig(...)
        imgui.PopStyleColor(4)
        return result
    end
end

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/TradeHelper/EagleSans-Reg.ttf', 20, _, glyph_ranges)
    font2 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/TradeHelper/EagleSans-Reg.ttf', 18, _, glyph_ranges)
    imgui.GetIO().IniFilename = nil
    white_style()
end)

local MainFrame = imgui.OnFrame(function() return MainWindow[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(525, 500), imgui.Cond.FirstUseEver)
    imgui.PushFont(font)
    imgui.Begin(u8"Основные настройки", MainWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        if imgui.BeginChild('Edit', imgui.ImVec2(250, 150), true) then
            imgui.Text(u8"Редактирование окна диалога:")
            imgui.Text(u8(string.format("Размер окна: %s, %s", size1,size2)))
            imgui.Text(u8(string.format("Позиция окна: %s, %s", posX,posY)))
            imgui.NewLine()
            if imgui.Button(u8"Вызвать окно диалога", imgui.ImVec2(230,38)) then
                DialogWindow[0] = not DialogWindow[0]
                EditedMenu = DialogWindow[0]
            end
            imgui.EndChild()
        end
        imgui.SameLine()
        if imgui.BeginChild('Information', imgui.ImVec2(250, 150), true) then
            imgui.Text(u8"Информация о скрипте:")
            imgui.Text(u8"Автор: Turan_")
            imgui.Link("https://github.com/Turan-Fresko/TradeHelper-ARZ",u8"Версия: " .. script.this.version)
            imgui.Text(u8"Состояние:")
            if imgui.Button(u8'Перезагрузить',imgui.ImVec2(125,38)) then
                lua_thread.create(function() 
                    sampAddChatMessage(tag .. 'Скрипт перезагружается...',colour)
                    wait(1000)
                    thisScript():reload()
                end)
            end
            imgui.SameLine()
            if imgui.Button(u8'Выключить',imgui.ImVec2(105,38)) then
                lua_thread.create(function() 
                    sampAddChatMessage(tag .. 'Скрипт выключается...',colour)
                    wait(1000)
                    thisScript():unload()
                end)
            end
            imgui.EndChild()
        end

        if imgui.Button(u8"Сохранить все", imgui.ImVec2(510,75)) then
            ini.settings.pos1 = posX
            ini.settings.pos2 = posY
            ini.settings.size1 = size1
            ini.settings.size2 = size2
            inicfg.save(ini,IniFilename)
            sampAddChatMessage(tag .. "Все успешно сохраненно!", colour)
        end
        imgui.VerticalSeparator()
    imgui.PopFont()
    imgui.End()
end)

local DialogFrame = imgui.OnFrame(function() return DialogWindow[0] end, function(player)
    -- imgui.ShowStyleEditor()
    imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(size1, size2), imgui.Cond.FirstUseEver)
    imgui.PushFont(font)
    imgui.Begin(u8"Диалог", DialogWindow, imgui.WindowFlags.NoCollapse)
        posX, posY, size1, size2 = imgui.GetWindowPos().x,imgui.GetWindowPos().y, imgui.GetWindowWidth(), imgui.GetWindowHeight()
        if tradePlayer[1] then
            imgui.Text(u8'Игрок: ' .. tradePlayer[1] .. '[' .. tradePlayer[2] .. ']')
            if imgui.BeginChild('Dialog', imgui.ImVec2(imgui.GetWindowWidth()-15, imgui.GetWindowHeight()-100), true) then
                if #DialogText > 0 then
                    for i, data in ipairs(DialogText) do
                        imgui.TextColoredRGB(string.format("%s[%s] %s", data.color, data.date,data.text))
                        if imgui.IsItemClicked() then
                            text = string.format("[%s] %s", data.date, data.text)
                            setClipboardText(text:gsub("{.-}", ""))
                            sampAddChatMessage(tag .. 'Вы успешно скопировали текст!', colour)
                        end
                    end
                end
                imgui.EndChild()
            end
            imgui.InputTextWithHint('##sendMessageDialog', u8'Введите текст для отправки в чат', inputDialog, 108)
            imgui.SameLine()
            if imgui.Button(u8'Отправить') then
                lua_thread.create(function()
                    text = u8:decode(ffi.string(inputDialog))
                    sampSendChat(text)
                end)
            end
        elseif EditedMenu then
            imgui.Text(u8"Вы сейчас редактируете окно...")
        else
            imgui.Text(u8'Ошибка, не удалось достать никнейм.\nЧто бы принудительно открыть диалог с игроком используйте команду /tr id')
        end
    imgui.PopFont()
    imgui.End()
end)

local UpdateFrame = imgui.OnFrame(function() return UpdateWindow[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(525, 300), imgui.Cond.FirstUseEver)
    imgui.PushFont(font)
    imgui.Begin(u8"Обновление", UpdateWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        if newUpdate.version == script.this.version then
            imgui.Text(u8"У вас последняя версия скрипта! :)")
        else
            imgui.Text(string.format(u8"Вышло обновление, новая версия %s, перед обновлением вы\nможете посмотреть исходный файл на ", newUpdate.version ))
            imgui.SetCursorPos(imgui.ImVec2(310, 53))
            imgui.Link("https://github.com/Turan-Fresko/TradeHelper-ARZ/",u8"репозитории GitHub.")
            imgui.Text(u8'Что нового?')
            if imgui.BeginChild('Updates', imgui.ImVec2(510,150), true) then
                if type(newUpdate.updates) == 'string' then
                    imgui.Text(newUpdate.updates)
                elseif type(newUpdate.updates) == 'table' then
                    for i, text in ipairs(newUpdate.updates) do
                        imgui.Text(text)
                    end
                end
                imgui.EndChild()
            end
            if imgui.Button(u8"Проверить наличие обновлений",imgui.ImVec2(300, 37)) then
                checkUpdates()
            end
            imgui.SameLine()
            if imgui.Button(u8"Обновить",imgui.ImVec2(200, 37)) then
                if newUpdate.version == script.this.version then
                    sampAddChatMessage(tag.. 'У вас сейчас установлена последняя версия скрипта!', colour)
                else
                    downloadUrlToFile('https://raw.githubusercontent.com/Turan-Fresko/TradeHelper-ARZ/main/tradehelper.lua', thisScript().path, function (id, status, p1, p2)
                        if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                            sampAddChatMessage(tag..'Обновление установлена! Перезагружаюсь...', colour)
                            sampAddChatMessage(" ", -1)
                            thisScript():reload()
                        end
                    end)
                end
            end
        end
    imgui.PopFont()
    imgui.End()
end)

local ItemFrame = imgui.OnFrame(function() return ItemWindow[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(600, 500), imgui.Cond.FirstUseEver)
    imgui.PushFont(font)
    imgui.Begin(u8"Информация о предмете", ItemWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        if sampIsDialogActive() then
            sampCloseCurrentDialogWithButton(1)
        end
        imgui.TextColoredRGB(ItemDialog.text)
    imgui.PopFont()
    imgui.End()
end)

function ev.onServerMessage(id,text ,color)
    if id == -65281 and string.find(text,"Вы предложили") then
        lua_thread.create(function() 
            tradeNickName = string.match(text, "Вы предложили%s*(.-)%[")
            print(tradeNickName)
            tradeId = string.match(text,"%[(%d+)%]")
            if not tradeNickName or not tradeId then sampAddChatMessage(tag.. 'Не удалось достать никнейм/id игрока, что бы принудительно открыть диалог /tr id', colour) return end
            tradePlayer = {tradeNickName, tradeId}
            DialogText = {}
            onTrade = true
            DialogWindow[0] = true
        end)
    end
    if id == -65281 and onTrade and string.find(text, 'Вы отказались от предложения торговли.') then
        sampAddChatMessage(tag.. 'Вы отказались от трейда с игроком: '.. tradePlayer[1] .. ', закрываю диалог.', colour)
        DialogText = {}
        onTrade = false
        DialogWindow[0] = false
    end
    if id == -1104335361 and onTrade and string.find(text, 'отменил сделку') and tradePlayer[1] then
        sampAddChatMessage(tag.. 'Игрок: '.. tradePlayer[1] .. ' отменил трейд, закрываю диалог.', colour)
        DialogText = {}
        onTrade = false
        DialogWindow[0] = false
    end
    if id == -1104335361 and onTrade and string.find(text, 'Вы отменили сделку') and tradePlayer[1] then
        sampAddChatMessage(tag.. 'Вы отменили сделку с игроком: '.. tradePlayer[1] .. ', закрываю диалог.', colour)
        DialogText = {}
        onTrade = false
        DialogWindow[0] = false
    end
    if id == -1347440641 and onTrade and string.find(text,"Вы подтвердили сделку!") or string.find(text,"Игрок подтвердил сделку!") then
        table.insert(DialogText,{date = os.date("%H:%M:%S"), text = text, color = "{fffb00}"})
    end
    if id == 1118842111 and onTrade and string.find(text,"Сделка прошла успешно!") then
        sampAddChatMessage(tag.. 'Вы завершили трейд с игроком '.. tradePlayer[1] .. ', закрываю диалог.', colour)
        DialogText = {}
        onTrade = false
        DialogWindow[0] = false
    end
    if onTrade and #tradePlayer == 2 then
        result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if not result then return sampAddChatMessage(tag .. 'Вы не авторизованы на сервере!', colour) end
        nickname1 = tradePlayer[1]:match("([%a_]+)")
        nickname2 = sampGetPlayerNickname(id):match("([%a_]+)")
        if not nickname1 or not nickname2 then return end
        if string.find(text, nickname1) or string.find(text, nickname2) then 
            table.insert(DialogText,{date = os.date("%H:%M:%S"), text = text, color = "{FFFFFF}"})
        end
    end
end

function ev.onShowTextDraw(id, data)
    if onTrade then
        if id == 2078 and not data.text == '_' then
            lua_thread.create(function()
                wait(152)
                table.insert(DialogText,{date = os.date("%H:%M:%S"), text = string.format("Игрок пложил в трейд %s %s", data.text, sampTextdrawGetString(2079)), color = "{049e20}"})
            end)
        end
    end
end

function checkUpdates()
    sampAddChatMessage(tag .. 'Проверка наличий обновлений...',colour)
    local result, response = pcall(requests.request, 'GET', 'https://raw.githubusercontent.com/Turan-Fresko/TradeHelper-ARZ/main/updates.json', nil, nil)
    if result then
        responseJson = decodeJson(response.text)
        if responseJson.version == script.this.version then sampAddChatMessage(tag .. 'У вас последняя версия скрипта!',colour)
        else
            newUpdate = responseJson
            sampAddChatMessage(tag .. 'Вышло новое обновление!',colour)
            UpdateWindow[0] = true
        end
    else sampAddChatMessage(tag .. '{ff4444}Не удалось проверить наличие обновлений!',colour) end
end

function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), 0x817e7e81)
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
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end
    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
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

function imgui.Link(link, text)
    text = text or link
    local tSize = imgui.CalcTextSize(text)
    local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
    local col = { 0xFFFF7700, 0xFFFF9900 }
    if imgui.InvisibleButton("##" .. link, tSize) then os.execute("explorer " .. link) end
    local color = imgui.IsItemHovered() and col[1] or col[2]
    DL:AddText(p, color, text)
    DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
end

function imgui.CenterButton(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(u8(text)).x/2)
    return imgui.Button(u8(text))
end

function ev.onShowDialog(id, style, title, button1, button2, text)
    if id == 8252 and string.find(title,"Торговля") then
        tradeNickName = string.match(text, "Игрок%s(.-)%[")
        tradeId = string.match(text,"%[(%d+)%]")
        if not tradeNickName or not tradeId then sampAddChatMessage(tag.. 'Не удалось достать никнейм/id игрока, что бы принудительно открыть диалог /tr id.', colour) return end
        tradePlayer = {tradeNickName, tradeId}
        onTrade = true
        DialogWindow[0] = true
    end
    if NewItemDialog and id == 8236 then
        ItemDialog = {id = id, title = title, text = text}
        ItemWindow[0] = true
    end
end

function get_player(nickname)
    for id = 0, 999 do
        if sampIsPlayerConnected(id) then
            local player_id = tonumber(nickname)
            if player_id then
                if id == player_id then
                    tradePlayer = {sampGetPlayerNickname(player_id), player_id}
                    return true
                end
            else
                local nick = sampGetPlayerNickname(id)
                if nick == nickname then
                    tradePlayer = {nick, id}
                    return true
                end
            end
        end
    end
    return false
end

function tmenu()
    MainWindow[0] = not MainWindow[0]
end

function tr(args)
    if #args == 0 then
        return sampAddChatMessage(tag.. 'Используйте /tr [id/name]',colour)
    end
    if not get_player(args) then
        return sampAddChatMessage(tag.. 'Игрок не найден!',colour)
    end
    DialogText = {}
    onTrade = true
    DialogWindow[0] = true
end

function test()
    UpdateWindow[0] = not UpdateWindow[0]
end