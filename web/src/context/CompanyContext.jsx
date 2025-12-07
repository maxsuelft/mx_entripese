import React, { createContext, useContext, useState, useEffect } from 'react';
import { api } from '../services/api';

const CompanyContext = createContext();

export function CompanyProvider({ children }) {
  const [selectedCompany, setSelectedCompany] = useState(null);
  const [companies, setCompanies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isAdmin, setIsAdmin] = useState(false);

  const loadCompanies = async () => {
    try {
      setLoading(true);
      const data = await api.getCompanies();
      setCompanies(data || []);
    } catch (error) {
      console.error('Erro ao carregar empresas:', error);
      setCompanies([]);
    } finally {
      setLoading(false);
    }
  };

  const checkAdmin = async () => {
    try {
      const result = await api.isAdmin();
      setIsAdmin(result.isAdmin || false);
    } catch (error) {
      setIsAdmin(false);
    }
  };

  useEffect(() => {
    loadCompanies();
    checkAdmin();
  }, []);

  const refreshCompanies = () => {
    loadCompanies();
  };

  return (
    <CompanyContext.Provider value={{
      selectedCompany,
      setSelectedCompany,
      companies,
      setCompanies,
      refreshCompanies,
      loading,
      isAdmin
    }}>
      {children}
    </CompanyContext.Provider>
  );
}

export function useCompany() {
  return useContext(CompanyContext);
}

