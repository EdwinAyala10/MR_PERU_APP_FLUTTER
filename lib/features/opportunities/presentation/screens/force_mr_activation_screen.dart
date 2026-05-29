import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForceMrActivationScreen extends StatelessWidget {
  final String opportunityId;
  
  const ForceMrActivationScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00607D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icon/logomrIA.png',
              width: 26,
              height: 26,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00A8DD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Force MR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00A8DD).withOpacity(0.1),
                            const Color(0xFF00607D).withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00A8DD).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A8DD).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/icon/logomrIA.png',
                              width: 56,
                              height: 56,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Te damos la bienvenida a tu asistente de IA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00607D),
                              letterSpacing: -0.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      icon: Icons.lightbulb_outline_rounded,
                      title: '¿Qué es Force MR?',
                      content:
                          'Estamos orgullosos de presentar a Force Mr, tu asistente de inteligencia artificial (IA) para simplificar y acelerar tu carga de trabajo diaria. Force MR está actualmente en versión Beta y utiliza servicios de inteligencia artificial de terceros para brindarte la mejor experiencia posible.',
                    ),
                    const SizedBox(height: 20),
                    _buildInfoSection(
                      icon: Icons.insights_rounded,
                      title: 'Capacidades principales',
                      content:
                          'Con Force MR podrás analizar oportunidades comerciales en segundos, identificar riesgos de cierre, detectar próximos pasos recomendados y obtener una lectura ejecutiva de cada cuenta sin perder contexto.',
                    ),
                    const SizedBox(height: 20),
                    _buildInfoSection(
                      icon: Icons.groups_rounded,
                      title: 'Diseñado para equipos comerciales',
                      content:
                          'Esta herramienta ha sido diseñada para equipos comerciales y de gestión que necesitan decisiones rápidas, información confiable y una vista consolidada del estado real de cada oportunidad.',
                    ),
                    const SizedBox(height: 20),
                    _buildInfoSection(
                      icon: Icons.security_rounded,
                      title: 'Privacidad y uso de datos',
                      content:
                          'Para operar, Force MR puede procesar información relevante de la oportunidad (como estado, fechas, importes, actividades y comentarios) con fines exclusivos de generación de insights y resúmenes.',
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A8DD).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF00A8DD),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Términos y condiciones',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00607D),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Al hacer clic en "Aceptar y activar Force MR", acepta nuestros términos y condiciones de uso de Force MR, así como nuestra política de privacidad aplicable.\n\nPodrás revisar y actualizar tus preferencias más adelante desde la configuración de tu cuenta.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/opportunity_summary/$opportunityId');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A8DD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: const Text(
                        'Aceptar y activar Force MR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'No activar a Force MR',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF00A8DD).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF00A8DD),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00607D),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
