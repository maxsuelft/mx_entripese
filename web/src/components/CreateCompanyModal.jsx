import React, { useState, useEffect } from 'react';
import { api } from '../services/api';

const COMPANY_TYPES = {
  industry: 'Indústria',
  service: 'Serviço',
  commerce: 'Comércio',
  mixed: 'Misto'
};

export default function CreateCompanyModal({ isOpen, onClose, onSuccess, isAdmin = false }) {
  const [formData, setFormData] = useState({
    name: '',
    label: '',
    type: 'mixed',
    cnpj: '',
    blip_enabled: false,
    blip_x: null,
    blip_y: null,
    blip_z: null,
    blip_sprite: '',
    blip_color: 'LIGHT_BLUE'
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [useCurrentLocation, setUseCurrentLocation] = useState(false);
  const [availableSprites, setAvailableSprites] = useState([]);
  const [availableColors, setAvailableColors] = useState([]);
  
  useEffect(() => {
    if (isOpen && isAdmin) {
      loadAvailableBlipData();
    }
  }, [isOpen, isAdmin]);
  
  const loadAvailableBlipData = async () => {
    try {
      const [sprites, colors] = await Promise.all([
        api.getAvailableBlipSprites(),
        api.getAvailableBlipColors()
      ]);
      setAvailableSprites(sprites || []);
      setAvailableColors(colors || []);
    } catch (err) {
      console.error('Erro ao carregar dados de blip:', err);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const result = await api.createCompany(formData);
      
      if (result.success) {
        setFormData({ 
          name: '', 
          label: '', 
          type: 'mixed', 
          cnpj: '',
          blip_enabled: false,
          blip_x: null,
          blip_y: null,
          blip_z: null,
          blip_sprite: '',
          blip_color: 'LIGHT_BLUE'
        });
        onSuccess?.();
        onClose();
      } else {
        setError(result.message || 'Erro ao criar empresa');
      }
    } catch (err) {
      setError('Erro ao criar empresa. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({ 
      ...prev, 
      [name]: type === 'checkbox' ? checked : value 
    }));
  };

  const handleGetCurrentLocation = async () => {
    try {
      const coords = await api.getPlayerCoords();
      setFormData(prev => ({
        ...prev,
        blip_x: coords.x,
        blip_y: coords.y,
        blip_z: coords.z,
        blip_enabled: true
      }));
      setUseCurrentLocation(true);
    } catch (err) {
      setError('Erro ao obter localização atual');
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-gray-800 rounded-lg p-6 w-full max-w-md">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-2xl font-bold text-white">Criar Nova Empresa</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white text-2xl"
          >
            ×
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">
              Nome (ID) *
            </label>
            <input
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
              required
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded text-white focus:outline-none focus:border-blue-500"
              placeholder="ex: empresa_exemplo"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">
              Nome de Exibição *
            </label>
            <input
              type="text"
              name="label"
              value={formData.label}
              onChange={handleChange}
              required
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded text-white focus:outline-none focus:border-blue-500"
              placeholder="ex: Empresa Exemplo LTDA"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">
              Tipo de Empresa *
            </label>
            <select
              name="type"
              value={formData.type}
              onChange={handleChange}
              required
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded text-white focus:outline-none focus:border-blue-500"
            >
              {Object.entries(COMPANY_TYPES).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">
              CNPJ (Opcional)
            </label>
            <input
              type="text"
              name="cnpj"
              value={formData.cnpj}
              onChange={handleChange}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded text-white focus:outline-none focus:border-blue-500"
              placeholder="00.000.000/0000-00"
            />
          </div>

          {isAdmin && (
            <>
              <div className="border-t border-gray-700 pt-4">
                <h3 className="text-lg font-semibold mb-3">Configurações de Blip (Admin)</h3>
                
                <div className="mb-3">
                  <label className="flex items-center space-x-2">
                    <input
                      type="checkbox"
                      name="blip_enabled"
                      checked={formData.blip_enabled}
                      onChange={handleChange}
                      className="w-4 h-4"
                    />
                    <span className="text-sm text-gray-300">Ativar blip no mapa</span>
                  </label>
                </div>

                {formData.blip_enabled && (
                  <>
                    <button
                      type="button"
                      onClick={handleGetCurrentLocation}
                      className="w-full mb-3 px-4 py-2 bg-green-600 hover:bg-green-700 rounded text-white text-sm"
                    >
                      Usar Localização Atual
                    </button>

                    <div className="mb-3">
                      <label className="block text-sm font-medium text-gray-300 mb-1">
                        Sprite do Blip
                      </label>
                      <select
                        name="blip_sprite"
                        value={formData.blip_sprite}
                        onChange={handleChange}
                        className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded text-white focus:outline-none focus:border-blue-500"
                      >
                        <option value="">Selecione um sprite</option>
                        {availableSprites.map((sprite, index) => (
                          <option key={index} value={sprite.sprite || sprite.hash || sprite}>
                            {sprite.name || sprite.sprite || sprite.hash || sprite}
                          </option>
                        ))}
                      </select>
                    </div>

                    <div className="mb-3">
                      <label className="block text-sm font-medium text-gray-300 mb-1">
                        Cor do Blip
                      </label>
                      <select
                        name="blip_color"
                        value={formData.blip_color}
                        onChange={handleChange}
                        className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded text-white focus:outline-none focus:border-blue-500"
                      >
                        {availableColors.map(color => (
                          <option key={color} value={color}>
                            {color}
                          </option>
                        ))}
                      </select>
                    </div>

                    <div className="grid grid-cols-3 gap-2">
                      <div>
                        <label className="block text-xs text-gray-400 mb-1">X</label>
                        <input
                          type="number"
                          step="0.01"
                          name="blip_x"
                          value={formData.blip_x || ''}
                          onChange={handleChange}
                          className="w-full px-2 py-1 bg-gray-700 border border-gray-600 rounded text-white text-sm"
                          placeholder="X"
                        />
                      </div>
                      <div>
                        <label className="block text-xs text-gray-400 mb-1">Y</label>
                        <input
                          type="number"
                          step="0.01"
                          name="blip_y"
                          value={formData.blip_y || ''}
                          onChange={handleChange}
                          className="w-full px-2 py-1 bg-gray-700 border border-gray-600 rounded text-white text-sm"
                          placeholder="Y"
                        />
                      </div>
                      <div>
                        <label className="block text-xs text-gray-400 mb-1">Z</label>
                        <input
                          type="number"
                          step="0.01"
                          name="blip_z"
                          value={formData.blip_z || ''}
                          onChange={handleChange}
                          className="w-full px-2 py-1 bg-gray-700 border border-gray-600 rounded text-white text-sm"
                          placeholder="Z"
                        />
                      </div>
                    </div>
                  </>
                )}
              </div>
            </>
          )}

          {error && (
            <div className="bg-red-500 bg-opacity-20 border border-red-500 text-red-200 px-4 py-2 rounded">
              {error}
            </div>
          )}

          <div className="flex gap-2 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded text-white"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex-1 px-4 py-2 bg-blue-500 hover:bg-blue-600 rounded text-white disabled:opacity-50"
            >
              {loading ? 'Criando...' : 'Criar Empresa'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

