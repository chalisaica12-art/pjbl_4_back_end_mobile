import 'package:get/get.dart';

class AdminController extends GetxController {
  var selectedIndex = 0.obs;
  var searchQuery = ''.obs;
  var filterStatus = 'Semua'.obs;
  var currentPage = 1.obs;
  var rowsPerPage = 10.obs;
  var sortColumnIndex = 0.obs;
  var sortAscending = true.obs;
  
  // Data dummy untuk admin (nanti ganti dengan Supabase)
  var users = <Map<String, dynamic>>[
    {'no': 1, 'name': 'Budi Santoso', 'email': 'budi@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-01-15'},
    {'no': 2, 'name': 'Siti Nurhaliza', 'email': 'siti@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-01-20'},
    {'no': 3, 'name': 'Agus Wijaya', 'email': 'agus@email.com', 'role': 'admin', 'status': 'active', 'joined': '2024-02-01'},
    {'no': 4, 'name': 'Dewi Sartika', 'email': 'dewi@email.com', 'role': 'user', 'status': 'inactive', 'joined': '2024-02-10'},
    {'no': 5, 'name': 'Joko Widodo', 'email': 'joko@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-03-05'},
    {'no': 6, 'name': 'Rina Oktaviani', 'email': 'rina@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-03-12'},
    {'no': 7, 'name': 'Hendra Gunawan', 'email': 'hendra@email.com', 'role': 'user', 'status': 'inactive', 'joined': '2024-03-20'},
    {'no': 8, 'name': 'Nadia Putri', 'email': 'nadia@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-04-01'},
    {'no': 9, 'name': 'Rizky Febrian', 'email': 'rizky@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-04-10'},
    {'no': 10, 'name': 'Maya Sari', 'email': 'maya@email.com', 'role': 'user', 'status': 'inactive', 'joined': '2024-04-15'},
    {'no': 11, 'name': 'Andi Pratama', 'email': 'andi@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-05-01'},
    {'no': 12, 'name': 'Lina Marlina', 'email': 'lina@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-05-10'},
    {'no': 13, 'name': 'Eko Prasetyo', 'email': 'eko@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-05-20'},
    {'no': 14, 'name': 'Tari Anisa', 'email': 'tari@email.com', 'role': 'user', 'status': 'active', 'joined': '2024-06-01'},
    {'no': 15, 'name': 'Bagas Putra', 'email': 'bagas@email.com', 'role': 'user', 'status': 'inactive', 'joined': '2024-06-10'},
  ].obs;
  
  var eras = <Map<String, dynamic>>[
    {'no': 1, 'title': 'Era Prakasa', 'questions': 5, 'status': 'active', 'order': 1},
    {'no': 2, 'title': 'Era Kerajaan Hindu Budha', 'questions': 5, 'status': 'active', 'order': 2},
    {'no': 3, 'title': 'Era Kerajaan Islam', 'questions': 5, 'status': 'active', 'order': 3},
    {'no': 4, 'title': 'Era Kolonialisme', 'questions': 5, 'status': 'active', 'order': 4},
    {'no': 5, 'title': 'Era Kemerdekaan', 'questions': 5, 'status': 'active', 'order': 5},
    {'no': 6, 'title': 'Era Orde Lama', 'questions': 5, 'status': 'inactive', 'order': 6},
    {'no': 7, 'title': 'Era Orde Baru', 'questions': 5, 'status': 'inactive', 'order': 7},
    {'no': 8, 'title': 'Reformasi', 'questions': 5, 'status': 'inactive', 'order': 8},
  ].obs;
  
  var questions = <Map<String, dynamic>>[
    {'no': 1, 'question': 'Siapakah proklamator Indonesia?', 'era': 'Era Kemerdekaan', 'correct': 'B', 'status': 'active'},
    {'no': 2, 'question': 'Kapan proklamasi kemerdekaan Indonesia?', 'era': 'Era Kemerdekaan', 'correct': 'A', 'status': 'active'},
    {'no': 3, 'question': 'Siapa presiden pertama Indonesia?', 'era': 'Era Kemerdekaan', 'correct': 'C', 'status': 'active'},
    {'no': 4, 'question': 'Kerajaan Hindu tertua di Indonesia?', 'era': 'Era Kerajaan Hindu Budha', 'correct': 'B', 'status': 'active'},
    {'no': 5, 'question': 'Siapa penemu Benua Amerika?', 'era': 'Era Kolonialisme', 'correct': 'D', 'status': 'inactive'},
  ].obs;
  
  void changeTab(int index) {
    selectedIndex.value = index;
    currentPage.value = 1;
    searchQuery.value = '';
    filterStatus.value = 'Semua';
  }
  
  void updateSearch(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
  }
  
  void updateFilter(String filter) {
    filterStatus.value = filter;
    currentPage.value = 1;
  }
  
  void updateSort(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    sortAscending.value = ascending;
  }
  
  void changePage(int page) {
    currentPage.value = page;
  }
  
  List<Map<String, dynamic>> getFilteredUsers() {
    var filtered = users.where((user) {
      if (filterStatus.value != 'Semua' && user['status'] != filterStatus.value) {
        return false;
      }
      if (searchQuery.value.isNotEmpty) {
        return user['name'].toLowerCase().contains(searchQuery.value.toLowerCase()) ||
               user['email'].toLowerCase().contains(searchQuery.value.toLowerCase());
      }
      return true;
    }).toList();
    
    // Sorting
    if (sortColumnIndex.value == 0) {
      filtered.sort((a, b) => sortAscending.value ? a['no'].compareTo(b['no']) : b['no'].compareTo(a['no']));
    } else if (sortColumnIndex.value == 1) {
      filtered.sort((a, b) => sortAscending.value ? a['name'].compareTo(b['name']) : b['name'].compareTo(a['name']));
    } else if (sortColumnIndex.value == 2) {
      filtered.sort((a, b) => sortAscending.value ? a['email'].compareTo(b['email']) : b['email'].compareTo(a['email']));
    } else if (sortColumnIndex.value == 3) {
      filtered.sort((a, b) => sortAscending.value ? a['role'].compareTo(b['role']) : b['role'].compareTo(a['role']));
    } else if (sortColumnIndex.value == 4) {
      filtered.sort((a, b) => sortAscending.value ? a['status'].compareTo(b['status']) : b['status'].compareTo(a['status']));
    }
    
    return filtered;
  }
  
  List<Map<String, dynamic>> getPaginatedUsers() {
    var filtered = getFilteredUsers();
    int start = (currentPage.value - 1) * rowsPerPage.value;
    int end = start + rowsPerPage.value;
    if (start >= filtered.length) return [];
    if (end > filtered.length) end = filtered.length;
    return filtered.sublist(start, end);
  }
  
  int get totalPages {
    int total = getFilteredUsers().length;
    return (total / rowsPerPage.value).ceil();
  }
  
  void logout() {
    Get.offAllNamed('/login');
  }
}