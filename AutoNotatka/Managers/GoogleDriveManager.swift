import Foundation
import GoogleSignIn
import GoogleAPIClientForREST_Drive

class GoogleDriveManager {
    static let shared = GoogleDriveManager()

    private let service: GTLRDriveService

    private init() {
        service = GTLRDriveService()
        service.shouldFetchNextPages = false
        service.isRetryEnabled = true
    }

    var hasAuthorizer: Bool {
        service.authorizer != nil
    }

    // MARK: - Configuration

    func configure(with user: GIDGoogleUser) {
        service.authorizer = user.fetcherAuthorizer
        print("[Drive] Configured with user: \(user.profile?.email ?? "unknown")")
        print("[Drive] Authorizer set: \(service.authorizer != nil)")
    }

    // MARK: - Shared With Me

    func listSharedFolders(completion: @escaping @Sendable (Result<[GTLRDrive_File], Error>) -> Void) {
        guard service.authorizer != nil else {
            DispatchQueue.main.async { completion(.success([])) }
            return
        }

        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.fields = "files(id,name,mimeType,modifiedTime,parents)"
        query.q = "mimeType='application/vnd.google-apps.folder' and sharedWithMe=true and trashed=false"
        query.orderBy = "name"

        print("[Drive] Listing shared-with-me folders...")
        service.executeQuery(query) { (_, response, error) in
            if let error = error {
                print("[Drive] Shared folders error: \(error)")
                DispatchQueue.main.async { completion(.success([])) }
                return
            }

            guard let fileList = response as? GTLRDrive_FileList else {
                DispatchQueue.main.async { completion(.success([])) }
                return
            }

            let files = fileList.files ?? []
            print("[Drive] Found \(files.count) shared folders")
            for file in files {
                print("[Drive]   - \(file.name ?? "?") (\(file.identifier ?? "?"))")
            }

            DispatchQueue.main.async { completion(.success(files)) }
        }
    }

    // MARK: - Create Folder

    func createFolder(name: String, parentId: String?, completion: @escaping @Sendable (Result<GTLRDrive_File, Error>) -> Void) {
        guard service.authorizer != nil else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "GoogleDriveManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Brak autoryzacji."])))
            }
            return
        }

        let folder = GTLRDrive_File()
        folder.name = name
        folder.mimeType = "application/vnd.google-apps.folder"

        if let parentId = parentId {
            folder.parents = [parentId]
        }

        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        query.fields = "id,name,mimeType,parents"

        print("[Drive] Creating folder '\(name)' in \(parentId ?? "root")...")
        service.executeQuery(query) { (_, response, error) in
            if let error = error {
                print("[Drive] Create folder error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let file = response as? GTLRDrive_File else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "GoogleDriveManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Nieoczekiwana odpowiedź"])))
                }
                return
            }

            print("[Drive] Created folder: \(file.name ?? "?") (\(file.identifier ?? "?"))")
            DispatchQueue.main.async { completion(.success(file)) }
        }
    }

    // MARK: - File Delete

    func deleteFile(fileId: String, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard service.authorizer != nil else {
            DispatchQueue.main.async { completion(.success(())) }
            return
        }

        let query = GTLRDriveQuery_FilesDelete.query(withFileId: fileId)

        print("[Drive] Deleting file: \(fileId)...")
        service.executeQuery(query) { (_, _, error) in
            if let error = error {
                print("[Drive] Delete error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            print("[Drive] File deleted: \(fileId)")
            DispatchQueue.main.async { completion(.success(())) }
        }
    }

    // MARK: - File Upload

    func uploadFile(localURL: URL, fileName: String, mimeType: String, parentFolderId: String, completion: @escaping @Sendable (Result<GTLRDrive_File, Error>) -> Void) {
        guard service.authorizer != nil else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "GoogleDriveManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Brak autoryzacji."])))
            }
            return
        }

        let metadata = GTLRDrive_File()
        metadata.name = fileName
        metadata.parents = [parentFolderId]

        guard let data = try? Data(contentsOf: localURL) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "GoogleDriveManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Nie znaleziono pliku do wysłania."])))
            }
            return
        }

        let uploadParams = GTLRUploadParameters(data: data, mimeType: mimeType)

        let query = GTLRDriveQuery_FilesCreate.query(withObject: metadata, uploadParameters: uploadParams)
        query.fields = "id,name,size"

        print("[Drive] Uploading \(fileName) (\(data.count) bytes) to folder \(parentFolderId)...")
        service.executeQuery(query) { (_, response, error) in
            if let error = error {
                print("[Drive] Upload error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let file = response as? GTLRDrive_File else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "GoogleDriveManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Nieoczekiwana odpowiedź po uploadzie."])))
                }
                return
            }

            print("[Drive] Upload complete: \(file.name ?? "?") (id: \(file.identifier ?? "?"), size: \(file.size ?? 0))")
            DispatchQueue.main.async { completion(.success(file)) }
        }
    }

    // MARK: - Folder Listing

    func listFolders(in parentFolderId: String?, driveId: String? = nil, completion: @escaping @Sendable (Result<[GTLRDrive_File], Error>) -> Void) {
        guard service.authorizer != nil else {
            print("[Drive] ERROR: No authorizer set")
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "GoogleDriveManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Brak autoryzacji. Wyloguj się i zaloguj ponownie."])))
            }
            return
        }

        var queryString = "mimeType='application/vnd.google-apps.folder' and trashed=false"

        if let parentId = parentFolderId {
            queryString += " and '\(parentId)' in parents"
        } else {
            queryString += " and 'root' in parents"
        }

        print("[Drive] Listing folders in: \(parentFolderId ?? "root"), driveId: \(driveId ?? "none")")
        print("[Drive] Query: \(queryString)")

        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.fields = "files(id,name,mimeType,modifiedTime,parents)"
        query.q = queryString
        query.orderBy = "name"

        // Support shared drives
        query.supportsAllDrives = true
        query.includeItemsFromAllDrives = true

        if let driveId = driveId {
            query.corpora = "drive"
            query.driveId = driveId
        }

        service.executeQuery(query) { (_, response, error) in
            if let error = error {
                print("[Drive] API ERROR: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let fileList = response as? GTLRDrive_FileList else {
                print("[Drive] Unexpected response type")
                DispatchQueue.main.async { completion(.success([])) }
                return
            }

            let files = fileList.files ?? []
            print("[Drive] Found \(files.count) folders")
            for file in files {
                print("[Drive]   - \(file.name ?? "?") (\(file.identifier ?? "?"))")
            }

            DispatchQueue.main.async { completion(.success(files)) }
        }
    }
}
