-- ============================================
-- NUI.LUA - NUI Callbacks
-- ============================================

-- Callback NUI - Fechar
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb('ok')
end)

-- Callbacks de dados
RegisterNUICallback('getCompanies', function(data, cb)
    lib.callback('mx_enterprise:getCompanies', false, function(companies)
        cb(companies)
    end)
end)

RegisterNUICallback('getCompany', function(data, cb)
    lib.callback('mx_enterprise:getCompany', false, function(company)
        cb(company)
    end, data.companyId)
end)

RegisterNUICallback('getMembers', function(data, cb)
    lib.callback('mx_enterprise:getMembers', false, function(members)
        cb(members)
    end, data.companyId)
end)

RegisterNUICallback('getRoles', function(data, cb)
    lib.callback('mx_enterprise:getRoles', false, function(roles)
        cb(roles)
    end, data.companyId)
end)

RegisterNUICallback('getStorage', function(data, cb)
    lib.callback('mx_enterprise:getStorage', false, function(storage)
        cb(storage)
    end, data.companyId)
end)

RegisterNUICallback('getBankBalance', function(data, cb)
    lib.callback('mx_enterprise:getBankBalance', false, function(balance)
        cb(balance)
    end, data.companyId)
end)

RegisterNUICallback('getBankTransactions', function(data, cb)
    lib.callback('mx_enterprise:getBankTransactions', false, function(transactions)
        cb(transactions)
    end, data.companyId, data.limit)
end)

RegisterNUICallback('getShopItems', function(data, cb)
    lib.callback('mx_enterprise:getShopItems', false, function(items)
        cb(items)
    end, data.companyId)
end)

RegisterNUICallback('getCrafts', function(data, cb)
    lib.callback('mx_enterprise:getCrafts', false, function(crafts)
        cb(crafts)
    end, data.companyId)
end)

-- Ações NUI
RegisterNUICallback('createCompany', function(data, cb)
    lib.callback('mx_enterprise:createCompany', false, function(success, message)
        if success then
            TriggerEvent('mx_enterprise:showNotification', Locales.Get('company_created'), 'success')
        else
            TriggerEvent('mx_enterprise:showNotification', message or Locales.Get('company_created_error'), 'error')
        end
        cb({ success = success, message = message })
    end, data)
end)

RegisterNUICallback('addMember', function(data, cb)
    lib.callback('mx_enterprise:addMember', false, function(success, message)
        if success then
            TriggerEvent('mx_enterprise:showNotification', Locales.Get('member_added'), 'success')
        else
            TriggerEvent('mx_enterprise:showNotification', message or 'Erro ao adicionar membro', 'error')
        end
        cb({ success = success, message = message })
    end, data.companyId, data.targetId, data.roleId)
end)

RegisterNUICallback('removeMember', function(data, cb)
    lib.callback('mx_enterprise:removeMember', false, function(success, message)
        if success then
            TriggerEvent('mx_enterprise:showNotification', Locales.Get('member_removed'), 'success')
        else
            TriggerEvent('mx_enterprise:showNotification', message or 'Erro ao remover membro', 'error')
        end
        cb({ success = success, message = message })
    end, data.companyId, data.memberId)
end)

RegisterNUICallback('depositMoney', function(data, cb)
    lib.callback('mx_enterprise:depositMoney', false, function(success, message)
        if success then
            TriggerEvent('mx_enterprise:showNotification', Locales.Get('money_deposited'), 'success')
        else
            TriggerEvent('mx_enterprise:showNotification', message or 'Erro ao depositar dinheiro', 'error')
        end
        cb({ success = success, message = message })
    end, data.companyId, data.amount)
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    lib.callback('mx_enterprise:withdrawMoney', false, function(success, message)
        if success then
            TriggerEvent('mx_enterprise:showNotification', Locales.Get('money_withdrawn'), 'success')
        else
            TriggerEvent('mx_enterprise:showNotification', message or 'Erro ao sacar dinheiro', 'error')
        end
        cb({ success = success, message = message })
    end, data.companyId, data.amount)
end)

RegisterNUICallback('craftItem', function(data, cb)
    lib.callback('mx_enterprise:craftItem', false, function(success, message)
        if success then
            TriggerEvent('mx_enterprise:showNotification', message or Locales.Get('item_crafted'), 'success')
        else
            TriggerEvent('mx_enterprise:showNotification', message or 'Erro ao craftar item', 'error')
        end
        cb({ success = success, message = message })
    end, data.companyId, data.craftId, data.amount)
end)

RegisterNUICallback('isAdmin', function(data, cb)
    lib.callback('mx_enterprise:isAdmin', false, function(isAdmin)
        cb({ isAdmin = isAdmin })
    end)
end)

RegisterNUICallback('updateCompany', function(data, cb)
    lib.callback('mx_enterprise:updateCompany', false, function(success, message)
        if success then
            TriggerEvent('mx_enterprise:showNotification', 'Empresa atualizada com sucesso', 'success')
        else
            TriggerEvent('mx_enterprise:showNotification', message or 'Erro ao atualizar empresa', 'error')
        end
        cb({ success = success, message = message })
    end, data.companyId, data)
end)

RegisterNUICallback('deleteCompany', function(data, cb)
    lib.callback('mx_enterprise:deleteCompany', false, function(success, message)
        if success then
            TriggerEvent('mx_enterprise:showNotification', 'Empresa deletada com sucesso', 'success')
        else
            TriggerEvent('mx_enterprise:showNotification', message or 'Erro ao deletar empresa', 'error')
        end
        cb({ success = success, message = message })
    end, data.companyId)
end)

RegisterNUICallback('getPlayerCoords', function(data, cb)
    local coords = GetEntityCoords(PlayerPedId())
    cb({ x = coords.x, y = coords.y, z = coords.z })
end)

RegisterNUICallback('getAvailableBlipSprites', function(data, cb)
    lib.callback('mx_enterprise:getAvailableBlipSprites', false, function(sprites)
        cb(sprites)
    end)
end)

RegisterNUICallback('getAvailableBlipColors', function(data, cb)
    lib.callback('mx_enterprise:getAvailableBlipColors', false, function(colors)
        cb(colors)
    end)
end)

RegisterNUICallback('closeShop', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Callback para mostrar notificações in-game
RegisterNUICallback('showNotification', function(data, cb)
    if data and data.message then
        -- Usar ox_lib para mostrar notificações
        local type = data.type or 'info'
        if lib and lib.notify then
            lib.notify({
                title = 'MX Enterprise',
                description = data.message,
                type = type,
                duration = 5000
            })
        else
            -- Fallback
            TriggerEvent('mx_enterprise:showNotification', 'MX Enterprise', data.message, type)
        end
    end
    cb('ok')
end)
