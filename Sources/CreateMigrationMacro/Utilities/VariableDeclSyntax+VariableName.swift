import SwiftSyntax

extension VariableDeclSyntax {
    var name: String {
        var name = self.bindings.first!.pattern.description
        if let i = name.firstIndex(of: " ") {
            name.remove(at: i)
        }
        return name
    }
    
    var value: String {
        self.bindings.first!.initializer!.value.description
    }
}

extension VariableDeclSyntax {
    var wrapper: String {
        self.attributes!.first!
            .as(AttributeSyntax.self)!
            .attributeName.description
    }
}

extension VariableDeclSyntax {
    var type: String {
        self.bindings.first!
            .typeAnnotation!.as(TypeAnnotationSyntax.self)!
            .type.as(OptionalTypeSyntax.self)?
            .wrappedType.as(SimpleTypeIdentifierSyntax.self)?
            .name.description ??
        self.bindings.first!
            .typeAnnotation!.as(TypeAnnotationSyntax.self)!
            .type.as(SimpleTypeIdentifierSyntax.self)!
            .name.description

    }
}
