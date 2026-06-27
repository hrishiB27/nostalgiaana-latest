import 'package:flutter/material.dart';

import '../../dashboard/presentation/admin_dashboard_shell.dart';
import '../../dashboard/presentation/user_home_shell.dart';
import '../data/models/user_role.dart';
import '../domain/authenticated_user.dart';

/// Sends a freshly authenticated user to the dashboard matching their
/// *actual* role — never just the portal (user/admin) they happened to log
/// in through, since the role gate is a UI shortcut, not an authorization
/// decision. The whole back stack (splash, role gate, auth screens) is
/// dropped so the back button can't return into a login form.
void routeToDashboard(BuildContext context, AuthenticatedUser user) {
  final destination =
      user.role == UserRole.admin ? const AdminDashboardShell() : const UserHomeScreenShell();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => destination),
    (route) => false,
  );
}
