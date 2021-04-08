// Copyright 2021, the Freemework.ORG project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'package:freemework/errors/CancellationException.dart';
import 'package:freemework/freemework.dart'
    show
        AggregateException,
        CancellationCallback,
        CancellationToken,
        FreemeworkException;

import 'CancellationTokenSource.dart';

class ManualCancellationTokenSource implements CancellationTokenSource {
  final List<CancellationCallback> _cancelListeners;
  bool _isCancellationRequested = false;

  ManualCancellationTokenSource() : _cancelListeners = [];

  @override
  CancellationToken get token => _ManualCancellationToken(this);

  @override
  bool get isCancellationRequested => _isCancellationRequested;

  @override
  void cancel() {
    if (_isCancellationRequested) {
      // Prevent to call listeners twice
      return;
    }
    _isCancellationRequested = true;

    if (_cancelListeners.isNotEmpty) {
      CancellationException cancellationException;
      try {
        throw CancellationException();
      } catch (e) {
        // Got stack trace in this way
        cancellationException = e;
      }

      final errors = <FreemeworkException>[];

      // Release callback. We do not need its anymore
      final cancelListeners = List<CancellationCallback>.from(_cancelListeners);
      for (final cancelListener in cancelListeners) {
        try {
          cancelListener(cancellationException);
        } catch (e) {
          errors.add(FreemeworkException.wrapIfNeeded(e));
        }
      }

      AggregateException.throwIfNeeded(errors);
    }
  }

  void _addCancelListener(CancellationCallback cb) {
    _cancelListeners.add(cb);
  }

  void _removeCancelListener(CancellationCallback cb) {
    _cancelListeners.remove(cb);
  }

  void _throwIfCancellationRequested() {
    if (_isCancellationRequested) {
      throw CancellationException();
    }
  }
}

class _ManualCancellationToken implements CancellationToken {
  final ManualCancellationTokenSource _owner;

  _ManualCancellationToken(this._owner);

  @override
  bool get isCancellationRequested => _owner.isCancellationRequested;

  @override
  void addCancelListener(CancellationCallback cb) {
    _owner._addCancelListener(cb);
  }

  @override
  void removeCancelListener(CancellationCallback cb) {
    _owner._removeCancelListener(cb);
  }

  @override
  void throwIfCancellationRequested() {
    _owner._throwIfCancellationRequested();
  }
}
