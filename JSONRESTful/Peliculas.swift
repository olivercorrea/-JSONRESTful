//
//  Peliculas.swift
//  JSONRESTful
//
//  Created by Oliver Correa.
//

import Foundation
struct Peliculas:Decodable{
    let usuarioId:Int
    let id:Int
    let nombre:String
    let genero:String
    let duracion:String
}
