import SwiftUI
import SwiftData

@Model
class Memo: Identifiable {
    var id: UUID
    var content: String
    var date: Date
    var colorHex: String
    
    var dateString: String {
        get {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
    }
    
    
    init(id: UUID = UUID(), content: String, date: Date, colorHex: String) {
        self.id = id
        self.content = content
        self.date = date
        self.colorHex = colorHex
    }
    
    // Color 값을 가져오기 위한 계산 속성
    var color: Color {
        Color(hex: colorHex)
    }
}

// Color 확장을 추가하여 16진수 문자열에서 Color 인스턴스를 생성하는 이니셜라이저 추가
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}



struct ContentView: View {
    @Query var memos: [Memo]
    @Environment(\.modelContext) var modelContext
    
    @State private var showAddModal = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 30) {
                    ForEach(memos) { memo in
                        VStack(alignment: .leading, spacing: 30) {
                            Text(memo.content)
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Text("\(memo.dateString)")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(hex: memo.colorHex))
                        
                        Divider()
                    }
                }
            }
            .padding(20)
            .navigationTitle("Memo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("추가") {
                        showAddModal = true
                    }
                    .font(.headline)
                }
            }
            .sheet(isPresented: $showAddModal) {
                AddMemoModalView(showAddModal: $showAddModal)
            }
        }
    }
}

struct AddMemoModalView: View {
    
    @Environment(\.modelContext) var modelContext
    @Binding var showAddModal: Bool
    @State private var addContent: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("메모하기")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                TextEditor(text: $addContent)
                    .padding()
                    .cornerRadius(10)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: 400, alignment: .topLeading)
                    .navigationViewStyle(StackNavigationViewStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .cornerRadius(10)
                
                
                HStack(spacing: 20) {
                    Button(action: {
                        addMemo()
                        showAddModal = false
                    }) {
                        Text("저장")
                            .padding([.top,.bottom], 5)
                            .padding([.trailing,.leading], 10)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showAddModal = false
                    }) {
                        Text("취소")
                            .padding([.top,.bottom], 5)
                            .padding([.trailing,.leading], 10)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
        }
    }
    func addMemo() {
           let newMemo = Memo(content: addContent, date: Date(), colorHex: randomColor())
           modelContext.insert(newMemo)
       }
       
       func randomColor() -> String {
           let letters = "0123456789ABCDEF"
           var color = "#"
           for _ in 0..<6 {
               color.append(letters.randomElement()!)
           }
           return color
       }
}

#Preview {
    ContentView()
        .modelContainer(for: Memo.self)
}
