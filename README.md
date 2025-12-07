# mx_enterprise - Sistema de Empresas para RedM

Sistema completo de gerenciamento de empresas para servidores RedM usando VORPCore.

## 📁 Estrutura

```
mx_enterprise/
│
├─ fxmanifest.lua
│
├─ server/
│  ├─ main.lua           -- Inicialização
│  ├─ company.lua        -- CRUD empresa
│  ├─ bank.lua           -- depósito / saque
│  ├─ storage.lua        -- armazém / baú
│  ├─ members.lua        -- membros / cargos
│  ├─ salary.lua         -- salários / pagamento
│  ├─ craft.lua          -- craft e receitas
│  └─ shop.lua           -- loja empresa
│
├─ client/
│  ├─ main.lua           -- Inicialização
│  ├─ zones.lua          -- markers / interação
│  ├─ nui.lua            -- NUI callbacks
│  ├─ ui_open.lua        -- teclas / abertura painel
│  ├─ animations.lua     -- animações
│  └─ notifications.lua   -- notificações
│
├─ shared/
│  ├─ config.lua         -- configs gerais
│  └─ locales.lua        -- tradução
│
├─ web/                  -- NUI
│  ├─ dist/              -- build final (minificado)
│  └─ src/               -- React + Tailwind
│     ├─ components/
│     ├─ pages/
│     ├─ hooks/
│     ├─ context/
│     ├─ services/        -- fetch → postMessage
│     └─ index.jsx
│
├─ database/
│  └─ schema.sql
│
├─ assets/
│  ├─ images/
│  └─ icons/
│
└─ scripts/
   └─ update-fxmanifest.js
```

## 🚀 Instalação

1. Execute o SQL: `database/schema.sql`
2. Adicione ao `server.cfg`:
   ```
   ensure mx_enterprise
   ```
3. Configure: Edite `config.json`

## 🛠️ Desenvolvimento

### Modo Development
```bash
cd web
npm install
npm run dev
```

O script `update-fxmanifest.js` automaticamente altera o `ui_page` para `web/shim.html` em modo dev.

### Modo Production
```bash
cd web
npm run build
```

O build será gerado em `web/dist/` e o `fxmanifest.lua` será atualizado para usar `web/dist/index.html`.

## 📦 Dependências

- `oxmysql` - Banco de dados
- `vorp_inventory` - Sistema de inventário
- `ox_lib` - Biblioteca core

## 🎮 Comandos

- `/empresa` - Abrir interface de empresas

## ⚙️ Configuração

Edite `config.json` para personalizar:
- Permissões
- Tipos de empresa
- Configurações de salário
- Limites de armazém
- Configurações de banco
- Configurações de craft e loja

## 🔒 Segurança

- **Server.lua**: Toda lógica crítica (dinheiro, inventário, craft) está no servidor
- **Client.lua**: Apenas visualização e interação
- **Validação**: Todas as ações são validadas no servidor antes de executar

## 📝 Notas

- Adapte as funções de dinheiro em `server/bank.lua` e `server/shop.lua` para seu framework
- O sistema usa callbacks do `ox_lib` para comunicação cliente-servidor
- A interface React usa Tailwind CSS para estilização
