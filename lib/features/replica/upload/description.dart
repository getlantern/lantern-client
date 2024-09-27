import 'package:lantern/core/utils/common.dart';

@RoutePage(name: 'ReplicaUploadDescription')
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
  late int textLength;

  @override
  void initState() {
    textEditingController.text = widget.fileDescription ?? '';
    textLength =
        widget.fileDescription != null ? widget.fileDescription!.length : 0;
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
            offset: const Offset(0, 14),
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
            onChanged: (value) => setState(() {
              textLength = value.length;
            }),
            maxLines: 8,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            controller: textEditingController,
            maxLength: maxCharLength,
            // Hacky, but as per design
            label: CText(
              '$textLength/$maxCharLength',
              style: CTextStyle(
                fontSize: 12,
                lineHeight: 12,
                color: textLength < (maxCharLength - 10) ? black : indicatorRed,
              ),
            ),
            style: tsBody2,
            // to keep the layout according to specs, we need an initial value as well as hintText
            hintText: 'description_initial_value'.i18n,
            textInputAction: TextInputAction.newline,
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
      text: 'next'.i18n,
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
