//
//  ViewController.swift
//  JSONRESTful
//
//  Created by Oliver Correa.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    
    var users = [Users]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtContrasena.isSecureTextEntry = true
    }
    
    func validarUsuario(ruta: String, completed: @escaping () -> ()) {
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    self.users = try JSONDecoder().decode([Users].self, from: data!)
                    DispatchQueue.main.async {
                            completed()
                    }
                } catch {
                    print("Error en JSON")
                }
            }
            }.resume()
    }
    
    @IBAction func logear(_ sender: Any) {
        let ruta = "http://localhost:3000/usuarios?"
        let usuario = txtUsuario.text!
        let contrasena = txtContrasena.text!
        let url = ruta + "nombre=\(usuario)&clave=\(contrasena)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")

        validarUsuario(ruta: crearURL) {
            DispatchQueue.main.async {
                if self.users.isEmpty {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Nombre de usuario y/o contraseña incorrecto")
                    print("Nombre de usuario y/o contraseña es incorrecto")
                } else {
                    // Guardar la información del usuario en SessionManager
                    SessionManager.shared.usuario = self.users.first

                    print("Logeo Exitoso")
                    self.performSegue(withIdentifier: "segueLogueo", sender: nil)
                    for data in self.users {
                        print("id: \(data.id), nombre: \(data.nombre), email: \(data.email)")
                    }
                }
            }
        }
    }

    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }

}
