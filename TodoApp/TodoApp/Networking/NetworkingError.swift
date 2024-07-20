import Foundation

enum NetworkingError: Error {
    case urlCreationFailed // Ошибка создания URL
    case incorrectRequestFormat // Ошибка формата запроса (400)
    case incorrectAuthorization // Ошибка авторизации (401)
    case elementNotFound // Элемент не найден (404)
    case conflict // Конфликт данных, например, при обновлении (409)
    case serverError // Общая ошибка сервера (500)
    case noInternetConnection // Нет подключения к интернету
    case requestTimedOut // Таймаут запроса
    case dataDecodingFailed // Ошибка декодирования данных
    case unknownError // Неизвестная ошибка
    
    var localizedDescription: String {
        switch self {
        case .urlCreationFailed:
            return "Не удалось создать URL."
        case .incorrectRequestFormat:
            return "Некорректный формат запроса."
        case .incorrectAuthorization:
            return "Неверная авторизация."
        case .elementNotFound:
            return "Элемент не найден."
        case .conflict:
            return "Конфликт данных, например, при обновлении."
        case .serverError:
            return "Ошибка сервера."
        case .noInternetConnection:
            return "Нет подключения к интернету."
        case .requestTimedOut:
            return "Запрос истек по времени."
        case .dataDecodingFailed:
            return "Ошибка декодирования данных."
        case .unknownError:
            return "Неизвестная ошибка."
        }
    }
}
