resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
    "config.lua",
    "client/marker_controller.lua",
    "client/events.lua",
    "client/main.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server/main.lua"
}

dependencies {
    "es_extended",
    "mysql-async"
}
