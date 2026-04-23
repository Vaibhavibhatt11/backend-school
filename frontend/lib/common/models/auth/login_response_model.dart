class LoginResponseModel {
  LoginResponseModel({
    required this.raw,
    required this.success,
    required this.message,
    required this.token,
    this.data,
  });

  final Map<String, dynamic> raw;
  final bool success;
  final String? message;
  final String token;
  final Map<String, dynamic>? data;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic dataDynamic = json['data'];
    final Map<String, dynamic>? dataMap =
        dataDynamic is Map<String, dynamic> ? dataDynamic : null;

    final token =
        (dataMap?['accessToken'] ??
                dataMap?['token'] ??
                json['accessToken'] ??
                json['token'] ??
                '')
            .toString();

    return LoginResponseModel(
      raw: json,
      success: (json['success'] == true) || token.isNotEmpty,
      message: json['message']?.toString(),
      token: token,
      data: dataMap,
    );
  }
}

