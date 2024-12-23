//
//  FAQs.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation

struct FAQ {
    let question: String
    let answer: String
}

struct FAQs {
    static func getAllFAQs() -> [FAQ] {
        return [
            FAQ(question: "How can I find a room to rent?", answer: "Check the 'Rooms' section to see available listings."),
            FAQ(question: "How to renew my visa?", answer: "Please check our Immigration info section for guides and required documents."),
            // Add more FAQs as needed
        ]
    }
}
