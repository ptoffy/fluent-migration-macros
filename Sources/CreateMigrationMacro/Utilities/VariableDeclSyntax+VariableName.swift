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
