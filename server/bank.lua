-- ============================================
-- BANK.LUA - Depósito e Saque
-- ============================================

lib.callback.register('mx_enterprise:getBankBalance', function(source, companyId)
    local result = MySQL.single.await('SELECT balance FROM company_bank WHERE company_id = ?', {companyId})
    return result and result.balance or 0
end)

lib.callback.register('mx_enterprise:depositMoney', function(source, companyId, amount)
    if amount <= 0 then
        return false, 'Valor inválido'
    end
    
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não é membro da empresa'
    end
    
    local balance = MySQL.single.await('SELECT balance FROM company_bank WHERE company_id = ?', {companyId})
    if not balance then
        MySQL.insert.await('INSERT INTO company_bank (company_id, balance) VALUES (?, ?)', {companyId, amount})
    else
        MySQL.update.await('UPDATE company_bank SET balance = balance + ? WHERE company_id = ?', {amount, companyId})
    end
    
    MySQL.insert.await('INSERT INTO company_bank_transactions (company_id, identifier, type, amount, note) VALUES (?, ?, "deposit", ?, ?)', {companyId, identifier, amount, 'Depósito'})
    
    TriggerClientEvent('mx_enterprise:bankUpdated', -1, companyId)
    
    return true
end)

lib.callback.register('mx_enterprise:withdrawMoney', function(source, companyId, amount)
    if amount <= 0 then
        return false, 'Valor inválido'
    end
    
    local identifier = Utils.GetIdentifier(source)
    if not identifier then
        return false, 'Identificador não encontrado'
    end
    
    local member = MySQL.single.await('SELECT * FROM company_user WHERE company_id = ? AND identifier = ? AND (is_owner = 1 OR is_manager = 1) AND status = "active"', {companyId, identifier})
    if not member then
        return false, 'Você não tem permissão'
    end
    
    local balance = MySQL.single.await('SELECT balance FROM company_bank WHERE company_id = ?', {companyId})
    if not balance or balance.balance < amount then
        return false, 'Saldo insuficiente'
    end
    
    MySQL.update.await('UPDATE company_bank SET balance = balance - ? WHERE company_id = ?', {amount, companyId})
    
    MySQL.insert.await('INSERT INTO company_bank_transactions (company_id, identifier, type, amount, note) VALUES (?, ?, "withdraw", ?, ?)', {companyId, identifier, amount, 'Saque'})
    
    TriggerClientEvent('mx_enterprise:bankUpdated', -1, companyId)
    
    return true
end)

lib.callback.register('mx_enterprise:getBankTransactions', function(source, companyId, limit)
    local result = MySQL.query.await('SELECT * FROM company_bank_transactions WHERE company_id = ? ORDER BY created_at DESC LIMIT ?', {companyId, limit or 50})
    return result or {}
end)
