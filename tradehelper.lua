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
        size2 = 289
        }
    }, IniFilename)
inicfg.save(ini,IniFilename)
--

-- mimgui
local new = imgui.new
local MainWindow = new.bool()
local DialogWindow = new.bool()
local inputDialog = new.char[108]()
local sizeX, sizeY = getScreenResolution()
local EditedMenu = false
local posX, posY, size1, size2 = ini.settings.pos1,ini.settings.pos2,ini.settings.size1,ini.settings.size2
--

local tag = '[ Trade Helper ] {e6e6e6}'
local colour = 0xe4ee5a

local tradePlayer = {}
local onTrade = false
local DialogText = {}

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampAddChatMessage(tag .. "Скрипт успешно загружен! Используйте /tmenu",colour)
    sampRegisterChatCommand('tr',tr)
    sampRegisterChatCommand('tmenu',tmenu)
    
    -- Установка шрифта
    if not doesFileExist('moonloader/TradeHelper/EagleSans-Reg.ttf') then
        downloadUrlToFile('https://github.com/Turan-Fresko/TradeHelper-ARZ/raw/5148b22a26b9b9506b30c8287595c0ec2be5e6c2/TradeHelper/EagleSans-Reg.ttf', 'moonloader/TradeHelper/EagleSans-Reg.ttf', function (id, status, p1, p2)
            if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                sampAddChatMessage(tag..'Шрифт был успешно установлен!', colour)
            end
        end)
    end
    --

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
    imgui.GetIO().IniFilename = nil
    white_style()
end)

local MainFrame = imgui.OnFrame(function() return MainWindow[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(525, 275), imgui.Cond.FirstUseEver)
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
            imgui.Text(u8"Версия: " .. script.this.version)
            if imgui.IsItemClicked() then
                os.execute('explorer https://github.com/Turan-Fresko/TradeHelper-ARZ')
            end
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
    imgui.PopFont()
    imgui.End()
end)

local DialogFrame = imgui.OnFrame(function() return DialogWindow[0] end, function(player)
    -- imgui.ShowStyleEditor()
    imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(size1, size2), imgui.Cond.FirstUseEver)
    imgui.PushFont(font)
    imgui.Begin(u8"Дилог", DialogWindow, imgui.WindowFlags.NoCollapse)
        posX, posY, size1, size2 = imgui.GetWindowPos().x,imgui.GetWindowPos().y, imgui.GetWindowWidth(), imgui.GetWindowHeight()
        if tradePlayer[1] then
            imgui.Text(u8'Игрок: ' .. tradePlayer[1] .. '[' .. tradePlayer[2] .. ']')
            if imgui.BeginChild('Dialog', imgui.ImVec2(imgui.GetWindowWidth()-15, imgui.GetWindowHeight()-100), true) then
                if #DialogText > 0 then
                    for i, Text in ipairs(DialogText) do
                        imgui.TextColoredRGB(string.format("{ffffff} %s", Text))
                        if imgui.IsItemClicked() then
                            setClipboardText(Text:gsub("{.-}", ""))
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
    if id == -65281 and string.find(text, 'Вы отказались от предложения торговли.') then
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
        table.insert(DialogText,text)
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
            table.insert(DialogText,string.format("[%s] %s", os.date("%H:%M:%S"), text))
        end
    end
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