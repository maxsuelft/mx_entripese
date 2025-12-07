-- ============================================
-- STORAGE.LUA - Armazém e Baú
-- ============================================

lib.callback.register('mx_enterprise:getStorage', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_storage WHERE company_id = ?', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:addToStorage', function(source, companyId, item, amount)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não é membro da empresa'
    end
    
    local exists = MySQL.single.await('SELECT * FROM company_storage WHERE company_id = ? AND item = ?', {companyId, item})
    if exists then
        MySQL.update.await('UPDATE company_storage SET amount = amount + ? WHERE company_id = ? AND item = ?', {amount, companyId, item})
    else
        MySQL.insert.await('INSERT INTO company_storage (company_id, item, amount) VALUES (?, ?, ?)', {companyId, item, amount})
    end
    
    TriggerClientEvent('mx_enterprise:storageUpdated', -1, companyId)
    
    return true
end)

lib.callback.register('mx_enterprise:removeFromStorage', function(source, companyId, item, amount)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não tem permissão'
    end
    
    local storage = MySQL.single.await('SELECT amount FROM company_storage WHERE company_id = ? AND item = ?', {companyId, item})
    if not storage or storage.amount < amount then
        return false, 'Quantidade insuficiente'
    end
    
    if storage.amount == amount then
        MySQL.update.await('DELETE FROM company_storage WHERE company_id = ? AND item = ?', {companyId, item})
    else
        MySQL.update.await('UPDATE company_storage SET amount = amount - ? WHERE company_id = ? AND item = ?', {amount, companyId, item})
    end
    
    TriggerClientEvent('mx_enterprise:storageUpdated', -1, companyId)
    
    return true
end)
