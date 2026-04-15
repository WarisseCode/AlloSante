import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';

final authRepositoryProvider = Provider((_) => AuthRepository());

// ─── État ────────────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  bool get isAuthenticated => user != null;
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  Future<bool> tryAutoLogin() async {
    final loggedIn = await ApiClient.instance.isLoggedIn;
    if (!loggedIn) return false;
    try {
      final user = await _repo.getMe();
      state = AuthState(user: user);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _repo.friendlyError(e));
      rethrow;
    }
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.verifyOtp(phoneNumber: phoneNumber, code: code);
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _repo.friendlyError(e));
      rethrow;
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
    await _repo.resendOtp(phoneNumber);
  }

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      state = AuthState(user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _repo.friendlyError(e));
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(error: null);
}

// ─── Provider ────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
