// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../core/theme/app_colors.dart';
// import '../controllers/otp_controller.dart';

// class OtpView extends GetView<OtpController> {
//   const OtpView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header with back and progress
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.chevron_left),
//                     onPressed: () => Get.back(),
//                   ),
//                   Expanded(
//                     child: LinearProgressIndicator(
//                       value: 0.75,
//                       backgroundColor:
//                           isDark ? AppColors.borderDark : Colors.grey[200],
//                       valueColor: const AlwaysStoppedAnimation(
//                         AppColors.primary,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 40), // balance
//                 ],
//               ),
//             ),
//             // Main content - scrollable
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 20),
//                     // Icon
//                     Container(
//                       width: 64,
//                       height: 64,
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Icon(
//                         Icons.security,
//                         size: 32,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Title
//                     const Text(
//                       'OTP Verification',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     // Description
//                     Text.rich(
//                       TextSpan(
//                         text: 'Enter the 6-digit code sent to\n',
//                         style: TextStyle(
//                           color:
//                               isDark
//                                   ? AppColors.textSecondaryDark
//                                   : AppColors.textSecondaryLight,
//                         ),
//                         children: const [
//                           TextSpan(
//                             text: '+1 ••• ••• 88',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     // OTP Input Fields (6 boxes)
//                     Obx(
//                       () => Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: List.generate(6, (index) {
//                           String digit =
//                               index < controller.otpCode.value.length
//                                   ? controller.otpCode.value[index]
//                                   : '';
//                           bool isActive =
//                               index == controller.otpCode.value.length;
//                           return Container(
//                             width: 50,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color:
//                                     isActive
//                                         ? AppColors.primary
//                                         : (isDark
//                                             ? AppColors.borderDark
//                                             : Colors.grey[300]!),
//                                 width: isActive ? 2 : 1,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                               color:
//                                   isActive
//                                       ? AppColors.primary.withValues(alpha: 0.05)
//                                       : (isDark
//                                           ? AppColors.surfaceDark
//                                           : Colors.white),
//                             ),
//                             child: Center(
//                               child:
//                                   digit.isEmpty && isActive
//                                       ? Container(
//                                         width: 2,
//                                         height: 20,
//                                         color: AppColors.primary,
//                                       )
//                                       : Text(
//                                         digit,
//                                         style: TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                           color:
//                                               isDark
//                                                   ? AppColors.textDark
//                                                   : AppColors.textLight,
//                                         ),
//                                       ),
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Timer and resend
//                     Obx(
//                       () => Center(
//                         child: Text.rich(
//                           TextSpan(
//                             text: "Didn't receive the code? ",
//                             style: TextStyle(
//                               color:
//                                   isDark
//                                       ? AppColors.textSecondaryDark
//                                       : AppColors.textSecondaryLight,
//                             ),
//                             children: [
//                               TextSpan(
//                                 text:
//                                     controller.resendSeconds.value > 0
//                                         ? 'Resend in ${controller.resendSeconds.value}s'
//                                         : 'Resend',
//                                 style: const TextStyle(
//                                   color: AppColors.primary,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 recognizer: null,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Verify button
//                     Obx(
//                       () => SizedBox(
//                         width: double.infinity,
//                         height: 54,
//                         child: ElevatedButton(
//                           onPressed:
//                               controller.isLoading.value
//                                   ? null
//                                   : controller.verifyOtp,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                           ),
//                           child:
//                               controller.isLoading.value
//                                   ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                   : const Text(
//                                     'Verify & Proceed',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20), // extra space
//                   ],
//                 ),
//               ),
//             ),
//             // Custom Numeric Keypad - fixed height
//             Container(
//               height: 280,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: isDark ? AppColors.surfaceDark : Colors.grey[50],
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(32),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: GridView.count(
//                       crossAxisCount: 3,
//                       mainAxisSpacing: 12,
//                       crossAxisSpacing: 12,
//                       childAspectRatio: 1.5,
//                       children: [
//                         for (int i = 1; i <= 9; i++)
//                           _buildKey(i.toString(), isDark),
//                         const SizedBox(),
//                         _buildKey('0', isDark),
//                         _buildBackspace(isDark),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // Home indicator
//                   Container(
//                     width: 120,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).dividerColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildKey(String label, bool isDark) {
//     return GestureDetector(
//       onTap: () => controller.addDigit(label),
//       child: Container(
//         decoration: BoxDecoration(
//           color: isDark ? AppColors.surfaceDark : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w500,
//               color: isDark ? AppColors.textDark : AppColors.textLight,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBackspace(bool isDark) {
//     return GestureDetector(
//       onTap: controller.removeDigit,
//       child: Container(
//         decoration: BoxDecoration(
//           color: isDark ? AppColors.surfaceDark : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: const Center(child: Icon(Icons.backspace, color: Colors.grey)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back and progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: 0.75,
                      backgroundColor:
                          isDark ? AppColors.borderDark : Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // balance
                ],
              ),
            ),
            // Main content - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.security,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'OTP Verification',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    Text.rich(
                      TextSpan(
                        text: 'Enter the 6-digit code sent to\n',
                        style: TextStyle(
                          color:
                              isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                        ),
                        children: const [
                          TextSpan(
                            text: '+1 ••• ••• 88',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // OTP Input Fields using PinCodeTextField
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      onChanged: controller.updateOtp,
                      onCompleted: (code) => controller.verifyOtp(),
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 60,
                        fieldWidth: 50,
                        activeFillColor:
                            isDark ? AppColors.surfaceDark : Colors.white,
                        inactiveFillColor:
                            isDark ? AppColors.surfaceDark : Colors.grey[100],
                        selectedFillColor:
                            isDark ? AppColors.surfaceDark : Colors.white,
                        activeColor: AppColors.primary,
                        inactiveColor:
                            isDark ? AppColors.borderDark : Colors.grey[300],
                        selectedColor: AppColors.primary,
                      ),
                      keyboardType: TextInputType.number,
                      enableActiveFill: true,
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Timer and resend
                    Obx(
                      () => Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Didn't receive the code? ",
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    controller.resendSeconds.value > 0
                                        ? 'Resend in ${controller.resendSeconds.value}s'
                                        : 'Resend',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: null, // Add gesture if needed
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Verify button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : controller.verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child:
                              controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Verify & Proceed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // extra space
                  ],
                ),
              ),
            ),
            // Remove custom keypad, keep only home indicator at bottom
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: 120,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
