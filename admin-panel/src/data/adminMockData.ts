// Admin Panel Mock Data

export interface User {
  id: string;
  name: string;
  phone: string;
  role: 'client' | 'electrician' | 'admin';
  wilaya?: string;
  commune?: string;
  yearsExperience?: number;
  idCardImage?: string;
  profileImage?: string;
  subscriptionStatus?: 'active' | 'inactive' | 'expired' | 'pending';
  subscriptionStartDate?: string;
  subscriptionEndDate?: string;
  accountStatus: 'active' | 'suspended';
  createdAt: string;
}

export interface SubscriptionPayment {
  id: string;
  electricianId: string;
  electricianName: string;
  paymentProofImage: string;
  amount: number;
  status: 'pending' | 'approved' | 'rejected';
  createdAt: string;
}

export interface ServiceRequest {
  id: string;
  clientId: string;
  clientName: string;
  title: string;
  description: string;
  wilaya: string;
  commune: string;
  status: 'open' | 'assigned' | 'closed';
  offersCount: number;
  createdAt: string;
}

export interface Offer {
  id: string;
  requestId: string;
  electricianId: string;
  electricianName: string;
  price: number;
  message: string;
  estimatedTime: string;
  status: 'pending' | 'accepted' | 'rejected';
  createdAt: string;
}

// Mock Users Data
export const mockUsers: User[] = [
  {
    id: 'c1',
    name: 'أحمد محمد',
    phone: '0555123456',
    role: 'client',
    accountStatus: 'active',
    createdAt: '2024-01-15',
  },
  {
    id: 'c2',
    name: 'محمد علي',
    phone: '0666234567',
    role: 'client',
    accountStatus: 'active',
    createdAt: '2024-01-20',
  },
  {
    id: 'c3',
    name: 'فاطمة الزهراء',
    phone: '0777345678',
    role: 'client',
    accountStatus: 'active',
    createdAt: '2024-02-01',
  },
  {
    id: 'c4',
    name: 'ياسين بن عمر',
    phone: '0551456789',
    role: 'client',
    accountStatus: 'suspended',
    createdAt: '2024-02-10',
  },
  {
    id: 'c5',
    name: 'سارة حسين',
    phone: '0662567890',
    role: 'client',
    accountStatus: 'active',
    createdAt: '2024-02-15',
  },
  {
    id: 'e1',
    name: 'خالد العربي',
    phone: '0555111222',
    role: 'electrician',
    wilaya: 'الجزائر',
    commune: 'باب الوادي',
    yearsExperience: 8,
    idCardImage: '/images/id1.jpg',
    profileImage: '/images/profile1.jpg',
    subscriptionStatus: 'active',
    subscriptionStartDate: '2024-02-01',
    subscriptionEndDate: '2024-03-01',
    accountStatus: 'active',
    createdAt: '2024-01-10',
  },
  {
    id: 'e2',
    name: 'عمر بوزيد',
    phone: '0666222333',
    role: 'electrician',
    wilaya: 'وهران',
    commune: 'وهران المدينة',
    yearsExperience: 5,
    idCardImage: '/images/id2.jpg',
    profileImage: '/images/profile2.jpg',
    subscriptionStatus: 'active',
    subscriptionStartDate: '2024-02-15',
    subscriptionEndDate: '2024-03-15',
    accountStatus: 'active',
    createdAt: '2024-01-12',
  },
  {
    id: 'e3',
    name: 'يوسف بن سالم',
    phone: '0777333444',
    role: 'electrician',
    wilaya: 'قسنطينة',
    commune: 'قسنطينة المدينة',
    yearsExperience: 10,
    idCardImage: '/images/id3.jpg',
    profileImage: '/images/profile3.jpg',
    subscriptionStatus: 'expired',
    subscriptionStartDate: '2024-01-01',
    subscriptionEndDate: '2024-02-01',
    accountStatus: 'active',
    createdAt: '2024-01-05',
  },
  {
    id: 'e4',
    name: 'إبراهيم مرابط',
    phone: '0551444555',
    role: 'electrician',
    wilaya: 'الجزائر',
    commune: 'حسين داي',
    yearsExperience: 3,
    idCardImage: '/images/id4.jpg',
    profileImage: '/images/profile4.jpg',
    subscriptionStatus: 'pending',
    accountStatus: 'active',
    createdAt: '2024-02-20',
  },
  {
    id: 'e5',
    name: 'سمير حداد',
    phone: '0662555666',
    role: 'electrician',
    wilaya: 'عنابة',
    commune: 'عنابة المدينة',
    yearsExperience: 7,
    idCardImage: '/images/id5.jpg',
    profileImage: '/images/profile5.jpg',
    subscriptionStatus: 'inactive',
    accountStatus: 'active',
    createdAt: '2024-02-18',
  },
  {
    id: 'e6',
    name: 'رضا بلعيد',
    phone: '0773666777',
    role: 'electrician',
    wilaya: 'البليدة',
    commune: 'البليدة المدينة',
    yearsExperience: 12,
    idCardImage: '/images/id6.jpg',
    profileImage: '/images/profile6.jpg',
    subscriptionStatus: 'active',
    subscriptionStartDate: '2024-02-10',
    subscriptionEndDate: '2024-03-10',
    accountStatus: 'active',
    createdAt: '2024-01-08',
  },
  {
    id: 'e7',
    name: 'نور الدين',
    phone: '0554777888',
    role: 'electrician',
    wilaya: 'سطيف',
    commune: 'سطيف المدينة',
    yearsExperience: 6,
    idCardImage: '/images/id7.jpg',
    profileImage: '/images/profile7.jpg',
    subscriptionStatus: 'pending',
    accountStatus: 'active',
    createdAt: '2024-02-25',
  },
  {
    id: 'e8',
    name: 'كريم زروال',
    phone: '0665888999',
    role: 'electrician',
    wilaya: 'تلمسان',
    commune: 'تلمسان المدينة',
    yearsExperience: 4,
    idCardImage: '/images/id8.jpg',
    subscriptionStatus: 'inactive',
    accountStatus: 'suspended',
    createdAt: '2024-02-22',
  },
];

