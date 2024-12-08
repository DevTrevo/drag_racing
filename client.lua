local raceActive = false
local countdownActive = false
local burnoutCountdownActive = false
local countdownTime = 30
local burnoutCountdownTime = 10 -- Ajustado para 20 segundos
local currentCheckpoint = 1
local startTime = nil
local raceFinished = false
local canRestart = false -- Controle de reinício

local checkpoints = {
    {x = 1531.43, y = 3204.23, z = 39.99}, -- Início da corrida
    {x = 1409.0, y = 3171.1, z = 39.99}, -- Checkpoints intermediários
    {x = 1150.5, y = 3102.53, z = 39.74} -- Final da corrida
}

local startRaceMarker = {x = 1531.43, y = 3204.23, z = 39.99} -- Local do marcador de início

-- Função para desenhar texto na tela
local function drawText(text, x, y, scale, color)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- Atualiza o status da corrida e a contagem regressiva
RegisterNetEvent('race:start')
AddEventHandler('race:start', function()
    raceActive = false
    countdownActive = true
    burnoutCountdownActive = false
    raceFinished = false
    canRestart = false
    currentCheckpoint = 1
    startTime = GetGameTimer()
    SetNewWaypoint(checkpoints[currentCheckpoint].x, checkpoints[currentCheckpoint].y)
end)

RegisterNetEvent('race:stop')
AddEventHandler('race:stop', function()
    raceActive = false
    countdownActive = false
    burnoutCountdownActive = false
    raceFinished = false
    canRestart = false
    currentCheckpoint = 1
    ClearGpsPlayerWaypoint()
end)

RegisterNetEvent('race:finished')
AddEventHandler('race:finished', function(time)
    raceActive = false
    countdownActive = false
    burnoutCountdownActive = false
    raceFinished = true
    canRestart = true
    currentCheckpoint = 1
    ClearGpsPlayerWaypoint()

    -- Exibir tempo da corrida na tela em milissegundos
    local raceTimeMs = GetGameTimer() - startTime
    local seconds = math.floor(raceTimeMs / 1000)
    local milliseconds = raceTimeMs % 1000
    
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"Corrida", string.format("Você terminou a corrida em %d segundos e %d milissegundos!", seconds, milliseconds)}
    })

    -- Exibir tempo da corrida na tela
    Citizen.CreateThread(function()
        local endTime = GetGameTimer()
        local displayTime = endTime + 10000
        while GetGameTimer() < displayTime do
            Citizen.Wait(0)
            drawText(string.format("Tempo da Corrida: %d segundos e %d milissegundos", seconds, milliseconds), 0.5, 0.5, 0.5, {255, 255, 255, 255})
        end
    end)
end)

-- Evento para informar que a corrida pode ser reiniciada
RegisterNetEvent('race:canRestart')
AddEventHandler('race:canRestart', function()
    canRestart = true
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleCoords = GetEntityCoords(vehicle)

        -- Desenhar o marcador de início da corrida
        DrawMarker(1, startRaceMarker.x, startRaceMarker.y, startRaceMarker.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)

        if #(playerCoords - vector3(startRaceMarker.x, startRaceMarker.y, startRaceMarker.z)) < 3.0 then
            SetTextComponentFormat('STRING')
            AddTextComponentString("Pressione ~INPUT_CONTEXT~ para iniciar a corrida")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustPressed(1, 51) then -- 51 é a tecla E
                if not countdownActive and not raceActive and not raceFinished then
                    TriggerServerEvent('race:start')
                elseif raceFinished and canRestart then
                    -- Verificar se o carro está no local do blip
                    if #(vehicleCoords - vector3(startRaceMarker.x, startRaceMarker.y, startRaceMarker.z)) < 5.0 then
                        TriggerServerEvent('race:restart')
                    else
                        TriggerEvent('chat:addMessage', {
                            color = {255, 0, 0},
                            multiline = true,
                            args = {"Corrida", "Coloque o carro no local do blip para reiniciar a corrida!"}
                        })
                    end
                end
            end
        end

        -- Mostrar contagem regressiva para "Frite os Pneus"
        if countdownActive then
            local elapsed = (GetGameTimer() - startTime) / 1000.0
            local remaining = countdownTime - math.floor(elapsed)
            if remaining > 0 then
                drawText(string.format("Aqueça os Penus para mais aderencia  em %d segundos", remaining), 0.5, 0.5, 0.5, {255, 0, 0, 255})
            else
                countdownActive = false
                burnoutCountdownActive = true
                startTime = GetGameTimer()
            end
        end

        -- Mostrar contagem regressiva para a arrancada
        if burnoutCountdownActive then
            local elapsed = (GetGameTimer() - startTime) / 1000.0
            local remaining = burnoutCountdownTime - math.floor(elapsed)
            if remaining > 0 then
                drawText(string.format("Preparar para a arrancada em %d segundos", remaining), 0.5, 0.5, 0.5, {255, 0, 0, 255})
            else
                burnoutCountdownActive = false
                raceActive = true
                startTime = GetGameTimer()
                TriggerEvent('chat:addMessage', { args = { "A corrida começou!" } })
                ClearGpsPlayerWaypoint()
            end
        end

        -- Monitorar progresso da corrida
        if raceActive then
            local checkpoint = checkpoints[currentCheckpoint]
            if #(playerCoords - vector3(checkpoint.x, checkpoint.y, checkpoint.z)) < 10.0 then
                TriggerServerEvent('race:checkpoint', currentCheckpoint)
                currentCheckpoint = currentCheckpoint + 1
                if currentCheckpoint <= #checkpoints then
                    SetNewWaypoint(checkpoints[currentCheckpoint].x, checkpoints[currentCheckpoint].y)
                else
                    raceActive = false
                    local raceTimeMs = GetGameTimer() - startTime
                    TriggerServerEvent('race:finished', raceTimeMs)
                end
            end
        end

        -- Permite reiniciar a corrida pressionando F5 se todas as condições estiverem atendidas
        if IsControlJustPressed(1, 166) then -- 166 é a tecla F5
            if raceFinished and canRestart then
                if #(vehicleCoords - vector3(startRaceMarker.x, startRaceMarker.y, startRaceMarker.z)) < 5.0 then
                    TriggerServerEvent('race:restart')
                else
                    TriggerEvent('chat:addMessage', {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"Corrida", "Coloque o carro no local do blip para reiniciar a corrida!"}
                    })
                end
            end
        end
    end
end)

-- Monitoramento da velocidade do veículo e envio de checkpoints
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local speed = GetEntitySpeed(vehicle) * (Config.useImperial and 2.23694 or 3.6) -- Converte a velocidade para km/h ou mph

        -- Verifica se o jogador está em um checkpoint de velocidade
        for i, checkpoint in ipairs(Config.times) do
            if speed >= checkpoint.speed then
                TriggerServerEvent('drag:race:checkpoint', i)
            end
        end

        -- Verifica a distância percorrida (opcional)
        -- Adapte de acordo com a lógica de distâncias do seu sistema
    end
end)





