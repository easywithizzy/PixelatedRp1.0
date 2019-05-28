# esx_inventoryhud
Inventory HUD for ESX. You can open and close inventory using F2. Part of code was taken from [es_extended](https://github.com/ESX-Org/es_extended).

## Requirements
* [es_extended](https://github.com/ESX-Org/es_extended)

## Features
- Using items
- Droping items
- Giving items
- Searching inventory
- Cash included
- Accounts support (bank, black money, ...)
- Fully configurable (check config.lua and html/js/config.js)
- Locale files included (check locales/ and html/locales/ directories)

## Screens
* [https://i.imgur.com/PRx3vX3.png](https://i.imgur.com/PRx3vX3.png)

## Download & Installation

### Using Git
```
cd resources
git clone https://github.com/Trsak/esx_inventoryhud [esx]/esx_inventoryhud
```

### Manually
- Download https://github.com/Trsak/esx_inventoryhud/archive/master.zip
- Put it in the `[esx]` directory

## Installation
- Open `es_extended`, then find and remove this code in `client/main.lua`:
```
-- Menu interactions
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if IsControlJustReleased(0, Keys['F2']) and IsInputDisabled(0) and not isDead and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
			ESX.ShowInventory()
		end

	end
end)
```
- Add this to your `server.cfg`:

```
start esx_inventoryhud
```

## Config files
* config.lua
* html/js/config.js
