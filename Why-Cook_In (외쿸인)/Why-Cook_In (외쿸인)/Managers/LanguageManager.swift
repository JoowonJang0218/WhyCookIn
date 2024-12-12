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
}

class LanguageManager {
    static let shared = LanguageManager()
    
    private let languageKey = "AppLanguage"
    private(set) var currentLanguage: AppLanguage = .english
    
    // In-memory dictionaries:
    private let enDictionary: [String: String] = [
        "login_title": "Log In",
        "welcome_message": "Welcome!",
        "email_placeholder": "Email",
        "password_placeholder": "Password",
        "sign_up_button": "Sign Up",
        "community_title": "Community",
        "profile_title": "Profile",
        "settings_title": "Settings",
        "sign_up_title": "Sign Up",
        "name_placeholder": "Name",
        "language_button": "Change Language",
        "error_title": "Error",
        "empty_fields_error": "Please fill in all fields.",
        "login_error_title": "Login Failed",
        "login_error_message": "Incorrect email or password.",
        "forgot_id_password": "Forgot your ID/Password?",
        "join_us": "Join us!",
        "logout_button": "Log Out",
        "delete_account_button": "Delete Account",
        "account_deleted_title": "Account Deleted",
        "account_deleted_message": "Your account has been deleted.",
        "post_title_placeholder": "Title of the post",
        "add_category_button": "Add Category",
        "new_category_placeholder": "Suggest a new category",
        "save_button": "Save",
        "add_post_title": "Add Post",
        "category_label": "Category",
        "language_info_title": "Language",
        "forgot_idpw_instructions": "Please enter your email to recover your account.",
        "submit_button": "Submit",
        "add_post_detail_view": "Post Details",
        "profile_nationality": "Nationality",
        "profile_age": "Age",
        "profile_sex": "Sex",
        "profile_ethnicity": "Ethnicity (Optional)",
        "profile_home_country": "Home Country (Optional)",
        "profile_childhood_country": "Childhood Country (Optional)",
        "profile_save": "Save",
        "profile_photo": "Add Photo",
        "comments_placeholder": "Comments (coming soon)"
    ]
    
    private let koDictionary: [String: String] = [
        "login_title": "로그인",
        "welcome_message": "환영합니다!",
        "email_placeholder": "이메일",
        "password_placeholder": "비밀번호",
        "sign_up_button": "회원가입",
        "community_title": "커뮤니티",
        "profile_title": "프로필",
        "settings_title": "설정",
        "sign_up_title": "회원가입",
        "name_placeholder": "이름",
        "language_button": "언어 변경",
        "error_title": "오류",
        "empty_fields_error": "빈칸을 모두 채워주세요.",
        "login_error_title": "로그인 실패",
        "login_error_message": "이메일 또는 비밀번호가 맞지 않습니다.",
        "forgot_id_password": "ID/비밀번호를 잊으셨나요?",
        "join_us": "회원가입",
        "logout_button": "로그아웃",
        "delete_account_button": "계정 삭제하기",
        "account_deleted_title": "계정 삭제됨",
        "account_deleted_message": "계정이 삭제되었습니다.",
        "post_title_placeholder": "게시글 제목",
        "add_category_button": "범주 추가",
        "new_category_placeholder": "새로운 범주를 제안해주세요",
        "save_button": "저장",
        "add_post_title": "게시글 올리기",
        "category_label": "범주",
        "language_info_title": "언어",
        "forgot_idpw_instructions": "계정 복구를 위해 이메일을 입력해주세요.",
        "submit_button": "제출",
        "add_post_detail_view": "게시글 상세",
        "profile_nationality": "국적",
        "profile_age": "나이",
        "profile_sex": "성별",
        "profile_ethnicity": "민족 (선택)",
        "profile_home_country": "마음의 고향 (선택)",
        "profile_childhood_country": "어린시절 나라 (선택)",
        "profile_save": "저장",
        "profile_photo": "사진 추가",
        "comments_placeholder": "댓글 (준비중)"
    ]
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: languageKey) {
            currentLanguage = (saved == "korean") ? .korean : .english
        }
    }
    
    func setLanguage(_ lang: AppLanguage) {
        currentLanguage = lang
        let val = (lang == .korean) ? "korean" : "english"
        UserDefaults.standard.set(val, forKey: languageKey)
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
}
