
local driftmode = false
local drift_speed_limit = 100.0
local IsEngineOn = true

local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

-- Handle key press
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if IsControlJustPressed(1, Keys["DELETE"]) and GetLastInputMethod(2) then

			driftmode = not driftmode -- toggle

			if driftmode then
				TriggerEvent('chatMessage', _U('drift'), {167,101,181}, _U('drift_enabled'))
			else
				TriggerEvent('chatMessage', _U('drift'), {167,101,181}, _U('drift_disabled'))
			end
		elseif IsControlPressed(1, Keys["LEFTSHIFT"]) and IsControlPressed(1, Keys["E"]) then
			local playerPed = GetPlayerPed(-1)
			local vehicle = GetVehiclePedIsIn(playerPed, false)

			if (IsPedSittingInAnyVehicle(playerPed)) then 
				if IsEngineOn == true then
					IsEngineOn = false
					SetVehicleEngineOn(vehicle,false,false,false)
				else
					IsEngineOn = true
					SetVehicleUndriveable(vehicle,false)
					SetVehicleEngineOn(vehicle,true,false,false)
				end
				
				while (IsEngineOn == false) do
					SetVehicleUndriveable(vehicle,true)
					Citizen.Wait(0)
				end
			end
		end
end)
		end
	end
end)

Citizen.CreateThread(function()
	local vehicle

	while true do
		Citizen.Wait(10)
		if driftmode then
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
				local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
				if GetPedInVehicleSeat(vehicle, -1) == GetPlayerPed(-1) then
					if GetEntitySpeed(vehicle) * 3.6 <= drift_speed_limit then
						if IsControlPressed(1, Keys['LEFTSHIFT']) then
							SetVehicleReduceGrip(vehicle, true)
						else
							SetVehicleReduceGrip(vehicle, false)
						end
					end
				end
			end
		else
			Citizen.Wait(1000)
		end
	end
end)