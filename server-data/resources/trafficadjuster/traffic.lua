Citizen.CreateThread(function()
	--[[ This is already handled by disable_dispatch in scrp_scripts
	for i = 1, 13 do
		EnableDispatchService(i, EnableDispatch)
	end
	]]

	while true do
		-- These natives has to be called every frame.
		SetVehicleDensityMultiplierThisFrame((TrafficAmount/100)+.0)
		SetPedDensityMultiplierThisFrame((PedestrianAmount/100)+.0)
		SetRandomVehicleDensityMultiplierThisFrame((TrafficAmount/100)+.0)
		SetParkedVehicleDensityMultiplierThisFrame((ParkedAmount/100)+.0)
		SetScenarioPedDensityMultiplierThisFrame((PedestrianAmount/100)+.0, (PedestrianAmount/100)+.0)
		Citizen.Wait(0)
	end
end)
