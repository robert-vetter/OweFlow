import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<bool> isEmailUsed(String email) async {
  try {
    final response = await Supabase.instance.client
        .rpc('is_email_used', params: {'email_to_check': email});
    return response as bool;
  } catch (e) {
    throw Exception('Error checking email: $e');
  }
}

Future<bool> isPhoneUsed(String phone) async {
  try {
    final response = await Supabase.instance.client
        .rpc('is_phone_used', params: {'phone_to_check': phone});
    return response as bool;
  } catch (e) {
    throw Exception('Error checking phone: $e');
  }
}

Future<bool> isUsernameUsed(String username) async {
  try {
    final response = await Supabase.instance.client
        .rpc('is_username_used', params: {'username_to_check': username});
    return response as bool;
  } catch (e) {
    throw Exception('Error checking username: $e');
  }
}

//passwort vergessen
Future<void> sendPasswordResetEmail(String email) async {
  try {
    final response =
        await Supabase.instance.client.auth.resetPasswordForEmail(email);
  } catch (e) {
    throw Exception('Error sending password reset email: $e');
  }
}

Future<void> loginWithEmail(String email, String password) async {
  try {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Invalid email or password');
    }
  } catch (e) {
    throw Exception('Login failed: $e');
  }
}

Future<void> loginWithPhone(String phone, String password) async {
  try {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      phone: phone,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Invalid email or password');
    }
  } catch (e) {
    throw Exception('Login failed: $e');
  }
}

//Login via Username and Password (Username + Pass --> Email + Pass)
Future<void> loginWithUsername(String username, String password) async {
  try {
    // Schritt 1: Rufe die E-Mail-Adresse über die benutzerdefinierte Supabase-Funktion ab
    final response = await Supabase.instance.client
        .rpc('get_email_by_username', params: {'username': username});

    if (response == null) {
      throw Exception('Username not found');
    }

    final email = response as String;

    // Schritt 2: Melde den Benutzer mit der E-Mail-Adresse und dem Passwort an
    final loginResponse =
        await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (loginResponse.user == null) {
      throw Exception('Invalid username or password');
    }
  } catch (e) {
    throw Exception('Login failed: $e');
  }
}

Future<void> nativeGoogleSignIn() async {
  /// Web Client ID that you registered with Google Cloud.
  const webClientId =
      '422006519414-oi3ll3vidm7trre9in6n90u8lu6jdd2q.apps.googleusercontent.com';

  /// iOS Client ID that you registered with Google Cloud.
  const iosClientId =
      '422006519414-n7g7g8ipg1n44b6f5625167fbamp2205.apps.googleusercontent.com';

  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: iosClientId,
    serverClientId: webClientId,
  );
  final googleUser = await googleSignIn.signIn();
  final googleAuth = await googleUser!.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if (accessToken == null) {
    throw 'No Access Token found.';
  }
  if (idToken == null) {
    throw 'No ID Token found.';
  }

  await Supabase.instance.client.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );
}

//register
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

    final response = await Supabase.instance.client.auth.signUp(
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

//verify email address via email (OTP- Verrify code via email)
Future<bool> verifyEmailWithToken(
  String email,
  String? token,
) async {
  // Add your function code here!
  // instantiate Supabase client
  final supabase = Supabase.instance.client;

  try {
    // call the supabase verifyOTP function
    // if successful, a response with the user and session is returned
    final AuthResponse res = await supabase.auth.verifyOTP(
      type: OtpType.signup,
      token: token ?? " ",
      email: email,
    );

    // return true if session is not null (i.e. user has signed in)
    return res.session != null;
  } on AuthException catch (e) {
    // catch any authenticatino errors and print them to the console
    print(e.message);
    return false;
  } catch (error) {
    // catch any other errors
    print(error);
    return false;
  }
}

//sign up via email address and password
Future<String?> signUpWithEmail(String email, String password) async {
  // Add your function code here!
  try {
    final supabase = Supabase.instance.client;

    final AuthResponse res = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    return null;
  } on AuthException catch (e) {
    return (e.message);
  }
}

//verification of the phone number via sms
Future<bool> verifyPhoneWithToken(
  String phone,
  String? token,
) async {
  // Add your function code here!
  // instantiate Supabase client
  final supabase = Supabase.instance.client;

  try {
    // call the supabase verifyOTP function
    // if successful, a response with the user and session is returned
    final AuthResponse res = await supabase.auth.verifyOTP(
      type: OtpType.signup,
      token: token ?? " ",
      phone: phone,
    );

    // return true if session is not null (i.e. user has signed in)
    return res.session != null;
  } on AuthException catch (e) {
    // catch any authenticatino errors and print them to the console
    print(e.message);
    return false;
  } catch (error) {
    // catch any other errors
    print(error);
    return false;
  }
}

// sign up via phone number and password
Future<String?> signUpWithPhone(String phone, String password) async {
  // Add your function code here!

  try {
    final supabase = Supabase.instance.client;

    final AuthResponse res = await supabase.auth.signUp(
      phone: phone,
      password: password,
    );
    return null;
  } on AuthException catch (e) {
    return (e.message);
  }
}

//'############ Auth Notifier #########

// Globaler AuthNotifier
class AuthNotifier extends ValueNotifier<bool> {
  AuthNotifier() : super(Supabase.instance.client.auth.currentSession != null) {
    // Supabase-Listener hinzufügen
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      update(); // Zustand aktualisieren
    });
  }

  void update() {
    value = Supabase.instance.client.auth.currentSession != null;
  }
}

final authNotifier = AuthNotifier();