// Mock Subscription Payments
export const mockSubscriptionPayments: SubscriptionPayment[] = [
  {
    id: 'p1',
    electricianId: 'e4',
    electricianName: 'إبراهيم مرابط',
    paymentProofImage: '/images/payment1.jpg',
    amount: 3000,
    status: 'pending',
    createdAt: '2024-02-20',
  },
  {
    id: 'p2',
    electricianId: 'e7',
    electricianName: 'نور الدين',
    paymentProofImage: '/images/payment2.jpg',
    amount: 3000,
    status: 'pending',
    createdAt: '2024-02-25',
  },
  {
    id: 'p3',
    electricianId: 'e1',
    electricianName: 'خالد العربي',
    paymentProofImage: '/images/payment3.jpg',
    amount: 3000,
    status: 'approved',
    createdAt: '2024-02-01',
  },
  {
    id: 'p4',
    electricianId: 'e2',
    electricianName: 'عمر بوزيد',
    paymentProofImage: '/images/payment4.jpg',
    amount: 3000,
    status: 'approved',
    createdAt: '2024-02-15',
  },
  {
    id: 'p5',
    electricianId: 'e6',
    electricianName: 'رضا بلعيد',
    paymentProofImage: '/images/payment5.jpg',
    amount: 3000,
    status: 'approved',
    createdAt: '2024-02-10',
  },
  {
    id: 'p6',
    electricianId: 'e3',
    electricianName: 'يوسف بن سالم',
    paymentProofImage: '/images/payment6.jpg',
    amount: 3000,
    status: 'rejected',
    createdAt: '2024-01-28',
  },
];

