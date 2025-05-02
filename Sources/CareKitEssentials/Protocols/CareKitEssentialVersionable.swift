//
//  OCKVersionable.swift
//  CareKitEssentials
//
//  Created by Corey Baker on 5/1/25.
//  Copyright © 2025 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
import Foundation

extension OCKPatient: CareKitEssentialVersionable {}
extension OCKCarePlan: CareKitEssentialVersionable {}
extension OCKContact: CareKitEssentialVersionable {}
extension OCKHealthKitTask: CareKitEssentialVersionable {}
extension OCKTask: CareKitEssentialVersionable {}
extension OCKOutcome: CareKitEssentialVersionable {}

public protocol CareKitEssentialVersionable: Hashable, Identifiable, Sendable {
	var id: String { get set }
	var uuid: UUID { get }
	var previousVersionUUIDs: [UUID] { get }
	var nextVersionUUIDs: [UUID] { get }
	var createdDate: Date? { get }
	var updatedDate: Date? { get }
	var deletedDate: Date? { get }
	var effectiveDate: Date { get set }
	var groupIdentifier: String? { get set }
	var tags: [String]? { get set }
	var remoteID: String? { get set }
	var userInfo: [String: String]? { get set }
	var source: String? { get set }
	var asset: String? { get set }
	var notes: [OCKNote]? { get set }
	var schemaVersion: OCKSemanticVersion? { get }
	var timezone: TimeZone { get set }
}
