// Copyright 2021, the Freemework.ORG project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:freemework/freemework.dart' show InvalidOperationException;

import 'ManualCancellationTokenSource.dart';

class TimeoutCancellationTokenSource extends ManualCancellationTokenSource {
  Timer _timeoutHandler;

  TimeoutCancellationTokenSource(Duration timeout) {
    _timeoutHandler = Timer(timeout, _onTimer);
  }

  bool get isActive => _timeoutHandler != null;

  @override
  void cancel() {
    if (_timeoutHandler != null) {
      _timeoutHandler.cancel();
      _timeoutHandler = null;
    }
    super.cancel();
  }

  ///
  /// After call the method, the instance behaves is as `SimpleCancellationTokenSource`
  ///
  void preventTimeout() {
    if (_timeoutHandler == null) {
      throw InvalidOperationException('Cannot prevent inactive timeout.');
    }

    _timeoutHandler.cancel();
    _timeoutHandler = null;
  }

  void _onTimer() {
    if (_timeoutHandler != null) {
      _timeoutHandler = null;
    }
    super.cancel();
  }
}
