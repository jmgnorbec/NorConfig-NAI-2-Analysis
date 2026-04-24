# Revue des notes du diagramme

## 1. Portée générale du configurateur

- [ ] Doit être capable de gérer les deux usines **STH** et **SRY**.
- [ ] Doit être capable de gérer un produit, par exemple **Norex-L**, qui est produit dans les deux usines.
- [ ] En fonction du type de produit, différents chemins de configuration sont possibles.

Questions à clarifier:
- [ ] Est-ce que la soumission de vente est liée à une usine?
- [ ] Est-ce que les deux usines fabriquent tous les produits?

## 2. Structure produit et règles de disponibilité

- [ ] En fonction du type de produit et du joint, différentes largeurs de panneaux sont disponibles.
- [ ] En fonction du type de produit, du joint et de la largeur, différentes épaisseurs de panneaux sont disponibles.
- [ ] En fonction du type de produit, du joint et de la largeur, différents aciers sont disponibles.
- [ ] En fonction du type de produit et du joint, différents profils de panneaux sont disponibles.
- [ ] En fonction de l'acier, différents profils sont disponibles.
- [ ] Si **Norex-H**, ajouter les caractéristiques antidérapantes.

Questions à clarifier:
- [ ] Est-ce que la largeur de l'acier limite la largeur du produit?
- [ ] Est-ce que la disponibilité des aciers est un facteur direct de la largeur requise pour produire le panneau?
- [ ] Clarifier ce qui détermine les profils côté produit.
- [ ] Clarifier ce qui détermine les profils côté acier.
- [ ] Expliquer les profils disponibles selon le type de produit et le joint.
- [ ] Expliquer les profils disponibles selon l'acier.
- [ ] Expliquer les caractéristiques antidérapantes de **Norex-H**.

## 3. Sélection des aciers disponibles

- [ ] Une feuille d'acier disponible comme choix de produit fait passer directement à la sélection d'aciers.
- [ ] Les quatre filtres sont disponibles; l'utilisateur peut utiliser n'importe quelle combinaison de ceux-ci.
- [ ] Processus de sélection optionnelle à confirmer.
- [ ] Sélection optionnelle du gauge.
- [ ] Sélection optionnelle du type de peinture.
- [ ] Sélection optionnelle de la texture.
- [ ] Sélection optionnelle de la couleur.
- [ ] Résultat: liste d'aciers disponibles.
- [ ] Filtre sur les aciers disponibles dans Epicor: on ne veut pas qu'ils s'affichent tous dans NorConfig.
- [ ] Les couleurs devront être mises à jour pour masquer les couleurs non disponibles, tout en proposant la liste complète pour le côté extérieur et le côté intérieur.

Exemples d'utilisation mentionnés:
- [ ] gauge + peinture pour une soumission;
- [ ] texture + couleur pour une autre.

Questions à clarifier:
- [ ] Est-ce qu'une pré-sélection est faite en fonction de la compatibilité avec le produit sélectionné?
- [ ] Est-ce que le filtre des aciers Epicor dépend d'une logique de priorité ou d'un autre critère?
- [ ] Est-ce que c'est fonction de la priorité ou si c'est une autre option?
- [ ] Est-ce qu'un mode `fréquent` et un mode `tout` amélioreraient l'efficacité de sélection?

## 4. Processus et gouvernance à mettre en place

- [ ] Processus de gestion de la gamme de couleurs offertes à mettre en place, impliquant Marketing et Appro.
- [ ] Processus à mettre en place pour s'assurer d'avoir un lisse et un embossé de chaque acier.

Questions à clarifier:
- [ ] Définir précisément le processus de gouvernance des couleurs.
- [ ] Expliquer le processus de gestion de la gamme de couleurs offertes.
- [ ] Expliquer si `lisse` et `embossé` sont des caractéristiques du SKU d'acier.
- [ ] Clarifier le processus garantissant la disponibilité de chaque fini.
- [ ] Clarifier le processus à mettre en place pour s'assurer d'avoir un lisse et un embossé de chaque acier.

## 5. Règles de configuration et annulations automatiques

- [ ] **NOROC**: annuler **Cannelé**.
- [ ] **NOREX-S**: annuler **Silkline-Plus** et **Micro-nervuré**.
- [ ] **NOREX-H**: cannelure automatique.
- [ ] **Tous types**: si le fini extérieur est en **26ga**, annuler le **Micro-nervuré**.
- [ ] **FINI**: proposer `lisse` ou `embossé` pour tout type de panneaux.
- [ ] **PROFILE**: limiter les profils selon le type de panneau.
- [ ] **Butyle**: coché automatiquement.

Questions à clarifier:
- [ ] Est-ce que la cannelure est obligatoire dans le cas de **Norex-H**?
- [ ] Est-ce que le fini est toujours un choix obligatoire?
- [ ] Clarifier l'ensemble des règles de profil ci-dessus.
- [ ] Est-ce que le butyle est toujours inclus, ou seulement coché par défaut?

## 6. Saisie des quantités et liste de coupe

- [ ] Saisie de la quantité en pi² ou par liste de coupe ou nombre de panneaux.
- [ ] Permettre de spécifier qu'on veut tarifer selon un nombre de pi² défini ou selon la liste de coupe.

Questions à clarifier:
- [ ] Est-ce qu'il existe un mode prix budgétaire distinct?

## 7. Prix et affichage

- [ ] On voudrait que le prix au pi² s'actualise au fil des sélections.
- [ ] L'actualisation du prix est possiblement disponible seulement une fois toutes les configurations sélectionnées.
- [ ] Permettre de spécifier qu'on veut que le prix du butyle soit inclus dans le prix du panneau, pas sur une ligne séparée.
- [x] Prix final affiché seulement; pas besoin du détail.
- [ ] Possibilité de connaître la version de prix des révisions antérieures.
- [ ] À valider: débat sur le calcul du prix.

Questions à clarifier:
- [ ] Est-ce qu'on a un prix nominal en bas de la quantité minimale ou au seuil de celle-ci?
- [ ] Est-ce qu'on doit garder toutes les versions de prix pour consultation antérieure?

## 8. Avertissements et validations UX

- [ ] Les avertissements sur les limitations de quantité minimum à soumissionner devront être visibles.
- [ ] Valider la pertinence d'avoir un bouton au début du cycle pour **Panneau INT** ou **Panneau EXT**.

Questions à clarifier:
- [ ] Est-ce que la limitation selon la quantité minimale est informative ou stricte?
