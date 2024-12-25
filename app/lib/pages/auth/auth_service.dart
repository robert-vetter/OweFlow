import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  Future<bool> isEmailUsed(String email) async {
    try {
      final response =
          await _client.rpc('is_email_used', params: {'email_to_check': email});
      return response as bool;
    } catch (e) {
      throw Exception('Error checking email: $e');
    }
  }

  Future<bool> isPhoneUsed(String phone) async {
    try {
      final response =
          await _client.rpc('is_phone_used', params: {'phone_to_check': phone});
      return response as bool;
    } catch (e) {
      throw Exception('Error checking phone: $e');
    }
  }

  Future<bool> isUsernameUsed(String username) async {
    try {
      final response = await _client
          .rpc('is_username_used', params: {'username_to_check': username});
      return response as bool;
    } catch (e) {
      throw Exception('Error checking username: $e');
    }
  }

  //Verifikation from phone number and email
  // Send OTP for email verification
  Future<bool> sendEmailVerification(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email);
      return true;
    } catch (e) {
      print('Failed to send email OTP: $e');
      return false;
    }
  }

  // Verify email with OTP
  Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.email,
        token: otp,
        email: email,
      );
      return response.session != null;
    } catch (e) {
      print('Failed to verify email OTP: $e');
      return false;
    }
  }

  // Send OTP for phone verification
  Future<bool> sendPhoneVerification(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
      return true;
    } catch (e) {
      print('Failed to send phone OTP: $e');
      return false;
    }
  }

  // Verify phone with OTP
  Future<bool> verifyPhoneOtp(String phone, String otp) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: phone,
      );
      return response.session != null;
    } catch (e) {
      print('Failed to verify phone OTP: $e');
      return false;
    }
  }

  //passwort vergessen
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final response = await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Error sending password reset email: $e');
    }
  }

  Future<void> login(String emailOrPhone, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: emailOrPhone,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String? phone,
  }) async {
    try {
      if (await isUsernameUsed(username)) {
        throw Exception('Username is already taken');
      }
      if (await isEmailUsed(email)) {
        throw Exception('Email is already in use');
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': fullName,
          'phone': phone,
        },
      );

      if (response.user == null) {
        throw Exception('Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
}
