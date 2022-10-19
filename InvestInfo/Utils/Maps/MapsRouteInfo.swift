import CoreLocation

struct MapsRouteInfo {
    let startPoint, endPoint: CLLocationCoordinate2D?
    
    enum RouteKey: String, CaseIterable {
        case yandexMaps, appleMaps, googleMaps, doubleGis
    }
    
    struct RouteInfo {
        let title, name, appURL, webURL: String
    }
    
    func getInfo(_ key: RouteKey) -> RouteInfo {
        let start = joinText(getText(from: startPoint?.latitude), getText(from: startPoint?.longitude))
        let end =   joinText(getText(from: endPoint?.latitude), getText(from: endPoint?.longitude))
        let start2Gis = joinText(getText(from: startPoint?.longitude), getText(from: startPoint?.latitude))
        let end2Gis =   joinText(getText(from: endPoint?.longitude), getText(from: endPoint?.latitude))
        
        switch key {
        case .yandexMaps:
            let suffix = start.isEmpty ?
            ["~", end].joined() : [start, end].joined(separator: "~")
            let appURL = ["yandexmaps://maps.yandex.ru/?rtext=", suffix].joined()
            let webURL = ["https://yandex.ru/maps/?rtext=", suffix].joined()
            return RouteInfo(title: "Яндекс.Карты", name: "ЯндексКарты", appURL: appURL, webURL: webURL)
        case .appleMaps:
            let suffix = start.isEmpty ?
            ["daddr=", end].joined() : ["saddr=", start, "&daddr=", end].joined()
            let appURL = ["maps://?", suffix].joined()
            let webURL = ["https://maps.apple.com/?", suffix].joined()
            return RouteInfo(title: "Карты", name: "AppleMaps", appURL: appURL, webURL: webURL)
        case .googleMaps:
            let appSuffix = start.isEmpty ?
            ["daddr=", end].joined() : ["saddr=", start, "&daddr=", end].joined()
            let webSuffix = start.isEmpty ?
            ["/", end].joined() : [start, end].joined(separator: "/")
            let appURL = ["comgooglemaps://?", appSuffix].joined()
            let webURL = ["https://google.com/maps/dir/", webSuffix].joined()
            return RouteInfo(title: "Google Maps", name: "GoogleMaps", appURL: appURL, webURL: webURL)
        case .doubleGis:
            let suffix = start2Gis.isEmpty ?
            ["2gis.ru/routeSearch/rsType/car/to/", end2Gis].joined() :
            ["2gis.ru/routeSearch/rsType/car/from/", start2Gis, "/to/", end2Gis].joined()
            let appURL = ["dgis://", suffix].joined()
            let webURL = ["https://", suffix].joined()
            return RouteInfo(title: "2ГИС", name: "2ГИС", appURL: appURL, webURL: webURL)
        }
    }
}

private extension MapsRouteInfo {
    func getText(from: Double?) -> String? {
        guard let from = from else { return nil }
        return String(describing: from)
    }
    
    func joinText(_ text1: String?, _ text2: String?) -> String {
        guard let text1 = text1, let text2 = text2 else { return "" }
        return [text1, text2].joined(separator: ",")
    }
}
