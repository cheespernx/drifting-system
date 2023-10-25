local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem(Config.Items.DriftingTyres.ItemName, function(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
  local ItemData = Player.Functions.GetItemByName(item.name)
	if not ItemData then return end
  if Player.Functions.RemoveItem(Config.Items.DriftingTyres.ItemName, Config.Items.DriftingTyres.Quantity) then
    TriggerClientEvent("arc-drifting-system:client:InstallComponent", source, {
      ItemName = Config.Items.DriftingTyres.ItemName,
      Label = ItemData.label
    })
  else
    TriggerClientEvent('QBCore:Notify', source, "Você precisa de "..Config.Items.DriftingTyres.Quantity.."x - "..ItemData.label, 'error', 5000)
  end
end)

QBCore.Functions.CreateUseableItem(Config.Items.Differential.ItemName, function(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
	local ItemData = Player.Functions.GetItemByName(item.name)
	if not ItemData then return end
  if Player.Functions.RemoveItem(Config.Items.Differential.ItemName, Config.Items.Differential.Quantity) then
    TriggerClientEvent("arc-drifting-system:client:InstallComponent", source, {
      ItemName = Config.Items.Differential.ItemName,
      Label = ItemData.label
    })
  else
    TriggerClientEvent('QBCore:Notify', source, "Você precisa de "..Config.Items.Differential.Quantity.."x - "..ItemData.label, 'error', 5000)
  end
end)

QBCore.Functions.CreateUseableItem(Config.Items.SteerKit.ItemName, function(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
  local ItemData = Player.Functions.GetItemByName(item.name)
	if not ItemData then return end
  if Player.Functions.RemoveItem(Config.Items.SteerKit.ItemName, Config.Items.SteerKit.Quantity) then
    TriggerClientEvent("arc-drifting-system:client:InstallComponent", source, {
      ItemName = Config.Items.SteerKit.ItemName,
      Label = ItemData.label
    })
  else
    TriggerClientEvent('QBCore:Notify', source, "Você precisa de "..Config.Items.SteerKit.Quantity.."x - "..ItemData.label, 'error', 5000)
  end
end)

RegisterNetEvent("arc-drifting-system:server:SaveCarToDB", function(plate, tyres, differential, steer_kit, wear)
  MySQL.insert('INSERT INTO drifting (`plate`, `tyres`, `differential`, `steer_kit`, `wear`) VALUES (?, ?, ?, ?, ?)', { plate, tyres, differential, steer_kit, wear })
end)

RegisterNetEvent("arc-drifting-system:server:UpdateCarInDB", function(property, value, plate)
  MySQL.update('UPDATE drifting SET `'..property..'` = ? WHERE plate = ?', { value, plate })
end)

RegisterNetEvent("arc-drifting-system:server:UpdateWearCarInDB", function(wear, plate)
  MySQL.update('UPDATE drifting SET wear = ? WHERE plate = ?', { wear, plate })
end)

QBCore.Functions.CreateCallback('arc-drifting-system:server:GetVehicleFromDB', function(_, cb, plate)
  local result = MySQL.query.await('SELECT * FROM drifting WHERE plate = ?', { plate })
  cb(result)
end)