// Mock Requests
export const mockRequests: ServiceRequest[] = [
  {
    id: 'r1',
    clientId: 'c1',
    clientName: 'أحمد محمد',
    title: 'إصلاح أعطال كهربائية في المطبخ',
    description: 'يوجد عطل في مفاتيح الإضاءة ومقابس الكهرباء في المطبخ',
    wilaya: 'الجزائر',
    commune: 'باب الوادي',
    status: 'open',
    offersCount: 3,
    createdAt: '2024-02-28',
  },
  {
    id: 'r2',
    clientId: 'c2',
    clientName: 'محمد علي',
    title: 'تركيب لوحة كهربائية جديدة',
    description: 'أحتاج تركيب لوحة كهربائية جديدة للمنزل بالكامل',
    wilaya: 'وهران',
    commune: 'وهران المدينة',
    status: 'assigned',
    offersCount: 5,
    createdAt: '2024-02-25',
  },
  {
    id: 'r3',
    clientId: 'c3',
    clientName: 'فاطمة الزهراء',
    title: 'صيانة التمديدات الكهربائية',
    description: 'فحص وصيانة التمديدات الكهربائية القديمة في البيت',
    wilaya: 'قسنطينة',
    commune: 'قسنطينة المدينة',
    status: 'closed',
    offersCount: 2,
    createdAt: '2024-02-20',
  },
  {
    id: 'r4',
    clientId: 'c1',
    clientName: 'أحمد محمد',
    title: 'تركيب مكيف هواء',
    description: 'تركيب مكيف سبليت في غرفة المعيشة',
    wilaya: 'الجزائر',
    commune: 'حسين داي',
    status: 'open',
    offersCount: 4,
    createdAt: '2024-02-27',
  },
  {
    id: 'r5',
    clientId: 'c5',
    clientName: 'سارة حسين',
    title: 'إصلاح سخان الماء الكهربائي',
    description: 'السخان لا يعمل بشكل صحيح ويحتاج صيانة',
    wilaya: 'البليدة',
    commune: 'البليدة المدينة',
    status: 'open',
    offersCount: 1,
    createdAt: '2024-02-26',
  },
  {
    id: 'r6',
    clientId: 'c2',
    clientName: 'محمد علي',
    title: 'تركيب كاميرات مراقبة',
    description: 'تركيب نظام كاميرات مراقبة للمنزل - 4 كاميرات',
    wilaya: 'عنابة',
    commune: 'عنابة المدينة',
    status: 'assigned',
    offersCount: 6,
    createdAt: '2024-02-24',
  },
  {
    id: 'r7',
    clientId: 'c3',
    clientName: 'فاطمة الزهراء',
    title: 'فحص دوري للكهرباء',
    description: 'فحص دوري شامل للتأكد من سلامة التمديدات',
    wilaya: 'سطيف',
    commune: 'سطيف المدينة',
    status: 'open',
    offersCount: 0,
    createdAt: '2024-02-23',
  },
  {
    id: 'r8',
    clientId: 'c4',
    clientName: 'ياسين بن عمر',
    title: 'تمديد كهرباء للحديقة',
    description: 'تمديد كهرباء خارجية للحديقة مع إضاءة',
    wilaya: 'تلمسان',
    commune: 'تلمسان المدينة',
    status: 'closed',
    offersCount: 3,
    createdAt: '2024-02-15',
  },
];

// Mock Offers
export const mockOffers: Offer[] = [
  {
    id: 'o1',
    requestId: 'r1',
    electricianId: 'e1',
    electricianName: 'خالد العربي',
    price: 5000,
    message: 'يمكنني إصلاح المشكلة في نفس اليوم',
    estimatedTime: 'ساعتين',
    status: 'pending',
    createdAt: '2024-02-28',
  },
  {
    id: 'o2',
    requestId: 'r1',
    electricianId: 'e6',
    electricianName: 'رضا بلعيد',
    price: 4500,
    message: 'لدي خبرة كبيرة في هذا النوع من الأعطال',
    estimatedTime: 'ساعة ونصف',
    status: 'pending',
    createdAt: '2024-02-28',
  },
  {
    id: 'o3',
    requestId: 'r2',
    electricianId: 'e2',
    electricianName: 'عمر بوزيد',
    price: 25000,
    message: 'سأقوم بالعمل باحترافية عالية',
    estimatedTime: 'يومين',
    status: 'accepted',
    createdAt: '2024-02-25',
  },
  {
    id: 'o4',
    requestId: 'r4',
    electricianId: 'e1',
    electricianName: 'خالد العربي',
    price: 8000,
    message: 'تركيب احترافي مع ضمان',
    estimatedTime: '3 ساعات',
    status: 'pending',
    createdAt: '2024-02-27',
  },
  {
    id: 'o5',
    requestId: 'r5',
    electricianId: 'e6',
    electricianName: 'رضا بلعيد',
    price: 3500,
    message: 'فحص وإصلاح السخان',
    estimatedTime: 'ساعة',
    status: 'pending',
    createdAt: '2024-02-26',
  },
  {
    id: 'o6',
    requestId: 'r6',
    electricianId: 'e2',
    electricianName: 'عمر بوزيد',
    price: 35000,
    message: 'تركيب كامل مع الضبط والتشغيل',
    estimatedTime: 'يوم واحد',
    status: 'accepted',
    createdAt: '2024-02-24',
  },
];

// Helper functions
export const getClientCount = () => mockUsers.filter(u => u.role === 'client').length;
export const getElectricianCount = () => mockUsers.filter(u => u.role === 'electrician').length;
export const getActiveSubscriptions = () => mockUsers.filter(u => u.role === 'electrician' && u.subscriptionStatus === 'active').length;
export const getPendingPayments = () => mockSubscriptionPayments.filter(p => p.status === 'pending').length;
export const getOpenRequests = () => mockRequests.filter(r => r.status === 'open').length;
export const getTotalOffers = () => mockOffers.length;
