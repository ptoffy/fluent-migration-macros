import FluentKit
import MigrationMacros

@Migratable
final class SomeModel: Model {
    static let schema = "some_model"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
}
