//
//  DataTypes.swift
//  Y-Tiles
//
//  Copyright 2025 Chris Yunker. All rights reserved.
//
struct Point {
    var x: Int
    var y: Int

    static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

enum Direction: Int, CaseIterable {
    case none = 0
    case left = 1
    case right = 2
    case up = 3
    case down = 4
}

enum PhotoType: Int, CaseIterable, Codable {
    case stockPhoto1
    case stockPhoto2
    case stockPhoto3
    case stockPhoto4
    case customPhoto
    
    var values: (id: Int, name: String) {
        switch self {
        case .stockPhoto1:
            return (0, "stockPhoto1")
        case .stockPhoto2:
            return (1, "stockPhoto2")
        case .stockPhoto3:
            return (2, "stockPhoto3")
        case .stockPhoto4:
            return (3, "stockPhoto4")
        case .customPhoto:
            return (4, "customPhoto")
        }
    }
    
    var id: Int { return values.id }
    var name: String { return values.name }
    
    init?(id: Int) {
        guard let photoType = PhotoType.allCases.first(where: { $0.id == id }) else {
            return nil
        }
        self = photoType
    }
}
