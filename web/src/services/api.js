// API Service - Comunicação com NUI callbacks
const resourceName = 'mx_enterprise';

export async function fetchNUI(endpoint, data = {}) {
  const response = await fetch(`https://${resourceName}/${endpoint}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });

  return response.json();
}

export const api = {
  getCompanies: () => fetchNUI('getCompanies'),
  getCompany: (companyId) => fetchNUI('getCompany', { companyId }),
  getMembers: (companyId) => fetchNUI('getMembers', { companyId }),
  getRoles: (companyId) => fetchNUI('getRoles', { companyId }),
  getStorage: (companyId) => fetchNUI('getStorage', { companyId }),
  getVault: (companyId) => fetchNUI('getVault', { companyId }),
  getBankBalance: (companyId) => fetchNUI('getBankBalance', { companyId }),
  getBankTransactions: (companyId, limit) => fetchNUI('getBankTransactions', { companyId, limit }),
  getShopItems: (companyId) => fetchNUI('getShopItems', { companyId }),
  getCrafts: (companyId) => fetchNUI('getCrafts', { companyId }),
  createCompany: (data) => fetchNUI('createCompany', data),
  updateCompany: (companyId, data) => fetchNUI('updateCompany', { companyId, ...data }),
  deleteCompany: (companyId) => fetchNUI('deleteCompany', { companyId }),
  isAdmin: () => fetchNUI('isAdmin'),
  getPlayerCoords: () => fetchNUI('getPlayerCoords'),
  addMember: (companyId, targetId, roleId) => fetchNUI('addMember', { companyId, targetId, roleId }),
  removeMember: (companyId, memberId) => fetchNUI('removeMember', { companyId, memberId }),
  addStorageItem: (companyId, item, amount) => fetchNUI('addStorageItem', { companyId, item, amount }),
  removeStorageItem: (companyId, item, amount) => fetchNUI('removeStorageItem', { companyId, item, amount }),
  depositMoney: (companyId, amount) => fetchNUI('depositMoney', { companyId, amount }),
  withdrawMoney: (companyId, amount) => fetchNUI('withdrawMoney', { companyId, amount }),
  buyShopItem: (companyId, itemId, amount) => fetchNUI('buyShopItem', { companyId, itemId, amount }),
  craftItem: (companyId, craftId, amount) => fetchNUI('craftItem', { companyId, craftId, amount }),
  getAvailableBlipSprites: () => fetchNUI('getAvailableBlipSprites'),
  getAvailableBlipColors: () => fetchNUI('getAvailableBlipColors'),
  closeShop: () => fetchNUI('closeShop'),
  showNotification: (message, type) => fetchNUI('showNotification', { message, type }),
};

