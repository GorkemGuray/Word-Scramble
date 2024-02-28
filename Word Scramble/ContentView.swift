//
//  ContentView.swift
//  Word Scramble
//
//  Created by Görkem Güray on 20.02.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    
    var body: some View {
        
        NavigationStack{
            List {
                Section{
                    TextField("Enter your word", text:$newWord)
                        .textInputAutocapitalization(.never)
                }//Section 1
                
                Section{
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }//HStack
                        
                    }//ForEach Closure
                }//Section 2
                
            }//List
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle,isPresented: $showingError) {} message: {
                Text(errorMessage)
            }
            
        }//NavigationStack

    }//body
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        // büyük/küçük harf farkı olan yinelenen sözcükler eklemedğinizden emin olmak için sözcüğü küçük harfle yazın ve trim yapın
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        // kalan string boşsa çık
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }//func addNewWord
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        // 1. Uygulama paketimizde start.txt için URL'i bul
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            // 2. start.txt dosyasını bir string'e yükleyin
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                // 3. string'i satır sonuna göre bir string array'e böl
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                // 4. Rastgele bir kelime seçin veya mantıklı bir varsayılan olarak "silkworm" kullanın
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit
                // Eğer buradaysak her şey yolunda gitmiştir, bu yüzden çıkabiliriz.
                return
            }// if let - 2
        }// if let - 1
        
        // If were are *here* then there was a problem – trigger a crash and report the error
        // Eğer *buradaysak* bir sorun var demektir, bir çökme tetikleyip hatayı bildirelim
        fatalError("Could not load start.txt from bundle")
    }//func startGame
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }// func isOriginal
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }// func isPossible
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
        
    }// func isReal
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }// func wordError
    
    
    
    
    
}//ContentView

#Preview {
    ContentView()
}
