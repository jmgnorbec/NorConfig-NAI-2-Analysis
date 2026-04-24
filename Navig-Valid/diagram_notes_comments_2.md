# Notes extraites du diagramme global

## 1. Portée générale du configurateur

- Doit être capable de gérer les deux usines **STH** et **SRY**.
- Doit être capable de gérer un produit, par exemple **Norex-L**, qui est produit dans les deux usines.
- En fonction du type de produit, différents chemins de configuration sont possibles.

## 2. Structure produit et règles de disponibilité

- En fonction du type de produit et du joint, différentes largeurs de panneaux sont disponibles.
- En fonction du type de produit, du joint et de la largeur, différentes épaisseurs de panneaux sont disponibles.
- En fonction du type de produit, du joint et de la largeur, différents aciers sont disponibles.
- En fonction du type de produit et du joint, différents profils de panneaux sont disponibles.
- En fonction de l'acier, différents profils sont disponibles.

## 3. Sélection des aciers disponibles

- Une feuille d'acier disponible comme choix de produit fait passer directement à la sélection d'aciers.
- Les quatre filtres sont disponibles; l'utilisateur peut utiliser n'importe quelle combinaison de ceux-ci, par exemple :
  - gauge + peinture pour une soumission;
  - texture + couleur pour une autre.
- Processus de sélection optionnelle :
  1. Sélection optionnelle du gauge.
  2. Sélection optionnelle du type de peinture.
  3. Sélection optionnelle de la texture.
  4. Sélection optionnelle de la couleur.
  5. Résultat : liste d'aciers disponibles.
- Filtre sur les aciers disponibles dans Epicor : on ne veut pas qu'ils s'affichent tous dans NorConfig.

## 4. Processus et gouvernance à mettre en place

- Processus de gestion de la gamme de couleurs offertes à mettre en place, impliquant Marketing et Appro.
- Processus à mettre en place pour s'assurer d'avoir un lisse et un embossé de chaque acier.

## 5. Règles de configuration et annulations automatiques

- **NOROC** : annuler **Cannelé**.
- **NOREX-S** : annuler **Silkline-Plus** et **Micro-nervuré**.
- **Tous types** : si le fini extérieur est en **26ga**, annuler le **Micro-nervuré**.
- **Butyle** : coché automatiquement.

## 6. Saisie des quantités et liste de coupe

- Saisie de la quantité en pi² ou par liste de coupe ou nombre de panneaux.
- Permettre de spécifier qu'on veut tarifer selon un nombre de pi² défini ou selon la liste de coupe.

## 7. Prix et affichage

- On voudrait que le prix au pi² s'actualise au fil des sélections.
- L'actualisation du prix est possiblement disponible seulement une fois toutes les configurations sélectionnées.
- Permettre de spécifier qu'on veut que le prix du butyle soit inclus dans le prix du panneau, pas sur une ligne séparée.
- Prix final affiché seulement; pas besoin du détail.
- Possibilité de connaître la version de prix des révisions antérieures.
- À valider : débat sur le calcul du prix.

## 8. Avertissements et validations UX

- Les avertissements sur les limitations de quantité minimum à soumissionner devront être visibles.
- Valider la pertinence d'avoir un bouton au début du cycle pour **Panneau INT** ou **Panneau EXT**.
