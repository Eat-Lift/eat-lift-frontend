import 'package:eatnlift/pages/user/check_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckCard extends StatelessWidget {
  final String date;

  const CheckCard({
    super.key,
    required this.date,
  });

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      String weekDay = DateFormat('EEEE', 'ca_ES').format(parsedDate);
      String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
      return "$weekDay $formattedDate";
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckInfoPage(date: date),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: Text(
          "Revisió ${_formatDate(date)}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
