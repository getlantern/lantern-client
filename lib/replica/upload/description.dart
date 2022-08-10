import 'package:lantern/common/common.dart';

class ReplicaUploadDescription extends StatefulWidget {
  final File fileToUpload;
  final String fileTitle;
  final String? fileDescription;

  ReplicaUploadDescription({
    Key? key,
    required this.fileToUpload,
    required this.fileTitle,
    this.fileDescription,
  });

  @override
  State<StatefulWidget> createState() => ReplicaUploadDescriptionState();
}

class ReplicaUploadDescriptionState extends State<ReplicaUploadDescription> {
  final formKey = GlobalKey<FormState>(debugLabel: 'replicaUploadDescription');
  late final textEditingController =
      CustomTextEditingController(formKey: formKey);

  @override
  void initState() {
    textEditingController.text = widget.fileDescription ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when clicking anywhere
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: BaseScreen(
        showAppBar: true,
        padHorizontal: true,
        title: 'add_description'.i18n,
        body: PinnedButtonLayout(
          content: [
            renderDescriptionField(),
          ],
          button: renderButtons(),
        ),
      ),
    );
  }

  Widget renderDescriptionField() {
    const maxCharLength = 1000;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 24.0,
        start: 8.0,
        end: 8.0,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: AlignmentDirectional.topStart,
        children: [
          Transform.translate(
            offset: const Offset(0, 16),
            child: Container(
              decoration: BoxDecoration(
                color: grey5,
                border: Border(
                  top: BorderSide(width: 1.0, color: black),
                ),
              ),
            ),
          ),
          CTextField(
            minLines: 10,
            autofocus: true,
            keyboardType: TextInputType.text,
            controller: textEditingController,
            maxLength: maxCharLength,
            // TODO: <08-10-22, kalli> Hacky, but as per design
            label:
                '${textEditingController.value.text.characters.length}/$maxCharLength',
            style: tsBody2,
            // to keep the layout according to specs, we need an initial value as well as hintText
            hintText: 'description_initial_value'.i18n,
            textInputAction: TextInputAction.done,
            removeBorder: true,
            contentPadding: const EdgeInsetsDirectional.only(
              top: 12.0,
              bottom: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget renderButtons() {
    return Button(
      width: 200,
      text: 'review'.i18n,
      onPressed: () async => await context.pushRoute(
        ReplicaUploadReview(
          fileToUpload: widget.fileToUpload,
          fileTitle: widget.fileTitle,
          // if initial value is not empty (so the user has not interacted with text field), don't carry it over to next screen
          fileDescription: widget.fileDescription ?? textEditingController.text,
        ),
      ),
    );
  }
}
