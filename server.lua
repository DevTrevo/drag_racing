local raceActive = false
local currentCheckpoint = 1
local startTime = nil
local playersInRace = {}
local checkpoints = {
    {x = 1531.43, y = 3204.23, z = 39.99}, -- Início da corrida
    {x = 1409.0, y = 3171.1, z = 39.99}, -- Checkpoints do meio
    {x = 1150.5, y = 3102.53, z = 39.74} -- Final da corrida
}

-- Função para reiniciar a corrida
local function restartRace()
    raceActive = false
    currentCheckpoint = 1
    playersInRace = {}
    TriggerClientEvent('race:stop', -1)
end

RegisterNetEvent('race:start')
AddEventHandler('race:start', function()
    local source = source
    if not raceActive then
        raceActive = true
        startTime = os.time()
        playersInRace[source] = {checkpoint = 1, startTime = startTime}
        TriggerClientEvent('race:start', -1, checkpoints)
    end
end)

RegisterNetEvent('race:checkpoint')
AddEventHandler('race:checkpoint', function(checkpointIndex)
    local source = source
    if raceActive and playersInRace[source] and playersInRace[source].checkpoint == checkpointIndex then
        playersInRace[source].checkpoint = checkpointIndex + 1
        if checkpointIndex == #checkpoints then
            local endTime = os.time()
            local raceTime = endTime - playersInRace[source].startTime
            TriggerClientEvent('race:finished', source, raceTime)
            playersInRace[source] = nil

            -- Verifica se todos os jogadores terminaram
            local allFinished = true
            for _, player in pairs(playersInRace) do
                if player then
                    allFinished = false
                    break
                end
            end

            -- Não reinicia automaticamente, apenas marca a corrida como não ativa
            if allFinished then
                raceActive = false
                TriggerClientEvent('race:canRestart', -1) -- Notifica todos os clientes que a corrida pode ser reiniciada
            end
        end
    end
end)

RegisterNetEvent('race:stop')
AddEventHandler('race:stop', function()
    raceActive = false
    currentCheckpoint = 1
    playersInRace = {}
    TriggerClientEvent('race:stop', -1)
end)

RegisterNetEvent('race:restart')
AddEventHandler('race:restart', function()
    local source = source
    local playerPed = GetPlayerPed(source)
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleCoords = GetEntityCoords(playerVehicle)
    
    -- Verifica se o veículo está no local do blip
    if #(vehicleCoords - vector3(checkpoints[1].x, checkpoints[1].y, checkpoints[1].z)) < 5.0 then
        restartRace() -- Reinicia a corrida
        Citizen.Wait(5000) -- Espera 5 segundos antes de reiniciar a corrida
        TriggerClientEvent('race:start', -1, checkpoints) -- Inicia uma nova corrida
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Corrida", "Coloque o carro no local do blip para reiniciar a corrida!"}
        })
    end
end)

-- Salvar tempo da corrida no banco de dados
local oxmysql = exports.oxmysql

RegisterNetEvent('drag_racing:saveRaceTime')
AddEventHandler('drag_racing:saveRaceTime', function(time)
    local playerId = source
    local identifier = GetPlayerIdentifier(playerId, 0)  -- Usar o primeiro identificador (geralmente Steam)
    
    -- Inserir tempo da corrida no banco de dados
    oxmysql:insert('INSERT INTO race_times (player_id, time) VALUES (?, ?)', {identifier, time}, function(insertedId)
        if insertedId then
            print("Tempo da corrida salvo com sucesso, ID: " .. insertedId)
        else
            print("Erro ao salvar o tempo da corrida no banco de dados.")
        end
    end)
end)
