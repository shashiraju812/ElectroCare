import 'package:flutter/material.dart';

class BookingScheduleDialog extends StatefulWidget {
  final String serviceType;
  const BookingScheduleDialog({super.key, required this.serviceType});

  @override
  State<BookingScheduleDialog> createState() => _BookingScheduleDialogState();
}

class _BookingScheduleDialogState extends State<BookingScheduleDialog> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Schedule ${widget.serviceType}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Date"),
            subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
          ListTile(
            title: const Text("Time"),
            subtitle: Text(selectedTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () => _selectTime(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'date': selectedDate,
              'time': selectedTime.format(context),
            });
          },
          child: const Text("CONFIRM"),
        ),
      ],
    );
  }
}
