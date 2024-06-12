//
//  ViewControllerUser.swift
//  JSONRESTful
//
//  Created by Oliver Correa on 12/06/24.
//

import UIKit

class ViewControllerUser: UIViewController {

    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtClave: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnGuardarCambios: UIButton!

    var usuario: Users?
    var cambiosRealizados = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Verificar si usuario está asignado
        if let usuario = usuario {
            // Configura los campos de texto con los datos del usuario
            txtNombre.text = usuario.nombre
            txtClave.text = usuario.clave
            txtEmail.text = usuario.email
            txtClave.isSecureTextEntry = true
        }

        // Observadores para detectar cambios en los campos de texto
        txtNombre.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtClave.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        txtEmail.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // Deshabilita el botón al inicio
        btnGuardarCambios.isEnabled = false
    }

    @objc func textFieldDidChange() {
        // Habilita el botón si detecta cambios en los campos de texto
        cambiosRealizados = true
        btnGuardarCambios.isEnabled = true
    }

    @IBAction func guardarCambiosTapped(_ sender: UIButton) {
        // Verifica si hay un usuario logeado y cambios realizados
        guard let usuario = usuario, cambiosRealizados else {
            // Manejar el caso en el que no hay un usuario logeado o no hay cambios realizados
            return
        }

        let ruta = "http://localhost:3000/usuarios/\(usuario.id)"
        let datos = ["nombre": txtNombre.text!, "clave": txtClave.text!, "email": txtEmail.text!]
        metodoPUT(ruta: ruta, datos: datos)

        // Después de guardar los cambios, puedes realizar alguna acción como volver atrás
        mostrarAlertaConCierreSesion(titulo: "Cambios Guardados", mensaje: "Vuelve a iniciar sesión con los nuevos datos.")
    }

    func metodoPUT(ruta: String, datos: [String: Any]) {
        print("Llamada a metodoPUT en ViewControllerEditarPerfil")
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

    func mostrarAlertaConCierreSesion(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Cerrar sesión y volver al ViewController de inicio de sesión
            self?.dismiss(animated: true, completion: nil)
        }
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }
}
