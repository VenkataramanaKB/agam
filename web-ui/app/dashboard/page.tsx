'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { ProtectedRoute } from '@/components/protected-route';
import { useAuth } from '@/lib/auth-context';
import { vaultAPI, fileAPI, Vault } from '@/lib/api';
import Link from 'next/link';

function DashboardContent() {
  const [vaults, setVaults] = useState<Vault[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [newVaultName, setNewVaultName] = useState('');
  const [newVaultType, setNewVaultType] = useState('personal');
  const { logout, userId } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (userId) {
      loadVaults();
    }
  }, [userId]);

  const loadVaults = async () => {
    if (!userId) return;
    try {
      const data = await vaultAPI.list(userId);
      setVaults(data);
    } catch (err: any) {
      setError(err.message || 'Failed to load vaults');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateVault = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!userId) return;
    setError('');

    try {
      await vaultAPI.create({
        name: newVaultName,
        type: newVaultType,
      }, userId);
      setNewVaultName('');
      setNewVaultType('personal');
      setShowCreateModal(false);
      loadVaults();
    } catch (err: any) {
      setError(err.message || 'Failed to create vault');
    }
  };

  const handleDeleteVault = async (vaultId: string) => {
    if (!userId) return;
    if (!confirm('Are you sure you want to delete this vault? All files will be deleted.')) {
      return;
    }

    try {
      await vaultAPI.delete(vaultId, userId);
      loadVaults();
    } catch (err: any) {
      setError(err.message || 'Failed to delete vault');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center">
              <h1 className="text-2xl font-bold text-black">Agam Cloud</h1>
            </div>
            <div className="flex items-center space-x-4">
              <button
                onClick={logout}
                className="text-gray-600 hover:text-gray-900 px-4 py-2 rounded-lg hover:bg-gray-100 transition-colors"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex justify-between items-center mb-8">
          <h2 className="text-3xl font-bold text-black">My Vaults</h2>
          <button
            onClick={() => setShowCreateModal(true)}
            className="bg-blue-600 text-white px-6 py-2 rounded-lg font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
          >
            + Create Vault
          </button>
        </div>

        {error && (
          <div className="mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-lg">
            {error}
          </div>
        )}

        {loading ? (
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-black">Loading vaults...</p>
          </div>
        ) : vaults.length === 0 ? (
          <div className="text-center py-12 bg-white rounded-lg shadow-sm">
            <p className="text-black mb-4">No vaults yet. Create your first vault to get started!</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {vaults.map((vault) => (
              <div
                key={vault.id}
                className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow"
              >
                <div className="flex justify-between items-start mb-4">
                  <h3 className="text-xl font-semibold text-black">{vault.name}</h3>
                  <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded-full">
                    {vault.type}
                  </span>
                </div>
                <p className="text-sm text-black mb-4">
                  Created {new Date(vault.created_timestamp).toLocaleDateString()}
                </p>
                <div className="flex space-x-2">
                  <Link
                    href={`/vault/${vault.id}`}
                    className="flex-1 bg-blue-600 text-white text-center py-2 px-4 rounded-lg font-medium hover:bg-blue-700 transition-colors"
                  >
                    Open
                  </Link>
                  <button
                    onClick={() => handleDeleteVault(vault.id)}
                    className="bg-red-600 text-white py-2 px-4 rounded-lg font-medium hover:bg-red-700 transition-colors"
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full p-6">
            <h3 className="text-2xl font-bold text-black mb-4">Create New Vault</h3>
            <form onSubmit={handleCreateVault} className="space-y-4">
              <div>
                <label htmlFor="vault-name" className="block text-sm font-medium text-black mb-2">
                  Vault Name
                </label>
                <input
                  id="vault-name"
                  type="text"
                  value={newVaultName}
                  onChange={(e) => setNewVaultName(e.target.value)}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  placeholder="My Vault"
                />
              </div>
              <div>
                <label htmlFor="vault-type" className="block text-sm font-medium text-black mb-2">
                  Type
                </label>
                <select
                  id="vault-type"
                  value={newVaultType}
                  onChange={(e) => setNewVaultType(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="personal">Personal</option>
                  <option value="work">Work</option>
                  <option value="shared">Shared</option>
                </select>
              </div>
              <div className="flex space-x-3 pt-4">
                <button
                  type="submit"
                  className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-lg font-medium hover:bg-blue-700 transition-colors"
                >
                  Create
                </button>
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="flex-1 bg-gray-200 text-gray-800 py-2 px-4 rounded-lg font-medium hover:bg-gray-300 transition-colors"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default function DashboardPage() {
  return (
    <ProtectedRoute>
      <DashboardContent />
    </ProtectedRoute>
  );
}

