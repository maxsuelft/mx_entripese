-- ============================================
-- SHOP.LUA - Loja da Empresa
-- ============================================

lib.callback.register('mx_enterprise:getShopItems', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_shop WHERE company_id = ?', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:addShopItem', function(source, companyId, item, price, stock)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não tem permissão'
    end
    
    local exists = MySQL.single.await('SELECT id FROM company_shop WHERE company_id = ? AND item = ?', {companyId, item})
    if exists then
        return false, 'Item já está na loja'
    end
    
    local result = MySQL.insert.await('INSERT INTO company_shop (company_id, item, price, stock) VALUES (?, ?, ?, ?)', {companyId, item, price, stock})
    
    if result then
        return true
    end
    
    return false, 'Erro ao adicionar item'
end)

lib.callback.register('mx_enterprise:removeShopItem', function(source, companyId, itemId)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não tem permissão'
    end
    
    MySQL.update.await('DELETE FROM company_shop WHERE id = ? AND company_id = ?', {itemId, companyId})
    
    return true
end)

lib.callback.register('mx_enterprise:updateShopItem', function(source, companyId, itemId, price, stock)
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não tem permissão'
    end
    
    MySQL.update.await('UPDATE company_shop SET price = ?, stock = ? WHERE id = ? AND company_id = ?', {price, stock, itemId, companyId})
    
    return true
end)

lib.callback.register('mx_enterprise:buyItem', function(source, companyId, itemId, amount, totalPrice)
    if amount <= 0 then
        return false, 'Quantidade inválida'
    end
    
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local shopItem = MySQL.single.await('SELECT * FROM company_shop WHERE id = ? AND company_id = ?', {itemId, companyId})
    if not shopItem or shopItem.stock < amount then
        return false, 'Item fora de estoque'
    end
    
    -- Aqui você poderia adicionar uma lógica de pagamento
    -- Por exemplo, retirar dinheiro do jogador ou de sua conta
    
    MySQL.update.await('UPDATE company_shop SET stock = stock - ? WHERE id = ?', {amount, itemId})
    
    TriggerClientEvent('mx_enterprise:shopUpdated', -1, companyId)
    
    return true
end)
