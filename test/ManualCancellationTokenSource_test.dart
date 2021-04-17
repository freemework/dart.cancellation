// Copyright 2021, the Freemework.ORG project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'package:freemework_cancellation/freemework_cancellation.dart'
    show ManualCancellationTokenSource;
import 'package:test/test.dart'
    show expect, group, isFalse, isTrue, setUp, tearDown, test;

void main() {
  group('ManualCancellationTokenSource tests', () {
    ManualCancellationTokenSource? cts;

    setUp(() {
      cts = ManualCancellationTokenSource();
    });

    tearDown(() {
      cts = null;
    });

    test(
        'Should set isCancellationRequested on both Token Source and its Token',
        () {
      final token = cts!.token;

      cts!.cancel();

      expect(cts!.isCancellationRequested, isTrue,
          reason:
              'Token Source should have active(true) isCancellationRequested value');
      expect(token.isCancellationRequested, isTrue,
          reason:
              'Token should have active(true) isCancellationRequested value');
    });

    test('Should call two cancel-listeners', () {
      var cancelFlag1 = false;
      var cancelFlag2 = false;

      final token = cts!.token;

      token.addCancelListener((e) {
        cancelFlag1 = true;
      });
      token.addCancelListener((e) {
        cancelFlag2 = true;
      });

      cts!.cancel();

      expect(cancelFlag1, isTrue);
      expect(cancelFlag2, isTrue);
    });

    test('Should call one cancel-listener due second one was removed', () {
      var cancelFlag1 = false;
      var cancelFlag2 = false;

      final token = cts!.token;

      token.addCancelListener((e) {
        cancelFlag1 = true;
      });

      final secondListener = (e) {
        cancelFlag2 = true;
      };

      token.addCancelListener(secondListener);
      token.removeCancelListener(secondListener);

      cts!.cancel();

      expect(cancelFlag1, isTrue);
      expect(cancelFlag2, isFalse);
    });

    test('Should allow multiple call of cancel()', () {
      var cancelFlag1 = 0;
      var cancelFlag2 = 0;

      final token = cts!.token;

      token.addCancelListener((e) {
        ++cancelFlag1;
      });
      token.addCancelListener((e) {
        ++cancelFlag2;
      });

      cts!.cancel();
      cts!.cancel();
      cts!.cancel();
      cts!.cancel();
      cts!.cancel();
      cts!.cancel();
      cts!.cancel();

      expect(cancelFlag1, 1);
      expect(cancelFlag2, 1);
    });
  });
}
