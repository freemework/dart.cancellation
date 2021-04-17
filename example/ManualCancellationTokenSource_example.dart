// Copyright 2021, the Freemework.ORG project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Completer, Future;

import 'package:freemework/freemework.dart'
    show CancellationException, CancellationToken;
import 'package:freemework_cancellation/freemework_cancellation.dart'
    show ManualCancellationTokenSource;

void main() {
  final cts = ManualCancellationTokenSource();

  // Run long operation (pass cancellation token to be able to interrupt execution)
  emulateLongRunIoJob(cts.token).then((value) {
    print('Never happened');
  }).catchError((e) {
    print(e.runtimeType); // "CancellationException"

    final CancellationException friendlyEx = e;

    print(friendlyEx.message); // "An operation was cancelled by an user."

    // StackTrace of interrupted long run IO operation. This will help to detect where long run IO operation interruped.
    print(
        'Long run task was interrupted in stackTrace: ${friendlyEx.stackTrace}');

    // StackTrace of cts.cancel(). This will help to detect where cancellation activates.
    print(
        'cts.cancel() was called in stackTrace: ${friendlyEx.cancellationOriginException!.stackTrace}');
  });

  Future.delayed(Duration(seconds: 5)).then((_) {
    // Cancel our long run IO operaion
    try {
      cts.cancel();
    } catch (e) {
      print('cancel() failure: ${e.toString()}');
    }
    return;
  });
}

///
/// The function is emulating long IO operation.
///
/// Usually, you do not need to handle cancellationToken at all,
/// but just to pass it in underlaying libraries that already
/// supported CancellationToken ecosystem.
///
Future<void> emulateLongRunIoJob(CancellationToken cancellationToken) async {
  // The completer never completed normally.
  final completer = Completer<void>();

  final cancellationListener = (CancellationException cancellationOrigin) {
    // The completer finished with CancellationException by cancel() request.
    try {
      // We grab stackTrace in this way. The user will have both
      // stackTraces: cancellationOrigin and executionOrigin
      throw CancellationException.withCancellationOrigin(cancellationOrigin);
    } catch (executionOrigin) {
      completer.completeError(executionOrigin);
    }
  };

  cancellationToken.addCancelListener(cancellationListener);
  try {
    await completer.future;
  } finally {
    cancellationToken.removeCancelListener(cancellationListener);
  }
}
