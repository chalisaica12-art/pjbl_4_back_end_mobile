import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class ManageUsersView extends StatelessWidget {
  const ManageUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kelola User',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF73090D)),
          ),
          const SizedBox(height: 20),
          
          // Search & Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari user...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => controller.updateSearch(value),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.filterStatus.value,
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.updateFilter(value);
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Data Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Obx(() {
                final users = controller.getPaginatedUsers();
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          sortColumnIndex: controller.sortColumnIndex.value,
                          sortAscending: controller.sortAscending.value,
                          headingRowColor: MaterialStateProperty.all(const Color(0xFF73090D).withOpacity(0.1)),
                          columns: [
                            const DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            const DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: users.map((user) {
                            return DataRow(cells: [
                              DataCell(Text('${user['no']}')),
                              DataCell(Text(user['name'])),
                              DataCell(Text(user['email'])),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: user['role'] == 'admin' ? Colors.purple : const Color(0xFF73090D),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user['role'],
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              )),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: user['status'] == 'active' ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user['status'],
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              )),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () {},
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                    
                    // Pagination
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total: ${controller.getFilteredUsers().length} user'),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: controller.currentPage.value > 1
                                    ? () => controller.changePage(controller.currentPage.value - 1)
                                    : null,
                              ),
                              Text('Page ${controller.currentPage.value} of ${controller.totalPages}'),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: controller.currentPage.value < controller.totalPages
                                    ? () => controller.changePage(controller.currentPage.value + 1)
                                    : null,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Rows per page: '),
                              DropdownButton<int>(
                                value: controller.rowsPerPage.value,
                                items: const [
                                  DropdownMenuItem(value: 5, child: Text('5')),
                                  DropdownMenuItem(value: 10, child: Text('10')),
                                  DropdownMenuItem(value: 25, child: Text('25')),
                                ],
                                onChanged: (value) {
                                  if (value != null) controller.rowsPerPage.value = value;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}