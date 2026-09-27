import Foundation

extension AdminItem {
    static let fixtures: [AdminItem] = [
        AdminItem(
            title: "Electricity bill", source: "Northstar Energy", summary: "A balance of £186.40 is due on 14 October. The amount is confirmed from the bill.",
            category: .bills, status: .actionNeeded, priority: .urgent,
            deadline: Calendar.current.date(byAdding: .day, value: 3, to: .now), amount: 186.40, currencyCode: "GBP", suggestedAction: "Review the balance and pay before the due date.",
            evidence: [.init(kind: .confirmed, label: "Provider", value: "Northstar Energy"), .init(kind: .confirmed, label: "Amount due", value: "£186.40"), .init(kind: .confirmed, label: "Account reference", value: "•••• 4821"), .init(kind: .interpretation, label: "Meaning", value: "Payment appears to be required by the due date."), .init(kind: .unclear, label: "Previous balance", value: "Not found")],
            nextSteps: [.init(title: "Review the £186.40 balance"), .init(title: "Pay by the due date if correct"), .init(title: "Contact the provider if you dispute it")],
            timeline: [.init(date: .now.addingTimeInterval(-86400), title: "Document imported", symbol: "square.and.arrow.down"), .init(date: .now.addingTimeInterval(-86000), title: "Analysis completed", symbol: "sparkles")]
        ),
        AdminItem(
            title: "Car insurance renewal", source: "Harbour Mutual", summary: "The annual premium increased from £487 to £612, approximately 25.7%.", category: .insurance, status: .review, priority: .dueSoon,
            deadline: Calendar.current.date(byAdding: .day, value: 12, to: .now), amount: 612, currencyCode: "GBP", suggestedAction: "Review the increase and decide whether to renew.",
            evidence: [.init(kind: .confirmed, label: "New premium", value: "£612"), .init(kind: .confirmed, label: "Previous premium", value: "£487"), .init(kind: .interpretation, label: "Change", value: "+25.7%")],
            nextSteps: [.init(title: "Compare the renewal terms"), .init(title: "Request a revised quote"), .init(title: "Decide before renewal")], timeline: [.init(date: .now.addingTimeInterval(-172800), title: "Renewal imported", symbol: "doc")]
        ),
        AdminItem(
            title: "Energy bill query", source: "Northstar Energy", summary: "You contacted the provider and are waiting for a response.", category: .bills, status: .waiting, priority: .dueSoon,
            deadline: Calendar.current.date(byAdding: .day, value: 5, to: .now), amount: nil, currencyCode: nil, suggestedAction: "Follow up if no response arrives by Friday.",
            evidence: [.init(kind: .confirmed, label: "Contacted", value: "18 September"), .init(kind: .interpretation, label: "Follow-up", value: "Allow seven days for a response")],
            nextSteps: [.init(title: "Wait for the provider response", canRemind: true), .init(title: "Follow up after seven days")], timeline: [.init(date: .now.addingTimeInterval(-604800), title: "Enquiry drafted", symbol: "envelope"), .init(date: .now.addingTimeInterval(-518400), title: "Marked waiting", symbol: "hourglass")]
        ),
        AdminItem(
            title: "Dentist appointment", source: "Willow Dental", summary: "Appointment at 10:30. Arrive ten minutes early.", category: .appointments, status: .scheduled, priority: .upcoming,
            deadline: Calendar.current.date(byAdding: .day, value: 18, to: .now), amount: nil, currencyCode: nil, suggestedAction: "Add preparation notes and confirm travel time.",
            evidence: [.init(kind: .confirmed, label: "Time", value: "10:30"), .init(kind: .confirmed, label: "Location", value: "14 Willow Road")], nextSteps: [.init(title: "Add appointment to calendar"), .init(title: "Plan travel")], timeline: [.init(date: .now, title: "Appointment letter imported", symbol: "calendar")]
        )
    ]
}

