# Notes et commentaires extraits du diagramme

Source: `Configurateur NAI 2.0 - Requis.png`

Ce document regroupe les notes, commentaires et règles visibles dans le diagramme. Le contenu a été retranscrit manuellement depuis l'image. Quelques notes demeurent partiellement lisibles; elles sont isolées dans une section distincte.

## Notes d'affaires visibles

- [ ] Doit être capable de gérer les deux usines (STH & SRY).
  - Est-ce que la soumission de vente est liée à une usine?
  - Est-ce que les deux usines fabriquent tous les produits?

- [ ] Les avertissements sur les limitations de qualité minimales semblent se contredire entre elles.
  - Est-ce que la limitation selon la quantité minimale est informative ou stricte?

- [ ] On voudrait que le prix au PI2 s'actualise au fil des sélections.
  - Est-ce qu'on a un prix nominal (prix en bas de la quantité minimale ou au seuil de celle-ci)?

- [ ] Possibilité de connaître la version de prix des aciers antérieures. Valider débat sur calcul du prix.
  - Est-ce qu'on doit garder toutes les versions pour consultation antérieure?

## Notes sur la logique de configuration produit

- [ ] Si Norex-H, ajouter les caractéristiques antidérapantes.
  - trouver sur diagramme???

- [ ] BUTYLE: coché automatique.
  - Est-ce qu'on inclus toujours du butyle?

## Notes sur la sélection d'acier, fini, texture, couleur

- [ ] Processus de gestion de la gamme de couleurs offertes impliquant Marketing et Appro.
  - Expliquer

- [ ] En fonction du type de produit & joint & largeur, différents aciers disponibles.
  - Est-ce que c'est un facteur de la largeur requise pour produire le panneau (largeur + type de joint)?

- [ ] Processus à mettre en place pour s'assurer d'avoir un lisse & un embossé de chaque aciers.
  - Expliquer lisse et embossé, est-ce une caractéristique du sku d'acier?

- [ ] En fonction du type de produit & joint, différents profils de panneaux disponibles.
  - Expliquer?

- [ ] En fonction de l'acier, différents profils disponibles.
  - Expliquer?

- [ ] Filtre sur les aciers disponibles dans Epicor: on ne veut pas qu'ils s'affichent tous dans NorConfig.
  - Est-ce que c'est fonction de la priorité ou si c'est une autre option?

## Règles explicites visibles dans le diagramme

- [ ] SÉLECTION ACIER: les couleurs devront être mises à jour (masquer les couleurs non disponibles). Proposer la liste complète pour le côté extérieur et le côté intérieur.
  - Est-ce que la possibilité d'un mode 'fréquent' et d'un mode 'tout' pourrait améliorer l'efficacité?

- [ ] FINI: proposer lisse ou embossé pour tout type de panneaux.
  - Donc toujours à être choisi?

- [ ] PROFILE: limiter les profiles selon le type de panneau.
  - NOROC: annuler Cannelé.
  - NOREX-S: annuler Silkline-Plus et Micro-nervuré.
- TOUS TYPES: si le fini extérieur est en 26ga, annuler le Micro-nervuré.
- Clarifier les points ci-haut?

## Notes sur prix et sortie utilisateur

- [ ] Permettre de spécifier qu'on veut que le prix du butyle soit inclus dans le prix du panneau (pas sur une ligne séparée).
- [ ] Permettre de spécifier qu'on veut tarifer selon un nombre de pi2 défini ou selon la liste de coupe.
  - Mode prix budgétaire?

- [x] Prix final affiché seulement (pas besoin du détail).

## Notes partiellement lisibles

Les éléments ci-dessous sont visibles dans l'image, mais certains mots restent trop flous pour être considérés comme une transcription certaine.

- Une note semble demander d'identifier si certains choix doivent être tarifés au coût ou comme option, possiblement pour les PI2 intérieurs ou extérieurs.
- Une petite note jaune près de la zone de prix est présente, mais sa phrase complète n'est pas suffisamment lisible pour être retranscrite sans risque.
- Une note à droite de l'étape de sélection de couleur semble indiquer que quatre items sont disponibles et que l'utilisateur peut imposer une combinaison de couleurs, ou ne mettre aucune restriction. Cette formulation doit être confirmée à partir de la source originale.

## Lecture structurée du diagramme

Les commentaires visibles se regroupent autour de cinq thèmes:

- besoins d'affaires liés aux usines, aux produits et au comportement de prix;
- règles de dérivation produit, surtout largeur et épaisseur selon le type de panneau;
- logique de sélection de l'acier et de ses attributs;
- contraintes sur les profils et les finis;
- décisions d'affichage et de sortie de prix.