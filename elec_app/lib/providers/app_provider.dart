import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../data/mock_data.dart';

enum AppLanguage { ar, fr }

class AppProvider extends ChangeNotifier {
  static const Duration _requestTimeout = Duration(seconds: 8);
  String? _preferredApiBaseUrl;

  List<String> get _apiBaseUrls {
    const overridden = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (overridden.isNotEmpty) {
      return [overridden];
    }

    if (kIsWeb) {
      return const ['http://localhost:3000/api', 'http://localhost:3001/api'];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return const [
        'http://10.0.2.2:3000/api',
        'http://10.0.2.2:3001/api',
        'http://localhost:3000/api',
        'http://localhost:3001/api',
      ];
    }

    return const ['http://localhost:3000/api', 'http://localhost:3001/api'];
  }

  User? _currentUser;
  List<ServiceRequest> _requests = [];
  List<Offer> _offers = [];
  List<ChatMessage> _messages = [];
  String? _selectedWilaya;
  String? _selectedCommune;
  String? _authError;
  bool _isLoading = false;
  AppLanguage _language = AppLanguage.ar;

  // Getters
  User? get currentUser => _currentUser;
  List<ServiceRequest> get requests => _requests;
  List<ServiceRequest> get allRequests => _requests;
  List<Offer> get offers => _offers;
  List<ChatMessage> get messages => _messages;
  String? get selectedWilaya => _selectedWilaya;
  String? get selectedCommune => _selectedCommune;
  String? get authError => _authError;
  bool get isLoading => _isLoading;
  AppLanguage get language => _language;
  bool get isFrench => _language == AppLanguage.fr;
  bool get isLoggedIn => _currentUser != null;
  bool get isClient => _currentUser?.role == UserRole.client;
  bool get isElectrician => _currentUser?.role == UserRole.electrician;
  bool get hasActiveSubscription => _currentUser?.isSubscriptionActive ?? false;
  bool get canUseElectricianFeatures {
    final status = _currentUser?.subscriptionStatus;
    return status == SubscriptionStatus.active ||
        status == SubscriptionStatus.pending;
  }

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  List<String> get _orderedApiBaseUrls {
    final candidates = _apiBaseUrls;
    final preferred = _preferredApiBaseUrl;
    if (preferred == null || !candidates.contains(preferred)) {
      return candidates;
    }

    return [preferred, ...candidates.where((url) => url != preferred)];
  }

  Future<http.Response> _getWithFallback(String path) async {
    Object? lastError;
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    for (final baseUrl in _orderedApiBaseUrls) {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/$normalizedPath'), headers: _headers)
            .timeout(_requestTimeout);

        if (response.statusCode != 404) {
          _preferredApiBaseUrl = baseUrl;
          return response;
        }
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception('Failed GET $path. Last error: $lastError');
  }

  Future<http.Response> _postWithFallback(String path, {Object? body}) async {
    Object? lastError;
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    for (final baseUrl in _orderedApiBaseUrls) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/$normalizedPath'),
              headers: _headers,
              body: body,
            )
            .timeout(_requestTimeout);

        if (response.statusCode != 404) {
          _preferredApiBaseUrl = baseUrl;
          return response;
        }
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception('Failed POST $path. Last error: $lastError');
  }

