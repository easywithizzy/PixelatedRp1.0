ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

function getEmployeeBars(xPlayer, cb)
    local params = { ["@identifier"] = xPlayer.getIndentifier() }
    local query  = [[SELECT bars.id, bars.name, x, y, z FROM bars
        INNER JOIN bar_employees ON bar_employees.bar_id = bars.id
        INNER JOIN users ON users.id = bar_employees.user_id
        WHERE users.identifier = @identifier]]

    MySQL.Async.fetchAll(query, params, function(results)
        cb(results)
    end)
end

RegisterNetEvent("pixelated_bartending:loading")
AddEventHandler("pixelated_bartending:loading", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer ~= nil then
        getEmployeeBars(xPlayer, function(results)
            TriggerClientEvent("pixelated_bartending:loaded", _source, results)
        end)
    end
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(xPlayer)
    if xPlayer ~= nil then
        getEmployeeBars(xPlayer, function(results)
            TriggerClientEvent("pixelated_bartending:loaded", _source, results)
        end)
    end
end)
