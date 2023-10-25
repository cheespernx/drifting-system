local QBCore = exports['qb-core']:GetCoreObject()

local isPlayerDrifting = false

local haveTyres = 0
local haveDifferential = 0
local haveSteerKit = 0

function saveOriginalCarState(vehicle, type)
  local plate = QBCore.Functions.GetPlate(vehicle)
  local originalState = {}

  for key, _value in pairs(Config.TyresModification) do
    originalState[key] = GetVehicleHandlingFloat(vehicle, "CHandlingData", key)
  end
  for key, _value in pairs(Config.DifferentialModifications) do
    originalState[key] = GetVehicleHandlingFloat(vehicle, "CHandlingData", key)
  end
  for key, _value in pairs(Config.AngleKitModifications) do
    originalState[key] = GetVehicleHandlingFloat(vehicle, "CHandlingData", key)
  end

  TriggerServerEvent("arc-drifting-system:server:UpdateCarInDB", type, json.encode(originalState), plate)
end

function restoreOriginalCarState(vehicle)
  local plate = QBCore.Functions.GetPlate(vehicle)
  QBCore.Functions.TriggerCallback('arc-drifting-system:server:GetVehicleFromDB', function(handling)
    if #handling > 0 then
      local originalState = json.decode(handling[1].original_handling)
      haveTyres = handling[1].tyres
      haveDifferential = handling[1].differential
      haveSteerKit = handling[1].steer_kit
      resetTyresWear(vehicle)
      for key, value in pairs(originalState) do
        SetVehicleHandlingField(vehicle, "CHandlingData", key, value)
      end
    end
  end, plate)
end

function angle(veh)
  if not veh then return false end
  local vx, vy, vz = table.unpack(GetEntityVelocity(veh))
  local modV = math.sqrt(vx * vx + vy * vy)

  local rx, ry, rz = table.unpack(GetEntityRotation(veh, 0))
  local sn, cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))

  if GetEntitySpeed(veh) * 3.6 < 30 or GetVehicleCurrentGear(veh) == 0 then return 0, modV end

  local cosX = (sn * vx + cs * vy) / modV
  if cosX > 0.966 or cosX < 0 then return 0, modV end
  return math.deg(math.acos(cosX)) * 0.5, modV
end

function resetTyresWear(vehicle) 
  SetTyreWearMultiplier(vehicle, 0, Config.Tyres.Wear.Normal)
  SetTyreWearMultiplier(vehicle, 1, Config.Tyres.Wear.Normal)
  SetTyreWearMultiplier(vehicle, 4, Config.Tyres.Wear.Normal)
  SetTyreWearMultiplier(vehicle, 5, Config.Tyres.Wear.Normal)
end

function setMinimunHealthTyre(vehicle) 
  SetTyreHealth(vehicle, 1, Config.Tyres.Health.Min)
  SetTyreHealth(vehicle, 2, Config.Tyres.Health.Min)
  SetTyreHealth(vehicle, 4, Config.Tyres.Health.Min)
  SetTyreHealth(vehicle, 5, Config.Tyres.Health.Min)
end

function getTyresHealth(vehicle)
  if Config.Use4Tyres then
    return math.min(math.floor(GetTyreHealth(vehicle, 1)), math.floor(GetTyreHealth(vehicle, 2)), math.floor(GetTyreHealth(vehicle, 4)), math.floor(GetTyreHealth(vehicle, 5)))
  else
    return math.min(math.floor(GetTyreHealth(vehicle, 4)), math.floor(GetTyreHealth(vehicle, 5)))
  end
end

function setHealthTyre(vehicle, health) 
  SetTyreHealth(vehicle, 1, health)
  SetTyreHealth(vehicle, 2, health)
  SetTyreHealth(vehicle, 4, health)
  SetTyreHealth(vehicle, 5, health)
end

function resetTyresHealth(vehicle) 
  SetTyreHealth(vehicle, 0, Config.Tyres.Health.Max)
  SetTyreHealth(vehicle, 1, Config.Tyres.Health.Max)
  SetTyreHealth(vehicle, 4, Config.Tyres.Health.Max)
  SetTyreHealth(vehicle, 5, Config.Tyres.Health.Max)
end

function setTyresWear(vehicle, multiply)
  SetTyreWearMultiplier(vehicle, 0, multiply)
  SetTyreWearMultiplier(vehicle, 1, multiply)
  SetTyreWearMultiplier(vehicle, 4, multiply)
  SetTyreWearMultiplier(vehicle, 5, multiply)
end

function setTyresModifications(vehicle)
  for key, value in pairs(Config.TyresModification) do
    SetVehicleHandlingField(vehicle, "CHandlingData", key, value)
  end
