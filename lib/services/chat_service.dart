import 'package:quan_ly_nha_thuoc/models/chat_model.dart';
import 'package:quan_ly_nha_thuoc/services/api_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();
  final String _basePath = '/Chat';

  /// Tạo cuộc trò chuyện mới hoặc lấy cuộc trò chuyện hiện tại
  Future<Conversation> createConversation(String maKH) async {
    try {
      final response = await _apiService.post(
        '$_basePath/conversations',
        data: {'MaKH': maKH},
      );

      final apiResponse = ApiResponse<Conversation>.fromJson(
        response.data,
        (json) => Conversation.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw Exception(apiResponse.message ?? 'Lỗi tạo cuộc trò chuyện');
      }
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  /// Lấy cuộc trò chuyện theo mã khách hàng
  Future<Conversation?> getConversationByCustomer(String maKH) async {
    try {
      final response = await _apiService.get(
        '$_basePath/conversations/by-kh/$maKH',
      );

      final apiResponse = ApiResponse<Conversation>.fromJson(
        response.data,
        (json) => Conversation.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.isSuccess) {
        return apiResponse.data;
      }
      return null;
    } catch (e) {
      // Nếu lỗi 404 nghĩa là chưa có cuộc trò chuyện
      if (e.toString().contains('404')) {
        return null;
      }
      // Các lỗi khác thì throw
      throw Exception(ApiService.handleError(e));
    }
  }

  /// Lấy danh sách tin nhắn của cuộc trò chuyện
  Future<List<Message>> getMessages(
    int conversationId, {
    int skip = 0,
    int take = 50,
  }) async {
    try {
      final response = await _apiService.get(
        '$_basePath/conversations/$conversationId/messages',
        queryParameters: {'skip': skip, 'take': take},
      );

      final apiResponse = ApiResponse<List<Message>>.fromJson(
        response.data,
        (json) =>
            (json as List)
                .map((e) => Message.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw Exception(apiResponse.message ?? 'Lỗi lấy tin nhắn');
      }
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }

  /// Gửi tin nhắn
  Future<Message> sendMessage(ChatCreateMessageDto message) async {
    try {
      final response = await _apiService.post(
        '$_basePath/messages',
        data: message.toJson(),
      );

      final apiResponse = ApiResponse<Message>.fromJson(
        response.data,
        (json) => Message.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw Exception(apiResponse.message ?? 'Lỗi gửi tin nhắn');
      }
    } catch (e) {
      throw Exception(ApiService.handleError(e));
    }
  }
}
