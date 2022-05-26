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
    var textViewBeginEditing:((UITextView)->())?
    var textViewEndEditing:((UITextView)->())?
    
    
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
        
        let btnDone = UIButton()
        btnDone.setTitle("Done", for: .normal)
        btnDone.setTitleColor(.systemBlue, for: .normal)
        btnDone.frame = CGRect(x: 0, y: 0, width: 128, height: 44)
        btnDone.addTarget(context.coordinator, action: #selector(Coordinator.doneClicked(_:)), for: .touchDown)
        
        let accessoryView = UIView()
        accessoryView.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        accessoryView.backgroundColor = .systemBackground
        accessoryView.addSubview(btnDone)
        textField.inputAccessoryView = accessoryView
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        context.coordinator.textViewBeginEditing = textViewBeginEditing
        context.coordinator.textViewEndEditing = textViewEndEditing
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
        var textViewBeginEditing:((UITextView)->())?
        var textViewEndEditing:((UITextView)->())?
        
        init(text: Binding<String>,
             minHeight:CGFloat,
             height: Binding<CGFloat>,
             onDone: ((String?) -> Void)? = nil,
             textViewBeginEditing: ((UITextView)->())? = nil,
             textViewEndEditing:((UITextView)->())? = nil
             
        ) {
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
        
        @objc func doneClicked(_ textFiled:UITextView){
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textViewBeginEditing?(textView)
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            textViewEndEditing?(textView)
        }
    }
}

struct MultilineTextField: View {
    
    private var placeholder  : String
    private var onDone       : ((String?) -> Void)?
    var backgroundColor      : UIColor         = .white
    var textColor            : UIColor         = .white
    var cornerRadius         : CGFloat         = 8
    var keyboardReturnType   : UIReturnKeyType = .done
    var textViewBeginEditing : ((UITextView)->())?
    var textViewEndEditing   : ((UITextView)->())?
    
    @State
    var isInEditing          = false
    
    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }
    
    @State private var dynamicHeight: CGFloat = 42
    @State private var showingPlaceholder = false
    
    init (
        _ placeholder        : String                 = "",
        text                 : Binding<String>,
        textColor            : UIColor                = .white,
        backgroundColor      : UIColor                = .white,
        cornerRadius         : CGFloat                = 8,
        keyboardReturnType   : UIReturnKeyType        = .done,
        onDone               : ((String?) -> Void)?   = nil,
        textViewBeginEditing : ((UITextView)->())?    = nil,
        textViewEndEditing   : ((UITextView)->())?    = nil
    ) {
        self.placeholder               = placeholder
        self.onDone                    = onDone
        self.textViewBeginEditing      = textViewBeginEditing
        self.textViewEndEditing        = textViewEndEditing
        self.textColor                 = textColor
        self.cornerRadius              = cornerRadius
        self._text                     = text
        self.backgroundColor           = backgroundColor
        self.keyboardReturnType        = keyboardReturnType
        self._showingPlaceholder       = State<Bool>(initialValue : self.text.isEmpty)
    }
    
    var body: some View {
        UITextViewWrapper(
            text                 : self.internalText,
            textColor            : textColor.cgColor,
            backgroundColor      : backgroundColor,
            calculatedHeight     : $dynamicHeight,
            minHeight            : dynamicHeight,
            keyboardReturnType   : keyboardReturnType,
            onDone               : onDone,
            textViewBeginEditing : { textView in
                withAnimation {
                    isInEditing = true
                }
                textViewBeginEditing?(textView)
            },
            textViewEndEditing   : { textView in
                withAnimation {
                    isInEditing = false
                }
                textViewEndEditing?(textView)
            }
        )
        .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius).stroke(isInEditing ? .accentColor : Color.primary.opacity(0.5))
        )
        .overlay(
            HStack{
                placeholderView
                Spacer()
            }
        )
    }
    
    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder).foregroundColor(.gray)
                    .padding(.leading, 8)
                    .disabled(true)
                    .allowsHitTesting(false)
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
