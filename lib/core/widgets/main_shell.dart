import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../constants/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  String _currentRoute(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  @override
  Widget build(BuildContext context) {
    final location = _currentRoute(context);

    return Scaffold(
      extendBody: true, // Importante para que el body pase por debajo del notch
      body: child,
      
      // 1. Botón central flotante (Speed Dial)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SpeedDial(
        icon: Icons.grid_view_rounded,
        activeIcon: Icons.close_rounded,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        overlayColor: AppColors.bgDark,
        overlayOpacity: 0.8,
        elevation: 8,
        shape: const CircleBorder(),
        childrenButtonSize: const Size(56, 56),
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.settings_rounded, color: Colors.white),
            backgroundColor: AppColors.textHint,
            label: 'Ajustes',
            labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
            labelBackgroundColor: Theme.of(context).cardTheme.color,
            onTap: () => context.go('/settings'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.star_rounded, color: Colors.white),
            backgroundColor: AppColors.warning,
            label: 'Recompensas',
            labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
            labelBackgroundColor: Theme.of(context).cardTheme.color,
            onTap: () => context.go('/rewards'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.flag_rounded, color: Colors.white),
            backgroundColor: AppColors.success,
            label: 'Metas',
            labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
            labelBackgroundColor: Theme.of(context).cardTheme.color,
            onTap: () => context.go('/goals'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.timer_rounded, color: Colors.white),
            backgroundColor: AppColors.error,
            label: 'Pomodoro',
            labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
            labelBackgroundColor: Theme.of(context).cardTheme.color,
            onTap: () => context.go('/pomodoro'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.favorite_rounded, color: Colors.white),
            backgroundColor: AppColors.info,
            label: 'Bienestar',
            labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
            labelBackgroundColor: Theme.of(context).cardTheme.color,
            onTap: () => context.go('/wellness'),
          ),
        ],
      ),
      
      // 2. Barra inferior con hueco en el centro
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 20,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Izquierda
              _buildNavItem(context, Icons.home_rounded, 'Inicio', '/', location),
              _buildNavItem(context, Icons.check_circle_outline_rounded, 'Tareas', '/tasks', location),
              
              const SizedBox(width: 48), // Espacio para el botón central
              
              // Derecha
              _buildNavItem(context, Icons.loop_rounded, 'Hábitos', '/habits', location),
              _buildNavItem(context, Icons.account_balance_wallet_rounded, 'Finanzas', '/finances', location),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String route, String currentLocation) {
    final isSelected = currentLocation == route || (route != '/' && currentLocation.startsWith(route));
    final color = isSelected ? AppColors.primary : AppColors.textHint;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