end

function setDifferentialModifications(vehicle)
  for key, value in pairs(Config.DifferentialModifications) do
    SetVehicleHandlingField(vehicle, "CHandlingData", key, value)
  end
end

function setAngleKitModifications(vehicle)
  for key, value in pairs(Config.AngleKitModifications) do
    SetVehicleHandlingField(vehicle, "CHandlingData", key, value)
  end
end

RegisterKeyMapping(Config.Bind.Command, Config.Bind.Description, 'keyboard', Config.Bind.Key)

RegisterCommand(Config.Bind.Command, function()
  local ped = PlayerPedId()
  local progressInfo = "Ativando modo drift"
  if isPlayerDrifting then
    progressInfo = "Desativando modo drift"
  else
    progressInfo = "Ativando modo drift"
  end

  if IsPedInAnyVehicle(ped, false) then
    QBCore.Functions.Progressbar("activating", progressInfo, Config.Timers.ActivateDriftMode, false, true, {
      disableMovement = true,
      disableCarMovement = true,
      disableMouse = false,
      disableCombat = true
    }, {}, {}, {}, function()
      local vehicle = GetVehiclePedIsIn(ped, false)
      local plate = QBCore.Functions.GetPlate(vehicle)
      if isPlayerDrifting then
        local tyreHealth = getTyresHealth(vehicle)
        TriggerServerEvent("arc-drifting-system:server:UpdateWearCarInDB", tyreHealth, plate)
        restoreOriginalCarState(vehicle)
        isPlayerDrifting = false
        if Config.Debug then
          print("Modo Drift Desativado!")
        end
        QBCore.Functions.Notify("Modo Drift Desativado!", 'success')
      else
        QBCore.Functions.TriggerCallback('arc-drifting-system:server:GetVehicleFromDB', function(vehicleData)
          if #vehicleData > 0 then
            if vehicleData[1].tyres == 1 or vehicleData[1].differential == 1 or vehicleData[1].steer_kit == 1 then
              setHealthTyre(vehicle, vehicleData[1].wear + .0)

              setTyresWear(vehicle, Config.Tyres.Wear.Drift)
              if Config.Debug then
                print("Desgaste aplicado: "..getTyresHealth(vehicle))
              end
              isPlayerDrifting = true
              if Config.Debug then
                print("Modo Drift Ativado!")
              end
              QBCore.Functions.Notify("Modo Drift Ativado!", 'success')
            end
            if vehicleData[1].tyres == 1 then
              haveTyres = vehicleData[1].tyres
              setTyresModifications(vehicle)
            end
            if vehicleData[1].differential == 1 then
              haveDifferential = vehicleData[1].differential
              setDifferentialModifications(vehicle)
            end
            if vehicleData[1].steer_kit == 1 then
              haveSteerKit = vehicleData[1].steer_kit
              setAngleKitModifications(vehicle)
            end
          else
            QBCore.Functions.Notify("O Carro precisa de preparação. Vá até uma mecânica.", 'error')
          end
        end, plate)
      end
    end, function()
      StopAnimTask(ped, "amb@world_human_vehicle_mechanic@male@base", "idle_a", 1.0)
      QBCore.Functions.Notify("Cancelado", "error")
    end)
  end
end, false)

