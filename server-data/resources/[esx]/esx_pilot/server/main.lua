ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
  TriggerEvent('esx_service:activateService', 'pilot', Config.MaxInService)
end

TriggerEvent('esx_phone:registerNumber', 'pilot', _U('pilot_client'), true, true)
TriggerEvent('esx_society:registerSociety', 'pilot', 'Pilot', 'society_pilot', 'society_pilot', 'society_pilot', {type = 'private'})

RegisterServerEvent('esx_pilot:success')
AddEventHandler('esx_pilot:success', function()

  math.randomseed(os.time())

  local xPlayer        = ESX.GetPlayerFromId(source)
  local total          = math.random(Config.NPCJobEarnings.min, Config.NPCJobEarnings.max);
  local societyAccount = nil

  if xPlayer.job.grade >= 3 then
    total = total * 2
  end

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_pilot', function(account)
    societyAccount = account
  end)

  if societyAccount ~= nil then

    local playerMoney  = math.floor(total / 100 * 200)
    local societyMoney = math.floor(total / 100 * 750)

    xPlayer.addMoney(playerMoney)
    societyAccount.addMoney(societyMoney)

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. playerMoney)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. societyMoney)

  else

    xPlayer.addMoney(total)
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. total)

  end

end)

RegisterServerEvent('esx_pilot:getStockItem')
AddEventHandler('esx_pilot:getStockItem', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pilot', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= count then
      inventory.removeItem(itemName, count)
      xPlayer.addInventoryItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. count .. ' ' .. item.label)

  end)

end)

ESX.RegisterServerCallback('esx_pilot:getStockItems', function(source, cb)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pilot', function(inventory)
    cb(inventory.items)
  end)

end)

RegisterServerEvent('esx_pilot:putStockItems')
AddEventHandler('esx_pilot:putStockItems', function(itemName, count)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pilot', function(inventory)

    local item = inventory.getItem(itemName)

    if item.count >= 0 then
      xPlayer.removeInventoryItem(itemName, count)
      inventory.addItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, _U('quantity_invalid'))
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('added') .. count .. ' ' .. item.label)

  end)

end)

ESX.RegisterServerCallback('esx_pilot:getPlayerInventory', function(source, cb)

  local xPlayer    = ESX.GetPlayerFromId(source)
  local items      = xPlayer.inventory

  cb({
    items      = items
  })

end)
