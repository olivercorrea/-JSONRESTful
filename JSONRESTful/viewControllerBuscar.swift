//
//  viewControllerBuscar.swift
//  JSONRESTful
//
//  Created by Oliver Correa.
//

import UIKit

class ViewControllerBuscar: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var peliculas = [Peliculas]()
    @IBOutlet weak var txtBuscar: UITextField!
    @IBOutlet weak var tablaPeliculas: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaPeliculas.delegate = self
        tablaPeliculas.dataSource = self

        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta) {
            self.tablaPeliculas.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peliculas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(peliculas[indexPath.row].nombre)"
        cell.detailTextLabel?.text = "Genero: \(peliculas[indexPath.row].genero) Duracion: \(peliculas[indexPath.row].duracion)"
        return cell
    }
    
    @IBAction func btnBuscar(_ sender: Any) {
        let ruta = "http://localhost:3000/peliculas?"
        let nombre = txtBuscar.text!
        let url = ruta + "nombre_like=\(nombre)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20" )

        if nombre.isEmpty {
            let ruta = "http://localhost:3000/peliculas/"
            cargarPeliculas(ruta: ruta) {
                self.tablaPeliculas.reloadData()
            }
        } else {
            cargarPeliculas(ruta: crearURL) {
                if self.peliculas.count <= 0 {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se encontraron coincidencias para: \(nombre)", accion: "cancel")
                } else {
                    self.tablaPeliculas.reloadData()
                }
            }
        }
    }
    
    
    @IBAction func btnSalir(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func cargarPeliculas(ruta: String, completed: @escaping () -> ()) {
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    self.peliculas = try JSONDecoder().decode([Peliculas].self, from: data!)
                    DispatchQueue.main.async {
                            completed()
                    }
                } catch {
                        print("Error en JSON")
                }
            }
            }.resume()
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let ruta = "http://localhost:3000/peliculas/"
        cargarPeliculas(ruta: ruta) {
            self.tablaPeliculas.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pelicula = peliculas[indexPath.row]
        performSegue(withIdentifier: "segueEditar", sender: pelicula)
    }
    
    @IBAction func editarPerfilTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "segueEditarPerfil", sender: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditarPerfil" {
            if let siguienteVC = segue.destination as? ViewControllerUser {
                siguienteVC.usuario = SessionManager.shared.usuario
            }
        } else if segue.identifier == "segueEditar" {
            if let siguienteVC = segue.destination as? ViewControllerAgregar, let pelicula = sender as? Peliculas {
                siguienteVC.pelicula = pelicula
            }
        }
    }
    


    func eliminarPelicula(id: Int) {
        let ruta = "http://localhost:3000/peliculas/\(id)"
        var request = URLRequest(url: URL(string: ruta)!)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error al eliminar la película: \(error)")
            } else {
                print("La película ha sido eliminada con éxito")
                self.cargarPeliculas(ruta: "http://localhost:3000/peliculas/") {
                    self.tablaPeliculas.reloadData()
                }
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let pelicula = peliculas[indexPath.row]

            let alert = UIAlertController(title: "Eliminar la Película", message: "¿Deseas eliminar la película '\(pelicula.nombre)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sí", style: .destructive, handler: { action in
                self.eliminarPelicula(id: pelicula.id)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    }
}
