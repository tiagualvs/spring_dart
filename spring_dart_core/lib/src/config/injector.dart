import 'dart:async';

class Injector {
  static final Injector _instance = Injector._();

  final Set<Instance> _instances = {};

  Injector._();

  static Injector get instance => _instance;

  Future<void> commit() async {
    final newInstances = Set<_InstanceAsync>.from(_instances.whereType<_InstanceAsync>());
    for (final i in newInstances) {
      final instance = await i.instantiateAsync();
      _instances.remove(i);
      _instances.add(instance);
    }
  }

  void set<T extends Object>(T Function() constructor) {
    _instances.add(Instance<T>.create(constructor));
  }

  void setAsync<T extends Object>(FutureOr<T> Function() instance) {
    _instances.add(Instance<T>.createAsync(instance));
  }

  T get<T extends Object>() {
    final instance = _instances.where((i) => i.type == T).firstOrNull;
    if (instance == null) {
      throw NotRegisteredException(T, 'No instance of $T found');
    }
    if (instance.alreadyInstantiated) return instance.instance;
    Instance<T> newInstance;
    try {
      newInstance = instance.instantiate() as Instance<T>;
    } on NotInstantiatedException catch (e) {
      final innerInstance = _getFromType(e.type).instantiate();
      _instances.removeWhere((i) => i.type == e.type);
      _instances.add(innerInstance);
      newInstance = instance.instantiate() as Instance<T>;
    } on Exception {
      rethrow;
    }
    _instances.remove(instance);
    _instances.add(newInstance);
    return newInstance.instance;
  }

  Instance _getFromType(Type type) {
    final instance = _instances.where((i) => i.type == type).firstOrNull;
    if (instance == null) {
      throw NotRegisteredException(type, 'No instance of $type found');
    }

    return instance;
  }
}

sealed class Instance<T> {
  final Type type;
  const Instance(this.type);
  const factory Instance.create(T Function() constructor) = _Instance<T>;
  const factory Instance.createAsync(FutureOr<T> Function() constructor) = _InstanceAsync<T>;

  bool get alreadyInstantiated;
  T get instance;
  Instance<T> instantiate();
  FutureOr<Instance<T>> instantiateAsync();
}

class _Instance<T> extends Instance<T> {
  final T Function() constructor;
  final T? _instance;

  const _Instance(this.constructor) : _instance = null, super(T);
  const _Instance.withInstance(this.constructor, this._instance) : super(T);

  @override
  bool get alreadyInstantiated => _instance != null;

  @override
  T get instance {
    if (alreadyInstantiated) return _instance!;
    throw NotInstantiatedException(T, '$T is not instantiated!');
  }

  @override
  Instance<T> instantiate() {
    if (alreadyInstantiated) return this;
    return _Instance<T>.withInstance(constructor, constructor());
  }

  @override
  FutureOr<Instance<T>> instantiateAsync() {
    return instantiate();
  }
}

final class _InstanceAsync<T> extends Instance<T> {
  final FutureOr<T> Function() constructor;
  final T? _instance;

  const _InstanceAsync(this.constructor) : _instance = null, super(T);
  const _InstanceAsync.withInstance(this.constructor, this._instance) : super(T);

  @override
  bool get alreadyInstantiated => _instance != null;

  @override
  T get instance {
    if (alreadyInstantiated) return _instance!;
    throw NotInstantiatedException(T, '$T is not instantiated!');
  }

  @override
  Instance<T> instantiate() {
    if (alreadyInstantiated) return this;
    throw NotInstantiatedException(T, '$T is not instantiated!');
  }

  @override
  Future<Instance<T>> instantiateAsync() async {
    if (alreadyInstantiated) return this;
    return _InstanceAsync<T>.withInstance(constructor, await constructor());
  }
}

abstract class InjectorException implements Exception {
  final Type type;
  final String message;

  const InjectorException(this.type, this.message);

  @override
  String toString() {
    return '$runtimeType(type: $type, message: $message)';
  }
}

class NotInstantiatedException extends InjectorException {
  const NotInstantiatedException(super.type, super.message);
}

class NotRegisteredException extends InjectorException {
  const NotRegisteredException(super.type, super.message);
}
