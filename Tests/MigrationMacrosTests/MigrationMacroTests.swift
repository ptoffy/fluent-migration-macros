import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import CreateMigrationMacro

let testMacros: [String: Macro.Type] = [
    "Migratable": CreateMigrationMacro.self
]

final class MigrationMacroTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            @Migratable
            final class SomeModel: Model {
                static let schema = "planets"
                
                @ID(key: .id)
                var id: UUID?
            
                @Field(key: "name")
                var name: String
            }
            """,
            expandedSource: """

            final class SomeModel: Model {
                static let schema = "planets"
                
                @ID(key: .id)
                var id: UUID?
            }
            """,
            macros: testMacros
        )
    }
    func testMacroOnNonClass() {
        assertMacroExpansion(
            """
            @Migratable
            struct SomeModel {
            }
            """,
            expandedSource: """

            struct SomeModel {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MigrationMacroError.onlyApplicableToClass.description, line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
    
    func testMacroOnNonModelClass() {
        assertMacroExpansion(
            """
            @Migratable
            final class SomeModel {
            }
            """,
            expandedSource: """

            final class SomeModel {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: MigrationMacroError.onlyApplicableToModel.description, line: 1, column: 1)
            ],
            macros: testMacros
        )
    }
}
