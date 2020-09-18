//
//  Themes.swift
//  VK Emotion Map (Vezdekod)
//
//  Created by Alex Yatsenko on 18.09.2020.
//  Copyright © 2020 AlexislogS. All rights reserved.
//

import CoreLocation

struct Themes {
    static let getThemes = [
        Theme(title: "Музыка",
              themeEmotion: "🎧",
              emotion: "😃 Хорошее настроение",
              coordinate: CLLocationCoordinate2D(latitude: 59.9241354,
                                                  longitude: 30.24112344)),
        Theme(title: "Фильмы",
              themeEmotion: "🍿",
              emotion: "😃 Хорошее настроение",
              coordinate: CLLocationCoordinate2D(latitude: 59.93174796,
                                                  longitude: 30.35364211)),
        Theme(title: "Осень",
              themeEmotion: "🍂",
              emotion: "😌 Полное спокойствие",
              coordinate: CLLocationCoordinate2D(latitude: 59.98338224,
                                                  longitude: 30.19630909)),
        Theme(title: "Работа",
              themeEmotion: "👔",
              emotion: "😜 Высокая энергия",
              coordinate: CLLocationCoordinate2D(latitude: 59.93583308,
                                                  longitude: 30.32586515)),
        Theme(title: "Карантин",
              themeEmotion: "😷 ",
              emotion: "😐 Безразличие...",
              coordinate: CLLocationCoordinate2D(latitude: 59.98559341,
                                                  longitude: 30.43230057))
    ]
}
