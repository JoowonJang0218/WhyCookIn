//
//  LanguageManager.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
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
    
    // MARK: - Loaded Lists from Files
    private(set) var nationalities: [String] = []
    private(set) var ethnicities: [String] = []
    
    // MARK: - English Dictionary
    // Organized by feature/category, then alphabetically by key:
    private let enDictionary: [String: String] = {
        var dict = [String: String]()
        
        // --- Authentication & Login ---
        dict["email_placeholder"] = "Email"
        dict["empty_fields_error"] = "Please fill in all fields."
        dict["error_title"] = "Error"
        dict["forgot_id_password"] = "Forgot your ID/Password?"
        dict["join_us"] = "Join us!"
        dict["login_error_message"] = "Incorrect email or password."
        dict["login_error_title"] = "Login Failed"
        dict["login_title"] = "Log In"
        dict["password_placeholder"] = "Password"
        dict["real_name_placeholder"] = "Real Name"
        dict["sign_up_button"] = "Sign Up"
        dict["sign_up_title"] = "Sign Up"
        dict["user_id_placeholder"] = "User ID"
        
        // --- Add Post / Community ---
        dict["add_category_button"] = "Add Category"
        dict["add_post_detail_view"] = "Post Details"
        dict["add_post_title"] = "Add Post"
        dict["category_housing"] = "Housing"
        dict["category_immigration"] = "Immigration"
        dict["category_jobs"] = "Jobs"
        dict["category_label"] = "Category"
        dict["category_general"] = "General"
        dict["category_suggest_new"] = "Suggest a new category"
        dict["comments_placeholder"] = "Comments (coming soon)"
        dict["new_category_placeholder"] = "Suggest a new category"
        dict["post_title_placeholder"] = "Title of the post"
        dict["save_button"] = "Save"
        
        // --- Profile ---
        dict["profile_age"] = "Age"
        dict["profile_childhood_country"] = "Childhood Country (Optional)"
        dict["profile_ethnicity"] = "Ethnicity (Optional)"
        dict["profile_home_country"] = "Home Country (Optional)"
        dict["profile_nationality"] = "Nationality"
        dict["profile_photo"] = "Add Photo"
        dict["profile_save"] = "Save"
        dict["profile_sex"] = "Sex"
        dict["choose_option"] = "Choose Option";
        
        // --- Settings ---
        dict["account_deleted_message"] = "Your account has been deleted."
        dict["account_deleted_title"] = "Account Deleted"
        dict["change_language_info"] = "To change the language, pick from the list."
        dict["delete_account_button"] = "Delete Account"
        dict["language_button"] = "Change Language"
        dict["language_info_title"] = "Language"
        dict["logout_button"] = "Log Out"
        dict["settings_title"] = "Settings"
        
        // --- General UI ---
        dict["welcome_message"] = "Welcome!"
        dict["email_placeholder"] = "Email"
        
        // --- Tabs / Sections ---
        dict["community_title"] = "Community"
        dict["profile_title"] = "Profile"
        
        return dict
    }()
    
    // MARK: - Korean Dictionary
    private let koDictionary: [String: String] = {
        var dict = [String: String]()
        
        // --- Authentication & Login ---
        dict["email_placeholder"] = "이메일"
        dict["empty_fields_error"] = "빈칸을 모두 채워주세요."
        dict["error_title"] = "오류"
        dict["forgot_id_password"] = "ID/비밀번호를 잊으셨나요?"
        dict["join_us"] = "회원가입 ㄱㄱ"
        dict["login_error_message"] = "이메일 또는 비밀번호가 맞지 않습니다."
        dict["login_error_title"] = "로그인 실패"
        dict["login_title"] = "로그인"
        dict["password_placeholder"] = "비밀번호"
        dict["real_name_placeholder"] = "실명"
        dict["sign_up_button"] = "회원가입"
        dict["sign_up_title"] = "회원가입"
        dict["user_id_placeholder"] = "아이디"
        
        
        // --- Add Post / Community ---
        dict["add_category_button"] = "범주 추가"
        dict["add_post_detail_view"] = "게시글 상세"
        dict["add_post_title"] = "게시글 올리기"
        dict["category_housing"] = "주거"
        dict["category_immigration"] = "이민"
        dict["category_jobs"] = "일자리"
        dict["category_label"] = "범주"
        dict["category_general"] = "일반"
        dict["category_suggest_new"] = "주원에게 새로운 범주 건의하기"
        dict["comments_placeholder"] = "댓글 (준비중)"
        dict["new_category_placeholder"] = "새로운 범주를 제안해주세요"
        dict["post_title_placeholder"] = "게시글 제목"
        dict["save_button"] = "저장"
        
        // --- Profile ---
        dict["profile_age"] = "나이"
        dict["profile_childhood_country"] = "어린시절 나라 (선택)"
        dict["profile_ethnicity"] = "민족 (선택)"
        dict["profile_home_country"] = "마음의 고향 (선택)"
        dict["profile_nationality"] = "국적"
        dict["profile_photo"] = "사진 추가"
        dict["profile_save"] = "저장"
        dict["profile_sex"] = "성별"
        dict["choose_option"] = "옵션 선택";

        
        // --- Settings ---
        dict["account_deleted_message"] = "계정이 삭제되었습니다."
        dict["account_deleted_title"] = "계정 삭제됨"
        dict["change_language_info"] = "언어를 변경하려면 목록에서 선택하세요."
        dict["delete_account_button"] = "계정 삭제하기"
        dict["language_button"] = "언어 변경"
        dict["language_info_title"] = "언어"
        dict["logout_button"] = "로그아웃"
        dict["settings_title"] = "설정"
        
        // --- General UI ---
        dict["welcome_message"] = "환영합니다!"
        dict["email_placeholder"] = "이메일"
        
        // --- Tabs / Sections ---
        dict["community_title"] = "커뮤니티"
        dict["profile_title"] = "프로필"
        
        return dict
    }()
    
    private init() {
        // Load saved language
        if let saved = UserDefaults.standard.string(forKey: languageKey), saved == "korean" {
            currentLanguage = .korean
        } else {
            currentLanguage = .english
        }
        
        // Load lists from files
        nationalities = loadListFromFile(named: "nationalities")
        ethnicities = loadListFromFile(named: "ethnicities")
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
    
    // MARK: - Loading Lists from Files
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
