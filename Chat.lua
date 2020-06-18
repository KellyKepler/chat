script_name('Pure Souls Chat')
script_author('Kelly Kepler')
script_version('31.05.2020')

require "lib.moonloader"
local dlstatus = require('moonloader').download_status
local as_action = require('moonloader').audiostream_state
--local keys = require "vkeys"
local sampev = require 'lib.samp.events'
local imgui = require 'imgui'
local inicfg = require 'inicfg'
--local encoding = require 'encoding'

local sms = -65366
local togphone = -1347440726
local status = false
local mute = false

local var_allow = true
update_state = false

local script_vers = 1
local script_vers_text = "1.00"

local update_url = "https://raw.githubusercontent.com/KellyKepler/chat/master/update.ini"
local update_path = getWorkingDirectory() .. "update.ini"

local script_url = "https://github.com/KellyKepler/chat/blob/master/Chat.luac?raw=true"
local script_path = thisScript().path

local ini = inicfg.load({
  number =
  {
	502502,
	303808,
  },
}, "ps-chat")

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	soundSmS = loadAudioStream("https://goo.su/1Hz")
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)
	rnick = nick:gsub("_", " ")
	sampRegisterChatCommand("ps", sending)
	sampRegisterChatCommand("padd", psave)

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("[PS-Chat]: Вышла новая версия скрипта: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
    


	while true do
		wait(0)
		if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("[PS-Chat]: Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
            break
        end
	end
end

function psave()
	sampAddChatMessage("[PS-Chat]: Пришло новое сообщение на почту.", -1)
end


function sending(arg)
	if var_allow then
		if arg ~= '' then
			if (string.len(arg) < 60) then
				status = true
				sampAddChatMessage("[PS-Chat]: "..rnick.." написал: " ..arg, -1)
				setAudioStreamState(soundSmS, as_action.PLAY)
				lua_thread.create(function ()
					for i, value in ipairs(ini.number) do
						mute = true
						sampSendChat("/sms "..value.." !s!" ..arg)
						wait(1300)
						var_allow = false
					end
					wait(5000)
					var_allow = true
				end)
			else
				sampAddChatMessage("[PS-Chat]: Ошибка отправки! Превышено допустимое количество символов.", -1)
			end
		else
			sampAddChatMessage("[PS-Chat]: Ошибка отправки! Сообщение не может быть пустым.", -1)
		end
	else
		sampAddChatMessage("[PS-Chat]: Ошибка отправки! Слишком часто используется команда.", -1)
	end
end

function sampev.onPlaySound(sound, x, y, z)
	--sampAddChatMessage(sound, -1)
	if mute and sound == 1054 then
		return false
	end
	mute = false
end

function sampev.onServerMessage(color, text)
	if color == sms and text:find("SMS:") and text:find("!s!") and text:find("Отправитель")then 
		msg = string.gsub(text, '%{FF%S%S%S%S%}', '')
		t1,t2,t3,t4 = msg:match("SMS: !s!(.+) | Отправитель: (%w+)_(%w+) (.+)")
		sampAddChatMessage("[PS-Chat]: "..t2.." "..t3.." написал: " ..t1, -1)
		setAudioStreamState(soundSmS, as_action.PLAY)
		
	return false end
	if color == sms and text:find("SMS:") and text:find("!s!") and text:find("Получатель")then return false end
	if status and color == togphone and text:find("Сначала нужно включить телефон") then 
		sampAddChatMessage("[PS-Chat]: Ошибка отправки! Для общения в чате необходимо включить телефон.", -1)
		status = false
	return false end
	if mute and color == togphone and text:find("Ошибка: Игрока с этим номером нет на сервере") then
	mute = false
		
	return false end
	
end
