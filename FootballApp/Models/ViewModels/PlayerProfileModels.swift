//
//  PlayerProfileModels.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 30/11/2025.
//

import Foundation

// MARK: - Algo Sport Archetypes (From PDF)

public enum SportDiscipline: String, Codable, CaseIterable {
    case football = "Football"
    case futsal = "Futsal"
    case fitness = "Fitness"
}

public enum PlayerPosition: String, Codable, CaseIterable {
    case goalkeeper = "Gardien"
    case defender = "Défenseur"
    case midfielder = "Milieu"
    case attacker = "Attaquant"
    case none = "Fitness" // Fallback
    
    // Returns the archetypes available for this position (Page 1 of Dossier)
    var availableArchetypes: [PlayerArchetype] {
        switch self {
        case .goalkeeper: return [.panthere, .pieuvre, .araignee, .chat]
        case .defender:   return [.casseur, .controleur, .polyvalent, .relanceur]
        case .midfielder: return [.architecte, .gazelle, .pitbull, .rock]
        case .attacker:   return [.magicien, .renard, .sniper, .tank]
        case .none:       return []
        }
    }
}

public enum PlayerArchetype: String, Codable, CaseIterable {
    // Gardiens
    case panthere = "Panthère"   // Focus: Puissance (Power)
    case pieuvre = "Pieuvre"     // Focus: Habileté/Allonge (Skill/Reach)
    case araignee = "Araignée"   // Focus: Malice/Agilité (Smart/Agile)
    case chat = "Chat"           // Focus: Explosivité (Reflexes)
    
    // Défenseurs
    case casseur = "Casseur"     // Focus: Physique/Dur (Physical)
    case controleur = "Contrôleur" // Focus: Maîtrise (Control)
    case polyvalent = "Polyvalent" // Focus: Adaptation
    case relanceur = "Relanceur"   // Focus: Propreté technique (Clean Passing)
    
    // Milieux
    case architecte = "Architecte" // Focus: Construction
    case gazelle = "Gazelle"       // Focus: Cardio/Endurance
    case pitbull = "Pitbull"       // Focus: Agressivité/Pressing
    case rock = "Rock"             // Focus: Force pure (Machine)
    
    // Attaquants
    case magicien = "Magicien"     // Focus: Talent/Technique
    case renard = "Renard"         // Focus: Finition
    case sniper = "Sniper"         // Focus: Précision
    case tank = "Tank"             // Focus: Puissance physique
    
    // Maps the Archetype to a technical training focus for the Algorithm
    var trainingFocus: TrainingFocus {
        switch self {
        case .panthere, .casseur, .rock, .tank, .pitbull:
            return .powerHypertrophy
        case .gazelle, .polyvalent:
            return .enduranceCardio
        case .chat, .magicien, .sniper, .araignee, .renard:
            return .explosivenessAgility
        case .architecte, .controleur, .pieuvre, .relanceur:
            return .skillStability
        }
    }
}

public enum TrainingFocus {
    case powerHypertrophy
    case enduranceCardio
    case explosivenessAgility
    case skillStability
}
