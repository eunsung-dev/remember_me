//
//  ContentView.swift
//  remember_me
//
//  Created by 최은성 on 2022/04/13.
//

import SwiftUI
import CoreData
import AVFoundation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.word, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var wordTextfield = ""
    @State var meaningTextfield = ""
    @State var showingAlert = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack {
                    TextField("단어를 입력하세요", text: $wordTextfield)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color(UIColor.secondarySystemBackground).cornerRadius(10))
                        .padding(.horizontal, 10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    TextField("의미를 입력하세요", text: $meaningTextfield)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color(UIColor.secondarySystemBackground).cornerRadius(10))
                        .padding(.horizontal, 10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                List {
                    ForEach(items) { item in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("\(item.word!)")
                                    .font(Font.custom("BMDoHyeon-OTF", size: 30))
                                    .padding()
//KoreanSDNR-B, KoreanSDNR-M
                                Text("\(item.meaning!)")
                                    .font(Font.custom("BMDoHyeon-OTF", size: 20))
                                    .padding()
                            }
                            Spacer()
                            ZStack {
                                Button(action: {
                                    // 단어 발음
                                    let synthesizer = AVSpeechSynthesizer()
                                    let utterance = AVSpeechUtterance(string: item.word!)
                                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                                    utterance.rate = 0.4
                                    synthesizer.speak(utterance)
                                }){
                                    Image(systemName: "speaker.wave.2.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding()
                                }
                                // 이미지만 눌렀을 때 반응하게
                                    .buttonStyle(PlainButtonStyle())
                                
                            }
                        }
                        .frame(height: 120)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(PlainListStyle())
                .background(Color("Color3"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                            .foregroundColor(.black)
                            .font(Font.headline.weight(.heavy))
                    }
                    ToolbarItem {
                        Button(action: {
                            if wordTextfield == "" || meaningTextfield == "" {
                                showingAlert = true
                            } else {
                                addItem()
                                hideKeyboard()
                            }
                        }, label: {
                            Text("Add")
                                .foregroundColor(.black)
                                .font(Font.headline.weight(.heavy))
                        })
                            .alert("모든 항목을 입력하세요", isPresented: $showingAlert) {
                                Button("확인") {}
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("단어장")
            .background(Color("Color1"))
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.word = wordTextfield
            newItem.meaning = meaningTextfield
            
            // 추가하고나서 textfield 초기화
            wordTextfield = ""
            meaningTextfield = ""

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
