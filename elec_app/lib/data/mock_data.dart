import '../models/models.dart';

// Mock current user (for testing different scenarios)
User? currentUser;

// Mock clients
final List<User> mockClients = [
  User(
    id: 'c1',
    name: 'أحمد محمد',
    phone: '0555123456',
    role: UserRole.client,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  ),
  User(
    id: 'c2',
    name: 'سارة بن علي',
    phone: '0666234567',
    role: UserRole.client,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
  ),
];

// Mock electricians
final List<User> mockElectricians = [
  User(
    id: 'e1',
    name: 'محمد أمين بلقاسم',
    phone: '0777345678',
    role: UserRole.electrician,
    wilaya: 'الجزائر',
    commune: 'باب الوادي',
    yearsExperience: 8,
    subscriptionStatus: SubscriptionStatus.active,
    subscriptionStartDate: DateTime.now().subtract(const Duration(days: 15)),
    subscriptionEndDate: DateTime.now().add(const Duration(days: 15)),
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
  ),
  User(
    id: 'e2',
    name: 'كريم حداد',
    phone: '0888456789',
    role: UserRole.electrician,
    wilaya: 'وهران',
    commune: 'وهران',
    yearsExperience: 5,
    subscriptionStatus: SubscriptionStatus.inactive,
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
  ),
  User(
    id: 'e3',
    name: 'يوسف مراد',
    phone: '0555567890',
    role: UserRole.electrician,
    wilaya: 'الجزائر',
    commune: 'الحراش',
    yearsExperience: 12,
    subscriptionStatus: SubscriptionStatus.active,
    subscriptionStartDate: DateTime.now().subtract(const Duration(days: 10)),
    subscriptionEndDate: DateTime.now().add(const Duration(days: 20)),
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
  ),
];

// Mock service requests
final List<ServiceRequest> mockRequests = [
  ServiceRequest(
    id: 'r1',
    clientId: 'c1',
    clientName: 'أحمد محمد',
    title: 'تركيب مكيف هواء',
    description: 'أحتاج كهربائي لتركيب مكيف هواء سبليت في غرفة النوم. المكيف جاهز ويحتاج فقط للتركيب والتوصيل الكهربائي.',
    images: [],
    wilaya: 'الجزائر',
    commune: 'باب الوادي',
    status: RequestStatus.open,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    offersCount: 3,
  ),
  ServiceRequest(
    id: 'r2',
    clientId: 'c2',
    clientName: 'سارة بن علي',
    title: 'إصلاح عطل كهربائي',
    description: 'يوجد عطل في الكهرباء في المطبخ، الأضواء لا تعمل والمقابس أيضاً. أحتاج فحص شامل وإصلاح.',
    images: [],
    wilaya: 'الجزائر',
    commune: 'الحراش',
    status: RequestStatus.open,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    offersCount: 5,
  ),
  ServiceRequest(
    id: 'r3',
    clientId: 'c1',
    clientName: 'أحمد محمد',
    title: 'تمديد كهرباء جديد',
    description: 'أريد تمديد خط كهرباء جديد لغرفة إضافية في المنزل مع تركيب مقابس وأضواء.',
    images: [],
    wilaya: 'وهران',
    commune: 'السانية',
    status: RequestStatus.open,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    offersCount: 2,
  ),
  ServiceRequest(
    id: 'r4',
    clientId: 'c2',
    clientName: 'سارة بن علي',
    title: 'تركيب لوحة كهربائية',
    description: 'أحتاج تغيير اللوحة الكهربائية القديمة بلوحة جديدة مع قواطع أوتوماتيكية.',
    images: [],
    wilaya: 'الجزائر',
    commune: 'سيدي امحمد',
    status: RequestStatus.assigned,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    offersCount: 4,
    assignedElectricianId: 'e1',
  ),
  ServiceRequest(
    id: 'r5',
    clientId: 'c1',
    clientName: 'أحمد محمد',
    title: 'صيانة دورية',
    description: 'صيانة دورية للتمديدات الكهربائية في الشقة.',
    images: [],
    wilaya: 'قسنطينة',
    commune: 'قسنطينة',
    status: RequestStatus.closed,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    offersCount: 6,
    assignedElectricianId: 'e3',
  ),
];

