// import 'package:flutter/material.dart';
//
// import '../../../domain/entities/check/check_session.dart';
//
// class CheckSessionCard extends StatelessWidget {
//   final CheckSession session;
//   final String currentUserId;
//   final VoidCallback? onTap;
//
//   const CheckSessionCard({
//     Key? key,
//     required this.session,
//     required this.currentUserId,
//     this.onTap,
//   }) : super(key: key);
//
//   bool get isCreatedByCurrentUser => session.createdBy == currentUserId;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       session.name,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   _StatusChip(status: session.status),
//                 ],
//               ),
//               const SizedBox(height: 12),
//
//               // Thời gian bắt đầu
//               Row(
//                 children: [
//                   const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Bắt đầu: ${_formatDate(session.startDate)}',
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//
//               // Thời gian kết thúc (nếu có)
//               if (session.endDate != null) ...[
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     const Icon(Icons.event, size: 16, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Hoàn thành: ${_formatDate(session.endDate!)}',
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ],
//
//               const SizedBox(height: 12),
//
//               // Thông tin người tạo và người kiểm kê
//               Row(
//                 children: [
//                   Expanded(
//                     child: _UserInfo(
//                       label: 'Người tạo',
//                       name: session.createdBy,
//                       isCurrentUser: isCreatedByCurrentUser,
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//
//               // Thống kê
//               Row(
//                 children: [
//                   _StatItem(
//                     label: 'Đã kiểm',
//                     value: session.totalProductsChecked.toString(),
//                     color: Colors.blue,
//                   ),
//                   const SizedBox(width: 16),
//                   _StatItem(
//                     label: 'Chênh lệch',
//                     value: session.discrepancyCount.toString(),
//                     color: Colors.orange,
//                   ),
//                 ],
//               ),
//
//               // Hiển thị ghi chú nếu có
//               if (session.note != null && session.note!.isNotEmpty) ...[
//                 const SizedBox(height: 8),
//                 const Divider(),
//                 Row(
//                   children: [
//                     const Icon(Icons.notes, size: 16, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         session.note!,
//                         style: const TextStyle(
//                           fontStyle: FontStyle.italic,
//                           color: Colors.grey,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//
//               // Hiển thị badge "Của bạn" nếu phiếu do người dùng hiện tại tạo
//               if (isCreatedByCurrentUser) ...[
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: const Text(
//                     'Phiếu của bạn',
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
//   }
// }
//
// // Widget hiển thị trạng thái phiếu kiểm kê
// class _StatusChip extends StatelessWidget {
//   final CheckSessionStatus status;
//
//   const _StatusChip({required this.status});
//
//   @override
//   Widget build(BuildContext context) {
//     Color color;
//     String text;
//
//     switch (status) {
//       case CheckSessionStatus.inProgress:
//         color = Colors.blue;
//         text = 'Đang thực hiện';
//         break;
//       case CheckSessionStatus.completed:
//         color = Colors.green;
//         text = 'Hoàn thành';
//         break;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: color,
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
//
// // Widget hiển thị thông tin người dùng
// class _UserInfo extends StatelessWidget {
//   final String label;
//   final String name;
//   final bool isCurrentUser;
//
//   const _UserInfo({
//     required this.label,
//     required this.name,
//     required this.isCurrentUser,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 2),
//         Row(
//           children: [
//             Icon(
//               Icons.person,
//               size: 14,
//               color: isCurrentUser ? Colors.green : Colors.grey,
//             ),
//             const SizedBox(width: 4),
//             Expanded(
//               child: Text(
//                 name,
//                 style: TextStyle(
//                   fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
//                   color: isCurrentUser ? Colors.green : Colors.black,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             if (isCurrentUser)
//               const Icon(
//                 Icons.check_circle,
//                 size: 14,
//                 color: Colors.green,
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// // Widget hiển thị thống kê
// class _StatItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;
//
//   const _StatItem({
//     required this.label,
//     required this.value,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: color,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
