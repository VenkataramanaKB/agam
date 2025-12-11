'use client';

import Image from 'next/image';
import Link from 'next/link';
import { ProtectedRoute } from '@/components/protected-route';
import { useAuth } from '@/lib/auth-context';
import { Vault } from '@/lib/api';

function DashboardContent() {
  const { logout, userId } = useAuth();

  const defaultVaults: Vault[] = [
    { id: '883fa696-f7a0-40e6-bd0f-7e3e5810f6c4', name: 'Memories', type: 'images', user_id: userId ?? 0, created_timestamp: '' },
    { id: 'ce9d0916-8337-40eb-9b67-6f1f85f6baa0', name: 'Thoughts', type: 'texts', user_id: userId ?? 0, created_timestamp: '' },
    { id: '6939770b-b0e5-4d16-9c85-710d4f6bbbc3', name: 'Echoes', type: 'audios', user_id: userId ?? 0, created_timestamp: '' },
    { id: '13c6b0bf-dfb6-493a-b658-42a66f4604c0', name: 'Documents', type: 'documents', user_id: userId ?? 0, created_timestamp: '' },
  ];

  const typeBadges: Record<string, string> = {
    images: 'Images',
    texts: 'Texts',
    audios: 'Audios',
    documents: 'Documents',
  };

  const typeIcons: Record<string, string> = {
    images: '🖼️',
    texts: '📝',
    audios: '🎧',
    documents: '📄',
  };

  return (
    <div className="min-h-screen flex bg-linear-to-b from-black via-[#0c0c0c] to-black text-white">
      <aside className="w-16 sm:w-56 border-r border-[#1c1c1c] bg-[#0f0f0f]/80 backdrop-blur p-4 sm:p-6 flex flex-col justify-between">
        <div className="space-y-6 sm:space-y-8">
          <div className="flex items-center sm:items-start sm:flex-col sm:space-y-4 space-x-3 sm:space-x-0">
            <Image src="/agam.png" alt="Agam Cloud" width={40} height={40} className="drop-shadow" priority />
            <div className="hidden sm:block text-left">
              <p className="text-xs text-white/60">Vault</p>
              <p className="text-lg font-semibold">Agam Cloud</p>
            </div>
          </div>
        </div>
        <button
          onClick={logout}
          className="w-full border border-white/20 text-white px-3 py-2 rounded-lg font-medium hover:bg-white/10 transition-colors text-sm sm:text-base"
        >
          Logout
        </button>
      </aside>

      <main className="flex-1 px-4 sm:px-8 py-10">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h2 className="text-3xl font-semibold tracking-tight">My Vaults</h2>
            <p className="text-white/60 text-sm mt-2">Your essentials at a glance.</p>
          </div>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-2  gap-6">
          {defaultVaults.map((vault, idx) => (
            <div
              key={vault.id}
              className={`relative bg-[#0f0f0f] rounded-2xl border border-[#1c1c1c] p-6 hover:border-white/20 hover:shadow-[0_10px_40px_-25px_rgba(255,255,255,0.6)] transition`}
            >
              <div className="absolute top-4 right-4 bg-white/8 border border-white/10 rounded-full px-3 py-1 text-sm text-white/80 flex items-center space-x-1">
                <span>{typeIcons[vault.type] ?? '📁'}</span>
                <span>{typeBadges[vault.type] ?? 'Vault'}</span>
              </div>
              <div className="space-y-4">
                <div className="flex items-center space-x-3">
                  <div className="h-10 w-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center text-lg">
                    {typeIcons[vault.type] ?? '📁'}
                  </div>
                  <div>
                    <h3 className="text-xl font-semibold text-white">{vault.name}</h3>
                    <p className="text-sm text-white/60 capitalize">{typeBadges[vault.type] ?? vault.type}</p>
                  </div>
                </div>
                <Link
                  href={`/vault/${vault.id}`}
                  className="inline-flex justify-center items-center bg-white text-black px-4 py-2 rounded-lg font-semibold hover:bg-white/90 transition-colors"
                >
                  Open
                </Link>
              </div>
            </div>
          ))}
        </div>
      </main>
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

