'use client';

import { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { useUI } from '@/context/UIContext';
import { 
  Search, 
  Filter, 
  User, 
  Phone, 
  MapPin,
  Briefcase,
  CreditCard,
  Eye,
  CheckCircle,
  XCircle,
  X,
  Clock,
  Image as ImageIcon,
  Calendar
} from 'lucide-react';

export default function ElectriciansPage() {
  const { users, updateUserStatus, activateSubscription } = useAdmin();
  const { language } = useUI();
  const tx = (ar: string, fr: string) => (language === 'fr' ? fr : ar);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [selectedElectrician, setSelectedElectrician] = useState<string | null>(null);
  const [showImageModal, setShowImageModal] = useState(false);

  const electricians = users.filter(user => user.role === 'electrician');

  const filteredElectricians = electricians.filter(elec => {
    const matchesSearch = elec.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         elec.phone.includes(searchTerm) ||
                         elec.wilaya?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || elec.subscriptionStatus === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getSubscriptionBadge = (status?: string) => {
    switch (status) {
      case 'active':
        return { label: tx('نشط', 'Actif'), color: 'bg-green-100 text-green-700', icon: CheckCircle };
      case 'pending':
        return { label: tx('معلق', 'En attente'), color: 'bg-amber-100 text-amber-700', icon: Clock };
      case 'expired':
        return { label: tx('منتهي', 'Expire'), color: 'bg-red-100 text-red-700', icon: XCircle };
      case 'inactive':
      default:
        return { label: tx('غير مشترك', 'Non abonne'), color: 'bg-gray-100 text-gray-700', icon: XCircle };
    }
  };

  const selectedElectricianData = selectedElectrician 
    ? electricians.find(e => e.id === selectedElectrician) 
    : null;

  return (
    <div className="p-6 lg:p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">{tx('التحقق من الكهربائيين', 'Verification des electriciens')}</h1>
        <p className="text-gray-500 mt-1">{tx('عرض وإدارة حسابات الكهربائيين والتحقق من هوياتهم', 'Afficher et gerer les comptes electriciens et verifier leurs identites')}</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-6">
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <p className="text-gray-500 text-sm">{tx('إجمالي الكهربائيين', 'Total electriciens')}</p>
          <p className="text-2xl font-bold text-gray-900">{electricians.length}</p>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <p className="text-gray-500 text-sm">{tx('اشتراكات نشطة', 'Abonnements actifs')}</p>
          <p className="text-2xl font-bold text-green-600">
            {electricians.filter(e => e.subscriptionStatus === 'active').length}
          </p>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <p className="text-gray-500 text-sm">{tx('في الانتظار', 'En attente')}</p>
          <p className="text-2xl font-bold text-amber-600">
            {electricians.filter(e => e.subscriptionStatus === 'pending').length}
          </p>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <p className="text-gray-500 text-sm">{tx('منتهية', 'Expires')}</p>
          <p className="text-2xl font-bold text-red-600">
            {electricians.filter(e => e.subscriptionStatus === 'expired').length}
          </p>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <p className="text-gray-500 text-sm">{tx('غير مشتركين', 'Non abonnes')}</p>
          <p className="text-2xl font-bold text-gray-600">
            {electricians.filter(e => e.subscriptionStatus === 'inactive' || !e.subscriptionStatus).length}
          </p>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-xl border border-gray-100 shadow-sm mb-6">
        <div className="p-4 flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder={tx('البحث بالاسم، الهاتف أو الولاية...', 'Rechercher par nom, telephone ou wilaya...')}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pr-10 pl-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          
          <div className="flex items-center gap-2">
            <Filter size={20} className="text-gray-400" />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">{tx('جميع الحالات', 'Tous les statuts')}</option>
              <option value="active">{tx('اشتراك نشط', 'Abonnement actif')}</option>
              <option value="pending">{tx('في الانتظار', 'En attente')}</option>
              <option value="expired">{tx('منتهي', 'Expire')}</option>
              <option value="inactive">{tx('غير مشترك', 'Non abonne')}</option>
            </select>
          </div>
        </div>
      </div>

      {/* Electricians Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filteredElectricians.map((elec) => {
          const badge = getSubscriptionBadge(elec.subscriptionStatus);
          const StatusIcon = badge.icon;
          
          return (
            <div 
              key={elec.id} 
              className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-shadow"
            >
              <div className="p-6">
                {/* Header */}
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center">
                      <User size={24} className="text-purple-600" />
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900">{elec.name}</h3>
                      <div className="flex items-center gap-1 text-sm text-gray-500">
                        <Phone size={14} />
                        <span>{elec.phone}</span>
                      </div>
                    </div>
                  </div>
                  <span className={`flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium ${badge.color}`}>
                    <StatusIcon size={12} />
                    {badge.label}
                  </span>
                </div>

                {/* Info */}
                <div className="space-y-2 mb-4">
                  <div className="flex items-center gap-2 text-gray-600">
                    <MapPin size={16} className="text-gray-400" />
                    <span className="text-sm">{elec.wilaya} - {elec.commune}</span>
                  </div>
                  <div className="flex items-center gap-2 text-gray-600">
                    <Briefcase size={16} className="text-gray-400" />
                    <span className="text-sm">{elec.yearsExperience} {tx('سنوات خبرة', 'ans d experience')}</span>
                  </div>
                  {elec.subscriptionEndDate && (
                    <div className="flex items-center gap-2 text-gray-600">
                      <Calendar size={16} className="text-gray-400" />
                      <span className="text-sm">{tx('ينتهي', 'Expire le')} : {elec.subscriptionEndDate}</span>
                    </div>
                  )}
                </div>

                {/* Actions */}
                <div className="flex gap-2">
                  <button
                    onClick={() => setSelectedElectrician(elec.id)}
                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-100 transition-colors"
                  >
                    <Eye size={16} />
                    <span>{tx('عرض التفاصيل', 'Voir les details')}</span>
                  </button>
                  {elec.idCardImage && (
                    <button
                      onClick={() => {
                        setSelectedElectrician(elec.id);
                        setShowImageModal(true);
                      }}
                      className="px-4 py-2 bg-gray-50 text-gray-600 rounded-lg hover:bg-gray-100 transition-colors"
                    >
                      <ImageIcon size={16} />
                    </button>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {filteredElectricians.length === 0 && (
        <div className="bg-white rounded-xl p-12 text-center text-gray-500">
          <User size={48} className="mx-auto mb-4 text-gray-300" />
          <p>{tx('لا توجد نتائج', 'Aucun resultat')}</p>
        </div>
      )}

      {/* Electrician Details Modal */}
      {selectedElectricianData && !showImageModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              {/* Header */}
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-gray-900">{tx('تفاصيل الكهربائي', 'Details de l electricien')}</h3>
                <button
                  onClick={() => setSelectedElectrician(null)}
                  className="p-2 hover:bg-gray-100 rounded-lg"
                >
                  <X size={20} />
                </button>
              </div>

              {/* Profile */}
              <div className="flex items-center gap-4 mb-6">
                <div className="w-20 h-20 bg-purple-100 rounded-full flex items-center justify-center">
                  <User size={40} className="text-purple-600" />
                </div>
                <div>
                  <h4 className="text-lg font-semibold text-gray-900">{selectedElectricianData.name}</h4>
                  <p className="text-gray-500">{selectedElectricianData.phone}</p>
                  <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium mt-1 ${
                    getSubscriptionBadge(selectedElectricianData.subscriptionStatus).color
                  }`}>
                    {getSubscriptionBadge(selectedElectricianData.subscriptionStatus).label}
                  </span>
                </div>
              </div>

              {/* Details */}
              <div className="space-y-4 mb-6">
                <div className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-gray-500">{tx('الولاية', 'Wilaya')}</span>
                  <span className="font-medium">{selectedElectricianData.wilaya}</span>
                </div>
                <div className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-gray-500">{tx('البلدية', 'Commune')}</span>
                  <span className="font-medium">{selectedElectricianData.commune}</span>
                </div>
                <div className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-gray-500">{tx('سنوات الخبرة', 'Annees d experience')}</span>
                  <span className="font-medium">{selectedElectricianData.yearsExperience} {tx('سنوات', 'ans')}</span>
                </div>
                <div className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-gray-500">{tx('تاريخ التسجيل', 'Date d inscription')}</span>
                  <span className="font-medium">{selectedElectricianData.createdAt}</span>
                </div>
                <div className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-gray-500">{tx('حالة الحساب', 'Statut du compte')}</span>
                  <span className={`font-medium ${
                    selectedElectricianData.accountStatus === 'active' ? 'text-green-600' : 'text-red-600'
                  }`}>
                    {selectedElectricianData.accountStatus === 'active' ? tx('نشط', 'Actif') : tx('موقوف', 'Suspendu')}
                  </span>
                </div>
                {selectedElectricianData.subscriptionStartDate && (
                  <div className="flex justify-between py-2 border-b border-gray-100">
                    <span className="text-gray-500">{tx('بداية الاشتراك', 'Debut abonnement')}</span>
                    <span className="font-medium">{selectedElectricianData.subscriptionStartDate}</span>
                  </div>
                )}
                {selectedElectricianData.subscriptionEndDate && (
                  <div className="flex justify-between py-2 border-b border-gray-100">
                    <span className="text-gray-500">{tx('نهاية الاشتراك', 'Fin abonnement')}</span>
                    <span className="font-medium">{selectedElectricianData.subscriptionEndDate}</span>
                  </div>
                )}
              </div>

              {/* ID Card */}
              {selectedElectricianData.idCardImage && (
                <div className="mb-6">
                  <h5 className="font-medium text-gray-900 mb-2">{tx('صورة بطاقة الهوية', 'Image de la piece d identite')}</h5>
                  <div 
                    className="bg-gray-100 rounded-lg h-40 flex items-center justify-center cursor-pointer hover:bg-gray-200 transition-colors"
                    onClick={() => setShowImageModal(true)}
                  >
                    <div className="text-center">
                      <ImageIcon size={32} className="mx-auto text-gray-400 mb-2" />
                      <span className="text-sm text-gray-500">{tx('انقر لعرض الصورة', 'Cliquer pour afficher l image')}</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Actions */}
              <div className="flex gap-3">
                {selectedElectricianData.accountStatus === 'active' ? (
                  <button
                    onClick={() => {
                      updateUserStatus(selectedElectricianData.id, 'suspended');
                      setSelectedElectrician(null);
                    }}
                    className="flex-1 px-4 py-2 bg-amber-100 text-amber-700 rounded-lg hover:bg-amber-200 transition-colors"
                  >
                    {tx('إيقاف الحساب', 'Suspendre le compte')}
                  </button>
                ) : (
                  <button
                    onClick={() => {
                      updateUserStatus(selectedElectricianData.id, 'active');
                      setSelectedElectrician(null);
                    }}
                    className="flex-1 px-4 py-2 bg-green-100 text-green-700 rounded-lg hover:bg-green-200 transition-colors"
                  >
                    {tx('تفعيل الحساب', 'Activer le compte')}
                  </button>
                )}
                {selectedElectricianData.subscriptionStatus !== 'active' && (
                  <button
                    onClick={() => {
                      activateSubscription(selectedElectricianData.id, 1);
                      setSelectedElectrician(null);
                    }}
                    className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    {tx('تفعيل الاشتراك (شهر)', 'Activer l abonnement (1 mois)')}
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Image Modal */}
      {showImageModal && selectedElectricianData && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4">
          <div className="relative max-w-2xl w-full">
            <button
              onClick={() => {
                setShowImageModal(false);
                setSelectedElectrician(null);
              }}
              className="absolute -top-12 left-0 text-white hover:text-gray-300"
            >
              <X size={32} />
            </button>
            <div className="bg-gray-200 rounded-xl h-96 flex items-center justify-center">
              <div className="text-center">
                <ImageIcon size={64} className="mx-auto text-gray-400 mb-4" />
                <p className="text-gray-500">{tx('صورة بطاقة الهوية', 'Image de la piece d identite')}</p>
                <p className="text-sm text-gray-400 mt-2">{selectedElectricianData.idCardImage}</p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
