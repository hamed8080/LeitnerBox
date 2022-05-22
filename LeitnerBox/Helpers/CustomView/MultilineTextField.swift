//
//  MultilineTextField.swift
//  LeitnerBox
//
//  Created by hamed on 5/20/22.
//

import SwiftUI

fileprivate struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    var textColor: CGColor
    var backgroundColor:UIColor
    @Binding var calculatedHeight: CGFloat
    var minHeight:CGFloat
    var keyboardReturnType:UIReturnKeyType = .done
    var onDone: ((String?) -> Void)?
    

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = backgroundColor
        textField.textColor = UIColor(cgColor: textColor)
        textField.returnKeyType = keyboardReturnType
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight, minHeight: minHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>, minHeight:CGFloat) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = max(minHeight, newSize.height)  // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, minHeight: minHeight, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var minHeight:CGFloat
        var onDone: ((String?) -> Void)?

        init(text: Binding<String>, minHeight:CGFloat, height: Binding<CGFloat>, onDone: ((String?) -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
            self.minHeight = minHeight
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight, minHeight: minHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone(textView.text)
                return false
            }
            return true
        }
    }

}

struct MultilineTextField: View {

    private var placeholder: String
    private var onDone: ((String?) -> Void)?
    var backgroundColor:UIColor  = .white
    var textColor:UIColor = .white
    var cornerRadius:CGFloat = 8
    var keyboardReturnType:UIReturnKeyType = .done
    
    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 42
    @State private var showingPlaceholder = false

    init (_ placeholder: String = "",
          text: Binding<String>,
          textColor:UIColor = .white,
          backgroundColor:UIColor = .white,
          cornerRadius:CGFloat = 8,
          keyboardReturnType:UIReturnKeyType = .done,
          onDone: ((String?) -> Void)? = nil ) {
        self.placeholder = placeholder
        self.onDone = onDone
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self._text = text
        self.backgroundColor = backgroundColor
        self.keyboardReturnType = keyboardReturnType
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText,
                          textColor: textColor.cgColor,
                          backgroundColor: backgroundColor,
                          calculatedHeight: $dynamicHeight,
                          minHeight: dynamicHeight,
                          keyboardReturnType: keyboardReturnType,
                          onDone:onDone)
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.primary.opacity(0.5))
            )
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder).foregroundColor(.gray)
                    .padding(.leading, 8)
                    .padding(.top, 8)
            }
        }
    }
}

#if DEBUG
struct MultilineTextField_Previews: PreviewProvider {
    static var test:String = ""//some very very very long description string to be initially wider than screen"
    static var testBinding = Binding<String>(get: { test }, set: {
        test = $0 } )

    static var previews: some View {
        VStack(alignment: .leading) {
            Text("Description:")
            MultilineTextField(
                "Enter some text here",
                text: testBinding,
                textColor: UIColor(named: "textColor")!,
                backgroundColor: UIColor(.primary.opacity(0.1)),
                keyboardReturnType: .search,
                onDone: { value in
                    print("Final text: \(test)")
                }
            )
            Text("Something static here...")
            Spacer()
        }
        .preferredColorScheme(.light)
        .padding()
    }
}
#endif
