import 'package:lantern/common/common.dart';

class ReplicaUploadDescription extends StatefulWidget {
  final File fileToUpload;
  final String fileTitle;

  ReplicaUploadDescription({
    Key? key,
    required this.fileToUpload,
    required this.fileTitle,
  });

  @override
  State<StatefulWidget> createState() => ReplicaUploadDescriptionState();
}

class ReplicaUploadDescriptionState extends State<ReplicaUploadDescription> {
  final formKey = GlobalKey<FormState>(debugLabel: 'replicaUploadDescription');
  late final textEditingController =
      CustomTextEditingController(formKey: formKey);
  late TextStyle textStyle = tsBody2.copiedWith(color: grey5);
  late String initialValue = 'description_initial_value'.i18n;

  @override
  void initState() {
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
      padding: const EdgeInsetsDirectional.only(top: 24.0),
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
            keyboardType: TextInputType.text,
            controller: textEditingController,
            maxLength: maxCharLength,
            label:
                '${textEditingController.value.text.characters.length}/$maxCharLength',
            style: textStyle,
            // to keep the layout according to specs, we need an initial value as well as hintText
            initialValue: initialValue,
            hintText: 'description_initial_value'.i18n,
            textInputAction: TextInputAction.done,
            removeBorder: true,
            contentPadding: const EdgeInsetsDirectional.only(
              top: 12.0,
              bottom: 12.0,
            ),
            onTap: () {
              // We only clear this on first tap, once the initial value is removed
              if (initialValue != '') textEditingController.text = '';
              setState(() {
                textStyle = tsBody2;
                initialValue = '';
              });
            },
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
          fileDescription: textEditingController.text,
        ),
      ),
    );
  }
}
