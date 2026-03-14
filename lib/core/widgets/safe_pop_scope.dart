import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget que intercepta el gesto de retroceso del sistema (Android back gesture / button).
/// Si hay historial en GoRouter, hace pop. Si no, navega a [fallbackRoute].
/// Así el usuario nunca cierra la app por accidente desde una pantalla intermedia.
class SafePopScope extends StatelessWidget {
  final Widget child;

  /// Ruta a la que regresar si no hay historial disponible (canPop == false).
  final String fallbackRoute;

  const SafePopScope({
    super.key,
    required this.child,
    required this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop = false hace que el sistema NO maneje el back gesture por su cuenta.
      // En cambio, onPopInvokedWithResult lo recibe y nosotros decidimos qué hacer.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return; // ya fue manejado (no debería pasar con canPop:false)
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(fallbackRoute);
        }
      },
      child: child,
    );
  }
}
