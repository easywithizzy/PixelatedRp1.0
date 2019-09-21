local MFS = MF_DrugSales
local currentDrug = ""
function MFS:Awake(...)
    while not ESX do Citizen.Wait(0); end
    while not ESX.IsPlayerLoaded() do Citizen.Wait(0); end
    self.PlayerData = ESX.GetPlayerData()
    ESX.TriggerServerCallback('MF_DrugSales:GetStartData', function(retVal,hintLoc) self.dS = true; self.cS = retVal; self.HintLocation = hintLoc; self:Start(); end)
end

function MFS:Start(...)
  if self.ShowBlip then self:DoBlips(); end
  if self.dS and self.cS then self:Update(); end
end

function MFS:DoBlips()
  if self.Blip then RemoveBlip(self.Blip); end
  local blip = AddBlipForCoord(self.HintLocation.x, self.HintLocation.y, self.HintLocation.z)
  SetBlipSprite               (blip, 205)
  SetBlipDisplay              (blip, 3)
  SetBlipScale                (blip, 1.0)
  SetBlipColour               (blip, 4)
  SetBlipAsShortRange         (blip, false)
  SetBlipHighDetail           (blip, true)
  BeginTextCommandSetBlipName ("STRING")
  AddTextComponentString      ("Shady Backalley")
  EndTextCommandSetBlipName   (blip)
  self.Blip = blip
end

function MFS:Update(...)
  local noteTemplate = Utils.DrawTextTemplate()
  noteTemplate.x = 0.5
  noteTemplate.y = 0.5
  local timer = 0
  while self.dS and self.cS do
    Citizen.Wait(0)
    local plyPed = GetPlayerPed(-1)
    local plyPos = GetEntityCoords(plyPed)
    if not self.MissionStarted then
      local dist = Utils.GetVecDist(plyPos, self.HintLocation)
      if dist < self.DrawTextDist then
        local p = self.HintLocation
        Utils.DrawText3D(p.x,p.y,p.z, "Press [~r~E~s~] to knock on the door.")
        if IsControlJustPressed(0, Keys["E"]) and GetGameTimer() - timer > 150 then    
          ESX.TriggerServerCallback('MF_DrugSales:GetCops',function(count)
            if count and count >= self.MinPoliceOnline then
              timer = GetGameTimer()
              TaskGoStraightToCoord(plyPed, p.x, p.y, p.z, 10.0, 10, p.w, 0.5)
              Wait(3000)
              ClearPedTasksImmediately(plyPed)

              while not HasAnimDictLoaded("timetable@jimmy@doorknock@") do RequestAnimDict("timetable@jimmy@doorknock@"); Citizen.Wait(0); end
              TaskPlayAnim( plyPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 8.0, 8.0, -1, 4, 0, 0, 0, 0 )     
              Citizen.Wait(0)
              while IsEntityPlayingAnim(plyPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 3) do Citizen.Wait(0); end          

              Citizen.Wait(1000)

              TriggerEvent('chat:addMessage', {color = { 255, 0, 0}, multiline = true, args = {"Me", "You notice a small piece of paper slide under the door."}})
              ClearPedTasksImmediately(plyPed)

              local elements = {}

              for k,v in pairs(self.DrugItems) do
                table.insert(elements, {label = k, value = v})
              end

              ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_selection', {
                title = 'Select your Dealer',
                align = 'center',
                elements = elements
              }, function(data, menu)
                menu.close()
                currentDrug = data.current.value
                local randNum = math.random(1,#self.SalesLocations)
                local spawnLoc = self.SalesLocations[randNum]
                local nearStreet = GetStreetNameFromHashKey(GetStreetNameAtCoord(spawnLoc.x,spawnLoc.y,spawnLoc.z))
                noteTemplate.text = "Find the buyer near "..nearStreet..".\nDon't be late."

                self.MissionStarted = spawnLoc

                SetNewWaypoint(spawnLoc.x,spawnLoc.y)

                local timer = GetGameTimer()
                while (GetGameTimer() - timer) < (self.NotificationTime * 1000) do
                  Citizen.Wait(0)
                  DrawSprite("commonmenu","", 0.5,0.53, 0.2,0.1,0.0, 125,125,125,200)
                  Utils.DrawText(noteTemplate)
                end
                self:MissionStart()
              end, function(data, menu)
                menu.close()
              end)
            else
              ESX.ShowNotification("There aren't enough police online.")
            end
          end)
        end
      end
    end
  end
end

