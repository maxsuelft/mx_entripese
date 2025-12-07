import React, { useState, useEffect, useCallback } from 'react';
import { CompanyProvider } from './context/CompanyContext';
import MainLayout from './pages/MainLayout';
import ShopModal from './components/ShopModal';

function App() {
  const [isOpen, setIsOpen] = useState(false);
  const [isShopOpen, setIsShopOpen] = useState(false);
  const [shopData, setShopData] = useState(null);

  const closeUI = useCallback(() => {
    setIsOpen(false);
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    }).catch(err => console.error('[mx_enterprise] Erro ao fechar:', err));
  }, []);

  const closeShop = useCallback(() => {
    setIsShopOpen(false);
    setShopData(null);
    fetch(`https://${GetParentResourceName()}/closeShop`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    }).catch(err => console.error('[mx_enterprise] Erro ao fechar loja:', err));
  }, []);

  useEffect(() => {
    const handleMessage = (event) => {
      const data = event.data;
      console.log('[mx_enterprise] NUI Message received:', data);
      console.log('[mx_enterprise] Action:', data?.action);
      
      if (data && data.action === 'open') {
        console.log('[mx_enterprise] Opening UI...');
        setIsOpen(true);
      } else if (data && data.action === 'close') {
        console.log('[mx_enterprise] Closing UI...');
        setIsOpen(false);
      } else if (data && data.action === 'openShop') {
        console.log('[mx_enterprise] Opening Shop...');
        setShopData({
          companyId: data.companyId,
          company: data.company,
          items: data.items
        });
        setIsShopOpen(true);
      } else if (data && data.action === 'notify') {
        // Tratar notificações (pode usar uma biblioteca de notificações se necessário)
        console.log('[mx_enterprise] Notification:', data.title, data.message, data.type);
        // Por enquanto, apenas logar. Você pode adicionar um sistema de notificações visual depois
      }
    };

    window.addEventListener('message', handleMessage);

    const handleKeyDown = (e) => {
      if (e.key === 'Escape') {
        if (isShopOpen) {
          closeShop();
        } else if (isOpen) {
          closeUI();
        }
      }
    };

    document.addEventListener('keydown', handleKeyDown);

    return () => {
      window.removeEventListener('message', handleMessage);
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen, isShopOpen, closeUI, closeShop]);

  return (
    <div style={{ display: isOpen || isShopOpen ? 'block' : 'none' }}>
      {isOpen && (
        <CompanyProvider>
          <MainLayout />
        </CompanyProvider>
      )}
      
      {isShopOpen && shopData && (
        <ShopModal
          isOpen={isShopOpen}
          onClose={closeShop}
          companyId={shopData.companyId}
          company={shopData.company}
          items={shopData.items}
        />
      )}
    </div>
  );
}

function GetParentResourceName() {
  return 'mx_enterprise';
}

export default App;
