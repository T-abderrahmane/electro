'use client';

import { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { useUI } from '@/context/UIContext';
import { 
  Search, 
  Filter, 
  ClipboardList,
  Eye,
  X,
  User,
  MapPin,
  Calendar,
  MessageSquare,
  XCircle,
  Trash2,
  CheckCircle,
  Clock,
  DollarSign
} from 'lucide-react';

export default function RequestsPage() {
  const { requests, offers, closeRequest, deleteRequest } = useAdmin();
  const { language } = useUI();
  const tx = (ar: string, fr: string) => (language === 'fr' ? fr : ar);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [selectedRequest, setSelectedRequest] = useState<string | null>(null);
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [requestToDelete, setRequestToDelete] = useState<string | null>(null);

  const filteredRequests = requests.filter(request => {
    const matchesSearch = request.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         request.clientName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         request.wilaya.includes(searchTerm);
    const matchesStatus = statusFilter === 'all' || request.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'open':
        return { label: tx('مفتوح', 'Ouvert'), color: 'bg-blue-100 text-blue-700', icon: Clock };
      case 'assigned':
        return { label: tx('قيد التنفيذ', 'En cours'), color: 'bg-amber-100 text-amber-700', icon: CheckCircle };
      case 'closed':
        return { label: tx('مغلق', 'Ferme'), color: 'bg-green-100 text-green-700', icon: CheckCircle };
      default:
        return { label: status, color: 'bg-gray-100 text-gray-700', icon: Clock };
    }
  };

  const getRequestOffers = (requestId: string) => {
    return offers.filter(o => o.requestId === requestId);
  };

  const selectedRequestData = selectedRequest 
    ? requests.find(r => r.id === selectedRequest) 
    : null;

  const handleDeleteRequest = () => {
    if (requestToDelete) {
      deleteRequest(requestToDelete);
      setShowDeleteModal(false);
      setRequestToDelete(null);
    }
  };

  const openCount = requests.filter(r => r.status === 'open').length;
  const assignedCount = requests.filter(r => r.status === 'assigned').length;
  const closedCount = requests.filter(r => r.status === 'closed').length;

  return (
    <div className="p-6 lg:p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">{tx('إدارة الطلبات', 'Gestion des demandes')}</h1>
        <p className="text-gray-500 mt-1">{tx('عرض وإدارة جميع طلبات الخدمة', 'Afficher et gerer toutes les demandes de service')}</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-gray-100 rounded-lg">
              <ClipboardList className="text-gray-600" size={24} />
            </div>
            <div>
              <p className="text-gray-500 text-sm">{tx('إجمالي الطلبات', 'Total demandes')}</p>
              <p className="text-2xl font-bold text-gray-900">{requests.length}</p>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-blue-100 rounded-lg">
              <Clock className="text-blue-600" size={24} />
            </div>
            <div>
              <p className="text-gray-500 text-sm">{tx('مفتوحة', 'Ouvertes')}</p>
              <p className="text-2xl font-bold text-blue-600">{openCount}</p>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-amber-100 rounded-lg">
              <CheckCircle className="text-amber-600" size={24} />
            </div>
            <div>
              <p className="text-gray-500 text-sm">{tx('قيد التنفيذ', 'En cours')}</p>
              <p className="text-2xl font-bold text-amber-600">{assignedCount}</p>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-green-100 rounded-lg">
              <CheckCircle className="text-green-600" size={24} />
            </div>
            <div>
              <p className="text-gray-500 text-sm">{tx('مغلقة', 'Fermees')}</p>
              <p className="text-2xl font-bold text-green-600">{closedCount}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-xl border border-gray-100 shadow-sm mb-6">
        <div className="p-4 flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder={tx('البحث بالعنوان، اسم العميل أو الولاية...', 'Rechercher par titre, client ou wilaya...')}
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
              <option value="open">{tx('مفتوح', 'Ouvert')}</option>
              <option value="assigned">{tx('قيد التنفيذ', 'En cours')}</option>
              <option value="closed">{tx('مغلق', 'Ferme')}</option>
            </select>
          </div>
        </div>
      </div>

      {/* Requests List */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {filteredRequests.map((request) => {
          const badge = getStatusBadge(request.status);
          const StatusIcon = badge.icon;
          const requestOffers = getRequestOffers(request.id);
          
          return (
            <div 
              key={request.id} 
              className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-shadow"
            >
              <div className="p-5">
                {/* Header */}
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <h3 className="font-semibold text-gray-900 mb-1">{request.title}</h3>
                    <div className="flex items-center gap-1 text-sm text-gray-500">
                      <User size={14} />
                      <span>{request.clientName}</span>
                    </div>
                  </div>
                  <span className={`flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium ${badge.color}`}>
                    <StatusIcon size={12} />
                    {badge.label}
                  </span>
                </div>

                {/* Description */}
                <p className="text-gray-600 text-sm mb-3 line-clamp-2">{request.description}</p>

                {/* Info */}
                <div className="flex flex-wrap gap-4 mb-4 text-sm text-gray-500">
                  <div className="flex items-center gap-1">
                    <MapPin size={14} className="text-gray-400" />
                    <span>{request.wilaya} - {request.commune}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Calendar size={14} className="text-gray-400" />
                    <span>{request.createdAt}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <MessageSquare size={14} className="text-gray-400" />
                    <span>{request.offersCount} {tx('عروض', 'offres')}</span>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex gap-2">
                  <button
                    onClick={() => setSelectedRequest(request.id)}
                    className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-blue-50 text-blue-600 rounded-lg hover:bg-blue-100 transition-colors"
                  >
                    <Eye size={16} />
                    <span>{tx('عرض التفاصيل', 'Voir details')}</span>
                  </button>
                  {request.status !== 'closed' && (
                    <button
                      onClick={() => closeRequest(request.id)}
                      className="px-4 py-2 bg-green-50 text-green-600 rounded-lg hover:bg-green-100 transition-colors"
                      title={tx('إغلاق الطلب', 'Fermer demande')}
                    >
                      <CheckCircle size={16} />
                    </button>
                  )}
                  <button
                    onClick={() => {
                      setRequestToDelete(request.id);
                      setShowDeleteModal(true);
                    }}
                    className="px-4 py-2 bg-red-50 text-red-600 rounded-lg hover:bg-red-100 transition-colors"
                    title={tx('حذف الطلب', 'Supprimer demande')}
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {filteredRequests.length === 0 && (
        <div className="bg-white rounded-xl p-12 text-center text-gray-500">
          <ClipboardList size={48} className="mx-auto mb-4 text-gray-300" />
          <p>{tx('لا توجد طلبات', 'Aucune demande')}</p>
        </div>
      )}

      {/* Request Details Modal */}
      {selectedRequestData && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              {/* Header */}
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-gray-900">{tx('تفاصيل الطلب', 'Details de la demande')}</h3>
                <button
                  onClick={() => setSelectedRequest(null)}
                  className="p-2 hover:bg-gray-100 rounded-lg"
                >
                  <X size={20} />
                </button>
              </div>

              {/* Request Info */}
              <div className="mb-6">
                <div className="flex items-start justify-between mb-4">
                  <div>
                    <h4 className="text-lg font-semibold text-gray-900">{selectedRequestData.title}</h4>
                    <div className="flex items-center gap-2 text-gray-500 mt-1">
                      <User size={16} />
                      <span>{selectedRequestData.clientName}</span>
                    </div>
                  </div>
                  <span className={`flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium ${getStatusBadge(selectedRequestData.status).color}`}>
                    {getStatusBadge(selectedRequestData.status).label}
                  </span>
                </div>

                <p className="text-gray-600 mb-4">{selectedRequestData.description}</p>

                <div className="grid grid-cols-2 gap-4">
                  <div className="flex items-center gap-2 text-gray-600">
                    <MapPin size={18} className="text-gray-400" />
                    <span>{selectedRequestData.wilaya} - {selectedRequestData.commune}</span>
                  </div>
                  <div className="flex items-center gap-2 text-gray-600">
                    <Calendar size={18} className="text-gray-400" />
                    <span>{selectedRequestData.createdAt}</span>
                  </div>
                </div>
              </div>

              {/* Offers */}
              <div className="border-t border-gray-100 pt-6">
                <h5 className="font-semibold text-gray-900 mb-4 flex items-center gap-2">
                  <MessageSquare size={18} />
                  {tx('العروض المقدمة', 'Offres recues')} ({getRequestOffers(selectedRequestData.id).length})
                </h5>

                {getRequestOffers(selectedRequestData.id).length > 0 ? (
                  <div className="space-y-3">
                    {getRequestOffers(selectedRequestData.id).map((offer) => (
                      <div 
                        key={offer.id} 
                        className={`p-4 rounded-lg border ${
                          offer.status === 'accepted' 
                            ? 'border-green-200 bg-green-50' 
                            : offer.status === 'rejected'
                            ? 'border-red-200 bg-red-50'
                            : 'border-gray-200 bg-gray-50'
                        }`}
                      >
                        <div className="flex items-start justify-between mb-2">
                          <div className="flex items-center gap-2">
                            <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                              <User size={16} className="text-purple-600" />
                            </div>
                            <span className="font-medium text-gray-900">{offer.electricianName}</span>
                          </div>
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                            offer.status === 'accepted' 
                              ? 'bg-green-100 text-green-700' 
                              : offer.status === 'rejected'
                              ? 'bg-red-100 text-red-700'
                              : 'bg-gray-100 text-gray-700'
                          }`}>
                            {offer.status === 'accepted' ? tx('مقبول', 'Accepte') : offer.status === 'rejected' ? tx('مرفوض', 'Refuse') : tx('معلق', 'En attente')}
                          </span>
                        </div>
                        <p className="text-gray-600 text-sm mb-2">{offer.message}</p>
                        <div className="flex items-center gap-4 text-sm">
                          <div className="flex items-center gap-1 text-green-600">
                            <DollarSign size={14} />
                            <span className="font-semibold">{offer.price.toLocaleString('ar-DZ')} د.ج</span>
                          </div>
                          <div className="flex items-center gap-1 text-gray-500">
                            <Clock size={14} />
                            <span>{offer.estimatedTime}</span>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8 text-gray-500">
                    <MessageSquare size={32} className="mx-auto mb-2 text-gray-300" />
                    <p>{tx('لا توجد عروض لهذا الطلب', 'Aucune offre pour cette demande')}</p>
                  </div>
                )}
              </div>

              {/* Actions */}
              <div className="border-t border-gray-100 pt-6 mt-6 flex gap-3">
                {selectedRequestData.status !== 'closed' && (
                  <button
                    onClick={() => {
                      closeRequest(selectedRequestData.id);
                      setSelectedRequest(null);
                    }}
                    className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
                  >
                    <CheckCircle size={18} />
                    <span>{tx('إغلاق الطلب', 'Fermer demande')}</span>
                  </button>
                )}
                <button
                  onClick={() => {
                    setRequestToDelete(selectedRequestData.id);
                    setShowDeleteModal(true);
                    setSelectedRequest(null);
                  }}
                  className="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors flex items-center justify-center gap-2"
                >
                  <Trash2 size={18} />
                  <span>{tx('حذف الطلب', 'Supprimer demande')}</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-[60] p-4">
          <div className="bg-white rounded-xl p-6 max-w-md w-full">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-bold text-gray-900">{tx('تأكيد الحذف', 'Confirmer suppression')}</h3>
              <button
                onClick={() => {
                  setShowDeleteModal(false);
                  setRequestToDelete(null);
                }}
                className="p-1 hover:bg-gray-100 rounded"
              >
                <X size={20} />
              </button>
            </div>
            <p className="text-gray-600 mb-6">
              {tx('هل أنت متأكد من حذف هذا الطلب؟ سيتم حذف جميع العروض المرتبطة به أيضاً.', 'Voulez-vous vraiment supprimer cette demande ? Toutes les offres liees seront aussi supprimees.')}
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => {
                  setShowDeleteModal(false);
                  setRequestToDelete(null);
                }}
                className="flex-1 px-4 py-2 border border-gray-200 rounded-lg hover:bg-gray-50"
              >
                {tx('إلغاء', 'Annuler')}
              </button>
              <button
                onClick={handleDeleteRequest}
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
