// The MIT License (MIT)
//
// Copyright (c) 2013-2019 Khan Academy and other contributors
// Copyright (c) 2020 znjameswu <znjameswu@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'parse_error.dart';

//命名空间包含两类设置，内置和当前设置
class Namespace<T> {
  Namespace(this.builtins, Map<String, T> current)
      : current = Map.from(current);
  final Map<String, T> current;
  final Map<String, T> builtins;
  final undefStack = <Map<String, T?>>[];

  T? get(String name) {
    final currentRes = this.current[name];
    if (currentRes != null) {
      return currentRes;
    }
    return this.builtins[name];
  }

  void set(String name, T value, {bool global = false}) {
    if (global) {
      for (final undef in undefStack) {
        undef.remove(name);
      }
      if (this.undefStack.isNotEmpty) {
        this.undefStack.last[name] = value;
      }
    } else {
      if (this.undefStack.isNotEmpty) {
        this.undefStack.last[name] = this.current[name];
      }
    }
    this.current[name] = value;
  }

  bool has(String name) =>
      this.current.containsKey(name) || this.builtins.containsKey(name);

  void beginGroup() {
    this.undefStack.add({});
  }

  void endGroup() {
    if (this.undefStack.isEmpty) {
      throw ParseException('Unbalanced namespace destruction: attempt '
          'to pop global namespace; please report this as a bug');
    }
    final undefs = this.undefStack.removeLast();
    undefs.forEach((key, value) {
      if (value == null) {
        this.current.remove(key);
      } else {
        this.current[key] = value;
      }
    });
  }
}
