-- https://wiki.fivem.net/wiki/Resource_manifest

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'An series of scripts'

version '1.1.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/sv.lua',
	'config.lua',
	'server/afkkick-server.lua',
	'server/gpstools-server.lua',
	'server/commands-server.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/sv.lua',
	'config.lua',
	'client/npc_drop-client.lua',
	'client/speed_limit-client.lua',
	'client/afkkick-client.lua',
	'client/gpstools-client.lua',
	'client/commands-client.lua',
	'client/no_vehicle_rewards-client.lua',
	'client/disable_dispatch-client.lua',
	'client/no_crosshair-client.lua',
	'client/drift_mode-client.lua',
	'client/friendly_npc-client.lua',
	'street_display-client.lua',
}
