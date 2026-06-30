import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';
import '../../inventory/inventory_list_screen.dart';
import '../../transactions/add_transaction_screen.dart';

class QuickAction extends StatefulWidget {
  const QuickAction({super.key});

  @override
  State<QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<QuickAction> {
  final actions = [
    {'label': 'ইনভেন্টরি', 'icon': Icons.inventory_2_outlined, 'color': Colors.teal},
    {'label': 'বাজার', 'icon': Icons.shopping_cart_outlined, 'color': Colors.orange},
    {'label': 'খাবার', 'icon': Icons.restaurant_rounded, 'color': Colors.redAccent},
    {'label': 'যাতায়াত', 'icon': Icons.directions_bus_rounded, 'color': Colors.blue},
    {'label': 'মেডিসিন', 'icon': Icons.medical_services_rounded, 'color': Colors.green},
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'কুইক অ্যাকশন',
            style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    if (action['label'] == 'ইনভেন্টরি') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InventoryListScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTransactionScreen(
                            initialCategory: action['label'] as String,
                          ),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(action['icon'] as IconData, color: action['color'] as Color),
                        const SizedBox(height: 8),
                        Text(
                          action['label'] as String,
                          style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