// Mock offers
final List<Offer> mockOffers = [
  Offer(
    id: 'o1',
    requestId: 'r1',
    electricianId: 'e1',
    electricianName: 'محمد أمين بلقاسم',
    price: 5000,
    message: 'يمكنني تركيب المكيف اليوم مساءً. لدي خبرة في تركيب جميع أنواع المكيفات.',
    estimatedTime: 'ساعتين',
    status: OfferStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    electricianExperience: 8,
    electricianRating: 4.8,
  ),
  Offer(
    id: 'o2',
    requestId: 'r1',
    electricianId: 'e3',
    electricianName: 'يوسف مراد',
    price: 4500,
    message: 'متاح غداً صباحاً. عمل احترافي مضمون.',
    estimatedTime: 'ساعة ونصف',
    status: OfferStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    electricianExperience: 12,
    electricianRating: 4.9,
  ),
  Offer(
    id: 'o3',
    requestId: 'r2',
    electricianId: 'e1',
    electricianName: 'محمد أمين بلقاسم',
    price: 3000,
    message: 'سأقوم بفحص شامل وإصلاح العطل. يمكنني الحضور خلال ساعة.',
    estimatedTime: 'ساعة للفحص + وقت الإصلاح',
    status: OfferStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    electricianExperience: 8,
    electricianRating: 4.8,
  ),
  Offer(
    id: 'o4',
    requestId: 'r4',
    electricianId: 'e1',
    electricianName: 'محمد أمين بلقاسم',
    price: 15000,
    message: 'سأقوم بتغيير اللوحة الكهربائية بمواد عالية الجودة.',
    estimatedTime: 'يوم كامل',
    status: OfferStatus.accepted,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 20)),
    electricianExperience: 8,
    electricianRating: 4.8,
  ),
];

// Mock chat messages
final List<ChatMessage> mockMessages = [
  ChatMessage(
    id: 'm1',
    requestId: 'r4',
    senderId: 'c2',
    senderName: 'سارة بن علي',
    message: 'مرحباً، متى يمكنك البدء في العمل؟',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 19)),
  ),
  ChatMessage(
    id: 'm2',
    requestId: 'r4',
    senderId: 'e1',
    senderName: 'محمد أمين بلقاسم',
    message: 'مرحباً، يمكنني البدء غداً صباحاً إن شاء الله.',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 18)),
  ),
  ChatMessage(
    id: 'm3',
    requestId: 'r4',
    senderId: 'c2',
    senderName: 'سارة بن علي',
    message: 'ممتاز، سأكون في الموعد. هل تحتاج شيئاً أحضره؟',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 17)),
  ),
  ChatMessage(
    id: 'm4',
    requestId: 'r4',
    senderId: 'e1',
    senderName: 'محمد أمين بلقاسم',
    message: 'لا شكراً، سأحضر كل المعدات والمواد اللازمة.',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 16)),
  ),
];

// Helper functions
List<ServiceRequest> getRequestsByWilaya(String wilaya) {
  return mockRequests.where((r) => r.wilaya == wilaya && r.status == RequestStatus.open).toList();
}

List<ServiceRequest> getRequestsByWilayaAndCommune(String wilaya, String commune) {
  return mockRequests.where((r) => 
    r.wilaya == wilaya && 
    r.commune == commune && 
    r.status == RequestStatus.open
  ).toList();
}

List<Offer> getOffersForRequest(String requestId) {
  return mockOffers.where((o) => o.requestId == requestId).toList();
}

List<ChatMessage> getMessagesForRequest(String requestId) {
  return mockMessages.where((m) => m.requestId == requestId).toList();
}

List<ServiceRequest> getClientRequests(String clientId) {
  return mockRequests.where((r) => r.clientId == clientId).toList();
}

List<ServiceRequest> getElectricianAssignedRequests(String electricianId) {
  return mockRequests.where((r) => r.assignedElectricianId == electricianId).toList();
}
