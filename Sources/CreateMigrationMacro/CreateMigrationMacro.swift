import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import FluentKit

public struct CreateMigrationMacro { }

public enum MigrationMacroError: CustomStringConvertible, Error {
    case onlyApplicableToClass
    case onlyApplicableToModel
    case noSchemaProvided
    
    public var description: String {
        switch self {
        case .onlyApplicableToClass:
            "@MigrationMacro can only be applied to classes"
        case .onlyApplicableToModel:
            "@MigrationMacro can only be applied to classes conforming to `FluentKit.Model`"
        case .noSchemaProvided:
            "No schema variable provided in Model. Please add `static let schema = ...`"
        }
    }
}

extension CreateMigrationMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // Check for the declaration being a class
        guard let classDeclaration = declaration.as(ClassDeclSyntax.self) else {
            throw MigrationMacroError.onlyApplicableToClass
        }
                        
        // Check for the class to be a `Model`
        guard classDeclaration.inheritanceClause?.inheritedTypeCollection.contains(where: {
            $0.typeName.description.contains("Model") // Heh `$0.typeName.description` prints `Model `...
        }) == true else {
            throw MigrationMacroError.onlyApplicableToModel
        }
        
        // Retrieve class variables
        let members = classDeclaration.memberBlock.members
        var variables = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }

        // Retrieve schema field
        guard let schema = retrieveSchemaName(from: variables) else {
            throw MigrationMacroError.noSchemaProvided
        }

        // Remove schema from variables array
        guard let schemaIndex = variables.firstIndex(where: { $0.name.contains("schema") }) else {
            throw MigrationMacroError.noSchemaProvided
        }
        variables.remove(at: schemaIndex)
        
        // Create migration code
        let result = try StructDeclSyntax("struct Create: AsyncMigration") {
            try FunctionDeclSyntax("func prepare(on database: Database) async throws") {
                ExprSyntax("try await database.schema(\(raw: schema))")
                for variable in variables {
                    ExprSyntax(
                        """
                        \(raw: makeField(from: variable))
                        """
                    )
                }
                ExprSyntax(".create()")
            }
            try FunctionDeclSyntax("func revert(on database: Database) async throws") {
                ExprSyntax("try await database.schema(\(raw: schema)).delete()")
            }
        }
            
        return [DeclSyntax(result)]
    }
}

/// Returns the schema variable value, which indicates what the model's name is going to be in the database.
private func retrieveSchemaName(from variables: [VariableDeclSyntax]) -> String? {
    let schemaVariable = variables.first(where: { $0.name.contains("schema") })

    return schemaVariable?.value
}

private func makeField(from variable: VariableDeclSyntax) -> String {
    let wrapper = variable.wrapper
    if wrapper == "ID" {
        return ".id()"
    }
    return ".field("\(variable.name)", .\(variable.type.lowercased()))"
}

@main
struct MigrationMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CreateMigrationMacro.self
    ]
}

