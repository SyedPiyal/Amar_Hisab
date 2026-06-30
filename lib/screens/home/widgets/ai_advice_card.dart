import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiAdviceCard extends StatelessWidget {
  final String advice;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AiAdviceCard({
    super.key,
    required this.advice,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.deepPurple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'এআই আর্থিক পরামর্শদাতা (AI Advisor)',
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.purple,
                    size: 20,
                  ),
                  onPressed: onRefresh,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.purple),
                ),
              )
            else
              Text(
                advice.isNotEmpty
                    ? advice
                    : 'আপনার লেনদেনের তালিকা খালি রয়েছে অথবা এআই রিফ্রেশ করুন।',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 13,
                  color: Colors.purple.shade900,
                  height: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
