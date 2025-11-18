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

    return SimplePaymentCreateResponse(
      success: data['success'] == true || statusFlag == 1,
      paymentUrl: (data['paymentUrl'] ?? '') as String,
      orderCode: (data['orderCode'] ?? '') as String,
      amount:
          (data['amount'] ?? 0) is num
              ? (data['amount'] as num).toInt()
              : int.tryParse('${data['amount']}') ?? 0,
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

    return SimplePaymentStatusResponse(
      orderCode: (data['orderCode'] ?? '') as String,
      status: (data['status'] ?? '') as String,
      isPaid: data['isPaid'] == true || statusFlag == 1,
      amount:
          (data['amount'] ?? 0) is num
              ? (data['amount'] as num).toInt()
              : int.tryParse('${data['amount']}') ?? 0,
      message: (data['message'] ?? json['message']) as String?,
    );
  }
}
