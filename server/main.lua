-- ============================================
-- mx_enterprise - SERVER MAIN
-- Inicialização e criação de tabelas
-- ============================================

CreateThread(function()
    Wait(1000)
    print('^2[mx_enterprise]^7 Sistema de Empresas carregado!')
    
    -- Criar todas as tabelas
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS companies (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(100) NOT NULL,
          label VARCHAR(120) NOT NULL,
          type ENUM('industry','service','commerce','mixed') DEFAULT 'mixed',
          blip_x FLOAT NULL,
          blip_y FLOAT NULL,
          blip_z FLOAT NULL,
          blip_enabled TINYINT(1) DEFAULT 0,
          blip_sprite VARCHAR(100) NULL,
          blip_color VARCHAR(50) NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          meta JSON DEFAULT NULL
        )
    ]])
    
    -- Adicionar colunas de blip se não existirem (migração)
    MySQL.query([[
        ALTER TABLE companies 
        ADD COLUMN IF NOT EXISTS blip_x FLOAT NULL,
        ADD COLUMN IF NOT EXISTS blip_y FLOAT NULL,
        ADD COLUMN IF NOT EXISTS blip_z FLOAT NULL,
        ADD COLUMN IF NOT EXISTS blip_enabled TINYINT(1) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS blip_sprite VARCHAR(100) NULL,
        ADD COLUMN IF NOT EXISTS blip_color VARCHAR(50) NULL
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_roles (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          name VARCHAR(100) NOT NULL,
          salary INT DEFAULT 0,
          permissions JSON DEFAULT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE KEY uk_role (company_id, name),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_user (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          identifier VARCHAR(100) NOT NULL,
          role_id INT NULL,
          is_owner TINYINT(1) DEFAULT 0,
          is_manager TINYINT(1) DEFAULT 0,
          status ENUM('active','suspended','left') DEFAULT 'active',
          joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          last_seen_at TIMESTAMP NULL,
          meta JSON DEFAULT NULL,
          UNIQUE KEY uk_company_user (company_id, identifier),
          INDEX idx_identifier (identifier),
          INDEX idx_company (company_id),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
          FOREIGN KEY (role_id) REFERENCES company_roles(id) ON DELETE SET NULL
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_storage (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          item VARCHAR(100) NOT NULL,
          amount INT DEFAULT 0,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          UNIQUE KEY uk_storage (company_id, item),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_vault (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          item VARCHAR(100) NOT NULL,
          amount INT DEFAULT 0,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          UNIQUE KEY uk_vault (company_id, item),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_bank (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          balance INT DEFAULT 0,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          UNIQUE KEY uk_bank (company_id),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_bank_transactions (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          identifier VARCHAR(100) NULL,
          type ENUM('deposit','withdraw','payroll','purchase','sale','fee') NOT NULL,
          amount INT NOT NULL,
          note VARCHAR(255) NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_shop (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          item VARCHAR(100) NOT NULL,
          price INT NOT NULL,
          stock INT DEFAULT 0,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          UNIQUE KEY uk_company_shop (company_id, item),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS company_craft (
          id INT AUTO_INCREMENT PRIMARY KEY,
          company_id INT NOT NULL,
          result_item VARCHAR(100) NOT NULL,
          result_amount INT NOT NULL DEFAULT 1,
          recipe JSON NOT NULL,
          craft_time INT DEFAULT 5,
          UNIQUE KEY uk_company_craft (company_id, result_item),
          FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE
        )
    ]])
    
    print('^2[mx_enterprise]^7 Tabelas do banco de dados verificadas!')
end)

-- Server Callbacks para a NUI (usando lib.callback)
lib.callback.register('mx_enterprise:getCompanies', function(source)
    local result = MySQL.query.await('SELECT * FROM companies ORDER BY name ASC')
    return result or {}
end)

lib.callback.register('mx_enterprise:getMembers', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_user WHERE company_id = ? AND status = "active"', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:getBank', function(source, companyId)
    local balance = MySQL.single.await('SELECT balance FROM company_bank WHERE company_id = ?', {companyId})
    local transactions = MySQL.query.await('SELECT * FROM company_bank_transactions WHERE company_id = ? ORDER BY created_at DESC LIMIT 50', {companyId})
    return {
        balance = balance and balance.balance or 0,
        transactions = transactions or {}
    }
end)

lib.callback.register('mx_enterprise:getStorage', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_storage WHERE company_id = ?', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:getCrafts', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_craft WHERE company_id = ?', {companyId})
    return result or {}
end)

lib.callback.register('mx_enterprise:getShop', function(source, companyId)
    local result = MySQL.query.await('SELECT * FROM company_shop WHERE company_id = ?', {companyId})
    return result or {}
end)

-- Callback para listar sprites de blips disponíveis do RedM
lib.callback.register('mx_enterprise:getAvailableBlipSprites', function(source)
    -- Lista completa de sprites do RedM organizados por categoria
    return {
        -- Ambientais
        { sprite = 'blip_ambient_coach', name = 'Diligência', hash = 1012165077 },
        { sprite = 'blip_ambient_herd', name = 'Rebanho', hash = 423351566 },
        { sprite = 'blip_ambient_hitching_post', name = 'Poste de Amarrar', hash = 1220803671 },
        { sprite = 'blip_ambient_horse', name = 'Cavalo', hash = -643888085 },
        { sprite = 'blip_ambient_loan_shark', name = 'Aguarista', hash = 1838354131 },
        { sprite = 'blip_ambient_newspaper', name = 'Jornal', hash = 587827268 },
        { sprite = 'blip_ambient_quartermaster', name = 'Intendente', hash = 249721687 },
        { sprite = 'blip_ambient_riverboat', name = 'Barco Fluvial', hash = 2033397166 },
        { sprite = 'blip_ambient_telegraph', name = 'Telégrafo', hash = 503049244 },
        { sprite = 'blip_ambient_sheriff', name = 'Xerife', hash = -693644997 },
        { sprite = 'blip_ambient_theatre', name = 'Teatro', hash = -417940443 },
        { sprite = 'blip_ambient_tithing', name = 'Dízimo', hash = -1954662204 },
        { sprite = 'blip_ambient_train', name = 'Trem', hash = -250506368 },
        { sprite = 'blip_ambient_wagon', name = 'Carroça', hash = 874255393 },
        { sprite = 'blip_ambient_warp', name = 'Teletransporte', hash = 784218150 },
        
        -- Animais
        { sprite = 'blip_animal', name = 'Animal', hash = -1646261997 },
        { sprite = 'blip_animal_skin', name = 'Pele de Animal', hash = 218395012 },
        
        -- Serviços
        { sprite = 'blip_bath_house', name = 'Casa de Banho', hash = -304640465 },
        { sprite = 'blip_post_office', name = 'Correios', hash = 1861010125 },
        { sprite = 'blip_post_office_rec', name = 'Correios (Recebido)', hash = 1475382911 },
        { sprite = 'blip_proc_bank', name = 'Banco', hash = -2128054417 },
        { sprite = 'blip_saloon', name = 'Salão', hash = 1879260108 },
        { sprite = 'blip_stable', name = 'Estábulo', hash = -73168905 },
        { sprite = 'blip_taxidermist', name = 'Taxidermista', hash = -1733535731 },
        
        -- Lojas
        { sprite = 'blip_shop_animal_trapper', name = 'Loja de Armadilhas', hash = -1406874050 },
        { sprite = 'blip_shop_barber', name = 'Barbearia', hash = -2090472724 },
        { sprite = 'blip_shop_blacksmith', name = 'Ferreiro', hash = -758970771 },
        { sprite = 'blip_shop_butcher', name = 'Açougue', hash = -1665418949 },
        { sprite = 'blip_shop_coach_fencing', name = 'Loja de Cercas', hash = -1989306548 },
        { sprite = 'blip_shop_doctor', name = 'Médico', hash = -1739686743 },
        { sprite = 'blip_shop_gunsmith', name = 'Armeiro', hash = -145868367 },
        { sprite = 'blip_shop_horse', name = 'Loja de Cavalos', hash = 1938782895 },
        { sprite = 'blip_shop_horse_fencing', name = 'Loja de Cercas (Cavalos)', hash = -1456209806 },
        { sprite = 'blip_shop_horse_saddle', name = 'Loja de Selas', hash = 469827317 },
        { sprite = 'blip_shop_market_stall', name = 'Barraca de Mercado', hash = 819673798 },
        { sprite = 'blip_shop_shady_store', name = 'Loja Suspeita', hash = 531267562 },
        { sprite = 'blip_shop_store', name = 'Loja', hash = 1475879922 },
        { sprite = 'blip_shop_tackle', name = 'Loja de Pesca', hash = -852241114 },
        { sprite = 'blip_shop_tailor', name = 'Alfaiate', hash = 1195729388 },
        { sprite = 'blip_shop_train', name = 'Loja de Trem', hash = 103490298 },
        { sprite = 'blip_shop_trainer', name = 'Treinador', hash = 1542275196 },
        
        -- Acampamentos
        { sprite = 'blip_camp_tent', name = 'Tenda de Acampamento', hash = -910004446 },
        { sprite = 'blip_campfire', name = 'Fogueira', hash = 1754365229 },
        { sprite = 'blip_campfire_full', name = 'Fogueira Completa', hash = 773587962 },
        { sprite = 'blip_region_caravan', name = 'Caravana', hash = -1606321000 },
        { sprite = 'blip_region_hideout', name = 'Esconderijo', hash = -428972082 },
        
        -- Itens e Objetos
        { sprite = 'blip_canoe', name = 'Canoa', hash = 62421675 },
        { sprite = 'blip_cash_bag', name = 'Saco de Dinheiro', hash = 688589278 },
        { sprite = 'blip_chest', name = 'Baú', hash = -1138864184 },
        { sprite = 'blip_grub', name = 'Comida', hash = 935247438 },
        { sprite = 'blip_hotel_bed', name = 'Cama de Hotel', hash = -211556852 },
        { sprite = 'blip_plant', name = 'Planta', hash = -675651933 },
        { sprite = 'blip_saddle', name = 'Sela', hash = -1327110633 },
        { sprite = 'blip_weapon', name = 'Arma', hash = 549686661 },
        { sprite = 'blip_weapon_bow', name = 'Arco', hash = -132369645 },
        { sprite = 'blip_weapon_cannon', name = 'Canhão', hash = -363516712 },
        
        -- Suprimentos
        { sprite = 'blip_supplies_ammo', name = 'Suprimentos: Munição', hash = 1576459965 },
        { sprite = 'blip_supplies_food', name = 'Suprimentos: Comida', hash = -1852063472 },
        { sprite = 'blip_supplies_health', name = 'Suprimentos: Saúde', hash = -695368421 },
        { sprite = 'blip_supply_icon_ammo', name = 'Ícone: Munição', hash = 1378990590 },
        { sprite = 'blip_supply_icon_food', name = 'Ícone: Comida', hash = 412928073 },
        { sprite = 'blip_supply_icon_health', name = 'Ícone: Saúde', hash = -924021303 },
        
        -- Eventos e Especiais
        { sprite = 'blip_donate_food', name = 'Doar Comida', hash = -1236018085 },
        { sprite = 'blip_event_appleseed', name = 'Evento: Appleseed', hash = 1904459580 },
        { sprite = 'blip_event_castor', name = 'Evento: Castor', hash = -1989725258 },
        { sprite = 'blip_event_railroad_camp', name = 'Evento: Acampamento Ferroviário', hash = -487631996 },
        { sprite = 'blip_event_riggs_camp', name = 'Evento: Acampamento Riggs', hash = -1944395098 },
        { sprite = 'blip_fence_building', name = 'Construção de Cerca', hash = -1179229323 },
        { sprite = 'blip_mg_poker', name = 'Pôquer', hash = 1243830185 },
        { sprite = 'blip_photo_studio', name = 'Estúdio Fotográfico', hash = 1364029453 },
        { sprite = 'blip_poi', name = 'Ponto de Interesse', hash = -2039778370 },
        { sprite = 'blip_player', name = 'Jogador', hash = -523921054 },
        { sprite = 'blip_player_coach', name = 'Diligência do Jogador', hash = -361388975 },
        { sprite = 'blip_proc_home', name = 'Casa', hash = 1586273744 },
        { sprite = 'blip_proc_home_locked', name = 'Casa (Trancada)', hash = -1498696713 },
        
        -- Verão (Summer)
        { sprite = 'blip_summer_cow', name = 'Vaca (Verão)', hash = 1078668923 },
        { sprite = 'blip_summer_feed', name = 'Alimentação (Verão)', hash = 669307703 },
        { sprite = 'blip_summer_guard', name = 'Guarda (Verão)', hash = -1735903728 },
        { sprite = 'blip_summer_horse', name = 'Cavalo (Verão)', hash = 552659337 }
    }
end)

-- Callback para listar cores disponíveis
lib.callback.register('mx_enterprise:getAvailableBlipColors', function(source)
    -- Cores disponíveis no jo_libs
    return {
        'WHITE',
        'RED',
        'GREEN',
        'BLUE',
        'YELLOW',
        'ORANGE',
        'PURPLE',
        'PINK',
        'LIGHT_BLUE',
        'LIGHT_GREEN',
        'LIGHT_RED',
        'BLACK'
    }
end)
