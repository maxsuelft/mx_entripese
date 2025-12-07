-- ============================================
-- CRAFT.LUA - Craft e Receitas
-- ============================================

lib.callback.register('mx_enterprise:getCrafts', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_craft WHERE company_id = ?', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:addCraft', function(source, companyId, data)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não tem permissão'
    end
    
    local result = MySQL.insert.await('INSERT INTO company_craft (company_id, result_item, result_amount, recipe, craft_time) VALUES (?, ?, ?, ?, ?)', {
        companyId,
        data.result_item,
        data.result_amount or 1,
        json.encode(data.recipe or {}),
        data.craft_time or 5
    })
    
    if result then
        return true, result
    end
    
    return false, 'Erro ao adicionar receita'
end)

lib.callback.register('mx_enterprise:removeCraft', function(source, companyId, craftId)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não tem permissão'
    end
    
    MySQL.update.await('DELETE FROM company_craft WHERE id = ? AND company_id = ?', {craftId, companyId})
    
    return true
end)

lib.callback.register('mx_enterprise:craftItem', function(source, companyId, craftId, amount)
    if amount <= 0 then
        return false, 'Quantidade inválida'
    end
    
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não é membro da empresa'
    end
    
    local craft = MySQL.single.await('SELECT * FROM company_craft WHERE id = ? AND company_id = ?', {craftId, companyId})
    if not craft then
        return false, 'Receita não encontrada'
    end
    
    local recipe = json.decode(craft.recipe or '{}')
    
    -- Verificar se temos todos os itens necessários
    for item, qty in pairs(recipe) do
        local storage = MySQL.single.await('SELECT amount FROM company_storage WHERE company_id = ? AND item = ?', {companyId, item})
        if not storage or storage.amount < (qty * amount) then
            return false, 'Ingredientes insuficientes para: ' .. item
        end
    end
    
    -- Remover ingredientes
    for item, qty in pairs(recipe) do
        MySQL.update.await('UPDATE company_storage SET amount = amount - ? WHERE company_id = ? AND item = ?', {qty * amount, companyId, item})
    end
    
    -- Adicionar resultado
    local resultItem = craft.result_item
    local resultAmount = craft.result_amount * amount
    local exists = MySQL.single.await('SELECT * FROM company_storage WHERE company_id = ? AND item = ?', {companyId, resultItem})
    if exists then
        MySQL.update.await('UPDATE company_storage SET amount = amount + ? WHERE company_id = ? AND item = ?', {resultAmount, companyId, resultItem})
    else
        MySQL.insert.await('INSERT INTO company_storage (company_id, item, amount) VALUES (?, ?, ?)', {companyId, resultItem, resultAmount})
    end
    
    TriggerClientEvent('mx_enterprise:craftComplete', -1, companyId, resultItem, resultAmount)
    
    return true
end)
