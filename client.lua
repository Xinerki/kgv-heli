local function Notification(text,duration)
    Citizen.CreateThread(function()
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        local Notification = DrawNotification(false, false)
        Citizen.Wait(duration)
        RemoveNotification(Notification)
    end)
end

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < -180 and t + 180 or t
end

helipads = { -- not yet
	-- vector2(-540.97, -901.46),
}


heliModel = `maverick`
pedModel = `s_m_m_pilot_01`

RegisterCommand("heli", function(source, args)
	Citizen.CreateThread(function()
		RequestModel(heliModel)
		repeat Wait(0) until HasModelLoaded(heliModel)
		RequestModel(pedModel)
		repeat Wait(0) until HasModelLoaded(pedModel)
		
		local playerCoords = GetEntityCoords(PlayerPedId())
		local x, y, z = table.unpack(playerCoords)
		
		local heli = CreateVehicle(heliModel, x, y, 500.0, 0.0, true, true)
		local ped = CreatePedInsideVehicle(heli, 4, pedModel, -1, true, true)
		SetHeliBladesFullSpeed(heli)
		TaskSetBlockingOfNonTemporaryEvents(ped, true)
		
		
		SwitchOutPlayer(PlayerPedId(), 0, 1)
		
		repeat Wait(0) until GetPlayerSwitchState() == 5 -- COMPLETELY IN THE SKY
		Wait(1500)
		
		SetPedIntoVehicle(PlayerPedId(), heli, 2)
		
		SwitchInPlayer(PlayerPedId())
		
		repeat Wait(0) until GetPlayerSwitchState() == 10 -- LAST STAGE, BASICALLY DONE
		
		repeat Wait(1500)
		
			if IsWaypointActive() then
				local waypoint = GetFirstBlipInfoId(8)
				local x, y, z = table.unpack(GetBlipCoords(waypoint))
				local x1, y1, z1 = table.unpack(GetEntityCoords(heli))
				TaskHeliMission(ped, heli, 0, 0, x, y, 100.0, 9, 50.0, 0.0, findRotation(x, y, x1, y1), -1, -1, -1, 0)
			end
			
		until GetVehiclePedIsIn(PlayerPedId(), 1) ~= heli
		
	end)
end)