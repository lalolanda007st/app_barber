import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/barber_provider.dart';
import '../models/hairstyle_model.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _bookingConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarberProvider>();

    if (_bookingConfirmed) {
      return _buildConfirmationScreen(context, provider);
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF0D0D0D),
          pinned: true,
          title: Text(
            'Agendar Cita',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF5F0E8),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected hairstyle summary
                if (provider.selectedHairstyle != null) ...[
                  _buildSelectedHairstyle(provider),
                  const SizedBox(height: 24),
                ],

                // Barber selection
                _sectionTitle('Elige tu barbero'),
                const SizedBox(height: 12),
                ...BarberData.barbers
                    .map((b) => _BarberSelectCard(barber: b))
                    .toList(),
                const SizedBox(height: 24),

                // Date selection
                _sectionTitle('Selecciona la fecha'),
                const SizedBox(height: 12),
                _buildDateSelector(),
                const SizedBox(height: 24),

                // Time selection
                if (provider.selectedBarber != null) ...[
                  _sectionTitle('Horario disponible'),
                  const SizedBox(height: 12),
                  _buildTimeSelector(provider),
                  const SizedBox(height: 24),
                ],

                // Summary and book button
                _buildBookingButton(provider),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF5F0E8),
      ),
    );
  }

  Widget _buildSelectedHairstyle(BarberProvider provider) {
    final h = provider.selectedHairstyle!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F0A), Color(0xFF1A1200)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A853).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                h.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF2A2A2A),
                  child:
                      const Icon(Icons.content_cut, color: Color(0xFFD4A853)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Corte seleccionado',
                    style: TextStyle(fontSize: 11, color: Color(0xFF998877))),
                Text(h.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD4A853),
                    )),
                Text(
                  '${h.duration} min · \$${h.price.toStringAsFixed(0)}',
                  style: GoogleFonts.lato(
                      fontSize: 12, color: const Color(0xFF999999)),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFFD4A853), size: 20),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final dates =
        List.generate(10, (i) => DateTime.now().add(Duration(days: i + 1)));
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final date = dates[i];
          final isSelected = _selectedDate.day == date.day &&
              _selectedDate.month == date.month;
          final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
          final dayName = dayNames[date.weekday - 1];

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4A853)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4A853)
                      : const Color(0xFF333333),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: isSelected
                          ? const Color(0xFF0D0D0D)
                          : const Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF0D0D0D)
                          : const Color(0xFFF5F0E8),
                    ),
                  ),
                  Text(
                    _getMonthShort(date.month),
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      color: isSelected
                          ? const Color(0xFF0D0D0D)
                          : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonthShort(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return months[month - 1];
  }

  Widget _buildTimeSelector(BarberProvider provider) {
    final times = provider.selectedBarber!.schedule;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.map((time) {
        final isSelected = provider.selectedTime == time;
        return GestureDetector(
          onTap: () => provider.selectTime(time),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFD4A853)
                  : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFD4A853)
                    : const Color(0xFF333333),
              ),
            ),
            child: Text(
              time,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0D0D0D)
                    : const Color(0xFFCCCCCC),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookingButton(BarberProvider provider) {
    final canBook =
        provider.selectedBarber != null && provider.selectedTime != null;

    // Booking summary
    return Column(
      children: [
        if (canBook) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              children: [
                _summaryRow('Barbero', provider.selectedBarber!.name),
                _summaryRow('Fecha',
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                _summaryRow('Hora', provider.selectedTime!),
                if (provider.selectedHairstyle != null)
                  _summaryRow('Corte', provider.selectedHairstyle!.name),
                const Divider(color: Color(0xFF2A2A2A), height: 24),
                _summaryRow(
                  'Total',
                  '\$${provider.selectedHairstyle?.price.toStringAsFixed(0) ?? "250"}',
                  isTotal: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        GestureDetector(
          onTap:
              canBook ? () => setState(() => _bookingConfirmed = true) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: canBook
                  ? const LinearGradient(
                      colors: [Color(0xFFD4A853), Color(0xFFB8860B)],
                    )
                  : null,
              color: canBook ? null : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available_rounded,
                  color: canBook
                      ? const Color(0xFF0D0D0D)
                      : const Color(0xFF555555),
                ),
                const SizedBox(width: 8),
                Text(
                  canBook
                      ? 'Confirmar Cita'
                      : 'Completa los datos para agendar',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: canBook
                        ? const Color(0xFF0D0D0D)
                        : const Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.lato(
                fontSize: isTotal ? 15 : 13,
                color:
                    isTotal ? const Color(0xFFD4A853) : const Color(0xFF888888),
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              )),
          Text(value,
              style: GoogleFonts.lato(
                fontSize: isTotal ? 16 : 13,
                color:
                    isTotal ? const Color(0xFFD4A853) : const Color(0xFFF5F0E8),
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _buildConfirmationScreen(
      BuildContext context, BarberProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4A853).withOpacity(0.15),
                  border: Border.all(color: const Color(0xFFD4A853), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A853).withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFFD4A853),
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '¡Cita Confirmada!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD4A853),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${provider.selectedBarber?.name ?? "Tu barbero"} te espera el ${_selectedDate.day}/${_selectedDate.month} a las ${provider.selectedTime}',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: const Color(0xFF998877),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              if (provider.selectedHairstyle != null)
                Text(
                  'Corte: ${provider.selectedHairstyle!.name}',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: const Color(0xFFF5F0E8),
                  ),
                ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => setState(() => _bookingConfirmed = false),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A853),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Volver al inicio',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0D0D0D),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarberSelectCard extends StatelessWidget {
  final BarberModel barber;
  const _BarberSelectCard({required this.barber});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarberProvider>();
    final isSelected = provider.selectedBarber?.id == barber.id;

    return GestureDetector(
      onTap: barber.available ? () => provider.selectBarber(barber) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A1F0A) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFD4A853) : const Color(0xFF2A2A2A),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2A2A2A),
                  backgroundImage: NetworkImage(barber.imageUrl),
                  onBackgroundImageError: (_, __) {},
                ),
                if (!barber.available)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: barber.available
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF888888),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF141414), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barber.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: barber.available
                          ? const Color(0xFFF5F0E8)
                          : const Color(0xFF666666),
                    ),
                  ),
                  Text(
                    barber.specialty,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: const Color(0xFF888888),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: barber.available
                            ? const Color(0xFFD4A853)
                            : const Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${barber.rating}',
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          color: barber.available
                              ? const Color(0xFF999999)
                              : const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!barber.available)
              Text(
                'Hoy ocupado',
                style: GoogleFonts.lato(
                    fontSize: 11, color: const Color(0xFF666666)),
              )
            else if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFFD4A853), size: 22),
          ],
        ),
      ),
    );
  }
}
