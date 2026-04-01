'use client';

import { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { useUI } from '@/context/UIContext';
import { 
  Search, 
  Filter, 
  MoreVertical, 
  User, 
  Phone, 
  Calendar,
  Ban,
  CheckCircle,
  Trash2,
  X
} from 'lucide-react';

export default function UsersPage() {
  const { users, updateUserStatus, deleteUser } = useAdmin();
  const { language } = useUI();
  const tx = (ar: string, fr: string) => (language === 'fr' ? fr : ar);
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState<string>('all');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [selectedUser, setSelectedUser] = useState<string | null>(null);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [userToDelete, setUserToDelete] = useState<string | null>(null);

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.phone.includes(searchTerm);
    const matchesRole = roleFilter === 'all' || user.role === roleFilter;
    const matchesStatus = statusFilter === 'all' || user.accountStatus === statusFilter;
    return matchesSearch && matchesRole && matchesStatus;
  });

  const handleDeleteUser = () => {
    if (userToDelete) {
      deleteUser(userToDelete);
      setShowDeleteModal(false);
      setUserToDelete(null);
    }
  };

  const getRoleLabel = (role: string) => {
    switch (role) {
      case 'client': return tx('عميل', 'Client');
      case 'electrician': return tx('كهربائي', 'Electricien');
      case 'admin': return tx('مدير', 'Admin');
      default: return role;
    }
  };

  const getRoleBadgeColor = (role: string) => {
    switch (role) {
      case 'client': return 'bg-blue-100 text-blue-700';
      case 'electrician': return 'bg-purple-100 text-purple-700';
      case 'admin': return 'bg-red-100 text-red-700';
      default: return 'bg-gray-100 text-gray-700';
    }
  };

  return (
    <div className="p-6 lg:p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">{tx('إدارة المستخدمين', 'Gestion des utilisateurs')}</h1>
        <p className="text-gray-500 mt-1">{tx('عرض وإدارة جميع مستخدمي المنصة', 'Afficher et gerer tous les utilisateurs de la plateforme')}</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <p className="text-gray-500 text-sm">{tx('إجمالي المستخدمين', 'Total utilisateurs')}</p>
          <p className="text-2xl font-bold text-gray-900">{users.length}</p>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <p className="text-gray-500 text-sm">{tx('العملاء', 'Clients')}</p>
          <p className="text-2xl font-bold text-blue-600">
            {users.filter(u => u.role === 'client').length}
          </p>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <p className="text-gray-500 text-sm">{tx('الكهربائيين', 'Electriciens')}</p>
          <p className="text-2xl font-bold text-purple-600">
            {users.filter(u => u.role === 'electrician').length}
          </p>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <p className="text-gray-500 text-sm">{tx('الحسابات الموقوفة', 'Comptes suspendus')}</p>
          <p className="text-2xl font-bold text-red-600">
            {users.filter(u => u.accountStatus === 'suspended').length}
          </p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-xl border border-gray-100 shadow-sm mb-6">
        <div className="p-4 flex flex-col md:flex-row gap-4">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder={tx('البحث بالاسم أو رقم الهاتف...', 'Rechercher par nom ou telephone...')}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pr-10 pl-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          
          {/* Role Filter */}
          <div className="flex items-center gap-2">
            <Filter size={20} className="text-gray-400" />
            <select
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value)}
              className="px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">{tx('جميع الأدوار', 'Tous les roles')}</option>
              <option value="client">{tx('عملاء', 'Clients')}</option>
              <option value="electrician">{tx('كهربائيين', 'Electriciens')}</option>
            </select>
          </div>

          {/* Status Filter */}
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="all">{tx('جميع الحالات', 'Tous les statuts')}</option>
            <option value="active">{tx('نشط', 'Actif')}</option>
            <option value="suspended">{tx('موقوف', 'Suspendu')}</option>
          </select>
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('المستخدم', 'Utilisateur')}</th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('رقم الهاتف', 'Telephone')}</th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('الدور', 'Role')}</th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('الحالة', 'Statut')}</th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('تاريخ التسجيل', 'Date d inscription')}</th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('الإجراءات', 'Actions')}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filteredUsers.map((user) => (
                <tr key={user.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                        <User size={20} className="text-gray-500" />
                      </div>
                      <div>
                        <p className="font-medium text-gray-900">{user.name}</p>
                        {user.wilaya && (
                          <p className="text-sm text-gray-500">{user.wilaya}</p>
                        )}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2 text-gray-600">
                      <Phone size={16} />
                      <span>{user.phone}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${getRoleBadgeColor(user.role)}`}>
                      {getRoleLabel(user.role)}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                      user.accountStatus === 'active' 
                        ? 'bg-green-100 text-green-700' 
                        : 'bg-red-100 text-red-700'
                    }`}>
                      {user.accountStatus === 'active' ? tx('نشط', 'Actif') : tx('موقوف', 'Suspendu')}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2 text-gray-500">
                      <Calendar size={16} />
                      <span>{user.createdAt}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="relative">
                      <button
                        onClick={() => setSelectedUser(selectedUser === user.id ? null : user.id)}
                        className="p-2 hover:bg-gray-100 rounded-lg"
                      >
                        <MoreVertical size={20} className="text-gray-500" />
                      </button>
                      
                      {selectedUser === user.id && (
                        <div className="absolute left-0 top-full mt-1 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-10 min-w-[160px]">
                          {user.accountStatus === 'active' ? (
                            <button
                              onClick={() => {
                                updateUserStatus(user.id, 'suspended');
                                setSelectedUser(null);
                              }}
                              className="flex items-center gap-2 w-full px-4 py-2 text-amber-600 hover:bg-amber-50"
                            >
                              <Ban size={16} />
                              <span>{tx('إيقاف الحساب', 'Suspendre le compte')}</span>
                            </button>
                          ) : (
                            <button
                              onClick={() => {
                                updateUserStatus(user.id, 'active');
                                setSelectedUser(null);
                              }}
                              className="flex items-center gap-2 w-full px-4 py-2 text-green-600 hover:bg-green-50"
                            >
                              <CheckCircle size={16} />
                              <span>{tx('تفعيل الحساب', 'Activer le compte')}</span>
                            </button>
                          )}
                          <button
                            onClick={() => {
                              setUserToDelete(user.id);
                              setShowDeleteModal(true);
                              setSelectedUser(null);
                            }}
                            className="flex items-center gap-2 w-full px-4 py-2 text-red-600 hover:bg-red-50"
                          >
                            <Trash2 size={16} />
                            <span>{tx('حذف الحساب', 'Supprimer le compte')}</span>
                          </button>
                        </div>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {filteredUsers.length === 0 && (
          <div className="p-12 text-center text-gray-500">
            <User size={48} className="mx-auto mb-4 text-gray-300" />
            <p>{tx('لا توجد نتائج', 'Aucun resultat')}</p>
          </div>
        )}
      </div>

      {/* Delete Confirmation Modal */}
      {showDeleteModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl p-6 max-w-md w-full mx-4">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-bold text-gray-900">{tx('تأكيد الحذف', 'Confirmer la suppression')}</h3>
              <button
                onClick={() => {
                  setShowDeleteModal(false);
                  setUserToDelete(null);
                }}
                className="p-1 hover:bg-gray-100 rounded"
              >
                <X size={20} />
              </button>
            </div>
            <p className="text-gray-600 mb-6">
              {tx('هل أنت متأكد من حذف هذا المستخدم؟ لا يمكن التراجع عن هذا الإجراء.', 'Voulez-vous vraiment supprimer cet utilisateur ? Cette action est irreversible.')}
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => {
                  setShowDeleteModal(false);
                  setUserToDelete(null);
                }}
                className="flex-1 px-4 py-2 border border-gray-200 rounded-lg hover:bg-gray-50"
              >
                {tx('إلغاء', 'Annuler')}
              </button>
              <button
                onClick={handleDeleteUser}
                className="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
              >
                {tx('حذف', 'Supprimer')}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
