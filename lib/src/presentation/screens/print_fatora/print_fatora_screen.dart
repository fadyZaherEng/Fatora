// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fatora/main.dart';
import 'package:fatora/src/config/theme/color_schemes.dart';
import 'package:fatora/src/core/base/widget/base_stateful_widget.dart';
import 'package:fatora/src/core/resources/image_paths.dart';
import 'package:fatora/src/core/utils/permission_service_handler.dart';
import 'package:fatora/src/core/utils/show_action_dialog_widget.dart';
import 'package:fatora/src/domain/entities/fatora.dart';
import 'package:fatora/src/presentation/screens/bluetooth/bluetooth_screen.dart';
import 'package:fatora/src/presentation/screens/bluetooth/bluetooth_printer_screen.dart';
import 'package:fatora/src/presentation/screens/bluetooth/test.dart';
import 'package:fatora/src/presentation/widgets/custom_button_widget.dart';
import 'package:fatora/src/presentation/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'dart:io';

class PrintFatoraScreen extends BaseStatefulWidget {
  final Fatora? fatora;

  const PrintFatoraScreen({
    super.key,
    required this.fatora,
  });

  @override
  BaseState<PrintFatoraScreen> baseCreateState() => _PrintFatoraScreenState();
}

class _PrintFatoraScreenState extends BaseState<PrintFatoraScreen> {
  final GlobalKey _globalKeyForPrint = GlobalKey();

  final _fatoraNameController = TextEditingController();

  @override
  Widget baseBuild(BuildContext context) {
    if (widget.fatora == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              "لا يوجد فاتورة من فضلك اختار فاتورة من سجل الفواتير \n او قم باضافة فاتورة جديدة",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: ColorSchemes.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                RepaintBoundary(
                  key: _globalKeyForPrint,
                  child: _buildFatoraDetails(isPrint: false),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWidget(
                        onTap: () {
                          _connectWithBluetoothPrinter();
                        },
                        buttonBorderRadius: 34,
                        text: "طباعة الفاتورة",
                        backgroundColor: ColorSchemes.primary,
                        textColor: ColorSchemes.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomButtonWidget(
                        onTap: () {
                          _captureAndSaveImage();
                        },
                        buttonBorderRadius: 34,
                        text: "تحميل الفاتورة",
                        backgroundColor: const Color.fromRGBO(48, 166, 41, 1),
                        textColor: ColorSchemes.white,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemNumber(label, value) {
    return Text('$label: $value',
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ColorSchemes.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ));
  }

  Widget _buildArrowWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(children: [
            Container(
              width: 10,
              height: 3,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 3),
            Container(
              width: 10,
              height: 3,
              color: Colors.grey[300],
            )
          ]),
          const SizedBox(width: 10),
          for (int i = 0; i < 8; i++)
            Row(
              children: [
                Column(children: [
                  Container(
                    width: 20,
                    height: 3,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 20,
                    height: 3,
                    color: Colors.grey[300],
                  )
                ]),
                const SizedBox(width: 10),
              ],
            ),
          const SizedBox(width: 10),
          Column(
            children: [
              Container(
                width: 10,
                height: 3,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 3),
              Container(
                width: 10,
                height: 3,
                color: Colors.grey[300],
              )
            ],
          ),
        ],
      );
  Uint8List? _imageBytes;

  // Function to capture the widget as an image
  Future<void> _captureAndSaveImage() async {
    // Delay capture until the widget has fully rendered
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Request permissions (for mobile platforms)
      if (await PermissionServiceHandler().handleServicePermission(
          setting: PermissionServiceHandler.getStorageFilesPermission(
        androidDeviceInfo:
            Platform.isAndroid ? await DeviceInfoPlugin().androidInfo : null,
      ))) {
        RenderRepaintBoundary boundary = _globalKeyForPrint.currentContext!
            .findRenderObject() as RenderRepaintBoundary;

        // Convert the widget to an image
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();
        // Update the state with the captured image
        setState(() {
          _imageBytes = pngBytes; // Set the image bytes to display later
        });
        // Save the image to the gallery using ImageGallerySaver
        final result = await ImageGallerySaver.saveImage(
            _imageBytes ?? Uint8List.fromList([]),
            quality: 100);
        print(result); // Prints the saved path in the gallery

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: ColorSchemes.white,
            content: Text('تم تحميل الفاتورة بنجاح الى المعرض',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorSchemes.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ))));
      } else {
        _dialogMessage(
            icon: ImagePaths.warning,
            message: "Storage Permission Is Required To Proceed",
            primaryAction: () async {
              Navigator.pop(context);
              openAppSettings().then((value) async {
                if (await PermissionServiceHandler()
                    .handleServicePermission(setting: Permission.storage)) {}
              });
            });
      }
    } catch (e) {
      print("Error capturing widget: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error capturing image')));
    }
  }

  Future<Uint8List?> createImageFromWidget(Widget widget,
      {Duration? wait, Size? logicalSize, Size? imageSize}) async {
    var cxt = appNavigatorKey.currentState!.context;
// Create a repaint boundary to capture the image
    final repaintBoundary = RenderRepaintBoundary();

// Calculate logicalSize and imageSize if not provided
    logicalSize ??= View.of(cxt).physicalSize / View.of(cxt).devicePixelRatio;
    imageSize ??= View.of(cxt).physicalSize;

// Ensure logicalSize and imageSize have the same aspect ratio
    assert(logicalSize.aspectRatio == imageSize.aspectRatio,
        'logicalSize and imageSize must not be the same');

// Create the render tree for capturing the widget as an image
    final renderView = RenderView(
      view: View.of(cxt),
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

// Attach the widget's render object to the render tree
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        )).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