  String? _extractApiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final value = decoded['error']?.toString();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    } catch (_) {
      // Ignore non-JSON bodies.
    }
    return null;
  }

  User _userFromApi(Map<String, dynamic> json) {
    final role = json['role'] == 'electrician'
        ? UserRole.electrician
        : UserRole.client;

    SubscriptionStatus subStatus = SubscriptionStatus.inactive;
    switch (json['subscriptionStatus']) {
      case 'active':
        subStatus = SubscriptionStatus.active;
        break;
      case 'expired':
        subStatus = SubscriptionStatus.expired;
        break;
      case 'pending':
        subStatus = SubscriptionStatus.pending;
        break;
      default:
        subStatus = SubscriptionStatus.inactive;
    }

    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: role,
      wilaya: json['wilaya']?.toString(),
      commune: json['commune']?.toString(),
      yearsExperience: json['yearsExperience'] as int?,
      idCardImage: json['idCardImage']?.toString(),
      profileImage: json['profileImage']?.toString(),
      subscriptionStatus: subStatus,
      subscriptionStartDate: json['subscriptionStartDate'] != null
          ? DateTime.tryParse(json['subscriptionStartDate'].toString())
          : null,
      subscriptionEndDate: json['subscriptionEndDate'] != null
          ? DateTime.tryParse(json['subscriptionEndDate'].toString())
          : null,
      isAccountActive: json['accountStatus'] != 'suspended',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String _serviceTypeFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('install') || t.contains('تركيب')) return 'installation';
    if (t.contains('repair') || t.contains('إصلاح')) return 'repair';
    if (t.contains('maint') || t.contains('صيانة')) return 'maintenance';
    if (t.contains('consult') || t.contains('استشار')) return 'consultation';
    return 'other';
  }

  RequestStatus _requestStatusFromApi(String? status) {
    switch (status) {
      case 'assigned':
      case 'in_progress':
      case 'completed':
        return RequestStatus.assigned;
      case 'closed':
      case 'cancelled':
        return RequestStatus.closed;
      default:
        return RequestStatus.open;
    }
  }

  OfferStatus _offerStatusFromApi(String? status) {
    switch (status) {
      case 'accepted':
        return OfferStatus.accepted;
      case 'rejected':
        return OfferStatus.rejected;
      default:
        return OfferStatus.pending;
    }
  }

  Future<void> _refreshCurrentUserFromApi() async {
    if (_currentUser == null) return;

    final response = await _getWithFallback('/users/${_currentUser!.id}');
    if (response.statusCode != 200) {
      return;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _currentUser = _userFromApi(data);
  }

  Future<void> _loadDataFromApi() async {
    if (_currentUser == null) return;

    // Keep local session in sync with admin-side account/subscription updates.
    await _refreshCurrentUserFromApi();

    final requestsResponse = await _getWithFallback('/requests');

    final offersResponse = await _getWithFallback('/offers');

    final messagesResponse = await _getWithFallback('/messages');

    if (requestsResponse.statusCode != 200 ||
        offersResponse.statusCode != 200 ||
        messagesResponse.statusCode != 200) {
      throw Exception('Failed to load remote data');
    }

    final requestsJson = jsonDecode(requestsResponse.body) as List<dynamic>;
    final offersJson = jsonDecode(offersResponse.body) as List<dynamic>;
    final messagesJson = jsonDecode(messagesResponse.body) as List<dynamic>;

    final loadedRequests = requestsJson
        .map((raw) => raw as Map<String, dynamic>)
        .map(
          (r) => ServiceRequest(
            id: r['id']?.toString() ?? '',
            clientId: r['clientId']?.toString() ?? '',
            clientName: r['clientName']?.toString() ?? '',
            title: r['title']?.toString() ?? (r['serviceType']?.toString() ?? 'Service request'),
            description: r['description']?.toString() ?? '',
            images: r['images'] is List
                ? List<String>.from(r['images'] as List)
                : <String>[],
            wilaya: r['wilaya']?.toString() ?? '',
            commune: r['commune']?.toString() ?? '',
            status: _requestStatusFromApi(r['status']?.toString()),
            createdAt: DateTime.tryParse(r['createdAt']?.toString() ?? '') ??
                DateTime.now(),
            assignedElectricianId: r['assignedElectricianId']?.toString(),
            assignedElectricianName: r['assignedElectricianName']?.toString(),
          ),
        )
        .toList();

    final loadedOffers = offersJson
        .map((raw) => raw as Map<String, dynamic>)
        .map(
          (o) => Offer(
            id: o['id']?.toString() ?? '',
            requestId: o['requestId']?.toString() ?? '',
            electricianId: o['electricianId']?.toString() ?? '',
            electricianName: o['electricianName']?.toString() ?? '',
            price: (o['price'] as num?)?.toDouble() ?? 0,
            message: o['message']?.toString() ?? o['description']?.toString() ?? '',
            estimatedTime: o['estimatedTime']?.toString() ??
                o['estimatedDuration']?.toString() ??
                '',
            status: _offerStatusFromApi(o['status']?.toString()),
            createdAt: DateTime.tryParse(o['createdAt']?.toString() ?? '') ??
                DateTime.now(),
            electricianExperience: (o['electricianExperience'] as num?)?.toInt() ?? 0,
            electricianRating: (o['electricianRating'] as num?)?.toDouble(),
          ),
        )
        .toList();

    final loadedMessages = messagesJson
        .map((raw) => raw as Map<String, dynamic>)
        .map(
          (m) => ChatMessage(
            id: m['id']?.toString() ?? '',
            requestId: m['requestId']?.toString() ?? '',
            senderId: m['senderId']?.toString() ?? '',
            senderName: m['senderName']?.toString() ?? '',
            message: m['message']?.toString(),
            imageUrl: m['imageUrl']?.toString(),
            createdAt: DateTime.tryParse(m['createdAt']?.toString() ?? '') ??
                DateTime.now(),
            isRead: m['isRead'] == true,
          ),
        )
        .toList();

    // Compute offers count for each request from loaded offers
    _requests = loadedRequests
        .map(
          (r) => ServiceRequest(
            id: r.id,
            clientId: r.clientId,
            clientName: r.clientName,
            title: r.title,
            description: r.description,
            images: r.images,
            wilaya: r.wilaya,
            commune: r.commune,
            status: r.status,
            createdAt: r.createdAt,
            offersCount: loadedOffers.where((o) => o.requestId == r.id).length,
            assignedElectricianId: r.assignedElectricianId,
            assignedElectricianName: r.assignedElectricianName,
          ),
        )
        .toList();

    _offers = loadedOffers;
    _messages = loadedMessages;
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }

  void toggleLanguage() {
    _language = _language == AppLanguage.ar ? AppLanguage.fr : AppLanguage.ar;
    notifyListeners();
  }

  // Initialize data
  void initializeData() {
    void _run() async {
      try {
        await _loadDataFromApi();
      } catch (_) {
        _requests = List.from(mockRequests);
        _offers = List.from(mockOffers);
        _messages = List.from(mockMessages);
      }
      notifyListeners();
    }

    _run();
  }

  // Authentication
  Future<bool> loginAsClient(String phone, String password) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final response = await _postWithFallback(
        '/auth/login',
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'role': 'client',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = _userFromApi(data['user'] as Map<String, dynamic>);
        await _loadDataFromApi();
        _authError = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _authError = _extractApiError(response.body) ?? 'Login failed';
    } catch (_) {
      _authError = 'Connection to server failed';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> loginAsElectrician(String phone, String password) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final response = await _postWithFallback(
        '/auth/login',
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'role': 'electrician',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = _userFromApi(data['user'] as Map<String, dynamic>);
        await _loadDataFromApi();
        _authError = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _authError = _extractApiError(response.body) ?? 'Login failed';
    } catch (_) {
      _authError = 'Connection to server failed';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> registerClient({
    required String name,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final response = await _postWithFallback(
        '/users',
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'password': password,
          'role': 'client',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = _userFromApi(data);
        await _loadDataFromApi();
        _authError = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _authError = _extractApiError(response.body) ?? 'Registration failed';
    } catch (_) {
      _authError = 'Connection to server failed';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> registerElectrician({
    required String name,
    required String phone,
    required String password,
    required String wilaya,
    required String commune,
    required int yearsExperience,
    String? idCardImage,
    String? profileImage,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final response = await _postWithFallback(
        '/users',
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'password': password,
          'role': 'electrician',
          'wilaya': wilaya,
          'commune': commune,
          'yearsExperience': yearsExperience,
          if (idCardImage != null) 'idCardImage': idCardImage,
          if (profileImage != null) 'profileImage': profileImage,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = _userFromApi(data);
        await _loadDataFromApi();
        _authError = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _authError = _extractApiError(response.body) ?? 'Registration failed';
    } catch (_) {
      _authError = 'Connection to server failed';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    _selectedWilaya = null;
    _selectedCommune = null;
    notifyListeners();
  }

  // Filters
  void setWilayaFilter(String? wilaya) {
    _selectedWilaya = wilaya;
    _selectedCommune = null; // Reset commune when wilaya changes
    notifyListeners();
  }

  void setCommuneFilter(String? commune) {
    _selectedCommune = commune;
    notifyListeners();
  }

  void clearFilters() {
    _selectedWilaya = null;
    _selectedCommune = null;
    notifyListeners();
  }

  // Filtered requests for electricians
  List<ServiceRequest> get filteredRequests {
    var filtered =
        _requests.where((r) => r.status == RequestStatus.open).toList();

    if (_selectedWilaya != null) {
      filtered = filtered.where((r) => r.wilaya == _selectedWilaya).toList();
    }

    if (_selectedCommune != null) {
      filtered = filtered.where((r) => r.commune == _selectedCommune).toList();
    }

    return filtered;
  }

  // Client's requests
  List<ServiceRequest> get clientRequests {
    if (_currentUser == null) return [];
    return _requests.where((r) => r.clientId == _currentUser!.id).toList();
  }

  // Electrician's assigned requests
  List<ServiceRequest> get electricianAssignedRequests {
    if (_currentUser == null) return [];
    return _requests
        .where((r) => r.assignedElectricianId == _currentUser!.id)
        .toList();
  }

  // Create new request
  Future<bool> createRequest({
    required String title,
    required String description,
    required String wilaya,
    required String commune,
    List<String> images = const [],
  }) async {
    print('[Provider] createRequest called with title: $title');
    _isLoading = true;
    notifyListeners();

    if (_currentUser == null) {
      print('[Provider] Error: No current user');
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      print('[Provider] Sending POST to /requests with fallback URLs: $_orderedApiBaseUrls');
      
      final response = await _postWithFallback(
        '/requests',
        body: jsonEncode({
          'clientId': _currentUser!.id,
          'clientName': _currentUser!.name,
          'title': title,
          'serviceType': _serviceTypeFromTitle(title),
          'description': description,
          'wilaya': wilaya,
          'commune': commune,
          'images': images,
        }),
      );

      print('[Provider] Response status: ${response.statusCode}');
      print('[Provider] Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newRequest = ServiceRequest(
          id: data['id']?.toString() ?? 'r${DateTime.now().millisecondsSinceEpoch}',
          clientId: data['clientId']?.toString() ?? _currentUser!.id,
          clientName: data['clientName']?.toString() ?? _currentUser!.name,
          title: data['title']?.toString() ?? title,
          description: data['description']?.toString() ?? description,
          images: images,
          wilaya: data['wilaya']?.toString() ?? wilaya,
          commune: data['commune']?.toString() ?? commune,
          createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
          status: RequestStatus.open,
        );

        _requests.insert(0, newRequest);
        print('[Provider] Request created successfully, ID: ${newRequest.id}');
        unawaited(_loadDataFromApi());
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('[Provider] Exception during API call: $e');
      // Fallback to local mock mode
    }

    final newRequest = ServiceRequest(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      clientId: _currentUser!.id,
      clientName: _currentUser!.name,
      title: title,
      description: description,
      images: images,
      wilaya: wilaya,
      commune: commune,
      createdAt: DateTime.now(),
    );

    _requests.insert(0, newRequest);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Get offers for a request
  List<Offer> getOffersForRequest(String requestId) {
    return _offers.where((o) => o.requestId == requestId).toList();
  }

  // Send offer (electrician)
  Future<bool> sendOffer({
    required String requestId,
    required double price,
    required String message,
    required String estimatedTime,
  }) async {
    if (_currentUser == null) return false;

    if (!canUseElectricianFeatures) {
      try {
        await _refreshCurrentUserFromApi();
      } catch (_) {
        // Ignore network refresh failure and keep existing guard behavior.
      }

      if (!canUseElectricianFeatures) {
        return false;
      }
    }

    _isLoading = true;
    notifyListeners();
    try {
      Offer? savedOffer;

      try {
        final response = await _postWithFallback(
          '/offers',
          body: jsonEncode({
            'requestId': requestId,
            'electricianId': _currentUser!.id,
            'electricianName': _currentUser!.name,
            'price': price,
            'message': message,
            'description': message,
            'estimatedTime': estimatedTime,
            'estimatedDuration': estimatedTime,
            'electricianExperience': _currentUser!.yearsExperience ?? 0,
          }),
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          savedOffer = Offer(
            id: data['id']?.toString() ??
                'o${DateTime.now().millisecondsSinceEpoch}',
            requestId: data['requestId']?.toString() ?? requestId,
            electricianId: data['electricianId']?.toString() ?? _currentUser!.id,
            electricianName:
                data['electricianName']?.toString() ?? _currentUser!.name,
            electricianImage: _currentUser!.profileImage,
            price: (data['price'] as num?)?.toDouble() ?? price,
            message:
                data['message']?.toString() ??
                data['description']?.toString() ??
                message,
            estimatedTime:
                data['estimatedTime']?.toString() ??
                data['estimatedDuration']?.toString() ??
                estimatedTime,
            status: _offerStatusFromApi(data['status']?.toString()),
            createdAt:
                DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
                DateTime.now(),
            electricianExperience:
                (data['electricianExperience'] as num?)?.toInt() ??
                (_currentUser!.yearsExperience ?? 0),
            electricianRating: (data['electricianRating'] as num?)?.toDouble(),
          );
        } else if (response.statusCode == 400) {
          final apiError = _extractApiError(response.body)?.toLowerCase() ?? '';
          if (apiError.contains('already sent an offer')) {
            await _loadDataFromApi();
            return true;
          }
          return false;
        } else {
          return false;
        }
      } catch (_) {
        // Keep local fallback for offline/dev mode.
      }

      final newOffer =
          savedOffer ??
          Offer(
            id: 'o${DateTime.now().millisecondsSinceEpoch}',
            requestId: requestId,
            electricianId: _currentUser!.id,
            electricianName: _currentUser!.name,
            electricianImage: _currentUser!.profileImage,
            price: price,
            message: message,
            estimatedTime: estimatedTime,
            createdAt: DateTime.now(),
            electricianExperience: _currentUser!.yearsExperience ?? 0,
          );

      final existingIndex = _offers.indexWhere((o) => o.id == newOffer.id);
      if (existingIndex == -1) {
        _offers.add(newOffer);
      } else {
        _offers[existingIndex] = newOffer;
      }

      // Update request offers count
      final requestIndex = _requests.indexWhere((r) => r.id == requestId);
      if (requestIndex != -1) {
        final request = _requests[requestIndex];
        _requests[requestIndex] = ServiceRequest(
          id: request.id,
          clientId: request.clientId,
          clientName: request.clientName,
          title: request.title,
          description: request.description,
          images: request.images,
          wilaya: request.wilaya,
          commune: request.commune,
          status: request.status,
          createdAt: request.createdAt,
          offersCount: request.offersCount + 1,
          assignedElectricianId: request.assignedElectricianId,
          assignedElectricianName: request.assignedElectricianName,
        );
      }

      unawaited(_loadDataFromApi());

      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Accept offer (client)
  Future<bool> acceptOffer(String offerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      try {
        Object? lastError;
        for (final baseUrl in _orderedApiBaseUrls) {
          try {
            final response = await http
                .put(
                  Uri.parse('$baseUrl/offers/$offerId'),
                  headers: _headers,
                  body: jsonEncode({'status': 'accepted'}),
                )
                .timeout(_requestTimeout);

            if (response.statusCode == 200) {
              _preferredApiBaseUrl = baseUrl;
              // Success, continue to local state update
              break;
            }
          } catch (e) {
            lastError = e;
          }
        }
      } catch (_) {
        // Fallback to local-only update for offline/dev mode
      }

      final offerIndex = _offers.indexWhere((o) => o.id == offerId);
      if (offerIndex == -1) {
        return false;
      }

      final offer = _offers[offerIndex];

      // Update offer status
      _offers[offerIndex] = Offer(
        id: offer.id,
        requestId: offer.requestId,
        electricianId: offer.electricianId,
        electricianName: offer.electricianName,
        electricianImage: offer.electricianImage,
        price: offer.price,
        message: offer.message,
        estimatedTime: offer.estimatedTime,
        status: OfferStatus.accepted,
        createdAt: offer.createdAt,
        electricianExperience: offer.electricianExperience,
        electricianRating: offer.electricianRating,
      );

      // Update request status
      final requestIndex = _requests.indexWhere((r) => r.id == offer.requestId);
      if (requestIndex != -1) {
        final request = _requests[requestIndex];
        _requests[requestIndex] = ServiceRequest(
          id: request.id,
          clientId: request.clientId,
          clientName: request.clientName,
          title: request.title,
          description: request.description,
          images: request.images,
          wilaya: request.wilaya,
          commune: request.commune,
          status: RequestStatus.assigned,
          createdAt: request.createdAt,
          offersCount: request.offersCount,
          assignedElectricianId: offer.electricianId,
          assignedElectricianName: offer.electricianName,
        );
      }

      // Reject other offers for this request
      for (int i = 0; i < _offers.length; i++) {
        if (_offers[i].requestId == offer.requestId && _offers[i].id != offerId) {
          final otherOffer = _offers[i];
          _offers[i] = Offer(
            id: otherOffer.id,
            requestId: otherOffer.requestId,
            electricianId: otherOffer.electricianId,
            electricianName: otherOffer.electricianName,
            electricianImage: otherOffer.electricianImage,
            price: otherOffer.price,
            message: otherOffer.message,
            estimatedTime: otherOffer.estimatedTime,
            status: OfferStatus.rejected,
            createdAt: otherOffer.createdAt,
            electricianExperience: otherOffer.electricianExperience,
            electricianRating: otherOffer.electricianRating,
          );
        }
      }

      unawaited(_loadDataFromApi());
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Chat messages for a request
  List<ChatMessage> getMessagesForRequest(String requestId) {
    return _messages.where((m) => m.requestId == requestId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> refreshMessagesForRequest(String requestId) async {
    if (_currentUser == null) return;

    try {
      final response = await _getWithFallback('/messages?requestId=$requestId');
      if (response.statusCode != 200) return;

      final messagesJson = jsonDecode(response.body) as List<dynamic>;
      final remoteMessages = messagesJson
          .map((raw) => raw as Map<String, dynamic>)
          .map(
            (m) => ChatMessage(
              id: m['id']?.toString() ?? '',
              requestId: m['requestId']?.toString() ?? '',
              senderId: m['senderId']?.toString() ?? '',
              senderName: m['senderName']?.toString() ?? '',
              message: m['message']?.toString(),
              imageUrl: m['imageUrl']?.toString(),
              createdAt:
                  DateTime.tryParse(m['createdAt']?.toString() ?? '') ??
                  DateTime.now(),
              isRead: m['isRead'] == true,
            ),
          )
          .toList();

      // Replace only this request's messages while keeping other requests cached.
      _messages.removeWhere((m) => m.requestId == requestId);
      _messages.addAll(remoteMessages);
      notifyListeners();
    } catch (_) {
      // Ignore refresh failures and keep local cache.
    }
  }

  // Send message
  Future<bool> sendMessage({
    required String requestId,
    String? message,
    String? imageUrl,
  }) async {
    if (_currentUser == null) return false;

    ServiceRequest? request;
    for (final item in _requests) {
      if (item.id == requestId) {
        request = item;
        break;
      }
    }

    String? receiverId;
    if (_currentUser!.role == UserRole.client) {
      receiverId = request?.assignedElectricianId;
      if (receiverId == null || receiverId.isEmpty) {
        Offer? acceptedOffer;
        for (final offer in _offers) {
          if (offer.requestId == requestId && offer.status == OfferStatus.accepted) {
            acceptedOffer = offer;
            break;
          }
        }
        receiverId = acceptedOffer?.electricianId;
      }
    } else {
      receiverId = request?.clientId;
    }

    ChatMessage? savedMessage;

    try {
      final response = await _postWithFallback(
        '/messages',
        body: jsonEncode({
          'requestId': requestId,
          'senderId': _currentUser!.id,
          'senderName': _currentUser!.name,
          'receiverId': receiverId,
          'message': message,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        savedMessage = ChatMessage(
          id: data['id']?.toString() ?? 'm${DateTime.now().millisecondsSinceEpoch}',
          requestId: data['requestId']?.toString() ?? requestId,
          senderId: data['senderId']?.toString() ?? _currentUser!.id,
          senderName: data['senderName']?.toString() ?? _currentUser!.name,
          message: data['message']?.toString() ?? message,
          imageUrl: data['imageUrl']?.toString() ?? imageUrl,
          createdAt:
              DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
              DateTime.now(),
          isRead: data['isRead'] == true,
        );
      }
    } catch (_) {
      // Keep local fallback for offline/dev mode.
    }

    final newMessage =
        savedMessage ??
        ChatMessage(
          id: 'm${DateTime.now().millisecondsSinceEpoch}',
          requestId: requestId,
          senderId: _currentUser!.id,
          senderName: _currentUser!.name,
          message: message,
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
        );

    _messages.add(newMessage);
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
    return true;
  }

  // Submit subscription payment
  Future<bool> submitSubscriptionPayment(String paymentProofImage) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // In real app, this would upload to backend
    // For demo, we'll update user status to pending
    if (_currentUser != null) {
      final updatedUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        phone: _currentUser!.phone,
        role: _currentUser!.role,
        wilaya: _currentUser!.wilaya,
        commune: _currentUser!.commune,
        yearsExperience: _currentUser!.yearsExperience,
        idCardImage: _currentUser!.idCardImage,
        profileImage: _currentUser!.profileImage,
        subscriptionStatus: SubscriptionStatus.pending,
        subscriptionStartDate: _currentUser!.subscriptionStartDate,
        subscriptionEndDate: _currentUser!.subscriptionEndDate,
        isAccountActive: _currentUser!.isAccountActive,
        createdAt: _currentUser!.createdAt,
      );
      _currentUser = updatedUser;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Check if electrician has already sent an offer for a request
  bool hasElectricianSentOffer(String requestId) {
    if (_currentUser == null) return false;
    return _offers.any(
      (o) => o.requestId == requestId && o.electricianId == _currentUser!.id,
    );
  }

  // Alias for hasElectricianSentOffer
  bool hasSubmittedOffer(String requestId) =>
      hasElectricianSentOffer(requestId);

  // Submit offer (alias for sendOffer for compatibility)
  Future<bool> submitOffer({
    required String requestId,
    required double price,
    required String estimatedTime,
    String? message,
  }) {
    return sendOffer(
      requestId: requestId,
      price: price,
      message: message ?? 'أنا جاهز للعمل على هذا الطلب',
      estimatedTime: estimatedTime,
    );
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    int? yearsExperience,
    String? profileImage,
  }) async {
    if (_currentUser == null) return false;

    final updatedUser = User(
      id: _currentUser!.id,
      name: name,
      phone: phone,
      role: _currentUser!.role,
      wilaya: _currentUser!.wilaya,
      commune: _currentUser!.commune,
      yearsExperience: yearsExperience ?? _currentUser!.yearsExperience,
      idCardImage: _currentUser!.idCardImage,
      profileImage: profileImage ?? _currentUser!.profileImage,
      subscriptionStatus: _currentUser!.subscriptionStatus,
      subscriptionStartDate: _currentUser!.subscriptionStartDate,
      subscriptionEndDate: _currentUser!.subscriptionEndDate,
      isAccountActive: _currentUser!.isAccountActive,
      createdAt: _currentUser!.createdAt,
    );

    _currentUser = updatedUser;

    if (updatedUser.role == UserRole.client) {
      final index = mockClients.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        mockClients[index] = updatedUser;
      }
    } else {
      final index = mockElectricians.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        mockElectricians[index] = updatedUser;
      }
    }

    notifyListeners();
    return true;
  }
}
