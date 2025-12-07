Locales = {}

Locales['pt-br'] = {
    ['company'] = 'Empresa',
    ['companies'] = 'Empresas',
    ['no_companies'] = 'Você não faz parte de nenhuma empresa',
    ['company_created'] = 'Empresa criada com sucesso!',
    ['company_created_error'] = 'Erro ao criar empresa',
    ['member_added'] = 'Membro adicionado com sucesso!',
    ['member_removed'] = 'Membro removido com sucesso!',
    ['item_added_storage'] = 'Item adicionado ao armazém!',
    ['item_removed_storage'] = 'Item removido do armazém!',
    ['item_added_vault'] = 'Item adicionado ao baú!',
    ['item_removed_vault'] = 'Item removido do baú!',
    ['money_deposited'] = 'Dinheiro depositado com sucesso!',
    ['money_withdrawn'] = 'Dinheiro sacado com sucesso!',
    ['item_purchased'] = 'Item comprado com sucesso!',
    ['item_crafted'] = 'Item craftado com sucesso!',
    ['no_permission'] = 'Sem permissão',
    ['not_member'] = 'Você não é membro desta empresa',
    ['insufficient_balance'] = 'Saldo insuficiente',
    ['insufficient_items'] = 'Itens insuficientes',
    ['inventory_full'] = 'Inventário cheio',
    ['invalid_value'] = 'Valor inválido',
    ['identifier_not_found'] = 'Identifier não encontrado',
}

Locales['en'] = {
    ['company'] = 'Company',
    ['companies'] = 'Companies',
    ['no_companies'] = 'You are not part of any company',
    ['company_created'] = 'Company created successfully!',
    ['company_created_error'] = 'Error creating company',
    ['member_added'] = 'Member added successfully!',
    ['member_removed'] = 'Member removed successfully!',
    ['item_added_storage'] = 'Item added to storage!',
    ['item_removed_storage'] = 'Item removed from storage!',
    ['item_added_vault'] = 'Item added to vault!',
    ['item_removed_vault'] = 'Item removed from vault!',
    ['money_deposited'] = 'Money deposited successfully!',
    ['money_withdrawn'] = 'Money withdrawn successfully!',
    ['item_purchased'] = 'Item purchased successfully!',
    ['item_crafted'] = 'Item crafted successfully!',
    ['no_permission'] = 'No permission',
    ['not_member'] = 'You are not a member of this company',
    ['insufficient_balance'] = 'Insufficient balance',
    ['insufficient_items'] = 'Insufficient items',
    ['inventory_full'] = 'Inventory full',
    ['invalid_value'] = 'Invalid value',
    ['identifier_not_found'] = 'Identifier not found',
}

function Locales.Get(key)
    local locale = Config.locale or 'pt-br'
    return Locales[locale] and Locales[locale][key] or key
end

