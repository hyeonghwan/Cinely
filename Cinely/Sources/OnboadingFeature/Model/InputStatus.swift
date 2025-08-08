//
//  InputStatus.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit

enum InputStatus: String {
    case inValidLength  = "2글자 이상 10글자 미만으로 설정해주세요"
    case invalidSymbol  = "닉네임에 특수문자는 포함할 수 없어요"
    case containNumeric = "닉네임에 숫자는 포함할 수 없어요"
    case valid          = "사용할 수 있는 닉네임 입니다."
    case none           = "편집 버튼을 눌러 닉네임을 입력해 주세요"
    
    var color: UIColor {
        switch self {
        case .inValidLength, .invalidSymbol, .containNumeric:
            return UIColor.systemRed
        case .valid:
            return Color.green
        case .none:
            return Color.white
        }
    }
    var toastState: ToastStatus {
        switch self {
        case .inValidLength, .invalidSymbol, .containNumeric, .none:
            return .warning
        case .valid:
            return .check
        }
    }
    static func validate(_ text: String) -> (String, InputStatus) {
        let notValidLength = 2 > text.count || 10 <= text.count
        if notValidLength {
            return (text, InputStatus.inValidLength)
        }
        let set = Set<Character>(Array("\\|[]{}-!@#$%^&*()_+-=,.:';'\"`~"))
        if text.contains(where: { char in set.contains(char) }) {
            return (text, InputStatus.invalidSymbol)
        }
        
        if text.contains(where: \.isNumber) {
            return (text, InputStatus.containNumeric)
        }
        return (text, InputStatus.valid)
    }
}
