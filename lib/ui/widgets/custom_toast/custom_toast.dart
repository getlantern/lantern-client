import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

class CustomToast {
  static Function show({
    required String title,
    required String body,
    required String surveyText,
    required Icon icon,
    Color? titleFontColor,
    VoidCallback? onClose,
    CancelFunc? onSurvey,
    Duration? duration,
  }) {
    return BotToast.showCustomNotification(
      toastBuilder: (cancel) => Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 60),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: Colors.grey.withOpacity(.3),
              spreadRadius: 16,
            )
          ],
        ),
        child: IntrinsicHeight(
          child: Material(
            child: ListTile(
              leading: icon,
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: titleFontColor ?? const Color.fromRGBO(52, 40, 19, 1),
                ),
              ),
              trailing: TextButton(
                onPressed: () {
                  onSurvey!();
                  cancel();
                },
                child: Text(
                  surveyText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      align: Alignment.bottomCenter,
      duration: duration,
      onlyOne: true,
      backButtonBehavior: BackButtonBehavior.ignore,
      enableSlideOff: false,
      enableKeyboardSafeArea: true,
    );
  }
}
