# fluent-migration-macros
This package provides a `@Migratable` macro which removes the need to manually write migrations when using Vapor's [Fluent-Kit](https://github.com/vapor/fluent-kit).

> ⚠️ This library is just a proof of concept, do not use it in production yet!

## Usage
You can just simply add `@Migratable` to your model and the migrations are going to be created automagically.

```swift
@Migratable
final class SomeModel: Model {
    static let schema = "some_model"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
}
```

This is going to create

```swift
struct Create: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("some_model")
        .id()
        .field("name", .string)
        .create()
    }
    func revert(on database: Database) async throws {
        try await database.schema("some_model").delete()
    }
}
```
