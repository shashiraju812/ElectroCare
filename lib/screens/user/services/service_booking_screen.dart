import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../models/booking_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/ai_service.dart';
import '../../../utils/app_colors.dart';

class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  String _selectedService = "Wiring";
  final TextEditingController _descriptionController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  bool _isAiSuggesting = false;

  // Scheduling fields
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _timeSlots = [
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
    "05:00 PM",
    "06:00 PM",
  ];

  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _descriptionController.removeListener(_onDescriptionChanged);
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onDescriptionChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (_descriptionController.text.isNotEmpty) {
        _predictCategory();
      }
    });
  }

  void _predictCategory() {
    setState(() => _isAiSuggesting = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final predicted = AiService.predictCategory(_descriptionController.text);
      if (predicted != _selectedService) {
        setState(() {
          _selectedService = predicted;
          _isAiSuggesting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text("Smartly switched to '$predicted'"),
              ],
            ),
            backgroundColor: AppColors.primaryBlue,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() => _isAiSuggesting = false);
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '⚡ Book Electrician  •  ఎలక్ట్రీషియన్ బుక్ చేయండి',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Service Type  •  సేవా రకం",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                if (_isAiSuggesting)
                  Row(
                    children: [
                      const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "AI Suggesting...",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildChip("Wiring"),
                _buildChip("Installation"),
                _buildChip("Repair"),
                _buildChip("Inspection"),
              ],
            ),
            const SizedBox(height: 22),

            // Description
            Text(
              "Describe Issue  •  సమస్య చెప్పండి",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "మీ సమస్యను వివరించండి  •  अपनी समस्या बताएं",
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "E.g. Switch board sparkling...  •  ఉదా: స్విచ్ బోర్డ్ మంటలు...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Address field
            Text(
              "Your Address  •  మీ చిరునామా",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText:
                    "House No., Street, Village, District  •  ఇల్లు, వీధి, గ్రామం",
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryBlue,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Schedule Date & Time
            Text(
              "Schedule  •  షెడ్యూల్",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 15),

            // Date Picker
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppColors.primaryBlue
                        : Colors.grey[300]!,
                    width: _selectedDate != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _selectedDate != null
                          ? AppColors.primaryBlue
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat(
                              'EEEE, MMM d, yyyy',
                            ).format(_selectedDate!)
                          : "Select a date",
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: _selectedDate != null
                            ? AppColors.textDark
                            : Colors.grey,
                        fontWeight: _selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: _selectedDate != null
                          ? AppColors.primaryBlue
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Time Slots
            Text(
              "Select Time Slot",
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey[300]!,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            const SizedBox(height: 22),

            // ─── Location Map (custom) ─────────────────────
            Text(
              "Service Location  •  సేవా స్థానం",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFE8EAF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.blue.shade100, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Grid lines simulating a map
                  CustomPaint(
                    size: const Size(double.infinity, 160),
                    painter: _MapGridPainter(),
                  ),
                  // Location pin
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          "We'll send the nearest electrician 📍",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "దగ్గరలో ఉన్న ఎలక్ట్రీషియన్‌ను పంపుతాం  •  निकटतम इलेक्ट्रीशियन भेजेंगे",
              style: GoogleFonts.outfit(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _submitBooking(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.accentAmber),
                    const SizedBox(width: 8),
                    Text(
                      "Book Now  •  ఇప్పుడే బుక్ చేయండి",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    bool isSelected = _selectedService == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _submitBooking(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final bookingService = Provider.of<BookingService>(context, listen: false);

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please describe the issue  •  సమస్యను వివరించండి"),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select a date & time  •  తేదీ & సమయం ఎంచుకోండి",
          ),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final newBooking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authService.userName ?? "Guest User",
      serviceType: _selectedService,
      description: _descriptionController.text.trim(),
      location: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : "Location not provided",
      timestamp: DateTime.now(),
      scheduledDate: _selectedDate,
      scheduledTime: _selectedTime,
      status: BookingStatus.pending,
      price: null,
    );

    await bookingService.createBooking(newBooking);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      _showBookingDialog(this.context);
    }
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              "బుకింగ్ నిర్ధారించబడింది! Booking Confirmed! 🎉",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "మేము మీ '$_selectedService' అభ్యర్థన కోసం దగ్గరలో ఉన్న ఎలక్ట్రీషియన్‌ను వెతుకుతున్నాం.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textGrey,
                fontSize: 13,
              ),
            ),
            if (_selectedDate != null && _selectedTime != null) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.event,
                      color: AppColors.primaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${DateFormat('MMM d, yyyy').format(_selectedDate!)} at $_selectedTime",
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to Home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Track Request",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that draws a simple grid to simulate a map background
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade200.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    const spacing = 28.0;
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
