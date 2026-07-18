import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../data/admin_user_api.dart';
import '../data/models/admin_user_response_model.dart';

enum AdminUsersStatus { initial, loading, loaded, error }

class AdminUsersState {
  const AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  final AdminUsersStatus status;
  final List<AdminUserResponseModel> users;
  final String? errorMessage;

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<AdminUserResponseModel>? users,
    String? errorMessage,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }
}

/// Drives the Manage Users screen: an initial list load plus a ban action
/// that updates the affected row in place once the server confirms it,
/// rather than refetching the whole list.
class AdminUsersNotifier extends Notifier<AdminUsersState> {
  @override
  AdminUsersState build() => const AdminUsersState();

  Future<void> load() async {
    state = state.copyWith(status: AdminUsersStatus.loading);
    try {
      final users = await ref.read(adminUserApiProvider).listUsers();
      state = AdminUsersState(status: AdminUsersStatus.loaded, users: users);
    } catch (error) {
      state = state.copyWith(status: AdminUsersStatus.error, errorMessage: messageFor(error));
    }
  }

  Future<void> banUser(String id) async {
    try {
      await ref.read(adminUserApiProvider).banUser(id);
      state = state.copyWith(
        status: AdminUsersStatus.loaded,
        users: [
          for (final user in state.users)
            if (user.id == id) user.copyWith(isActive: false) else user,
        ],
      );
    } catch (error) {
      state = state.copyWith(status: AdminUsersStatus.error, errorMessage: messageFor(error));
    }
  }

  Future<void> approveUser(String id) async {
    try {
      await ref.read(adminUserApiProvider).approveUser(id);
      state = state.copyWith(
        status: AdminUsersStatus.loaded,
        users: [
          for (final user in state.users)
            if (user.id == id) user.copyWith(approved: true) else user,
        ],
      );
    } catch (error) {
      state = state.copyWith(status: AdminUsersStatus.error, errorMessage: messageFor(error));
    }
  }

  Future<void> unsuspendUser(String id) async {
    try {
      await ref.read(adminUserApiProvider).unsuspendUser(id);
      state = state.copyWith(
        status: AdminUsersStatus.loaded,
        users: [
          for (final user in state.users)
            if (user.id == id) user.copyWith(isActive: true) else user,
        ],
      );
    } catch (error) {
      state = state.copyWith(status: AdminUsersStatus.error, errorMessage: messageFor(error));
    }
  }

  Future<void> denyUser(String id) async {
    try {
      await ref.read(adminUserApiProvider).denyUser(id);
      state = state.copyWith(
        status: AdminUsersStatus.loaded,
        users: [for (final user in state.users) if (user.id != id) user],
      );
    } catch (error) {
      state = state.copyWith(status: AdminUsersStatus.error, errorMessage: messageFor(error));
    }
  }
}

final adminUsersProvider = NotifierProvider<AdminUsersNotifier, AdminUsersState>(
  AdminUsersNotifier.new,
);