function MFS:MissionStart()
  local plyPed = GetPlayerPed(-1)
  local pPos = GetEntityCoords(plyPed)
  local tPos = self.MissionStarted
  local distToDropoff = CalculateTravelDistanceBetweenPoints(tPos.x,tPos.y,tPos.z, pPos.x,pPos.y,pPos.z)
  while not distToDropoff or (distToDropoff >= 10000 or distToDropoff <= 1000) do distToDropoff = CalculateTravelDistanceBetweenPoints(tPos.x,tPos.y,tPos.z, pPos.x,pPos.y,pPos.z); pPos = GetEntityCoords(GetPlayerPed(-1)); Citizen.Wait(10); end
  local textTemplate = Utils.DrawTextTemplate()
  local prices = {}
  for k,v in pairs(self.DrugItems) do 
    prices[v] = math.floor(self.DrugPrices[v]*(math.random(100.0-self.MaxPriceVariance,100.0+self.MaxPriceVariance)/100.0))
  end
  textTemplate.x = 0.8
  textTemplate.y = 0.8
  local startTime = GetGameTimer()
  local startDist = distToDropoff
  local timer = ((startDist / 1000) * 60) * 1000
  local saleAvailable = true
  while ((GetGameTimer() - startTime) < math.floor(timer) and not self.MissionCompleted) or (self.MissionCompleted and distToDropoff < (self.DrawTextDist*2.0) and saleAvailable == true)  do
    Citizen.Wait(0)   
    plyPed = GetPlayerPed(-1)
    pPos = GetEntityCoords(plyPed)
    distToDropoff = Utils.GetVecDist(tPos,pPos)
    if not self.MissionCompleted then
      textTemplate.text = 'Time Remaining : '..math.floor((((startDist / 1000) * 60) * 1000 - (GetGameTimer() - startTime))/1000)..' seconds.'
      Utils.DrawText(textTemplate)
    end
    if distToDropoff < 50.0 then
      if not self.PedSpawned then
        local hash = GetHashKey(self.DealerPed)
        while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end
        self.PedSpawned = CreatePed(4, hash, tPos.x,tPos.y,tPos.z,tPos.w, true,true)
        SetEntityAsMissionEntity(self.PedSpawned,true,true)
        SetModelAsNoLongerNeeded(hash)
      end
      if distToDropoff < self.DrawTextDist then
        if not self.MissionCompleted then 
          startTime = 0
          self.MissionCompleted = true
          ESX.ShowNotification("You found the buyer!")
        end
        Utils.DrawText3D(tPos.x,tPos.y,tPos.z, "Press [~r~E~s~] to speak to the dealer.")
        if IsControlJustPressed(0,38) then
          --self:PoliceNotifyTimer(tPos)
          self:CheckForWitness()
          ESX.TriggerServerCallback('MF_DrugSales:GetDrugCount', function(counts)
            ESX.UI.Menu.CloseAll()
            local elements = {}
            for k,v in pairs(self.DrugItems) do 
              if v == currentDrug then
                drugPrice = prices[v]
                table.insert(elements, {label = k..' : $'..drugPrice, val = v, price = drugPrice})
              end
            end
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Drug_Dealer',
            { 
              title = "Drug Buyer", align = 'left', elements = elements 
            }, function(data,menu) 
                menu.close()
                local count = false
                local sellAmount = 0 
                if counts[data.current.val] > self.MaxSellPerDealer then
                  sellAmount = self.MaxSellPerDealer
                else
                  sellAmount = counts[data.current.val]
                end
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'How_Much', 
                {
                  title = "How much do you want to sell? [Max : "..sellAmount.."]"
                }, function(data2, menu2)
                    local quantity = tonumber(data2.value)

                    if quantity == nil then
                      ESX.ShowNotification("Invalid amount.")
                    else
                      if quantity > self.MaxSellPerDealer then
                        count = self.MaxSellPerDealer
                      else
                        count = quantity
                      end

                      if tonumber(count) > tonumber(counts[data.current.val]) then 
                        ESX.ShowNotification("You don't have that much "..data.current.label..".")
                      else 
                        menu2.close()
                        saleAvailable = false
                        ESX.ShowNotification("You sold "..tonumber(count).." "..data.current.label.." for $"..tonumber(count)*tonumber(data.current.price)..".")
                        TriggerServerEvent('MF_DrugSales:Sold',data.current.val,data.current.price,count)
                      end
                    end
                  end, function(data2, menu2)
                    menu2.close()
                end)
            end, function(data,menu)
              menu.close()
            end)
          end)
        end
      end
    end
  end
  
  if not self.MissionCompleted then
    ESX.ShowNotification("You ran out of time and the buyer left.")
    if self.PedSpawned then 
      --DeletePed(self.PedSpawned)
      TaskWanderStandard(self.PedSpawned, 10.0, 10)
      SetEntityAsMissionEntity(self.PedSpawned,false,false)
    end
    self.MissionCompleted = false 
    self.MissionStarted = false
    self.PedSpawned = false
  else
    ESX.ShowNotification("The dealer has left the spot.")
    if self.PedSpawned then 
      --DeletePed(self.PedSpawned)
      TaskWanderStandard(self.PedSpawned, 10.0, 10)
      SetEntityAsMissionEntity(self.PedSpawned,false,false)
    end
    self.MissionCompleted = false 
    self.MissionStarted = false
    self.PedSpawned = false
  end
