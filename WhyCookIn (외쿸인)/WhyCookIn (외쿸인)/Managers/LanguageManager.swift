//
//  LanguageManager.swift
//  Why-Cook_In (외쿸인)
//

import Foundation

enum AppLanguage {
    case english
    case korean
    
    var code: String {
        switch self {
        case .english: return "english"
        case .korean: return "korean"
        }
    }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .korean: return "한국어"
        }
    }
}

class LanguageManager {
    static let shared = LanguageManager()
    
    private let languageKey = "AppLanguage"
    private(set) var currentLanguage: AppLanguage = .english
    
    private(set) var nationalities: [String] = []
    private(set) var ethnicities: [String] = []
    private(set) var countries: [String] = []
    
    private var enDictionary: [String: String] = {
        var dict = [String: String]()
        
        // Authentication & Login
        dict["email_placeholder"] = "Email"
        dict["empty_fields_error"] = "Please fill in all fields."
        dict["error_title"] = "Error"
        dict["forgot_id_password"] = "Forgot your ID/Password?"
        dict["join_us"] = "Join us!"
        dict["login_error_message"] = "Incorrect email or password."
        dict["login_error_title"] = "Login Failed"
        dict["login_title"] = "Log In"
        dict["password_placeholder"] = "Password"
        dict["sign_up_button"] = "Sign Up"
        dict["sign_up_title"] = "Sign Up"
        dict["user_id_placeholder"] = "User ID"
        dict["invalid_credentials"] = "Invalid email or password format."
        
        // Replacing Real Name with First and Last Name
        dict["first_name_placeholder"] = "First Name"
        dict["last_name_placeholder"] = "Last Name"
        
        // Add Post / Community
        dict["add_category_button"] = "Add Category"
        dict["add_post_detail_view"] = "Post Details"
        dict["add_post_title"] = "Add Post"
        dict["category_housing"] = "Housing"
        dict["category_immigration"] = "Immigration"
        dict["category_jobs"] = "Jobs"
        dict["category_label"] = "Category"
        dict["category_general"] = "General"
        dict["category_suggest_new"] = "Suggest a new category"
        dict["category_sim_card"] = "SIM Card"
        dict["category_bank_account"] = "Bank Account"
        dict["comments_placeholder"] = "Comments (coming soon)"
        dict["new_category_placeholder"] = "Suggest a new category"
        dict["post_title_placeholder"] = "Title of the post"
        dict["save_button"] = "Save"
        
        // Profile
        dict["profile_age"] = "Age"
        dict["profile_childhood_country"] = "Childhood Country (Optional)"
        dict["profile_ethnicity"] = "Ethnicity (Optional)"
        dict["profile_home_country"] = "Home Country (Optional)"
        dict["profile_nationality"] = "Nationality"
        dict["profile_photo"] = "Add Photo"
        dict["profile_save"] = "Save"
        dict["profile_sex"] = "Sex"
        dict["choose_option"] = "Choose Option"
        
        // Profile Detail & Actions
        dict["edit_button"] = "Edit"
        dict["swipe_match_button"] = "Swipe & Match"
        dict["direct_messages_button"] = "Messages"
        dict["visibility_toggle"] = "Visible to Others"
        
        // Settings
        dict["account_deleted_message"] = "Your account has been deleted."
        dict["account_deleted_title"] = "Account Deleted"
        dict["change_language_info"] = "To change the language, pick from the list."
        dict["delete_account_button"] = "Delete Account"
        dict["language_button"] = "Change Language"
        dict["language_info_title"] = "Language"
        dict["logout_button"] = "Log Out"
        dict["settings_title"] = "Settings"
        dict["privacy_button"] = "Privacy"
        
        // General UI
        dict["welcome_message"] = "Welcome!"
        
        // Tabs / Sections
        dict["community_title"] = "Community"
        dict["profile_title"] = "Profile"
        
        // Detailed signup errors
        dict["email_requirements"] = "Email must be a valid format (e.g., contains '@' and '.')"
        dict["password_requirements"] = "Password must be at least 8 characters, contain a digit."
        dict["missing_required_fields"] = "Please fill in all required fields."
        dict["picture_required"] = "A profile picture is required."
        
        // AI bot jokes/examples
        dict["ai_joke_1"] = "AI Bot: Did you know that kimchi is basically spicy, fermented happiness?"
        dict["ai_joke_2"] = "AI Bot: If language learning were easy, I'd be a K-pop idol by now!"
        
        
        return dict
    }()
    
