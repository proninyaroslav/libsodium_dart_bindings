// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library secure_key_ffi_test;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/secure_key_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/memory_protection.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

import '../../../test_data.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

class MockSodiumPointer extends Mock implements SodiumPointer<UnsignedChar> {}

void main() {
  final mockSodium = MockSodiumFFI();
  final mockSodiumPointer = MockSodiumPointer();

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);
  });

  group('construction', () {
    setUp(() {
      mockAllocArray(mockSodium);
    });

    test('raw locks and blocks access on construction', () {
      SecureKeyFFI(mockSodiumPointer);

      verify(() => mockSodiumPointer.locked = true);
      verify(
        () => mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
      );
    });

    test('alloc allocates new memory', () {
      const length = 42;
      SecureKeyFFI.alloc(mockSodium, length);

      verify(() => mockSodium.sodium_allocarray(length, 1));
    });

    group('random', () {
      test('allocates new memory', () {
        const length = 42;
        SecureKeyFFI.random(mockSodium, length);

        verify(() => mockSodium.sodium_allocarray(length, 1));
      });

      test('fills buffer with random data', () {
        const length = 10;
        SecureKeyFFI.random(mockSodium, length);

        verify(
          () => mockSodium.randombytes_buf(
            any(that: isNot(nullptr)),
            length,
          ),
        );
      });

      test('disposes allocated pointer if random fails', () {
        when(() => mockSodium.randombytes_buf(any(), any()))
            .thenThrow(Exception());

        const length = 10;
        expect(
          () => SecureKeyFFI.random(mockSodium, length),
          throwsA(isA<Exception>()),
        );

        verify(() => mockSodium.sodium_free(any(that: isNot(nullptr))));
      });
    });

    group('attach', () {
      test('throws if nativeHandle has invalid length', () {
        expect(
          () => SecureKeyFFI.attach(mockSodium, [1, 2, 3]),
          throwsA(isArgumentError),
        );
      });

      test('creates key from valid native handle', () {
        final key = SecureKeyFFI.attach(mockSodium, [1, 2]);

        expect(key.length, 2);
        verifyNever(() => mockSodium.sodium_allocarray(any(), any()));
        verify(
          () => mockSodium.sodium_mprotect_noaccess(Pointer.fromAddress(1)),
        );
      });
    });
  });

  group('members', () {
    final testList = Uint8List.fromList(const [0, 1, 2, 3, 4]);
    late Pointer<UnsignedChar> testPtr;

    late SecureKeyFFI sut;

    setUp(() {
      testPtr = testList.toPointer().cast();

      when(() => mockSodiumPointer.count).thenReturn(testList.length);
      when(() => mockSodiumPointer.ptr).thenReturn(testPtr);
      when(() => mockSodiumPointer.asListView()).thenReturn(testList);
      when(() => mockSodiumPointer.asListView<int>()).thenReturn(testList);

      sut = SecureKeyFFI(mockSodiumPointer);
      clearInteractions(mockSodiumPointer);
    });

    tearDown(() {
      calloc.free(testPtr);
    });

    test('length returns pointer length', () {
      expect(sut.length, testList.length);
    });

    group('runUnlockedRaw', () {
      testData<(bool, MemoryProtection)>(
        'sets memory protection levels before running the callback',
        const [
          (false, MemoryProtection.readOnly),
          (true, MemoryProtection.readWrite),
        ],
        (fixture) {
          final res = sut.runUnlockedNative(
            (pointer) {
              expect(pointer, mockSodiumPointer);
              verify(() => mockSodiumPointer.memoryProtection = fixture.$2);
              return true;
            },
            writable: fixture.$1,
          );
          expect(res, isTrue);
        },
      );

      test('resets memory protection after callback', () {
        final res = sut.runUnlockedNative((pointer) {
          verifyNever(
            () =>
                mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
          );
          return true;
        });

        expect(res, isTrue);
        verify(
          () => mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
        );
      });

      test('resets memory protection on exceptions', () {
        expect(
          () => sut.runUnlockedNative((_) => throw Exception()),
          throwsA(isA<Exception>()),
        );
        verifyInOrder([
          () => mockSodiumPointer.memoryProtection = MemoryProtection.readOnly,
          () => mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
        ]);
      });
    });

    group('runUnlockedSync', () {
      testData<(bool, MemoryProtection)>(
        'sets memory protection levels before running the callback',
        const [
          (false, MemoryProtection.readOnly),
          (true, MemoryProtection.readWrite),
        ],
        (fixture) {
          final res = sut.runUnlockedSync(
            (data) {
              expect(data, testList);
              verify(() => mockSodiumPointer.memoryProtection = fixture.$2);
              return true;
            },
            writable: fixture.$1,
          );
          expect(res, isTrue);
        },
      );

      test('resets memory protection after callback', () {
        final res = sut.runUnlockedSync((pointer) {
          verifyNever(
            () =>
                mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
          );
          return true;
        });

        expect(res, isTrue);
        verify(
          () => mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
        );
      });

      test('resets memory protection on exceptions', () {
        expect(
          () => sut.runUnlockedSync((_) => throw Exception()),
          throwsA(isA<Exception>()),
        );
        verifyInOrder([
          () => mockSodiumPointer.memoryProtection = MemoryProtection.readOnly,
          () => mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
        ]);
      });
    });

    group('runUnlockedAsync', () {
      testData<(bool, MemoryProtection)>(
        'sets memory protection levels before running the callback',
        const [
          (false, MemoryProtection.readOnly),
          (true, MemoryProtection.readWrite),
        ],
        (fixture) async {
          final res = await sut.runUnlockedAsync(
            (data) {
              expect(data, testList);
              verify(() => mockSodiumPointer.memoryProtection = fixture.$2);
              return true;
            },
            writable: fixture.$1,
          );
          expect(res, isTrue);
        },
      );

      test('resets memory protection after callback', () async {
        final res = await sut.runUnlockedAsync((pointer) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          verifyNever(
            () =>
                mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
          );
          return true;
        });

        expect(res, isTrue);
        verify(
          () => mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
        );
      });

      test('resets memory protection on exceptions', () async {
        await expectLater(
          () => sut.runUnlockedAsync((_) => throw Exception()),
          throwsA(isA<Exception>()),
        );
        verifyInOrder([
          () => mockSodiumPointer.memoryProtection = MemoryProtection.readOnly,
          () => mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
        ]);
      });
    });

    group('extractBytes', () {
      test('returns copy of bytes', () {
        final bytes = sut.extractBytes();

        expect(bytes, testList);
        expect(bytes, isNot(same(testList)));
      });

      test('unlocks then relocks memory for extracting', () {
        sut.extractBytes();

        verifyInOrder([
          () => mockSodiumPointer.memoryProtection = MemoryProtection.readOnly,
          () => mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
        ]);
      });
    });

    group('copy', () {
      setUp(() {
        mockAllocArray(mockSodium);
        when(() => mockSodiumPointer.sodium).thenReturn(mockSodium);
      });

      test('copy copies key data to newly created key', () {
        sut.copy();

        verifyInOrder([
          () => mockSodiumPointer.memoryProtection = MemoryProtection.readOnly,
          () => mockSodium.sodium_allocarray(testList.length, 1),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
          () => mockSodiumPointer.memoryProtection = MemoryProtection.noAccess,
        ]);
      });

      test('returns independent data copy', () {
        final res = sut.copy();

        expect(res.extractBytes(), testList);
      });
    });

    test('dispose disposes the pointer', () {
      sut.dispose();

      verify(() => mockSodiumPointer.dispose());
    });

    test('detach returns list with detached address and count', () {
      when(() => mockSodiumPointer.detach()).thenReturn(testPtr);

      final nativeHandle = sut.detach();

      expect(nativeHandle, hasLength(2));
      expect(nativeHandle[0], testPtr.address);
      expect(nativeHandle[1], testList.length);

      verify(() => mockSodiumPointer.detach());
    });
  });
}
