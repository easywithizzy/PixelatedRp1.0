function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
    --Example 1: AddTextEntry('gameName', 'VEHICLE_NAME_HERE')
    --Example 2: AddTextEntry('f350', '2013 Ford F350')
    AddTextEntry('SFTSU', 'DOT Pickup')
    AddTextEntry('SFBC1', 'BCSO Explorer Supervisor')
    AddTextEntry('SFBC2', 'BCSO Charger')
    AddTextEntry('SFBC3', 'BCSO Explorer Classic')
    AddTextEntry('SFBC4', 'BCSO Crown Vic')
    AddTextEntry('SFBC5', 'BCSO Explorer')
    AddTextEntry('SFUM1', 'Unmarked Tahoe')
    AddTextEntry('SFUM2', 'Unmarked Crown Vic')
end)