    private var koDictionary: [String: String] = {
        var dict = [String: String]()
        
        // Authentication & Login
        dict["email_placeholder"] = "이메일"
        dict["empty_fields_error"] = "빈칸을 모두 채워주세요."
        dict["error_title"] = "오류"
        dict["forgot_id_password"] = "ID/비밀번호를 잊으셨나요?"
        dict["join_us"] = "회원가입 ㄱㄱ"
        dict["login_error_message"] = "이메일 또는 비밀번호가 맞지 않습니다."
        dict["login_error_title"] = "로그인 실패"
        dict["login_title"] = "로그인"
        dict["password_placeholder"] = "비밀번호"
        dict["sign_up_button"] = "회원가입"
        dict["sign_up_title"] = "회원가입"
        dict["user_id_placeholder"] = "아이디"
        dict["invalid_credentials"] = "이메일 또는 비밀번호 형식이 올바르지 않습니다."
        
        // Replacing Real Name with First and Last Name
        dict["first_name_placeholder"] = "이름"
        dict["last_name_placeholder"] = "성"
        
        // Add Post / Community
        dict["add_category_button"] = "범주 추가"
        dict["add_post_detail_view"] = "게시글 상세"
        dict["add_post_title"] = "게시글 올리기"
        dict["category_housing"] = "주거"
        dict["category_immigration"] = "이민"
        dict["category_jobs"] = "일자리"
        dict["category_label"] = "범주"
        dict["category_general"] = "일반"
        dict["category_suggest_new"] = "주원에게 새로운 범주 건의하기"
        dict["category_sim_card"] = "심카드"
        dict["category_bank_account"] = "은행 계좌"
        dict["comments_placeholder"] = "댓글 (준비중)"
        dict["new_category_placeholder"] = "새로운 범주를 제안해주세요"
        dict["post_title_placeholder"] = "게시글 제목"
        dict["save_button"] = "저장"
        
        // Profile
        dict["profile_age"] = "나이"
        dict["profile_childhood_country"] = "어린시절 나라 (선택)"
        dict["profile_ethnicity"] = "민족 (선택)"
        dict["profile_home_country"] = "마음의 고향 (선택)"
        dict["profile_nationality"] = "국적"
        dict["profile_photo"] = "사진 추가"
        dict["profile_save"] = "저장"
        dict["profile_sex"] = "성별"
        dict["choose_option"] = "옵션 선택"
        
        // Profile Detail & Actions
        dict["edit_button"] = "편집"
        dict["swipe_match_button"] = "스와이프 & 매칭"
        dict["direct_messages_button"] = "메시지"
        dict["visibility_toggle"] = "다른 사용자에게 보이기"
        
        // Settings
        dict["account_deleted_message"] = "계정이 삭제되었습니다."
        dict["account_deleted_title"] = "계정 삭제됨"
        dict["change_language_info"] = "언어를 변경하려면 목록에서 선택하세요."
        dict["delete_account_button"] = "계정 삭제하기"
        dict["language_button"] = "언어 변경"
        dict["language_info_title"] = "언어"
        dict["logout_button"] = "로그아웃"
        dict["settings_title"] = "설정"
        dict["privacy_button"] = "개인정보"
        
        // General UI
        dict["welcome_message"] = "환영합니다!"
        
        // Tabs / Sections
        dict["community_title"] = "커뮤니티"
        dict["profile_title"] = "프로필"
        
        // Detailed signup errors
        dict["email_requirements"] = "이메일은 '@'와 '.'을 포함한 유효한 형식이어야 합니다."
        dict["password_requirements"] = "비밀번호는 8자 이상이며 숫자를 포함해야 합니다."
        dict["missing_required_fields"] = "필수 항목을 모두 채워주세요."
        dict["picture_required"] = "프로필 사진이 필요합니다."
        
        // AI bot jokes/examples
        dict["ai_joke_1"] = "AI 봇: 김치는 매콤하고 발효된 행복이란 걸 아시나요?"
        dict["ai_joke_2"] = "AI 봇: 언어 배우기가 쉽다면 지금쯤 K-pop 아이돌이 됐을 겁니다!"
        
        
        return dict
    }()
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: languageKey), saved == "korean" {
            currentLanguage = .korean
        } else {
            currentLanguage = .english
        }
        
        nationalities = loadListFromFile(named: "nationalities")
        ethnicities = loadListFromFile(named: "ethnicities")
        countries = loadListFromFile(named: "list-of-countries")
    }
    
    func setLanguage(_ lang: AppLanguage) {
        currentLanguage = lang
        UserDefaults.standard.set(lang.code, forKey: languageKey)
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    func string(forKey key: String) -> String {
        switch currentLanguage {
        case .english:
            return enDictionary[key] ?? key
        case .korean:
            return koDictionary[key] ?? key
        }
    }
    
    func availableLanguages() -> [AppLanguage] {
        return [.english, .korean]
    }
    
    private func loadListFromFile(named fileName: String) -> [String] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
            return []
        }
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            return lines
        } catch {
            print("Failed to load \(fileName).txt: \(error)")
            return []
        }
    }
}
