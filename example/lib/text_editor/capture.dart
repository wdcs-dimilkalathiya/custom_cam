import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List> captureFromWidget(
  Widget widget, {
  Duration delay = const Duration(seconds: 1),
  double? pixelRatio,
  BuildContext? context,
  Size? targetSize,
}) async {
  ui.Image image =
      await widgetToUiImage(widget, delay: delay, pixelRatio: pixelRatio, context: context, targetSize: targetSize);
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  return byteData!.buffer.asUint8List();
}

/// If you are building a desktop/web application that supports multiple view. Consider passing the [context] so that flutter know which view to capture.
Future<ui.Image> widgetToUiImage(
  Widget widget, {
  Duration delay = const Duration(seconds: 1),
  double? pixelRatio,
  BuildContext? context,
  Size? targetSize,
}) async {
  ///
  ///Retry counter
  ///
  int retryCounter = 3;
  bool isDirty = false;

  Widget child = widget;

  if (context != null) {
    ///
    ///Inherit Theme and MediaQuery of app
    ///
    ///
    child = InheritedTheme.captureAll(
      context,
      MediaQuery(
        data: MediaQuery.of(context),
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }

  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
  final fallBackView = platformDispatcher.views.first;
  final view = context == null ? fallBackView : View.maybeOf(context) ?? fallBackView;
  Size logicalSize = targetSize ?? view.physicalSize / view.devicePixelRatio; // Adapted
  Size imageSize = targetSize ?? view.physicalSize; // Adapted

  assert(logicalSize.aspectRatio.toStringAsPrecision(5) ==
      imageSize.aspectRatio.toStringAsPrecision(5)); // Adapted (toPrecision was not available)

  final RenderView renderView = RenderView(
    view: view,
    child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: logicalSize,
      devicePixelRatio: pixelRatio ?? 1.0,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(
      focusManager: FocusManager(),
      onBuildScheduled: () {
        ///
        ///current render is dirty, mark it.
        ///
        isDirty = true;
      });

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: child,
      )).attachToRenderTree(
    buildOwner,
  );
  ////
  ///Render Widget
  ///
  ///

  buildOwner.buildScope(
    rootElement,
  );
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  ui.Image? image;

  do {
    ///
    ///Reset the dirty flag
    ///
    ///
    isDirty = false;

    image = await repaintBoundary.toImage(pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

    ///
    ///This delay sholud increas with Widget tree Size
    ///

    await Future.delayed(delay);

    ///
    ///Check does this require rebuild
    ///
    ///
    if (isDirty) {
      ///
      ///Previous capture has been updated, re-render again.
      ///
      ///
      buildOwner.buildScope(
        rootElement,
      );
      buildOwner.finalizeTree();
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();
    }
    retryCounter--;

    ///
    ///retry untill capture is successfull
    ///
  } while (isDirty && retryCounter >= 0);
  try {
    /// Dispose All widgets
    // rootElement.visitChildren((Element element) {
    //   rootElement.deactivateChild(element);
    // });
    buildOwner.finalizeTree();
  } catch (e) {
    rethrow;
  }

  return image; // Adapted to directly return the image and not the Uint8List
}
