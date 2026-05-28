import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class ManageErasView extends StatelessWidget {
  const ManageErasView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kelola Era',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Era'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF73090D),
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => ListView.builder(
                itemCount: controller.eras.length,
                itemBuilder: (context, index) {
                  final era = controller.eras[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF73090D),
                      child: Text('${era['no']}'),
                    ),
                    title: Text(era['title']),
                    subtitle: Text('${era['questions']} soal | Order: ${era['order']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                        ),
                        Switch(
                          value: era['status'] == 'active',
                          onChanged: (value) {},
                          activeColor: const Color(0xFF73090D),
                        ),
                      ],
                    ),
                  );
                },
              )),
            ),
          ),
        ],
      ),
    );
  }
}