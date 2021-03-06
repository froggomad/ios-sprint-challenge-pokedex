//
//  DetailViewController.swift
//  PokeDex
//
//  Created by Kenny on 1/17/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var abilitiesLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    //MARK: IBActions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if let pokemon = searchedPokemon {
            pokemonController?.savePokemon(pokemon: pokemon)
            self.saveButton.isHidden = true
            self.saveButton.isUserInteractionEnabled = false
        } else if let pokemon = pokemon {
            pokemonController?.removePokemon(pokemon: pokemon)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Class Properties
    var pokemon: Pokemon?
    var pokemonController: PokemonTrainer?
    /**
        Updates the UI when a pokemon is found using the searchBar
     */
    var searchedPokemon: Pokemon? {
        didSet {
            updateUI()
        }
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupViews()
    }
    
    //MARK: Helper Functions
    func setupViews() {
        if pokemon == nil {
            nameLabel.isHidden = true
            idLabel.isHidden = true
            typesLabel.isHidden = true
            abilitiesLabel.isHidden = true
            saveButton.isHidden = true
            saveButton.isUserInteractionEnabled = false
        }
        
        updateUI()
    }
    /**
     Updates UI elements with Pokemon details. Switches elements based on state
     */
    func updateUI() {
        guard let pokemon = pokemon,
            let pokemonController = pokemonController
        else {return}
        if nameLabel.isHidden { //if this is hidden, so are other elements
            nameLabel.isHidden = false
            idLabel.isHidden = false
            typesLabel.isHidden = false
            abilitiesLabel.isHidden = false
            
            if pokemon != self.pokemon {
                saveButton.isHidden = false
                saveButton.isUserInteractionEnabled = true
            }
        }
        
        //fill in UI elements
        title = pokemon.name
        nameLabel.text = pokemon.name
        idLabel.text = "ID: \(pokemon.id)"
        typesLabel.text = "Types: \(prettyPrintTypes(typeArray: pokemon.types))"
        abilitiesLabel.text = "Abilities: \(prettyPrintAbilities(abilitiesArray: pokemon.abilities))"
        //get image
        let imageUrl = URL(string: pokemon.picture.url)
        pokemonController.getPokemonPicture(url: imageUrl, completion: { (pictureData) in
            guard let pictureData = pictureData else {
                print("no picture data")
                return
            }
            let image = UIImage(data: pictureData)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        })
        for savedPokemon in pokemonController.pokemon {
            if pokemon == savedPokemon {
                saveButton.setTitle("Delete Pokemon", for: .normal)
                saveButton.tintColor = UIColor.red
            }
        }
        saveButton.isHidden = false
        saveButton.isUserInteractionEnabled = true
    }
    
    func prettyPrintTypes(typeArray: [Types]) -> String {
        var returnString = ""
        for (index, value) in typeArray.enumerated() {
            if index < typeArray.count - 1 {
                returnString.append("\(value.type.name), ")
            } else {
                returnString.append(value.type.name)
            }
        }
        return returnString
    }
    
    func prettyPrintAbilities(abilitiesArray: [Abilities]) -> String {
        var returnString = ""
        for (index, value) in abilitiesArray.enumerated() {
            if index < abilitiesArray.count - 1 {
                returnString.append("\(value.ability.name), ")
            } else {
                returnString.append(value.ability.name)
            }
        }
        return returnString
    }
    
    func getPokemonFromUrl(url: String) {
        let url = URL(string: url)
        pokemonController?.getPokemonFromURL(url: url) { (pokemon) in
            guard let pokemon = pokemon else {return}
            DispatchQueue.main.async {
                self.pokemon = pokemon
                self.searchedPokemon = pokemon
                self.searchBar.resignFirstResponder()
            }
        }
    }
    
}

//MARK: SearchBar Delegate
extension DetailViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text,
            searchText != "",
            let pokeDataArray = pokemonController?.pokeDataArray
        else {return}
        
        for pokemonData in pokeDataArray {
            if pokemonData.name.uppercased() == searchText.uppercased() {
                getPokemonFromUrl(url: pokemonData.url)
                return
            }
        }
        //Alert not found, check spelling
    }
}

