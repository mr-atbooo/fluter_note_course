// import 'package:flutter/material.dart';

// Widget _buildSearchBox() {
//   return Padding(
//     padding: const EdgeInsets.all(12),
//     child: Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () async {
//               fromDate = await _pickDate();
//               setState(() {});
//             },
//             child: Text(
//               fromDate == null
//                   ? 'من تاريخ'
//                   : DateFormat('yyyy/MM/dd').format(fromDate!),
//             ),
//           ),
//         ),
//         SizedBox(width: 8),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () async {
//               toDate = await _pickDate();
//               setState(() {});
//             },
//             child: Text(
//               toDate == null
//                   ? 'إلى تاريخ'
//                   : DateFormat('yyyy/MM/dd').format(toDate!),
//             ),
//           ),
//         ),
//         IconButton(
//           icon: Icon(Icons.check),
//           onPressed: _applyDateFilter,
//         )
//       ],
//     ),
//   );
// }
