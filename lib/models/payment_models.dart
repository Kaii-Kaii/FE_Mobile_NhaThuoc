class SimplePaymentCreateResponse {
  final bool success;
  final String paymentUrl;
  final String orderCode;
  final int amount;
  final String? message;

  SimplePaymentCreateResponse({
    required this.success,
    required this.paymentUrl,
    required this.orderCode,
    required this.amount,
    this.message,
  });

  factory SimplePaymentCreateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final statusFlag = json['status'];

    final rawAmount = data['amount'];

    return SimplePaymentCreateResponse(
      success: data['success'] == true || statusFlag == 1,
      paymentUrl: (data['paymentUrl'] ?? '') as String,
      orderCode: (data['orderCode'] ?? '') as String,
      amount:
          rawAmount is num
              ? rawAmount.toInt()
              : int.tryParse('$rawAmount') ?? 0,
      message: (data['message'] ?? json['message']) as String?,
    );
  }
}

class SimplePaymentStatusResponse {
  final String orderCode;
  final String status;
  final bool isPaid;
  final int amount;
  final String? message;

  SimplePaymentStatusResponse({
    required this.orderCode,
    required this.status,
    required this.isPaid,
    required this.amount,
    this.message,
  });

  factory SimplePaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final statusFlag = json['status'];

    final rawAmount = data['amount'];

    return SimplePaymentStatusResponse(
      orderCode: (data['orderCode'] ?? '') as String,
      status: (data['status'] ?? '') as String,
      isPaid: data['isPaid'] == true || statusFlag == 1,
      amount:
          rawAmount is num
              ? rawAmount.toInt()
              : int.tryParse('$rawAmount') ?? 0,
      message: (data['message'] ?? json['message']) as String?,
    );
  }
}
