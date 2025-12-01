/// Generic API Response Wrapper
class ApiResponse<T> {
  final int status;
  final String? message;
  final T? data;

  ApiResponse({required this.status, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      status: (json['Status'] ?? json['status']) as int? ?? 0,
      message: (json['Message'] ?? json['message']) as String?,
      data:
          (json['Data'] ?? json['data']) != null
              ? fromJsonT(json['Data'] ?? json['data'])
              : null,
    );
  }

  bool get isSuccess => status == 1;
}

/// Conversation Model (CuocTroChuyen)
class Conversation {
  final int maCuocTroChuyen;
  final String maKH;

  Conversation({required this.maCuocTroChuyen, required this.maKH});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      maCuocTroChuyen:
          (json['MaCuocTroChuyen'] ?? json['maCuocTroChuyen']) as int,
      maKH: (json['MaKH'] ?? json['maKH']) as String,
    );
  }
}

/// Conversation Summary DTO (For List)
class ConversationSummaryDto {
  final int maCuocTroChuyen;
  final String maKH;
  final String? tenKH;
  final String? lastNoiDung;
  final DateTime? lastThoiGian;
  final bool? lastLaKhachGui;
  final bool chuaTraLoi;
  final int tongTinNhan;

  ConversationSummaryDto({
    required this.maCuocTroChuyen,
    required this.maKH,
    this.tenKH,
    this.lastNoiDung,
    this.lastThoiGian,
    this.lastLaKhachGui,
    required this.chuaTraLoi,
    required this.tongTinNhan,
  });

  factory ConversationSummaryDto.fromJson(Map<String, dynamic> json) {
    return ConversationSummaryDto(
      maCuocTroChuyen:
          (json['MaCuocTroChuyen'] ?? json['maCuocTroChuyen']) as int,
      maKH: (json['MaKH'] ?? json['maKH']) as String,
      tenKH: (json['TenKH'] ?? json['tenKH']) as String?,
      lastNoiDung: (json['LastNoiDung'] ?? json['lastNoiDung']) as String?,
      lastThoiGian:
          (json['LastThoiGian'] ?? json['lastThoiGian']) != null
              ? DateTime.parse(
                (json['LastThoiGian'] ?? json['lastThoiGian']) as String,
              )
              : null,
      lastLaKhachGui:
          (json['LastLaKhachGui'] ?? json['lastLaKhachGui']) as bool?,
      chuaTraLoi: (json['ChuaTraLoi'] ?? json['chuaTraLoi']) as bool? ?? false,
      tongTinNhan: (json['TongTinNhan'] ?? json['tongTinNhan']) as int? ?? 0,
    );
  }
}

/// Message Model (TinNhan)
class Message {
  final int maTN;
  final int maCuocTroChuyen;
  final bool laKhachGui;
  final String? maNV;
  final String noiDung;
  final DateTime thoiGian;

  Message({
    required this.maTN,
    required this.maCuocTroChuyen,
    required this.laKhachGui,
    this.maNV,
    required this.noiDung,
    required this.thoiGian,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      maTN: (json['MaTN'] ?? json['maTN']) as int,
      maCuocTroChuyen:
          (json['MaCuocTroChuyen'] ?? json['maCuocTroChuyen']) as int,
      laKhachGui: (json['LaKhachGui'] ?? json['laKhachGui']) as bool,
      maNV: (json['MaNV'] ?? json['maNV']) as String?,
      noiDung: (json['NoiDung'] ?? json['noiDung']) as String,
      thoiGian:
          DateTime.parse(
            (json['ThoiGian'] ?? json['thoiGian']) as String,
          ).toLocal(),
    );
  }
}

/// DTO for sending a message
class ChatCreateMessageDto {
  final int maCuocTroChuyen;
  final bool laKhachGui;
  final String? maNV;
  final String noiDung;

  ChatCreateMessageDto({
    required this.maCuocTroChuyen,
    required this.laKhachGui,
    this.maNV,
    required this.noiDung,
  });

  Map<String, dynamic> toJson() {
    return {
      'MaCuocTroChuyen': maCuocTroChuyen,
      'LaKhachGui': laKhachGui,
      if (maNV != null) 'MaNV': maNV,
      'NoiDung': noiDung,
    };
  }
}
