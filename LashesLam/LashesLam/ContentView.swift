//
//  ContentView.swift
//  LashesLam
//
//  Created by Alejandro Mejia v on 15/10/25.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        SplashScreen()
    }
    
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
