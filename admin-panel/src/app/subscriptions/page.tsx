'use client';

import { useState } from 'react';
import { useAdmin } from '@/context/AdminContext';
import { useUI } from '@/context/UIContext';
import { 
  Search, 
  Filter, 
  CreditCard,
  Clock,
  CheckCircle,
  XCircle,
  Eye,
  X,
  Image as ImageIcon,
  Calendar,
  User,
  DollarSign,
  AlertTriangle
} from 'lucide-react';

export default function SubscriptionsPage() {
  const { payments, users, approvePayment, rejectPayment, activateSubscription } = useAdmin();
  const { language } = useUI();
  const tx = (ar: string, fr: string) => (language === 'fr' ? fr : ar);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [selectedPayment, setSelectedPayment] = useState<string | null>(null);
  const [showImageModal, setShowImageModal] = useState(false);
  const [manualActivation, setManualActivation] = useState<string | null>(null);
  const [activationMonths, setActivationMonths] = useState(1);

  const electricians = users.filter(u => u.role === 'electrician');

  const filteredPayments = payments.filter(payment => {
    const matchesSearch = payment.electricianName.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || payment.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'approved':
        return { label: tx('موافق عليه', 'Approuve'), color: 'bg-green-100 text-green-700', icon: CheckCircle };
      case 'pending':
        return { label: tx('في الانتظار', 'En attente'), color: 'bg-amber-100 text-amber-700', icon: Clock };
      case 'rejected':
        return { label: tx('مرفوض', 'Refuse'), color: 'bg-red-100 text-red-700', icon: XCircle };
      default:
        return { label: status, color: 'bg-gray-100 text-gray-700', icon: Clock };
    }
  };

  const selectedPaymentData = selectedPayment 
    ? payments.find(p => p.id === selectedPayment) 
    : null;

  const pendingCount = payments.filter(p => p.status === 'pending').length;
  const approvedCount = payments.filter(p => p.status === 'approved').length;
  const totalRevenue = payments.filter(p => p.status === 'approved').reduce((sum, p) => sum + p.amount, 0);

  return (
    <div className="p-6 lg:p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">{tx('إدارة الاشتراكات', 'Gestion des abonnements')}</h1>
        <p className="text-gray-500 mt-1">{tx('مراجعة طلبات الاشتراك وتفعيلها', 'Verifier les demandes et activer les abonnements')}</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-amber-100 rounded-lg">
              <Clock className="text-amber-600" size={24} />
            </div>
            <div>
              <p className="text-gray-500 text-sm">{tx('في الانتظار', 'En attente')}</p>
              <p className="text-2xl font-bold text-amber-600">{pendingCount}</p>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-green-100 rounded-lg">
              <CheckCircle className="text-green-600" size={24} />
            </div>
            <div>
              <p className="text-gray-500 text-sm">{tx('تم الموافقة', 'Approuves')}</p>
              <p className="text-2xl font-bold text-green-600">{approvedCount}</p>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-blue-100 rounded-lg">
              <CreditCard className="text-blue-600" size={24} />
            </div>
            <div>
              <p className="text-gray-500 text-sm">{tx('إجمالي الطلبات', 'Total demandes')}</p>
              <p className="text-2xl font-bold text-blue-600">{payments.length}</p>
            </div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-4 border border-gray-100 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="p-3 bg-purple-100 rounded-lg">
              <DollarSign className="text-purple-600" size={24} />
            </div>
            <div>
              <p className="text-gray-500 text-sm">{tx('الإيرادات', 'Revenus')}</p>
              <p className="text-2xl font-bold text-purple-600">{totalRevenue.toLocaleString('ar-DZ')} د.ج</p>
            </div>
          </div>
        </div>
      </div>

      {/* Pending Alert */}
      {pendingCount > 0 && (
        <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 mb-6 flex items-center gap-3">
          <AlertTriangle className="text-amber-600" size={24} />
          <div>
            <p className="font-medium text-amber-800">{tx(`يوجد ${pendingCount} طلبات اشتراك في الانتظار`, `${pendingCount} demandes d abonnement en attente`)}</p>
            <p className="text-sm text-amber-600">{tx('يرجى مراجعتها والموافقة عليها أو رفضها', 'Veuillez les verifier puis approuver ou refuser')}</p>
          </div>
        </div>
      )}

      {/* Filters */}
      <div className="bg-white rounded-xl border border-gray-100 shadow-sm mb-6">
        <div className="p-4 flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder={tx('البحث باسم الكهربائي...', 'Rechercher par nom d electricien...')}
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
              <option value="pending">{tx('في الانتظار', 'En attente')}</option>
              <option value="approved">{tx('موافق عليه', 'Approuve')}</option>
              <option value="rejected">{tx('مرفوض', 'Refuse')}</option>
            </select>
          </div>

          <button
            onClick={() => setManualActivation('new')}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            {tx('تفعيل يدوي', 'Activation manuelle')}
          </button>
        </div>
      </div>

      {/* Payments List */}
      <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('الكهربائي', 'Electricien')}</th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('المبلغ', 'Montant')}</th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('التاريخ', 'Date')}</th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('الحالة', 'Statut')}</th>
                <th className="px-6 py-4 text-right text-sm font-semibold text-gray-600">{tx('الإجراءات', 'Actions')}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filteredPayments.map((payment) => {
                const badge = getStatusBadge(payment.status);
                const StatusIcon = badge.icon;
                
                return (
                  <tr key={payment.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center">
                          <User size={20} className="text-purple-600" />
                        </div>
                        <span className="font-medium text-gray-900">{payment.electricianName}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="font-semibold text-gray-900">{payment.amount.toLocaleString('ar-DZ')} د.ج</span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2 text-gray-500">
                        <Calendar size={16} />
                        <span>{payment.createdAt}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium ${badge.color}`}>
                        <StatusIcon size={14} />
                        {badge.label}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => setSelectedPayment(payment.id)}
                          className="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                          title={tx('عرض التفاصيل', 'Voir les details')}
                        >
                          <Eye size={18} />
                        </button>
                        {payment.status === 'pending' && (
                          <>
                            <button
                              onClick={() => approvePayment(payment.id)}
                              className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors"
                              title={tx('موافقة', 'Approuver')}
                            >
                              <CheckCircle size={18} />
                            </button>
                            <button
                              onClick={() => rejectPayment(payment.id)}
                              className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                              title={tx('رفض', 'Refuser')}
                            >
                              <XCircle size={18} />
                            </button>
                          </>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        
        {filteredPayments.length === 0 && (
          <div className="p-12 text-center text-gray-500">
            <CreditCard size={48} className="mx-auto mb-4 text-gray-300" />
            <p>{tx('لا توجد طلبات دفع', 'Aucune demande de paiement')}</p>
          </div>
        )}
      </div>

      {/* Payment Details Modal */}
      {selectedPaymentData && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl max-w-lg w-full">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-gray-900">{tx('تفاصيل طلب الدفع', 'Details de la demande')}</h3>
                <button
                  onClick={() => setSelectedPayment(null)}
                  className="p-2 hover:bg-gray-100 rounded-lg"
                >
                  <X size={20} />
                </button>
              </div>

              <div className="space-y-4 mb-6">
                <div className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-gray-500">{tx('الكهربائي', 'Electricien')}</span>
                  <span className="font-medium">{selectedPaymentData.electricianName}</span>
                </div>
                <div className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-gray-500">{tx('المبلغ', 'Montant')}</span>
                  <span className="font-semibold text-green-600">{selectedPaymentData.amount.toLocaleString('ar-DZ')} د.ج</span>
                </div>
                <div className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-gray-500">{tx('التاريخ', 'Date')}</span>
                  <span className="font-medium">{selectedPaymentData.createdAt}</span>
                </div>
                <div className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-gray-500">{tx('الحالة', 'Statut')}</span>
                  <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-sm font-medium ${getStatusBadge(selectedPaymentData.status).color}`}>
                    {getStatusBadge(selectedPaymentData.status).label}
                  </span>
                </div>
              </div>

              {/* Payment Proof */}
              <div className="mb-6">
                <h5 className="font-medium text-gray-900 mb-2">{tx('إثبات الدفع', 'Preuve de paiement')}</h5>
                <div 
                  className="bg-gray-100 rounded-lg h-48 flex items-center justify-center cursor-pointer hover:bg-gray-200 transition-colors"
                  onClick={() => setShowImageModal(true)}
                >
                  <div className="text-center">
                    <ImageIcon size={40} className="mx-auto text-gray-400 mb-2" />
                    <span className="text-sm text-gray-500">{tx('انقر لعرض الصورة', 'Cliquer pour afficher l image')}</span>
                  </div>
                </div>
              </div>

              {/* Actions */}
              {selectedPaymentData.status === 'pending' && (
                <div className="flex gap-3">
                  <button
                    onClick={() => {
                      approvePayment(selectedPaymentData.id);
                      setSelectedPayment(null);
                    }}
                    className="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
                  >
                    <CheckCircle size={18} />
                    <span>{tx('موافقة وتفعيل', 'Approuver et activer')}</span>
                  </button>
                  <button
                    onClick={() => {
                      rejectPayment(selectedPaymentData.id);
                      setSelectedPayment(null);
                    }}
                    className="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors flex items-center justify-center gap-2"
                  >
                    <XCircle size={18} />
                    <span>{tx('رفض', 'Refuser')}</span>
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Image Modal */}
      {showImageModal && selectedPaymentData && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-[60] p-4">
          <div className="relative max-w-2xl w-full">
            <button
              onClick={() => setShowImageModal(false)}
              className="absolute -top-12 left-0 text-white hover:text-gray-300"
            >
              <X size={32} />
            </button>
            <div className="bg-gray-200 rounded-xl h-96 flex items-center justify-center">
              <div className="text-center">
                <ImageIcon size={64} className="mx-auto text-gray-400 mb-4" />
                <p className="text-gray-500">{tx('صورة إثبات الدفع', 'Image de preuve de paiement')}</p>
                <p className="text-sm text-gray-400 mt-2">{selectedPaymentData.paymentProofImage}</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Manual Activation Modal */}
      {manualActivation && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl max-w-md w-full">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-gray-900">{tx('تفعيل اشتراك يدوي', 'Activation manuelle d abonnement')}</h3>
                <button
                  onClick={() => {
                    setManualActivation(null);
                    setActivationMonths(1);
                  }}
                  className="p-2 hover:bg-gray-100 rounded-lg"
                >
                  <X size={20} />
                </button>
              </div>

              <div className="space-y-4 mb-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">{tx('اختر الكهربائي', 'Choisir l electricien')}</label>
                  <select
                    className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={manualActivation === 'new' ? '' : manualActivation}
                    onChange={(e) => setManualActivation(e.target.value)}
                  >
                    <option value="">{tx('اختر كهربائي...', 'Selectionner un electricien...')}</option>
                    {electricians.map(elec => (
                      <option key={elec.id} value={elec.id}>
                        {elec.name} - {elec.wilaya}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">{tx('مدة الاشتراك (بالأشهر)', 'Duree d abonnement (mois)')}</label>
                  <select
                    className="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={activationMonths}
                    onChange={(e) => setActivationMonths(Number(e.target.value))}
                  >
                    <option value={1}>{tx('شهر واحد', '1 mois')}</option>
                    <option value={3}>{tx('3 أشهر', '3 mois')}</option>
                    <option value={6}>{tx('6 أشهر', '6 mois')}</option>
                    <option value={12}>{tx('سنة كاملة', '1 an')}</option>
                  </select>
                </div>
              </div>

              <div className="flex gap-3">
                <button
                  onClick={() => {
                    setManualActivation(null);
                    setActivationMonths(1);
                  }}
                  className="flex-1 px-4 py-2 border border-gray-200 rounded-lg hover:bg-gray-50"
                >
                  {tx('إلغاء', 'Annuler')}
                </button>
                <button
                  onClick={() => {
                    if (manualActivation && manualActivation !== 'new') {
                      activateSubscription(manualActivation, activationMonths);
                      setManualActivation(null);
                      setActivationMonths(1);
                    }
                  }}
                  disabled={!manualActivation || manualActivation === 'new'}
                  className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {tx('تفعيل', 'Activer')}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
