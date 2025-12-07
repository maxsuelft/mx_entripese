import React, { useState } from 'react';
import { useCompany } from '../context/CompanyContext';
import CreateCompanyModal from '../components/CreateCompanyModal';
import EditCompanyModal from '../components/EditCompanyModal';

const COMPANY_TYPES = {
  industry: 'Indústria',
  service: 'Serviço',
  commerce: 'Comércio',
  mixed: 'Misto'
};

export default function MainLayout() {
  const { selectedCompany, setSelectedCompany, companies, refreshCompanies, loading, isAdmin } = useCompany();
  const [activeTab, setActiveTab] = useState('overview');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);

  return (
    <div 
      className="flex text-white"
      style={{
        width: '900px',
        height: '600px',
        backgroundImage: 'url(img/bg.png)',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat',
        position: 'relative',
        overflow: 'hidden'
      }}
    >
      <div className="w-64 bg-gray-800 border-r border-gray-700 bg-opacity-90">
        <div className="p-4 border-b border-gray-700">
          <div className="flex justify-between items-center mb-2">
            <h2 className="text-xl font-bold">Empresas</h2>
            <button
              onClick={() => {
                fetch(`https://${GetParentResourceName()}/close`, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({})
                });
              }}
              className="text-2xl hover:text-red-400"
            >
              ×
            </button>
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="w-full px-4 py-2 bg-blue-500 hover:bg-blue-600 rounded text-white text-sm font-medium"
          >
            + Nova Empresa
          </button>
        </div>
        <div className="overflow-y-auto">
          {loading ? (
            <div className="p-4 text-center text-gray-400">
              Carregando empresas...
            </div>
          ) : companies.length === 0 ? (
            <div className="p-4 text-center text-gray-400">
              <p className="mb-2">Nenhuma empresa cadastrada</p>
              <p className="text-sm">Clique em "Nova Empresa" para começar</p>
            </div>
          ) : (
            companies.map(company => (
              <div
                key={company.id}
                onClick={() => setSelectedCompany(company)}
                className={`p-4 cursor-pointer hover:bg-gray-700 ${
                  selectedCompany?.id === company.id ? 'bg-gray-700 border-l-2 border-blue-500' : ''
                }`}
              >
                <div className="font-bold">{company.label || company.name}</div>
                <div className="text-sm text-gray-400">
                  {COMPANY_TYPES[company.type] || company.type}
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      <div className="flex-1 flex flex-col bg-gray-900">
        {selectedCompany ? (
          <>
            <div className="p-6 border-b border-gray-700">
              <div className="flex justify-between items-center mb-4">
                <h1 className="text-2xl font-bold text-white">{selectedCompany.label}</h1>
                {isAdmin && (
                  <button
                    onClick={() => setShowEditModal(true)}
                    className="px-4 py-2 bg-yellow-600 hover:bg-yellow-700 rounded text-white text-sm"
                  >
                    Editar (Admin)
                  </button>
                )}
              </div>
              <div className="flex gap-2 flex-wrap">
                {['overview', 'members', 'roles', 'storage', 'vault', 'bank', 'shop', 'craft'].map(tab => (
                  <button
                    key={tab}
                    onClick={() => setActiveTab(tab)}
                    className={`px-4 py-2 rounded text-white ${
                      activeTab === tab ? 'bg-blue-500' : 'bg-gray-700 hover:bg-gray-600'
                    }`}
                  >
                    {tab.charAt(0).toUpperCase() + tab.slice(1)}
                  </button>
                ))}
              </div>
            </div>
            <div className="flex-1 overflow-y-auto p-6">
              <div className="bg-gray-800 rounded p-4 text-white">
                <p>Conteúdo da aba: {activeTab}</p>
              </div>
            </div>
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center">
            <div className="text-center text-white">
              <h2 className="text-2xl font-bold mb-4">Sistema de Empresas</h2>
              <p className="text-gray-400 mb-4">
                {loading ? 'Carregando...' : companies.length === 0 ? 'Nenhuma empresa cadastrada' : 'Selecione uma empresa da lista ao lado'}
              </p>
              {isAdmin && (
                <p className="text-sm text-gray-500">Modo Administrador Ativo</p>
              )}
            </div>
          </div>
        )}
      </div>

      <CreateCompanyModal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
        onSuccess={() => {
          refreshCompanies?.();
        }}
        isAdmin={isAdmin}
      />

      <EditCompanyModal
        isOpen={showEditModal}
        onClose={() => setShowEditModal(false)}
        onSuccess={() => {
          refreshCompanies?.();
          setSelectedCompany(null);
        }}
        company={selectedCompany}
        isAdmin={isAdmin}
      />
    </div>
  );
}

function GetParentResourceName() {
  return 'mx_enterprise';
}
