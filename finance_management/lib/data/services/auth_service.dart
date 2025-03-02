import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio();
  final String _baseUrl =
      'http://your-api-base-url.com/api'; // Replace with your actual API URL

  // Store tokens after login/registration
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Remove tokens on logout
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Get stored refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String dateOfBirth,
    required String password,
    String? monthlyIncome,
    String? financialGoal,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phoneNumber,
          'date_of_birth': dateOfBirth,
          'password': password,
          'monthly_income': monthlyIncome,
          'financial_goal': financialGoal,
        },
      );

      // If successful, save tokens
      if (response.statusCode == 201) {
        await _saveTokens(
          response.data['tokens']['accessToken'],
          response.data['tokens']['refreshToken'],
        );
      }

      return response.data;
    } on DioException catch (e) {
      // Handle and transform DioException
      if (e.response != null) {
        // The server responded with an error
        return {
          'status': 'error',
          'error':
              e.response?.data['error'] ??
              {
                'message': 'An error occurred during registration',
                'code': 'UNKNOWN_ERROR',
              },
        };
      } else {
        // Network or connection error
        return {
          'status': 'error',
          'error': {
            'message': 'Network error. Please check your connection',
            'code': 'NETWORK_ERROR',
          },
        };
      }
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );

      // If successful, save tokens
      if (response.statusCode == 200) {
        await _saveTokens(
          response.data['tokens']['accessToken'],
          response.data['tokens']['refreshToken'],
        );
      }

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'status': 'error',
          'error':
              e.response?.data['error'] ??
              {
                'message': 'An error occurred during login',
                'code': 'UNKNOWN_ERROR',
              },
        };
      } else {
        return {
          'status': 'error',
          'error': {
            'message': 'Network error. Please check your connection',
            'code': 'NETWORK_ERROR',
          },
        };
      }
    }
  }

  // Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        return {
          'status': 'error',
          'error': {'message': 'Not logged in', 'code': 'NOT_LOGGED_IN'},
        };
      }

      final response = await _dio.post(
        '$_baseUrl/auth/logout',
        data: {'refreshToken': refreshToken},
      );

      // Clear tokens regardless of response
      await _clearTokens();

      return response.data;
    } on DioException catch (e) {
      // Still clear tokens even if there's an error
      await _clearTokens();

      if (e.response != null) {
        return {
          'status': 'error',
          'error':
              e.response?.data['error'] ??
              {
                'message': 'An error occurred during logout',
                'code': 'UNKNOWN_ERROR',
              },
        };
      } else {
        return {
          'status': 'error',
          'error': {
            'message': 'Network error. Please check your connection',
            'code': 'NETWORK_ERROR',
          },
        };
      }
    }
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        return {
          'status': 'error',
          'error': {
            'message': 'No refresh token found',
            'code': 'NO_REFRESH_TOKEN',
          },
        };
      }

      final response = await _dio.post(
        '$_baseUrl/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      // If successful, save new tokens
      if (response.statusCode == 200) {
        await _saveTokens(
          response.data['tokens']['accessToken'],
          response.data['tokens']['refreshToken'],
        );
      }

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'status': 'error',
          'error':
              e.response?.data['error'] ??
              {
                'message': 'An error occurred while refreshing token',
                'code': 'UNKNOWN_ERROR',
              },
        };
      } else {
        return {
          'status': 'error',
          'error': {
            'message': 'Network error. Please check your connection',
            'code': 'NETWORK_ERROR',
          },
        };
      }
    }
  }

  // Request password reset
  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/request-password-reset',
        data: {'email': email},
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'status': 'error',
          'error':
              e.response?.data['error'] ??
              {
                'message': 'An error occurred while requesting password reset',
                'code': 'UNKNOWN_ERROR',
              },
        };
      } else {
        return {
          'status': 'error',
          'error': {
            'message': 'Network error. Please check your connection',
            'code': 'NETWORK_ERROR',
          },
        };
      }
    }
  }

  // Reset password with token
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'status': 'error',
          'error':
              e.response?.data['error'] ??
              {
                'message': 'An error occurred while resetting password',
                'code': 'UNKNOWN_ERROR',
              },
        };
      } else {
        return {
          'status': 'error',
          'error': {
            'message': 'Network error. Please check your connection',
            'code': 'NETWORK_ERROR',
          },
        };
      }
    }
  }

  // Verify email with token
  Future<Map<String, dynamic>> verifyEmail({required String token}) async {
    try {
      final response = await _dio.get('$_baseUrl/auth/verify-email/$token');

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'status': 'error',
          'error':
              e.response?.data['error'] ??
              {
                'message': 'An error occurred while verifying email',
                'code': 'UNKNOWN_ERROR',
              },
        };
      } else {
        return {
          'status': 'error',
          'error': {
            'message': 'Network error. Please check your connection',
            'code': 'NETWORK_ERROR',
          },
        };
      }
    }
  }
}
