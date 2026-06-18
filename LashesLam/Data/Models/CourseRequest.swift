//
//  CourseRequest.swift
//  LashesLam
//
//  Espejo de network/CourseRequest.kt + CreateCourseRequestDto.kt. Solicitud de
//  inscripción a un curso (colección course_requests).
//

import Foundation
import FirebaseFirestore

struct CourseRequest: Identifiable {
    var id: String { requestId }
    var requestId: String = ""
    var userId: String = ""
    var courseId: String = ""
    var courseName: String = ""
    var status: String = ""
    var date: String = ""
    var schedule: String = ""
    var nameUser: String = ""
    var emailUser: String = ""
    var timestamp: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    var price: String = ""
    var location: String = ""
    var apartar: String = ""

    init() {}

    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.requestId = data["requestId"] as? String ?? document.documentID
        self.userId = data["userId"] as? String ?? ""
        self.courseId = data["courseId"] as? String ?? ""
        self.courseName = data["courseName"] as? String ?? ""
        self.status = data["status"] as? String ?? ""
        self.date = data["date"] as? String ?? ""
        self.schedule = data["schedule"] as? String ?? ""
        self.nameUser = data["nameUser"] as? String ?? ""
        self.emailUser = data["emailUser"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? NSNumber)?.int64Value ?? 0
        self.price = data["price"] as? String ?? ""
        self.location = data["location"] as? String ?? ""
        self.apartar = data["apartar"] as? String ?? ""
    }
}
