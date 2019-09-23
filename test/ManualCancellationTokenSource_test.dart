// Copyright 2021, the Freemework.ORG project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'package:freemework_cancellation/freemework_cancellation.dart' show ManualCancellationTokenSource;
import 'package:test/test.dart' show expect, group, isFalse, isTrue, setUp, tearDown, test;

void main() {
  group('SimpleCancellationTokenSource tests', () {
    ManualCancellationTokenSource cts;

    setUp(() {
      cts = ManualCancellationTokenSource();
    });

    tearDown(() {
      cts = null;
    });

    test('Should cancel two listeners', () {
      var cancel1 = false;
      var cancel2 = false;

      final token = cts.token;

      token.addCancelListener((e) {
        cancel1 = true;
      });
      token.addCancelListener((e) {
        cancel2 = true;
      });

      cts.cancel();

      expect(cancel1, isTrue);
      expect(cancel2, isTrue);
    });

    test('Should cancel one listener due second one was removed', () {
      var cancel1 = false;
      var cancel2 = false;

      final token = cts.token;

      token.addCancelListener((e) {
        cancel1 = true;
      });

      final secondListener = (e) {
        cancel2 = true;
      };

      token.addCancelListener(secondListener);
      token.removeCancelListener(secondListener);

      cts.cancel();

      expect(cancel1, isTrue);
      expect(cancel2, isFalse);
    });
  });
}
