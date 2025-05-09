// ignore_for_file: use_build_context_synchronously
import 'package:email_validator/email_validator.dart';
import 'package:lantern/core/app/app_loading_dialog.dart';
import 'package:lantern/core/utils/common.dart';

@RoutePage(name: 'ReportIssue')
class ReportIssue extends StatefulWidget {
  final String? description;

  const ReportIssue({super.key, this.description});

  @override
  State<ReportIssue> createState() => _ReportIssueState();
}

class _ReportIssueState extends State<ReportIssue> {
  final emailFieldKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    text: sessionModel.userEmail.value,
    formKey: emailFieldKey,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      return EmailValidator.validate(value ?? '')
          ? null
          : 'please_enter_a_valid_email_address'.i18n;
    },
  );

  final issueFieldKey = GlobalKey<FormState>();
  late final issueController = CustomTextEditingController(
    formKey: issueFieldKey,
    validator: (value) {
      if (value!.isEmpty) {
        return 'select_an_issue'.i18n;
      }
      return null;
    },
  );

  final descFieldKey = GlobalKey<FormState>();
  late final descController = CustomTextEditingController(
      text: widget.description ?? '',
      formKey: descFieldKey,
      validator: (value) {
        if (value!.isEmpty) {
          return 'enter_description'.i18n;
        }
        return null;
      });

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'report_an_issue'.i18n,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 20,
          end: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // * Email field
            Container(
              margin: const EdgeInsetsDirectional.only(
                top: 24,
                bottom: 8,
              ),
              child: Form(
                key: emailFieldKey,
                child: CTextField(
                  controller: emailController,
                  autovalidateMode: AutovalidateMode.disabled,
                  label: 'email'.i18n,
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const CAssetImage(path: ImagePaths.email),
                ),
              ),
            ),
            Container(
                margin: const EdgeInsetsDirectional.only(
                  top: 8,
                  bottom: 8,
                ),
                child: Form(
                    key: issueFieldKey,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: grey3,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: blue4,
                            ),
                          ),
                          prefixIcon: Transform.scale(
                              scale: 0.4,
                              child:
                                  const CAssetImage(path: ImagePaths.alert))),
                      hint: CText('select_an_issue'.i18n, style: tsBody1),
                      value: issueController.text != ''
                          ? issueController.text
                          : null,
                      icon: const CAssetImage(path: ImagePaths.arrow_down),
                      //iconSize: iconSize,
                      elevation: 16,
                      onChanged: (String? newValue) {
                        setState(() {
                          issueController.text = newValue!;
                        });
                      },
                      padding: isDesktop()
                          ? const EdgeInsetsDirectional.only(
                              top: 8,
                              bottom: 8,
                            )
                          : const EdgeInsetsDirectional.all(0),
                      items: <String>[
                        'cannot_access_blocked_sites'.i18n,
                        'cannot_complete_purchase'.i18n,
                        'cannot_sign_in'.i18n,
                        'discover_not_working'.i18n,
                        'spinner_loads_endlessly'.i18n,
                        'slow'.i18n,
                        'cannot_link_devices'.i18n,
                        'application_crashes'.i18n,
                        'other'.i18n
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: CText(value, style: tsBody1),
                        );
                      }).toList(),
                    ))),
            const SizedBox(height: 8),
            Form(
              key: descFieldKey,
              child: CTextField(
                tooltipMessage: 'report_description'.i18n,
                controller: descController,
                contentPadding: isDesktop()
                    ? const EdgeInsetsDirectional.all(16.0)
                    : const EdgeInsetsDirectional.all(8.0),
                hintText: 'issue_description'.i18n,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                autovalidateMode: AutovalidateMode.disabled,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const Spacer(),
            Tooltip(
              message: isDesktop() ? '' : AppKeys.sendReport,
              child: Button(
                width: 200,
                disabled: isButtonDisabled(),
                text: 'send_report'.i18n,
                onPressed: onSendReportTap,
              ),
            ),
            if (!Platform.isLinux) ...[
              const SizedBox(
                height: 26.0,
              ),
              Tooltip(
                message: isDesktop() ? '' : "Share logs",
                child: Button(
                  width: 200,
                  text: "Share logs",
                  onPressed: onShareLogsTap,
                ),
              ),
            ],
            const SizedBox(
              height: 56.0,
            ),
          ],
        ),
      ),
    );
  }

  bool isButtonDisabled() {
    if (emailController.text.isNotEmpty) {
      if (!EmailValidator.validate(emailController.text)) {
        return true;
      }
    }
    if (issueController.text.isEmpty) {
      return true;
    }
    return false;
  }

  Future<void> onSendReportTap() async {
    try {
      AppLoadingDialog.showLoadingDialog(context);
      await sessionModel.reportIssue(emailController.value.text,
          issueController.value.text, descController.value.text);
      AppLoadingDialog.dismissLoadingDialog(context);
      CDialog.showInfo(
        context,
        title: 'report_sent'.i18n,
        description: 'thank_you_for_reporting_your_issue'.i18n,
        actionLabel: 'continue'.i18n,
        agreeAction: () async {
          resetController();
          return true;
        },
      );
    } catch (error, stackTrace) {
      print(stackTrace);
      AppLoadingDialog.dismissLoadingDialog(context);
      CDialog.showError(
        context,
        error: error,
        stackTrace: stackTrace,
        description: error.localizedDescription, // This is coming localized
      );
    }
  }

  Future<void> onShareLogsTap() async {
    try {
      AppLoadingDialog.showLoadingDialog(context);
      await sessionModel.shareLogs();
      AppLoadingDialog.dismissLoadingDialog(context);
    } catch (error, stackTrace) {
      print(stackTrace);
      AppLoadingDialog.dismissLoadingDialog(context);
      CDialog.showError(
        context,
        error: error,
        stackTrace: stackTrace,
        description: error.localizedDescription, // This is coming localized
      );
    }
  }

  void resetController() {
    setState(() {
      issueController.clear();
      descController.clear();
      emailController.clear();
    });
  }
}
