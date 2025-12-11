abstract class DataProducer<T> {
  void push(T data);
}

abstract class DataConsumer<T> {
  void listen(void Function(T) onChange);
}

abstract class DataBinder<T1, T2>
    implements DataProducer<T1>, DataConsumer<T2> {
  late void Function(T2 p1) onChange;

  T2 map(T1 data);

  @override
  void listen(void Function(T2 p1) onChange) => this.onChange = onChange;

  @override
  void push(T1 data) => onChange(map(data));
}
