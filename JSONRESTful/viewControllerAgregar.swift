//
//  viewControllerAgregar.swift
//  JSONRESTful
//
//  Created by Oliver Correa.
//

import UIKit

class ViewControllerAgregar: UIViewController {

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtGenero: UITextField!
    @IBOutlet weak var txtDuracion: UITextField!
    @IBOutlet weak var botonGuardar: UIButton!
    @IBOutlet weak var botonActualizar: UIButton!

    var pelicula: Peliculas?

    override func viewDidLoad() {
        super.viewDidLoad()

        if pelicula == nil {
            botonGuardar.isEnabled = true
            botonActualizar.isEnabled = false
        } else {
            botonGuardar.isEnabled = false
            botonActualizar.isEnabled = true
            txtNombre.text = pelicula!.nombre
            txtGenero.text = pelicula!.genero
            txtDuracion.text = pelicula!.duracion
        }
    }

    @IBAction func btnGuardar(_ sender: Any) {
        let nombre = txtNombre.text!
        let genero = txtGenero.text!
        let duracion = txtDuracion.text!
        let datos = ["usuarioId": 1, "nombre": nombre, "genero": genero, "duracion": duracion] as Dictionary<String, Any>
        let ruta = "http://localhost:3000/peliculas"
        metodoPOST(ruta: ruta, datos: datos)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActualizar(_ sender: Any) {
        let nombre = txtNombre.text!
        let genero = txtGenero.text!
        let duracion = txtDuracion.text!
        
        guard let peliculaId = pelicula?.id else {
            // Manejar el caso en el que no hay una película seleccionada
            return
        }
        
        let datos = ["usuarioId": 1, "nombre": "\(nombre)", "genero": "\(genero)", "duracion": "\(duracion)"] as Dictionary<String, Any>
        
        let ruta = "http://localhost:3000/peliculas/\(peliculaId)"
        
        metodoPUT(ruta: ruta, datos: datos)
        
        navigationController?.popViewController(animated: true)
    }

    func metodoPOST(ruta: String, datos: [String: Any]) {
        let url: URL = URL(string: ruta)!
        var request = URLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "POST"

        // This is your input parameter dictionary
        let params = datos

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            // Catch any exception here
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    print(dict)
                } catch {
                    // Catch any exception here
                    print("Error en la conversión de la respuesta JSON: \(error)")
                }
            } else if let error = error {
                print("Error en la solicitud: \(error)")
            }
        }
        task.resume()
    }
    
    func metodoPUT(ruta: String, datos: [String: Any]) {
        let url: URL = URL(string: ruta)!
        var request = URLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "PUT"

        // This is your input parameter dictionary
        let params = datos

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            // Handle any exception here
            print("Error in JSON serialization")
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    print(dict)
                } catch {
                    // Handle any exception here
                    print("Error in JSON deserialization")
                }
            }
        }

        task.resume()
    }
}
