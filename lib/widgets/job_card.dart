import 'package:flutter/material.dart';
import '../models/job_post.dart';

class JobCard extends StatelessWidget {
  final JobPost job;
  final bool hasApplied;
  final VoidCallback onApply;

  const JobCard({
    super.key,
    required this.job,
    required this.hasApplied,
    required this.onApply,
  });

  int _daysLeft() {
    if (job.deadline == null) return 0;
    return job.deadline!.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = job.status == 'open';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFF3B3FD4) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Professor
          Row(
            children: [
              const CircleAvatar(radius: 14),
              const SizedBox(width: 8),
              Text(
                job.professorName ?? 'Professor',
                style: TextStyle(
                  color: isOpen ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: Colors.yellow, size: 16),
            ],
          ),

          const SizedBox(height: 10),

          // 🔹 Title
          Text(
            job.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isOpen ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          // 🔹 Description
          Text(
            job.description,
            style: TextStyle(color: isOpen ? Colors.white70 : Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // 🔹 Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 💰 เงิน + จำนวน
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '฿${job.salary ?? 0}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOpen ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'เหลือเวลา ${_daysLeft()} วัน',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOpen ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${job.maxApplicants ?? 0} คน',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOpen ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'ขาดอีก ${(job.maxApplicants ?? 0) - (job.currentApplicants ?? 0)} คน',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOpen ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 🔹 ปุ่มสมัคร
              ElevatedButton(
                onPressed: hasApplied || !isOpen ? null : onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasApplied ? Colors.grey : Colors.white,
                  foregroundColor: hasApplied
                      ? Colors.white
                      : const Color(0xFF3B3FD4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(hasApplied ? 'สมัครแล้ว' : 'สมัคร'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
