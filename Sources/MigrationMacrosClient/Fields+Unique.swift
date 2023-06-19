import FluentKit

//public protocol Uniqueable { }
//extension FieldProperty: Uniqueable { }
//extension IDProperty: Uniqueable { }

extension Fields {
    public typealias Unique<Value> = UniqueProperty<Self, Value> where Value: Property
}

@propertyWrapper
public final class UniqueProperty<Model, Value> where Model: Fields, Value: AnyProperty {
    public var projectedValue: UniqueProperty<Model, Value> { self }
    private(set) var value: Value

    public var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }

    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}
