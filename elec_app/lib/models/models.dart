// User roles
enum UserRole { client, electrician }

// Subscription status
enum SubscriptionStatus { active, inactive, expired, pending }

// Payment status
enum PaymentStatus { pending, approved, rejected }

// Request status
enum RequestStatus { open, assigned, closed }

// Offer status
enum OfferStatus { pending, accepted, rejected }

// User model
class User {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? wilaya;
  final String? commune;
  final int? yearsExperience;
  final String? idCardImage;
  final String? profileImage;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isAccountActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.wilaya,
    this.commune,
    this.yearsExperience,
    this.idCardImage,
    this.profileImage,
    this.subscriptionStatus = SubscriptionStatus.inactive,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isAccountActive = true,
    required this.createdAt,
  });

  bool get isSubscriptionActive {
    if (subscriptionStatus == SubscriptionStatus.inactive ||
        subscriptionStatus == SubscriptionStatus.expired) {
      return false;
    }

    // If dates exist, validate they're within range (using date-only comparison)
    if (subscriptionStartDate != null && subscriptionEndDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDay = DateTime(
        subscriptionStartDate!.year,
        subscriptionStartDate!.month,
        subscriptionStartDate!.day,
      );
      final endDay = DateTime(
        subscriptionEndDate!.year,
        subscriptionEndDate!.month,
        subscriptionEndDate!.day,
      );

      return today.isAtSameMomentAs(startDay) ||
          today.isAfter(startDay) &&
              today.isBefore(endDay.add(Duration(days: 1)));
    }

    // No dates means invalid
    return false;
  }
}

// Service Request model
class ServiceRequest {
  final String id;
  final String clientId;
  final String clientName;
  final String title;
  final String description;
  final List<String> images;
  final String wilaya;
  final String commune;
  final RequestStatus status;
  final DateTime createdAt;
  final int offersCount;
  final String? assignedElectricianId;
  final String? assignedElectricianName;

  ServiceRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.title,
    required this.description,
    required this.images,
    required this.wilaya,
    required this.commune,
    this.status = RequestStatus.open,
    required this.createdAt,
    this.offersCount = 0,
    this.assignedElectricianId,
    this.assignedElectricianName,
  });
}

// Offer model
class Offer {
  final String id;
  final String requestId;
  final String electricianId;
  final String electricianName;
  final String? electricianImage;
  final double price;
  final String message;
  final String estimatedTime;
  final OfferStatus status;
  final DateTime createdAt;
  final int electricianExperience;
  final double? electricianRating;

  Offer({
    required this.id,
    required this.requestId,
    required this.electricianId,
    required this.electricianName,
    this.electricianImage,
    required this.price,
    required this.message,
    required this.estimatedTime,
    this.status = OfferStatus.pending,
    required this.createdAt,
    required this.electricianExperience,
    this.electricianRating,
  });
}

// Chat Message model
class ChatMessage {
  final String id;
  final String requestId;
  final String senderId;
  final String senderName;
  final String? message;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.senderName,
    this.message,
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
  });
}

// Subscription Payment model
class SubscriptionPayment {
  final String id;
  final String electricianId;
  final String paymentProofImage;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;

  SubscriptionPayment({
    required this.id,
    required this.electricianId,
    required this.paymentProofImage,
    required this.amount,
    this.status = PaymentStatus.pending,
    required this.createdAt,
  });
}
