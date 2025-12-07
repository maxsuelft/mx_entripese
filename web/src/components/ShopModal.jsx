import React, { useState, useEffect } from 'react';
import { api } from '../services/api';

export default function ShopModal({ isOpen, onClose, companyId, company, items: initialItems }) {
  const [items, setItems] = useState(initialItems || []);
  const [loading, setLoading] = useState(false);
  const [cart, setCart] = useState({});
  const [total, setTotal] = useState(0);

  useEffect(() => {
    if (isOpen && companyId) {
      loadShopItems();
    }
  }, [isOpen, companyId]);

  useEffect(() => {
    // Calcular total do carrinho
    let cartTotal = 0;
    Object.entries(cart).forEach(([itemId, quantity]) => {
      const item = items.find(i => i.id === parseInt(itemId));
      if (item && quantity > 0) {
        cartTotal += item.price * quantity;
      }
    });
    setTotal(cartTotal);
  }, [cart, items]);

  const loadShopItems = async () => {
    try {
      const shopItems = await api.getShopItems(companyId);
      setItems(shopItems || []);
    } catch (error) {
      console.error('Erro ao carregar itens da loja:', error);
    }
  };

  const handleQuantityChange = (itemId, change) => {
    setCart(prev => {
      const current = prev[itemId] || 0;
      const newQuantity = Math.max(0, current + change);
      const item = items.find(i => i.id === itemId);
      
      if (item && newQuantity > item.stock) {
        return prev; // Não permite comprar mais que o estoque
      }
      
      if (newQuantity === 0) {
        const newCart = { ...prev };
        delete newCart[itemId];
        return newCart;
      }
      
      return { ...prev, [itemId]: newQuantity };
    });
  };

  const handleBuy = async () => {
    if (Object.keys(cart).length === 0) {
      return;
    }

    setLoading(true);
    try {
      // Processar cada item do carrinho
      const purchases = [];
      for (const [itemId, quantity] of Object.entries(cart)) {
        if (quantity > 0) {
          const item = items.find(i => i.id === parseInt(itemId));
          if (item) {
            const totalPrice = item.price * quantity;
            const result = await api.buyShopItem(companyId, parseInt(itemId), quantity, totalPrice);
            if (result && result.success) {
              purchases.push({ item: item.item, quantity });
            } else {
              // Se algum item falhar, mostrar erro
              const errorMsg = result?.message || 'Erro ao comprar item';
              // Usar notificação in-game
              await api.showNotification(errorMsg, 'error');
              setLoading(false);
              return;
            }
          }
        }
      }

      if (purchases.length > 0) {
        // Limpar carrinho e recarregar itens
        setCart({});
        await loadShopItems();
        
        // Notificar sucesso in-game
        await api.showNotification('Compra realizada com sucesso!', 'success');
      }
    } catch (error) {
      console.error('Erro ao comprar:', error);
      await api.showNotification('Erro ao realizar compra. Tente novamente.', 'error');
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div 
      className="fixed inset-0 flex items-center justify-center z-50"
      style={{
        backgroundImage: 'url(img/bg.png)',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        backgroundRepeat: 'no-repeat'
      }}
    >
      <div 
        className="bg-gray-900 bg-opacity-95 rounded-lg shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col"
        style={{ width: '900px', height: '600px' }}
      >
        {/* Header */}
        <div className="bg-gray-800 px-6 py-4 border-b border-gray-700 flex justify-between items-center">
          <div>
            <h2 className="text-2xl font-bold text-white">{company?.label || 'Loja'}</h2>
            <p className="text-sm text-gray-400">Total: ${total.toFixed(2)}</p>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white text-3xl font-bold w-10 h-10 flex items-center justify-center rounded hover:bg-gray-700 transition"
          >
            ×
          </button>
        </div>

        {/* Items List */}
        <div className="flex-1 overflow-y-auto p-6">
          {items.length === 0 ? (
            <div className="text-center text-gray-400 py-12">
              <p className="text-lg">Nenhum item disponível</p>
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-4">
              {items.map(item => {
                const cartQuantity = cart[item.id] || 0;
                const availableStock = item.stock - cartQuantity;
                
                return (
                  <div
                    key={item.id}
                    className="bg-gray-800 rounded-lg p-4 border border-gray-700 hover:border-blue-500 transition"
                  >
                    <div className="flex justify-between items-start mb-3">
                      <div className="flex-1">
                        <h3 className="text-lg font-semibold text-white mb-1">
                          {item.item}
                        </h3>
                        <p className="text-2xl font-bold text-green-400">
                          ${item.price.toFixed(2)}
                        </p>
                        <p className="text-sm text-gray-400 mt-1">
                          Estoque: {item.stock}
                        </p>
                      </div>
                    </div>

                    {/* Quantity Controls */}
                    <div className="flex items-center gap-2 mt-3">
                      <button
                        onClick={() => handleQuantityChange(item.id, -1)}
                        disabled={cartQuantity === 0}
                        className="px-3 py-1 bg-gray-700 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed text-white rounded transition"
                      >
                        −
                      </button>
                      <span className="px-4 py-1 bg-gray-700 text-white rounded min-w-[60px] text-center">
                        {cartQuantity}
                      </span>
                      <button
                        onClick={() => handleQuantityChange(item.id, 1)}
                        disabled={availableStock <= 0}
                        className="px-3 py-1 bg-gray-700 hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed text-white rounded transition"
                      >
                        +
                      </button>
                      <span className="ml-auto text-sm text-gray-400">
                        ${(item.price * cartQuantity).toFixed(2)}
                      </span>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="bg-gray-800 px-6 py-4 border-t border-gray-700">
          <div className="flex justify-between items-center">
            <div className="text-white">
              <span className="text-gray-400">Total: </span>
              <span className="text-2xl font-bold text-green-400">${total.toFixed(2)}</span>
            </div>
            <div className="flex gap-2">
              <button
                onClick={onClose}
                className="px-6 py-2 bg-gray-700 hover:bg-gray-600 rounded text-white transition"
              >
                Fechar
              </button>
              <button
                onClick={handleBuy}
                disabled={loading || total === 0}
                className="px-6 py-2 bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed rounded text-white font-semibold transition"
              >
                {loading ? 'Processando...' : 'Comprar'}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

