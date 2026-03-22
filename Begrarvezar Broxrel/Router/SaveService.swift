//
//  SaveService.swift
//  Begrarvezar Broxrel
//
//  Created by Hughesan Drew on 22.03.2026.
//

import Foundation

struct SaveService {
    
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: "LastUrl") }
        set { UserDefaults.standard.set(newValue, forKey: "LastUrl") }
    }
}
