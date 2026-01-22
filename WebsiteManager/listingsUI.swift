//
//  listingsUI.swift
//  ScentsOfHope
//
//  Created by Andrew Ogren on 1/4/26.
//

import SwiftUI
import FirebaseFirestore
import PhotosUI

struct listingsUI: View {
    @StateObject private var viewModel = ListingsViewModel()
    @State private var showingSaveSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteSheet = false
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 20) {
                    DashboardItem(title: "Add New Candle",
                                   description: "Just Enter the Candle details and it will get added to the Listings.",
                                   icon: "plus.circle.fill",
                                   color: .green
                    ) { showingSaveSheet = true }
                    
                    DashboardItem(title: "Edit Existing Candle",
                                   description: "Enter in the Name of the Candle you want to change and change the things you want.",
                                   icon: "square.and.pencil",
                                   color: .yellow
                    ) { showingEditSheet = true }
                    
                    DashboardItem(title: "Delete a Candle",
                                  description: "Enter in the Name of the Candle you want to delete.",
                                  icon: "trash",
                                  color: .red
                    ) { showingDeleteSheet = true }
                    
                    if !viewModel.statusMessage.isEmpty {
                        Text(viewModel.statusMessage)
                            .padding().foregroundColor(.gray)
                    }
                }
                .navigationTitle("Edit Candle Listings ✏️")
                
                .sheet(isPresented: $showingSaveSheet) {
                    AddListingView(viewModel: viewModel)
                }
                .sheet(isPresented: $showingEditSheet) {
                    EditListingView(viewModel: viewModel)
                }
                .sheet(isPresented: $showingDeleteSheet) {
                    DeleteListingView(viewModel: viewModel)
                }
            }
        }
    }
}

struct AddListingView: View {
    @ObservedObject var viewModel: ListingsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedImage: PhotosPickerItem? = nil
    var body: some View {
        NavigationView {
            VStack{
                Form {
                    TextField("Name", text: $viewModel.name)
                    TextField("Price", text: $viewModel.priceString)
                        .keyboardType(.decimalPad)
                    TextField("Description", text:$viewModel.desc)
                    TextField("Collection", text:$viewModel.collection)
                    Toggle("Is the Candle on sale?", isOn:$viewModel.sale)
                    Section("Candle Image") {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            HStack{
                                Label("Select Photo", systemImage:"photo.on.rectangle")
                                Spacer()
                                if let uiImage = viewModel.selectedImage{
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Save New Listing")
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                }
                
                Spacer()
                
                WMButton(title: "Save New Candle", icon:"plus.circle", color: .green){
                    viewModel.saveListing()
                    dismiss()
                }
            }
            .onChange(of: selectedImage) { oldValue, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            viewModel.selectedImage = uiImage
                        }
                    }
                }
            }
        }
    }
}

struct EditListingView: View {
    @ObservedObject var viewModel: ListingsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedImage: PhotosPickerItem? = nil
    var body: some View {
        NavigationView {
            VStack{
                Form {
                    Section(header: Text("Identify by Name")) {
                        TextField("Current Candle Name", text: $viewModel.name)
                    }
                    Section(header: Text("Fields to Update (Leave blank to keep old)")) {
                        TextField("New Price", text: $viewModel.priceString).keyboardType(.decimalPad)
                        TextField("New Description", text: $viewModel.desc)
                        TextField("New Collection", text: $viewModel.collection)
                        Toggle("Is it still on Sale?", isOn: $viewModel.sale)
                    }
                    Section("Candle Image") {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            HStack{
                                Label("Select Photo", systemImage:"photo.on.rectangle")
                                Spacer()
                                if let uiImage = viewModel.selectedImage{
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                            }
                        }
                    }
                    
                    
                }
                .navigationTitle("Edit Listing")
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                }
                
                Spacer()
                
                WMButton(title: "Edit Candle", icon:"square.and.pencil", color: .yellow){
                    viewModel.saveListing()
                    dismiss()
                }
            }
            .onChange(of: selectedImage) { oldValue, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            viewModel.selectedImage = uiImage
                        }
                    }
                }
            }
        }
    }
}

struct DeleteListingView: View {
    @ObservedObject var viewModel: ListingsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack { 
                Form {
                    TextField("Name of Candle to Delete", text: $viewModel.name)
                }
                .frame(height: 150)
                
                Spacer()
                
                WMButton(title: "Delete Candle", icon: "trash", color: .red, role: .destructive) {
                    viewModel.deleteListing()
                    dismiss()
                }
            }
            .navigationTitle("Delete Listing")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
            }
        }
    }
}
//#Preview {
//    listingsUI()
//}