end

function MFS:CheckForWitness()
  local pedWasReported = false

    Citizen.CreateThread(function()
      while not pedWasReported do
        local pedLoc, distance

        local playerPed = PlayerPedId()
        local playerLoc = GetEntityCoords(playerPed, false)
        local foundPed  = nil

        for ped in EnumeratePeds() do
          if DoesEntityExist(ped) then
            pedLoc   = GetEntityCoords(ped, false)
            distance = GetDistanceBetweenCoords(playerLoc.x, playerLoc.y, playerLoc.z, pedLoc.x, pedLoc.y, pedLoc.z)

            if playerPed ~= ped and distance < Config.CallCopsDistance then
              foundPed = ped
              break
            end
          end
        end

        if foundPed then
          print("PED FOUND! REPORTING TO POLICE!")
          pedWasReported = true
          TriggerServerEvent('MF_DrugSales:NotifyPolice')
          TaskTurnPedToFaceEntity(foundPed, playerPed, -1)
          Citizen.Wait(3000)
          TaskStartScenarioInPlace(foundPed, "WORLD_HUMAN_MOBILE_FILM_SHOCKING", 0, true)
        end

        Citizen.Wait(10000)
      end
    end)
end

function MFS:PoliceNotifyTimer(pos)
  Citizen.CreateThread(function(...)
    Citizen.Wait(self.PoliceNotifyCountdown * 60 * 1000)
    TriggerServerEvent('MF_DrugSales:NotifyPolice',pos)
    local nearStreet = GetStreetNameFromHashKey(GetStreetNameAtCoord(pos.x,pos.y,pos.z))
    ESX.ShowNotification("Police have been alerted of a drug deal nearby "..nearStreet..".")
  end)
end

function MFS:DoNotifyPolice(pos)
  Citizen.CreateThread(function(...)
    local timer = GetGameTimer()
    local street = GetStreetNameAtCoord(pos.x,pos.y,pos.z)
    local msg = ""
    if street then
      local nearStreet = GetStreetNameFromHashKey(street)
      msg = "Somebody reported suspicious activity at "..nearStreet..". [~g~LEFTALT~s~]"
    else
      msg = "Somebody reported suspicious activity. [~g~LEFTALT~s~]"
    end
    PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0)
    ESX.ShowAdvancedNotification('911 Call.', 'Drugs', msg, 'CHAR_CALL911', 7)

    local blip = AddBlipForRadius(pos.x,pos.y,pos.z, 100.0)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 1)
    SetBlipAlpha (blip, 128)
    while GetGameTimer() - timer < self.NotifyPoliceTimer * 1000 do
      if IsControlJustPressed(0, 19) then SetNewWaypoint(pos.x,pos.y); end
      Citizen.Wait(0)
    end
    RemoveBlip(blip)
  end)
end

function MFS:SetJob(job)
  local lastJob = self.PlayerData.job
  if lastJob.name == self.PoliceJobName and job.name ~= self.PoliceJobName then
    TriggerServerEvent('MF_DrugSales:RemoveCop')
    self.PlayerData.job = job
  elseif lastJob.name ~= self.PoliceJobName and job.name == self.PoliceJobName then
    TriggerServerEvent('MF_DrugSales:SetCop')
    self.PlayerData.job = job
  end
end

RegisterNetEvent('MF_DrugSales:DoNotify')
AddEventHandler('MF_DrugSales:DoNotify', function(pos) MFS:DoNotifyPolice(pos); end)

RegisterNetEvent('MF_DrugSales:SetHint')
AddEventHandler('MF_DrugSales:SetHint', function(hint)
  MFS.HintLocation = hint;
  if MFS.ShowBlip then MFS:DoBlips(); end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job) MFS:SetJob(job); end)

Citizen.CreateThread(function(...) MFS:Awake(...); end)