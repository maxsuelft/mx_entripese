import { useState, useEffect } from 'react';
import { api } from '../services/api';

export function useCompanyData(companyId) {
  const [data, setData] = useState({
    members: [],
    roles: [],
    storage: [],
    vault: [],
    bankBalance: 0,
    transactions: [],
    shopItems: [],
    crafts: []
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!companyId) return;

    const loadData = async () => {
      setLoading(true);
      try {
        const [members, roles, storage, vault, bankBalance, transactions, shopItems, crafts] = await Promise.all([
          api.getMembers(companyId),
          api.getRoles(companyId),
          api.getStorage(companyId),
          api.getVault(companyId),
          api.getBankBalance(companyId),
          api.getBankTransactions(companyId, 50),
          api.getShopItems(companyId),
          api.getCrafts(companyId)
        ]);

        setData({
          members,
          roles,
          storage,
          vault,
          bankBalance,
          transactions,
          shopItems,
          crafts
        });
      } catch (error) {
        console.error('Error loading company data:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [companyId]);

  return { data, loading };
}

