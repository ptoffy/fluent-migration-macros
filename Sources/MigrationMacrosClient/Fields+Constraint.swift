import FluentKit

public protocol ConstrainableProperty: FluentKit.Property {
    associatedtype ConstrainedValueType: Codable
    
    var wrappedValue: ConstrainedValueType { get set }
    
    var projectedValue: Self { get }
}

extension Fields {
    public typealias Constrained<Value> = ConstrainedProperty<Self, Value> where Value: ConstrainableProperty
}

@propertyWrapper
public struct ConstrainedProperty<Model, Value> where Model: FluentKit.Fields, Value: ConstrainableProperty {
    public typealias TargetKeyPath = ReferenceWritableKeyPath<Model, Value>
    public typealias SelfKeyPath = ReferenceWritableKeyPath<Model, ConstrainedProperty>
    
    public static subscript<T>(
        _enclosingInstance owner: Model,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Model, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<Model, ConstrainedProperty>
    ) -> Value.ConstrainedValueType {
        get {
            owner[keyPath: storageKeyPath].wrappedValue
        }
        set {
            owner[keyPath: storageKeyPath].wrappedValue = newValue
        }
    }
    
    @available(*, unavailable, message: "Can only be applied to classes")
    public var wrappedValue: Value.Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    @available(*, unavailable, message: "Can only be applied to classes")
    public var projectedValue: Value {
        fatalError()
    }
    
    private let constraints: [DatabaseSchema.FieldConstraint]
    
    public init(_ constraints: DatabaseSchema.FieldConstraint...) {
        self.constraints = constraints
    }
}

extension FluentKit.IDProperty: ConstrainableProperty {}
extension FluentKit.CompositeIDProperty: ConstrainableProperty {}

extension FluentKit.FieldProperty: ConstrainableProperty {}
extension FluentKit.OptionalFieldProperty: ConstrainableProperty {}

extension FluentKit.BooleanProperty: ConstrainableProperty {}
extension FluentKit.OptionalBooleanProperty: ConstrainableProperty {}

extension FluentKit.EnumProperty: ConstrainableProperty {}
extension FluentKit.OptionalEnumProperty: ConstrainableProperty {}

extension FluentKit.TimestampProperty: ConstrainableProperty {}

extension FluentKit.ParentProperty: ConstrainableProperty {}
extension FluentKit.OptionalParentProperty: ConstrainableProperty {}

extension FluentKit.ChildrenProperty: ConstrainableProperty {}
extension FluentKit.OptionalChildProperty: ConstrainableProperty {}

extension FluentKit.SiblingsProperty: ConstrainableProperty {}

extension FluentKit.GroupProperty: ConstrainableProperty {}
