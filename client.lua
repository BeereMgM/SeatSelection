local tiempo = 800

local function isMovementKeyPressed()
    return IsControlPressed(0, 32) or  -- W
           IsControlPressed(0, 34) or  -- A
           IsControlPressed(0, 33) or  -- S
           IsControlPressed(0, 35)     -- D
end

RegisterNUICallback("selectSeat", function(data, cb)
    SetNuiFocus(false, false)
    local seatIndex = tonumber(data.seat) - 2
    local vehicleNetId = data.vehicle

    if not vehicleNetId then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if DoesEntityExist(vehicle) then
        TriggerEvent('car_door:goIntoVehicle', seatIndex, vehicle)
    end
    cb("OK")
end)

RegisterNUICallback("closeUI", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        tiempo = 800
        
        local ped = PlayerPedId()
        local pco = GetEntityCoords(ped)
        local closestVehicle = nil
        local closestDist = 5.0

        for _, vehicle in ipairs(GetGamePool("CVehicle")) do
            local vehCoords = GetEntityCoords(vehicle)
            local dist = #(pco - vehCoords)

            if dist < closestDist then
                closestDist = dist
                closestVehicle = vehicle
            end
        end


        if closestVehicle and IsControlJustReleased(1, Config.KeyBind) then 
            local vehicleNetId = NetworkGetNetworkIdFromEntity(closestVehicle)
            local vehicleModel = GetEntityModel(closestVehicle)
            local modelName = GetDisplayNameFromVehicleModel(vehicleModel)
            local seats = GetVehicleModelNumberOfSeats(vehicleModel)
            local vehicleClass = GetVehicleClass(closestVehicle)

            SendNUIMessage({
                action = "openUI",
                seats = seats,
                vehicle = vehicleNetId
            })
            SetNuiFocus(true, true)
        end    
    end
end)

RegisterNetEvent('car_door:goIntoVehicle')
AddEventHandler('car_door:goIntoVehicle', function(seat, vehicle)
    local ped = PlayerPedId()

    if not DoesEntityExist(vehicle) then
        return
    end

    local doorPos = GetEntryPositionOfDoor(vehicle, seat+1)

    if doorPos then
        if IsPedInVehicle(ped, vehicle, false) then
            showNotification("You are already in a vehicle.")
            return
        end
        if not IsVehicleSeatFree(vehicle, seat) then
            
            local newSeat = (seat== 2 and 3) or (seat == 3 and 2) or seat
            seat = newSeat - 2
            showNotification("There is another person on the seat. Sitting yourself on another seat.")
            doorPos = GetEntryPositionOfDoor(vehicle, seat+1)
        end

        if doorPos then
            if doorPos == "tp" then
                SetPedIntoVehicle(ped, vehicle, seat)
            elseif doorPos == "straight" then
                local straightPos = straightCoords(vehicle, seat+1)
                TaskGoStraightToCoord(ped, straightPos.x, straightPos.y, straightPos.z+0.3, 1.0, -1, 180,0.5)
            else
                TaskGoToCoordAnyMeans(ped, doorPos.x, doorPos.y, doorPos.z+0.3, 1.0, 0, 0, 32, 0)
                local walking = true
                while walking == true do
                    Citizen.Wait(10)
                    local playerCoords = GetEntityCoords(ped)
                    local distance = GetDistanceBetweenCoords(doorPos.x, doorPos.y, doorPos.z+0.3, playerCoords.x, playerCoords.y, playerCoords.z, false)
                    if distance <= 1 then
                        walking = false
                    end
                    if isMovementKeyPressed() then
                        ClearPedTasks(ped)
                        walking = false
                        return
                    end
                end
            end

            TaskEnterVehicle(ped, vehicle, 10000, seat, 1.0, 1, 0)
            
        else
            TaskEnterVehicle(ped, vehicle, 10000, seat, 1.0, 1, 0)
        end
    end
end)


function GetEntryPositionOfDoor(vehicle, seat)
    if not DoesEntityExist(vehicle) then
        return nil
    end

    

    local leftDoor = {
        [0] = "door_dside_f",
        [2] = "door_dside_r" 
    }
    
    local rightDoor = {
        [1] = "door_pside_f",
        [3] = "door_pside_r" 
    }


    local vehicleClass = GetVehicleClass(vehicle)
    if vehicleClass == 17 then
        seat = 0
    end


    if vehicleClass == 15 or vehicleClass == 16 then
        if seat > 2 then
            return "tp"
        else
            return "straight"
        end
    end
    

    local bone = leftDoor[seat] or rightDoor[seat]
    if not bone then
        return nil
    end

    local boneIndex = GetEntityBoneIndexByName(vehicle, bone)
    if boneIndex == -1 then
        return nil
    end

    local doorPos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    return doorPos
end


function straightCoords(vehicle, seat)
    if not DoesEntityExist(vehicle) then
        return nil
    end

        

    local leftDoor = {
        [0] = "door_dside_f",
        [2] = "door_dside_r" 
    }
    
    local rightDoor = {
        [1] = "door_pside_f",
        [3] = "door_pside_r" 
    }

    local bone = leftDoor[seat] or rightDoor[seat]
    if not bone then
        return nil
    end

    local boneIndex = GetEntityBoneIndexByName(vehicle, bone)
    if boneIndex == -1 then
        return nil
    end

    local doorPos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    return doorPos
end



function showNotification(message, color, flash, saveToBrief)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    ThefeedNextPostBackgroundColor(color)
    EndTextCommandThefeedPostTicker(flash, saveToBrief)
end