// Delay if specified
    if (wait != null) {
      await Future.delayed(wait);
    }

// Build and finalize the render tree
    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();

// Flush layout, compositing, and painting operations
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

// Capture the image and convert it to byte data
    final image = await repaintBoundary.toImage(
        pixelRatio: imageSize.width / logicalSize.width);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

// Return the image data as Uint8List
    return byteData?.buffer.asUint8List();
  }

  void _dialogMessage({
    required String message,
    required String icon,
    required Function() primaryAction,
    Function()? secondaryAction,
  }) {
    showActionDialogWidget(
        context: context,
        text: message,
        icon: icon,
        primaryText: "نعم",
        secondaryText: "لا",
        primaryAction: () async {
          primaryAction();
        },
        secondaryAction: () {
          secondaryAction ?? Navigator.pop(context);
        });
  }

  void _connectWithBluetoothPrinter() async {
    if (await PermissionServiceHandler().handleServicePermission(
        setting: PermissionServiceHandler.getStorageFilesPermission(
      androidDeviceInfo:
          Platform.isAndroid ? await DeviceInfoPlugin().androidInfo : null,
    ))) {
      _imageBytes = await createImageFromWidget(
        _buildFatoraDetails(isPrint: true),
        logicalSize: const Size(500, 500),
        imageSize: const Size(680, 680),
      );
    } else {
      _dialogMessage(
          icon: ImagePaths.warning,
          message: "الرجاء تفعيل صلاحية المستخدم للتطبيق",
          primaryAction: () async {
            Navigator.pop(context);
            openAppSettings().then((value) async {
              if (await PermissionServiceHandler()
                  .handleServicePermission(setting: Permission.storage)) {}
            });
          });
    }
    if (_imageBytes != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintScreenApp(
            imageBytes: _imageBytes!,
          ),
        ),
      );
    }
  }

  Widget _buildFatoraDetails({bool isPrint = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ImagePaths.log,
              width: 40,
              height: 30,
            ),
            const SizedBox(width: 10),
            SvgPicture.asset(
              ImagePaths.visa,
              width: 40,
              height: 35,
            ),
            const SizedBox(width: 10),
            SvgPicture.asset(
              ImagePaths.master,
              width: 40,
              height: 35,
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          widget.fatora!.paymentMethod,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColorSchemes.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.fatora!.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColorSchemes.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 15),
        Text(
          "شحن بطاقة",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColorSchemes.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        _buildArrowWidget(),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              Text(widget.fatora!.date.split(" ")[0],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColorSchemes.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      )),
              const Spacer(),
              Text(
                widget.fatora!.time.split(" ")[0],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ColorSchemes.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildArrowWidget(),
        const SizedBox(height: 15),
        Text(
          widget.fatora!.status,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColorSchemes.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          "المبلغ",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColorSchemes.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.fatora!.price,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ColorSchemes.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.fatora!.statusSuccess,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ColorSchemes.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          "بطاقة المستلم",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ColorSchemes.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(height: 10),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.fatora!.fatoraId.substring(0, 4),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorSchemes.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              Text(
                "XXXXXXXX",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorSchemes.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              Text(
                widget.fatora!.fatoraId.substring(
                    widget.fatora!.fatoraId.length - 4,
                    widget.fatora!.fatoraId.length),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorSchemes.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.fatora!.fatoraSenderId.substring(0, 4),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorSchemes.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              Text(
                "XXXXXXXX",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorSchemes.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              Text(
                widget.fatora!.fatoraSenderId.substring(
                    widget.fatora!.fatoraSenderId.length - 4,
                    widget.fatora!.fatoraSenderId.length),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorSchemes.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        isPrint
            ? Text(
                _fatoraNameController.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorSchemes.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
              )
            : CustomTextFieldWidget(
                hintText: "الاسم",
                isPrefixIcon: false,
                textEditingController: _fatoraNameController,
                keyboardType: TextInputType.text,
                onChanged: (String value) {
                  _fatoraNameController.text = value;
                },
              ),
        const SizedBox(height: 10),
        _buildArrowWidget(),
        const SizedBox(height: 10),
        //add some space
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemNumber("رقم الايصال", widget.fatora!.numberArrived),
                  const SizedBox(height: 10),
                  _buildItemNumber("رقم الحركة", widget.fatora!.numberMove),
                  const SizedBox(height: 10),
                  _buildItemNumber("رقم الجهاز", widget.fatora!.deviceNumber),
                  const SizedBox(height: 10),
                  _buildItemNumber("رقم التاجر", widget.fatora!.traderNumber),
                  const SizedBox(height: 10),
                ]),
          ),
        ),
        _buildArrowWidget(),
        const SizedBox(height: 10),
      ],
    );
  }
}