RegisterNetEvent("arc-drifting-system:client:InstallComponent", function(component)
  local ped = PlayerPedId()
  if not IsPedInAnyVehicle(ped, false) then
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(vehicle)
    local progressInfo = component.Label
    QBCore.Functions.Progressbar("install_drift_components", "Instalando "..progressInfo, Config.Timers.ComponentInstall, false, true, {
      disableMovement = true,
      disableCarMovement = true,
      disableMouse = false,
      disableCombat = true
    }, {
      animDict = "mini@repair",
		  anim = "fixing_a_ped",
		  flags = 49,
    }, {}, {}, function() -- Done        
      if vehicle then
        QBCore.Functions.TriggerCallback('arc-drifting-system:server:GetVehicleFromDB', function(result)
          if #result > 0 then
            if component.ItemName == Config.Items.DriftingTyres.ItemName then
              if result[1].tyres == 1 then
                haveTyres = result[1].tyres
                resetTyresWear(vehicle)
                resetTyresHealth(vehicle)
                QBCore.Functions.Notify("Você trocou o jogo de pneus.", 'success')
                return false
              else
                TriggerServerEvent("arc-drifting-system:server:UpdateCarInDB", "tyres", 1, plate)
                haveTyres = result[1].tyres
                QBCore.Functions.Notify("Você instalou pneus de drift.", 'success')
              end
            elseif component.ItemName == Config.Items.Differential.ItemName then
              if result[1].differential == 1 then
                haveDifferential = result[1].differential
                QBCore.Functions.Notify("O carro já possui diferencial instalado", 'error')
                return false
              else
                TriggerServerEvent("arc-drifting-system:server:UpdateCarInDB", "differential", 1, plate)
                haveDifferential = result[1].differential
                QBCore.Functions.Notify("Você instalou um diferencial.", 'success')
              end
            elseif component.ItemName == Config.Items.SteerKit.ItemName then
              if result[1].steer_kit == 1 then
                haveSteerKit = result[1].steer_kit
                QBCore.Functions.Notify("O carro já possui kit ângulo instalado", 'error')
                return false
              else
                TriggerServerEvent("arc-drifting-system:server:UpdateCarInDB", "steer_kit", 1, plate)
                haveSteerKit = result[1].steer_kit
                QBCore.Functions.Notify("Você instalou um kit ângulo.", 'success')
              end
            end
          else
            if component.ItemName == Config.Items.DriftingTyres.ItemName then
              TriggerServerEvent("arc-drifting-system:server:SaveCarToDB", plate, 1, 0, 0, 1000)
              saveOriginalCarState(vehicle, "original_handling")
              resetTyresHealth(vehicle)
              haveTyres = 1
              QBCore.Functions.Notify("Você instalou um kit de pneus de drift!", 'success')
            elseif component.ItemName == Config.Items.Differential.ItemName then
              TriggerServerEvent("arc-drifting-system:server:SaveCarToDB", plate, 0, 1, 0, 1000)
              saveOriginalCarState(vehicle, "original_handling")
              haveDifferential = 1
              QBCore.Functions.Notify("Você instalou um diferencial blocante!", 'success')
            elseif component.ItemName == Config.Items.SteerKit.ItemName then
              TriggerServerEvent("arc-drifting-system:server:SaveCarToDB", plate, 0, 0, 1, 1000)
              saveOriginalCarState(vehicle, "original_handling")
              haveSteerKit = 1
              QBCore.Functions.Notify("Você instalou um kit ângulo!", 'success')
            end
          end
        end, plate)
      end
    end, function() -- Cancel
      StopAnimTask(ped, "amb@world_human_vehicle_mechanic@male@base", "idle_a", 1.0)
      QBCore.Functions.Notify("Cancelado", "error")
    end)
  else
    QBCore.Functions.Notify("Você precisa estar fora do veículo.", "error")
  end
end)

CreateThread(function()
  while true do
    if isPlayerDrifting then
      local ped = PlayerPedId()
      if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local angle, velocity = angle(vehicle)
        if vehicle and angle ~= 0 then
          local wheelWear = getTyresHealth(vehicle) / 10
          if Config.Debug then
            print("Desgaste: "..wheelWear.."%")
          end
          if wheelWear == 60 then
            QBCore.Functions.Notify("Os pneus estão gastos.", 'error')
          elseif wheelWear == 40 then
            QBCore.Functions.Notify("Os pneus estão muito gastos. Risco de estourar!!!", 'error')
          end
          if wheelWear <= 100 and wheelWear >= 61 then
            setTyresWear(vehicle, Config.Tyres.Wear.Drift)
            if haveTyres == 1 then
              SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", Config.WearPartsHandling.Full.fLowSpeedTractionLossMult)
            end
            if haveSteerKit == 1 then
              SetVehicleHandlingField(vehicle, "CHandlingData", "fSteeringLock", Config.WearPartsHandling.Full.fSteeringLock)
            end
          elseif wheelWear <= 60 and wheelWear >= 51 then
            if haveTyres == 1 then
              SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", Config.WearPartsHandling.Half.fLowSpeedTractionLossMult)
            end
            if haveSteerKit == 1 then
              SetVehicleHandlingField(vehicle, "CHandlingData", "fSteeringLock", Config.WearPartsHandling.Half.fSteeringLock)
            end
          elseif wheelWear <= 50 then
            if Config.Debug then
              print("Os pneus: ")
            end
            if haveTyres == 1 then
              SetVehicleHandlingField(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", Config.WearPartsHandling.Low.fLowSpeedTractionLossMult)
            end
            if haveSteerKit == 1 then
              SetVehicleHandlingField(vehicle, "CHandlingData", "fSteeringLock", Config.WearPartsHandling.Low.fSteeringLock)
            end
          end
          TriggerEvent('hud:client:UpdateWheelWear', wheelWear)
        end
      end
    end
    Wait(500)
  end
end)
