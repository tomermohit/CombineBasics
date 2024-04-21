//
//  ContentView.swift
//  CombineBasics
//
//  Created by Mohit Tomer on 21/04/24.
//

import SwiftUI
import Combine


@MainActor class SubscribeViewModel: ObservableObject {
    
    @Published var count: Int = 0
    @Published var textFieldText: String = ""
    @Published var isTextVaid: Bool = false
    @Published var showButton: Bool = false
    
    
    // var timer: AnyCancellable?
    var cancellables = Set<AnyCancellable> ()
    
    init() {
        setUpTimer()
        addTextFieldSubscriber()
        addButtonSubscriber()
    }
    
    // MARK: - Timer Setup
    
    func setUpTimer() {
        Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect() // it start the timer
            .sink { [weak self] _ in
                guard let self else {return}
                self.count += 1
                
                // MARK: - don't want to stop timer that's why not cancelling timer at all
                
                //                if self.count >= 10 {
                //                    //self.timer?.cancel() // -- for timer cancellable
                //                    for items in self.cancellable {
                //                        items.cancel()
                //                    }
                //                }
            }
            .store(in: &self.cancellables)
    }
    
    func addTextFieldSubscriber() {
        $textFieldText
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .map { text in
                if text.count > 3 {
                    return true
                }else {
                    return false
                }
            }
        //.assign(to: \.isTextVaid, on: self)  // -- It does capture strong reference so we don't want it.
            .sink(receiveValue: { [weak self] isValid in
                guard let self else {return}
                self.isTextVaid = isValid
            })
            .store(in: &self.cancellables)
    }
    
    func addButtonSubscriber() {
        $isTextVaid
            .combineLatest($count)
            .sink { [weak self] (isValid, count) in
                guard let self else {return}
                if isValid && count >= 10 {
                    self.showButton = true
                }else {
                    self.showButton = false
                }
            }
            .store(in: &self.cancellables)
    }
    
}


struct ContentView: View {
    
    @StateObject private var viewModel = SubscribeViewModel()
    
    var body: some View {
        
        VStack {
            Text("\(viewModel.count)")
                .font(.largeTitle)
            
            //Text(viewModel.isTextVaid.description)
            
            TextField("Type something here...", text: $viewModel.textFieldText)
                .frame(height: 50)
                .padding(.leading)
                .font(.headline)
                .background(Color.gray.opacity(0.3))
                .clipShape(.rect(cornerRadius: 10))
                .overlay (
                    ZStack {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.red)
                            .opacity(
                                viewModel.textFieldText.count < 1 ? 0 :
                                    viewModel.isTextVaid ? 0.0 : 1.0
                            )
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.green)
                            .opacity(viewModel.isTextVaid ? 1.0 : 0.0)
                    }
                        .font(.headline)
                        .padding(.trailing)
                    , alignment: .trailing
                )
            
            Button(action: {}, label: {
                Text("Submit".uppercased())
                    .font(.headline)
                // .frame(height: 55)
                // .frame(maxWidth: .infinity)
                    .frame(maxWidth: .infinity, minHeight: 55)
                    .background(Color.purple)
                    .foregroundStyle(Color.white)
                    .clipShape(.rect(cornerRadius: 10))
                    .opacity(viewModel.showButton ? 1.0 : 0.6)
                
            })
            .disabled(!viewModel.showButton)
            .padding(.top)
        }
        .padding()
        
    }
}

#Preview {
    ContentView()
}
