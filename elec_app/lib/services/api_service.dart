import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  // Backend URL shared with admin panel (Next.js API routes).
  // Override with --dart-define=API_BASE_URL=http://YOUR_HOST:3000/api
  // Android emulator example: --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  void clearAuthToken() {
    _authToken = null;
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };
  
  // ==================== AUTH ====================
  
  Future<ApiResponse<User>> login({
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'role': role,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        return ApiResponse.success(_userFromJson(data['user']));
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<User>> register({
    required String name,
    required String phone,
    required String password,
    required String role,
    String? wilaya,
    String? commune,
    int? yearsExperience,
    List<String>? specialties,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'password': password,
          'role': role,
          if (wilaya != null) 'wilaya': wilaya,
          if (commune != null) 'commune': commune,
          if (yearsExperience != null) 'yearsExperience': yearsExperience,
          if (specialties != null) 'specialties': specialties,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_userFromJson(data));
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // ==================== USERS ====================
  
  Future<ApiResponse<User>> getUser(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_userFromJson(data));
      } else {
        return ApiResponse.error('User not found');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<User>> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_userFromJson(data));
      } else {
        return ApiResponse.error('Update failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<List<User>>> getElectricians({String? wilaya}) async {
    try {
      String url = '$baseUrl/users?role=electrician';
      if (wilaya != null) url += '&wilaya=$wilaya';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return ApiResponse.success(data.map((e) => _userFromJson(e)).toList());
      } else {
        return ApiResponse.error('Failed to fetch electricians');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // ==================== REQUESTS ====================
  
  Future<ApiResponse<List<ServiceRequest>>> getRequests({
    String? clientId,
    String? wilaya,
    String? status,
    String? electricianId,
  }) async {
    try {
      String url = '$baseUrl/requests?';
      if (clientId != null) url += 'clientId=$clientId&';
      if (wilaya != null) url += 'wilaya=$wilaya&';
      if (status != null) url += 'status=$status&';
      if (electricianId != null) url += 'electricianId=$electricianId&';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return ApiResponse.success(data.map((r) => _requestFromJson(r)).toList());
      } else {
        return ApiResponse.error('Failed to fetch requests');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<ServiceRequest>> getRequest(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/requests/$id'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_requestFromJson(data));
      } else {
        return ApiResponse.error('Request not found');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<ServiceRequest>> createRequest({
    required String clientId,
    required String serviceType,
    required String description,
    required String wilaya,
    required String commune,
    String? address,
    List<String>? images,
    String? preferredDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/requests'),
        headers: _headers,
        body: jsonEncode({
          'clientId': clientId,
          'serviceType': serviceType,
          'description': description,
          'wilaya': wilaya,
          'commune': commune,
          if (address != null) 'address': address,
          if (images != null) 'images': images,
          if (preferredDate != null) 'preferredDate': preferredDate,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_requestFromJson(data));
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['error'] ?? 'Failed to create request');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<ServiceRequest>> updateRequest(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/requests/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_requestFromJson(data));
      } else {
        return ApiResponse.error('Update failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<bool>> deleteRequest(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/requests/$id'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error('Delete failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // ==================== OFFERS ====================
  
  Future<ApiResponse<List<Offer>>> getOffers({
    String? requestId,
    String? electricianId,
    String? status,
  }) async {
    try {
      String url = '$baseUrl/offers?';
      if (requestId != null) url += 'requestId=$requestId&';
      if (electricianId != null) url += 'electricianId=$electricianId&';
      if (status != null) url += 'status=$status&';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return ApiResponse.success(data.map((o) => _offerFromJson(o)).toList());
      } else {
        return ApiResponse.error('Failed to fetch offers');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<Offer>> createOffer({
    required String requestId,
    required String electricianId,
    required double price,
    required String description,
    required String estimatedDuration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/offers'),
        headers: _headers,
        body: jsonEncode({
          'requestId': requestId,
          'electricianId': electricianId,
          'price': price,
          'description': description,
          'estimatedDuration': estimatedDuration,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_offerFromJson(data));
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['error'] ?? 'Failed to create offer');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<Offer>> updateOffer(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/offers/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_offerFromJson(data));
      } else {
        return ApiResponse.error('Update failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // ==================== MESSAGES ====================
  
  Future<ApiResponse<List<ChatMessage>>> getMessages({
    String? requestId,
    String? senderId,
  }) async {
    try {
      String url = '$baseUrl/messages?';
      if (requestId != null) url += 'requestId=$requestId&';
      if (senderId != null) url += 'senderId=$senderId&';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return ApiResponse.success(data.map((m) => _messageFromJson(m)).toList());
      } else {
        return ApiResponse.error('Failed to fetch messages');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<ChatMessage>> sendMessage({
    required String requestId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: _headers,
        body: jsonEncode({
          'requestId': requestId,
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_messageFromJson(data));
      } else {
        return ApiResponse.error('Failed to send message');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // ==================== PAYMENTS ====================
  
  Future<ApiResponse<Map<String, dynamic>>> submitPayment({
    required String electricianId,
    required String paymentMethod,
    required String transactionId,
    String? screenshotUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: _headers,
        body: jsonEncode({
          'electricianId': electricianId,
          'paymentMethod': paymentMethod,
          'transactionId': transactionId,
          if (screenshotUrl != null) 'screenshotUrl': screenshotUrl,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data);
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(error['error'] ?? 'Payment submission failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getPayments({String? electricianId}) async {
    try {
      String url = '$baseUrl/payments';
      if (electricianId != null) url += '?electricianId=$electricianId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return ApiResponse.success(List<Map<String, dynamic>>.from(data));
      } else {
        return ApiResponse.error('Failed to fetch payments');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  // ==================== HELPERS ====================
  
  User _userFromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'] == 'client' ? UserRole.client : UserRole.electrician,
      wilaya: json['wilaya'],
      commune: json['commune'],
      yearsExperience: json['yearsExperience'],
      specialties: json['specialties'] != null 
          ? List<String>.from(json['specialties'])
          : null,
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      subscriptionStatus: _parseSubscriptionStatus(json['subscriptionStatus']),
        isAccountActive: json['accountStatus'] != 'suspended',
      subscriptionEndDate: json['subscriptionEndDate'] != null 
          ? DateTime.parse(json['subscriptionEndDate'])
          : null,
      rating: json['rating']?.toDouble(),
      completedJobs: json['completedJobs'],
    );
  }
  
  SubscriptionStatus _parseSubscriptionStatus(String? status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'pending':
        return SubscriptionStatus.pending;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.inactive;
    }
  }
  
  ServiceRequest _requestFromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      serviceType: _parseServiceType(json['serviceType']),
      description: json['description'],
      wilaya: json['wilaya'],
      commune: json['commune'],
      address: json['address'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      status: _parseRequestStatus(json['status']),
      assignedElectricianId: json['assignedElectricianId'],
      createdAt: DateTime.parse(json['createdAt']),
      preferredDate: json['preferredDate'] != null 
          ? DateTime.parse(json['preferredDate'])
          : null,
    );
  }
  
  ServiceType _parseServiceType(String type) {
    switch (type) {
      case 'installation':
        return ServiceType.installation;
      case 'repair':
        return ServiceType.repair;
      case 'maintenance':
        return ServiceType.maintenance;
      case 'consultation':
        return ServiceType.consultation;
      default:
        return ServiceType.other;
    }
  }
  
  RequestStatus _parseRequestStatus(String status) {
    switch (status) {
      case 'pending':
        return RequestStatus.pending;
      case 'open':
        return RequestStatus.open;
      case 'assigned':
        return RequestStatus.assigned;
      case 'in_progress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'closed':
        return RequestStatus.closed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }
  
  Offer _offerFromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      requestId: json['requestId'],
      electricianId: json['electricianId'],
      electricianName: json['electricianName'],
      price: json['price'].toDouble(),
      description: json['description'],
      estimatedDuration: json['estimatedDuration'],
      status: _parseOfferStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  OfferStatus _parseOfferStatus(String status) {
    switch (status) {
      case 'accepted':
        return OfferStatus.accepted;
      case 'rejected':
        return OfferStatus.rejected;
      default:
        return OfferStatus.pending;
    }
  }
  
  ChatMessage _messageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      requestId: json['requestId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}

// Generic API Response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  ApiResponse._({this.data, this.error, required this.isSuccess});
  
  factory ApiResponse.success(T data) => ApiResponse._(data: data, isSuccess: true);
  factory ApiResponse.error(String message) => ApiResponse._(error: message, isSuccess: false);
}
