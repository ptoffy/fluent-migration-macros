enum GenericMacroError: CustomStringConvertible, Error {
    case variableHasNoName
    
    var description: String {
        switch self {
        case .variableHasNoName:
            "Selected variable has no name"
        }
    }
}
