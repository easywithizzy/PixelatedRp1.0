-- Settings
local color = { r = 220, g = 220, b = 220, alpha = 255 } -- Color of the text
local font = 2 -- Font of the text
local time = 7000 -- Duration of the display of the text : 1000ms = 1sec
local background = {
    enable = true,
    color = { r = 35, g = 35, b = 35, alpha = 200 },
}
local chatMessage = false
local dropShadow = false

-- Don't touch
local nbrDisplaying = 1

RegisterCommand('me', function(source, args)
    local text = ''
    for i = 1,#args do
        text = text .. ' ' .. args[i]
    end

    TriggerServerEvent('3dme:shareDisplay', text)
end)

RegisterNetEvent('3dme:triggerDisplay')
AddEventHandler('3dme:triggerDisplay', function(text, source)
    local offset = 1 + (nbrDisplaying*0.04)
    Display(GetPlayerFromServerId(source), text, offset)
end)

function Display(mePlayer, text, offset)
    local displaying = true

    -- Chat message
    if chatMessage then
        local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
        local coords = GetEntityCoords(PlayerPedId(), false)
        local dist = Vdist2(coordsMe, coords)
        if dist < 2500 then
            TriggerEvent('chat:addMessage', {
                color = { color.r, color.g, color.b },
                multiline = true,
                args = { text}
            })
        end
    end

    Citizen.CreateThread(function()
        Wait(time)
        displaying = false
    end)
    Citizen.CreateThread(function()
        nbrDisplaying = nbrDisplaying + 1
        print(nbrDisplaying)
        while displaying do
            Wait(0)
            local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
            local coords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist2(coordsMe, coords)
            if dist < 2500 then
                if HasEntityClearLosToEntity(PlayerPedId(), GetPlayerPed(mePlayer), 17 ) then
                    DrawText3D(coordsMe['x'], coordsMe['y'], coordsMe['z']+1, text)
                end
            end
        end
        nbrDisplaying = nbrDisplaying - 1
    end)
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = ((1/dist)*2)*(1/GetGameplayCamFov())*100

    if onScreen then

        -- Formalize the text
        SetTextColour(color.r, color.g, color.b, color.alpha)
        SetTextScale(0.0*scale, 0.35*scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextCentre(true)
        if dropShadow then
            SetTextDropshadow(10, 100, 100, 100, 255)
        end

        -- Calculate width and height
        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local height = GetTextScaleHeight(0.35*scale, font)
        local width = EndTextCommandGetWidth(font)

        -- Diplay the text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)

        if background.enable then
            DrawRect(_x, _y+scale/75, width, height, background.color.r, background.color.g, background.color.b , background.color.alpha)
        end
    end
end


RegisterCommand('droll1', function(source, args, rawCommand)
	local number = math.random(1,6)
	loadAnimDict("anim@mp_player_intcelebrationmale@wank")
	TaskPlayAnim(GetPlayerPed(-1), "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Citizen.Wait(1500)
	ClearPedTasks(GetPlayerPed(-1))
	TriggerServerEvent('3dme:shareDisplay', 'You rolled a '..number)
end)

RegisterCommand('droll2', function(source, args, rawCommand)
    local diceOne = math.random(1,6)
    local diceTwo = math.random(1,6)
    local text = 'You rolled: ' .. diceOne .. ' ' .. diceTwo
	loadAnimDict("anim@mp_player_intcelebrationmale@wank")
	TaskPlayAnim(GetPlayerPed(-1), "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Citizen.Wait(1500)
	ClearPedTasks(GetPlayerPed(-1))
	TriggerEvent('chatMessage', '[Dice]', {128, 0, 128}, text)
	TriggerServerEvent('3dme:shareDisplay', text)
end)

RegisterCommand('droll3', function(source, args, rawCommand)
    local diceOne = math.random(1,6)
    local diceTwo = math.random(1,6)
    local diceThree = math.random(1,6)
    local text = 'You rolled: ' .. diceOne .. ' ' .. diceTwo .. ' ' .. diceThree
	loadAnimDict("anim@mp_player_intcelebrationmale@wank")
	TaskPlayAnim(GetPlayerPed(-1), "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Citizen.Wait(1500)
	ClearPedTasks(GetPlayerPed(-1))
	TriggerServerEvent('3dme:shareDisplay', text)
end)

   
function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
        RequestAnimDict( dict )
	    Citizen.Wait(5)
    end
end