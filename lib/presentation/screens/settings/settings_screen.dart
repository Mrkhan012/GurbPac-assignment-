import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/theme/theme_cubit.dart';
import '../../cubits/theme/theme_state.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/user_avatar.dart';
import 'debug_panel_view.dart';

class SettingsScreen extends StatelessWidget {
  final User user;

  const SettingsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileCard(context),
        const SizedBox(height: 16),
        _buildTokenCard(context),
        const SizedBox(height: 16),
        _buildAppearanceCard(context),
        const SizedBox(height: 16),
        const DebugPanelView(),
        const SizedBox(height: 24),
        _buildLogoutButton(context),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            UserAvatar(name: user.name, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(user.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: user.isAdmin ? AppColors.accent : AppColors.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.isAdmin ? 'Role: Org Admin' : 'Role: Member',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenCard(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isRefreshing = state is Authenticated && state.isRefreshing;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.security_rounded, size: 20, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Simulated JWT Session', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access token expires in 15 minutes (900s). Demonstrates automatic & manual mock token refresh.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isRefreshing ? null : () => context.read<AuthCubit>().refreshSessionToken(),
                    icon: isRefreshing
                        ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.autorenew_rounded, size: 16),
                    label: const Text('Simulate Token Refresh'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppearanceCard(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Card(
          child: SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Toggle between dark and light themes', style: TextStyle(fontSize: 12)),
            secondary: Icon(themeState.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
            value: themeState.isDarkMode,
            onChanged: (val) => context.read<ThemeCubit>().toggleTheme(),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text('Log Out'),
      onPressed: () async {
        final confirm = await ConfirmationDialog.show(
          context,
          title: 'Sign Out',
          content: 'Are you sure you want to sign out of your account?',
          confirmText: 'Log Out',
          isDestructive: true,
        );
        if (confirm == true && context.mounted) {
          context.read<AuthCubit>().logout();
        }
      },
    );
  }
}
