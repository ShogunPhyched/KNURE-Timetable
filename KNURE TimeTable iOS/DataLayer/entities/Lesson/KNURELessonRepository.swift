//
//  KNURELessonRepository.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import CoreData

class KNURELessonRepository: LessonRepository {

	private let coreDataService: CoreDataService
	private let importService: ImportService

	init(coreDataService: CoreDataService,
		 importService: ImportService) {
		self.coreDataService = coreDataService
		self.importService = importService
    }

//	func localTimetable(identifier: String) -> Observable<[Lesson]> {
//		let request = NSFetchRequest<LessonManaged>(entityName: "LessonManaged")
//		request.predicate = NSPredicate(format: "itemIdentifier = %@", identifier)
//		return reactiveCoreDataService.observe(request).map {
//			$0.map { $0.newValue }
//		}
//	}

//	func localLesson(identifier: String) -> Promise<Lesson> {
//		let request = NSFetchRequest<LessonManaged>(entityName: "LessonManaged")
//		request.predicate = NSPredicate(format: "subjectIdentifier = %@", identifier)
//		return coreDataService.fetch(request).firstValue.map { $0.domainValue }
//	}
//
//	func localExport(identifier: String, range: Void) -> Promise<Void> {
//		// TODO: implement
//		return Promise()
//	}
//
//    func remoteLoadTimetable(identifier: String) {
//		do {
//			let path = Bundle.main.path(forResource: "timetable", ofType: "json")
//			let data = NSData(contentsOfFile: path!)! as Data
//			try self.importService.decode(data, info: ["identifier": identifier])
//		} catch {
//			print(error)
//		}
//    }
}
