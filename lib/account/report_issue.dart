import 'package:email_validator/email_validator.dart';
import 'package:lantern/common/common.dart';

bool isEmpty(value) => value == null || value == '';

class ReportIssue extends StatefulWidget {
  ReportIssue({
    Key? key,
  }) : super(key: key);

  @override
  State<ReportIssue> createState() => _ReportIssueState();
}

class _ReportIssueState extends State<ReportIssue> {
  final emailFieldKey = GlobalKey<FormState>();
  late final emailController = CustomTextEditingController(
    formKey: emailFieldKey,
    validator: (value) => EmailValidator.validate(value ?? '')
        ? null
        : 'please_enter_a_valid_email_address'.i18n,
  );
  final issueFieldKey = GlobalKey<FormState>();
  late final issueController = CustomTextEditingController(
    formKey: issueFieldKey,
    validator: (value) => !isEmpty(value) ? null : 'select_an_issue'.i18n,
  );

  final descFieldKey = GlobalKey<FormState>();
  late final descController = CustomTextEditingController(
    formKey: descFieldKey,
    validator: (value) => !isEmpty(value) ? null : 'enter_description'.i18n,
  );

  @override
  void dispose() {
    emailController.dispose();
    issueController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return sessionModel.emailAddress((
      BuildContext context,
      String emailAddress,
      Widget? child,
    ) {
      return sessionModel
          .proUser((BuildContext context, bool proUser, Widget? child) {
        return BaseScreen(
          title: 'report_an_issue'.i18n,
          resizeToAvoidBottomInset: false,
          body: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 25,
                end: 23,
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
                          initialValue: proUser ? emailAddress : '',
                          controller: emailController,
                          autovalidateMode: proUser
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          label: 'email'.i18n,
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
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: blue4,
                                    ),
                                  ),
                                  prefixIcon: Transform.scale(
                                      scale: 0.4,
                                      child: const CAssetImage(
                                          path: ImagePaths.alert))),
                              hint:
                                  CText('select_an_issue'.i18n, style: tsBody1),
                              value: issueController.text != ''
                                  ? issueController.text
                                  : null,
                              icon: const CAssetImage(
                                  path: ImagePaths.arrow_down),
                              //iconSize: iconSize,
                              elevation: 16,
                              onChanged: (String? newValue) {
                                issueController.text = newValue!;
                              },
                              items: <String>[
                                '',
                                'cannot_access_blocked_sites'.i18n,
                                'cannot_complete_purchase'.i18n,
                                'cannot_sign_in'.i18n,
                                'spinner_loads_endlessly'.i18n,
                                'other'.i18n
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: CText(value, style: tsBody1),
                                );
                              }).toList(),
                            ))),
                    Container(
                        margin: const EdgeInsetsDirectional.only(
                          top: 8,
                        ),
                        child: Form(
                          key: descFieldKey,
                          child: CTextField(
                            controller: descController,
                            contentPadding: EdgeInsetsDirectional.all(8.0),
                            label: '',
                            hintText: 'issue_description'.i18n,
                            autovalidateMode: AutovalidateMode.disabled,
                            maxLines: 8,
                            keyboardType: TextInputType.multiline,
                          ),
                        )),
                    const Spacer(),
                    Container(
                        padding: const EdgeInsetsDirectional.only(bottom: 56),
                        child: Button(
                          width: 200,
                          disabled: emailFieldKey.currentState?.validate() ==
                                  false ||
                              issueFieldKey.currentState?.validate() == false ||
                              descFieldKey.currentState?.validate() == false,
                          text: 'send_report'.i18n,
                          onPressed: () async {
                            await sessionModel
                                .reportIssue(
                                    emailController.value.text,
                                    issueController.value.text,
                                    descController.value.text)
                                .then((value) async {
                              CDialog.showInfo(
                                context,
                                title: 'report_sent'.i18n,
                                description:
                                    'thank_you_for_reporting_your_issue'.i18n,
                                actionLabel: 'continue'.i18n,
                                agreeAction: () async {
                                  await context.pushRoute(Support());
                                  return true;
                                },
                              );
                            }).onError((error, stackTrace) {
                              CDialog.showError(
                                context,
                                error: e,
                                stackTrace: stackTrace,
                                description: (error as PlatformException)
                                    .message
                                    .toString(), // This is coming localized
                              );
                            });
                          },
                        )),
                  ])),
        );
      });
    });
  }
}
