-- ============================================
-- CLIENT MAIN - Inicialização e Comandos
-- ============================================

local isMenuOpen = false

print('^2[mx_enterprise]^7 Client carregado!')

-- Comando para abrir o painel de administração
RegisterCommand('adminempresa', function(source, args, rawCommand)
    if isMenuOpen then return end
    
    isMenuOpen = true
    
    -- Abrir a NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openPanel'
    })
end, false)

-- Fechar o painel
RegisterNUICallback('closePanel', function(data, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb('ok')
end)

-- Evento para atualizar blips
RegisterNetEvent('mx_enterprise:refreshBlips', function()
    -- Recarregar blips se necessário
end)

-- Evento de banco atualizado
RegisterNetEvent('mx_enterprise:bankUpdated', function(companyId)
    -- Notificar cliente
end)

-- Evento de armazenamento atualizado
RegisterNetEvent('mx_enterprise:storageUpdated', function(companyId)
    -- Notificar cliente
end)

-- Evento de craft completo
RegisterNetEvent('mx_enterprise:craftComplete', function(companyId, item, amount)
    -- Notificar cliente
end)

-- Evento de loja atualizada
RegisterNetEvent('mx_enterprise:shopUpdated', function(companyId)
    -- Notificar cliente
end)

-- Evento de membro adicionado
RegisterNetEvent('mx_enterprise:memberAdded', function(companyId, identifier)
    -- Notificar cliente
end)

-- Evento de membro removido
RegisterNetEvent('mx_enterprise:memberRemoved', function(companyId, memberId)
    -- Notificar cliente
end)