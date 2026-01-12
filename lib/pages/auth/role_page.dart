// import 'package:flutter/material.dart';

// class RolePage extends StatefulWidget {
//   const RolePage({super.key});

//   @override
//   State<RolePage> createState() => _RolePageState();
// }

// class _RolePageState extends State<RolePage> {
//   String? selectedRole; // user / mitra

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "Pilih Peran",
//           style: TextStyle(
//             color: Colors.blueAccent,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Siapa anda?",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),

//             // ==============================
//             // PILIH ROLE USER
//             // ==============================
//             _buildRoleCard(
//               title: "Pengguna",
//               icon: Icons.person_rounded,
//               value: "user",
//             ),
//             const SizedBox(height: 15),

//             // ==============================
//             // PILIH ROLE MITRA
//             // ==============================
//             _buildRoleCard(
//               title: "Mitra",
//               icon: Icons.car_repair,
//               value: "mitra",
//             ),

//             const Spacer(),

//             // ==============================
//             // TOMBOL LANJUT
//             // ==============================
//             SizedBox(
//               width: double.infinity,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: selectedRole == null
//                     ? null
//                     : () {
//                         if (selectedRole == "user") {
//                           Navigator.pushNamed(context, "/login");
//                         } else if (selectedRole == "mitra") {
//                           Navigator.pushNamed(context, "/login-mitra");
//                         }
//                       },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: selectedRole == null
//                       ? Colors.grey
//                       : Colors.blueAccent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   "Mulai",
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==============================
//   // WIDGET KARTU ROLE
//   // ==============================
//   Widget _buildRoleCard({
//     required String title,
//     required IconData icon,
//     required String value,
//   }) {
//     final bool isSelected = selectedRole == value;

//     return GestureDetector(
//       onTap: () => setState(() => selectedRole = value),
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
//             width: 2,
//           ),
//           color: isSelected ? Colors.blue.shade50 : Colors.white,
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               size: 32,
//               color: isSelected ? Colors.blueAccent : Colors.grey,
//             ),
//             const SizedBox(width: 16),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w600,
//                 color: isSelected ? Colors.blueAccent : Colors.black87,
//               ),
//             ),
//             const Spacer(),
//             if (isSelected)
//               const Icon(Icons.check_circle, color: Colors.blueAccent),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  String? selectedRole; // user / mitra

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Pilih Peran",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Siapa anda?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // ==============================
            // PILIH ROLE USER
            // ==============================
            _buildRoleCard(
              title: "Pengguna",
              icon: Icons.person_rounded,
              value: "user",
            ),
            const SizedBox(height: 15),

            // ==============================
            // PILIH ROLE MITRA
            // ==============================
            _buildRoleCard(
              title: "Mitra",
              icon: Icons.car_repair,
              value: "mitra",
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // WIDGET KARTU ROLE
  // ==============================
  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final bool isSelected = selectedRole == value;

    return GestureDetector(
      onTap: () {
        // langsung lanjut ke halaman login sesuai role
        setState(() => selectedRole = value);

        if (value == "user") {
          Navigator.pushNamed(context, "/login");
        } else if (value == "mitra") {
          Navigator.pushNamed(context, "/login-mitra");
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: 2,
          ),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.blueAccent : Colors.grey,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blueAccent : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}
