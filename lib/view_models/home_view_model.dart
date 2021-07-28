import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_object_detection/app/base/base_view_model.dart';
import '/models/recognition.dart';
import 'package:flutter_realtime_object_detection/services/tensorflow_service.dart';
import 'package:flutter_realtime_object_detection/view_states/home_view_state.dart';

class HomeViewModel extends BaseViewModel<HomeViewState> {
  bool _isLoadModel = false;
  bool _isDetecting = false;

  late TensorFlowService _tensorFlowService;

  HomeViewModel(BuildContext context, this._tensorFlowService)
      : super(context, HomeViewState());

  Future switchCamera() async {
    state.cameraIndex = state.cameraIndex == 0 ? 1 : 0;
    this.notifyListeners();
  }

  Future<void> loadModel(ModelType type) async {
    if (type != this._tensorFlowService.type) {
      await this._tensorFlowService.loadModel(type);
    }
    this._isLoadModel = true;
  }

  Future<void> runModel(CameraImage cameraImage) async {
    if (_isLoadModel) {
      if (!this._isDetecting) {
        this._isDetecting = true;
        int startTime = new DateTime.now().millisecondsSinceEpoch;
        var recognitions =
            await this._tensorFlowService.runModelOnFrame(cameraImage);
        int endTime = new DateTime.now().millisecondsSinceEpoch;
        print('Time detection: ${endTime - startTime}');
        if (recognitions != null) {
          state.recognitions = List<Recognition>.from(
              recognitions.map((model) => Recognition.fromJson(model)));
          state.widthImage = cameraImage.width;
          state.heightImage = cameraImage.height;
          notifyListeners();
        }
        this._isDetecting = false;
      }
    } else {
      throw 'Please run `loadModel(type)` before running `runModel(cameraImage)`';
    }
  }

  void close() {
    this._tensorFlowService.close();
  }
}
