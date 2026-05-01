# Revue des notes du diagramme

- Surcharge pour couleurs non-standard intérieur
- Transformation de panneau horizontal (Martin opère transformations manuelles)
  - Équipe 2D transpose dessin main levée fait par le client (source de non-conformités)
- NAI pricing reste en production et doit être intégré
- [x] Expliquer et énumérer les options pour chacune des caractéristiques (profil, embossé, micro-nervuré, fini, ...)
- [x] Embossé, il y a trois options: stucco, séville, embossé Norbec de Strathroy ... échantillon ancien stucco

## 1. Portée générale du configurateur

- Doit pouvoir inclure les panneaux de toit.
  - [x] Doit pouvoir identifier tête et queue de panneau : extrémités de panneau en fonction de la ligne
  - [x] Cut back, endlap, ...
- [x] Doit pouvoir implanter des règles de validation afin de réduire les non-conformités.
- [x] Doit pouvoir guider l'utilisateur dans le processus pour la même raison que le point précédent.
- Doit être capable de gérer les deux usines **STH** et **SRY**.
  - [x] Usine choisie en aval, par exemple au moment de la commande ou de la planification de production. **NON**
  - en gros pas de Noroc à SRY
- [ ] En fonction du type de produit, différents chemins de configuration sont possibles.

```
- Processus
  - Sélection du type de panneau (Norex-S, Norex-L, Norex-H, Noroc, Norex-M[strathroy])
  - Sélection de la largeur de panneau et épaisseur
    - Norex-S (Norex-In à SRY) (panneau intérieur seulement)
      - largeur: 44
        - epaisseurs: 4
      - profil: aucun, ondulé (pas les autres silkline-plus et micro-nervuré)

    - Norex-L (Norex-M à SRY)
      - largeur: 42.5
        - epaisseurs: 2, 3, 4, 5, 6, 8
      - largeur: 36
        - epaisseurs: 3, 4

    - Norex-H
      - largeur: 41.5
        - epaisseurs: 3, 4
      - largeur: 36
        - epaisseurs: 3, 4
      - largeur: 30
        - epaisseurs: 3, 4
      - largeur: 24
        - epaisseurs: 3, 4
      - ajouter caractéristique **antidérapant** - clarifier (et déterminer appelation)

    - Noroc
      - largeur: 42.5
        - epaisseurs: 5, 6, 8
    - Norex-P et Z ???
    - Panneaux de toiture
      - largeur: ??
        - epaisseurs: ??
      - tête de panneau: cut back, endlap, ...
      - queue de panneau: cut back, endlap, ...

  - Sélection de l'acier (couleur, peinture, gauge)
    - Les aciers disponibles sont limités aux largeurs correspondant au type de panneau et largeur
      - [ ] La sélection du sku d'acier est optimisée en fonction de la priorité ???
      - [ ] Aciers 'limités' présentés sous deux modes pour choisir un sku d'acier
        - Aciers fréquents/probables/optimals
        - Tout les aciers
      - [x] Est-ce que les disponibilités en inventaire peuvent influencer la présentation des sku d'acier
        - **Non** en soumission
      - [x] Est-ce qu'il y a des restrictions sur les aciers en fonction des caractéristiques du panneau
        - **Non** Pas de contraintes

  - Sélection de Fini
    - Lisse
    - Stucco
    - Séville
    - Norbec
      - 1 fournisseur (machine stucco brisée, machine séville fonctionne)
      - dans configurateur on a seulement embossé (pas de distinction entre stucco et séville)
      - SRY peut fabriquer embossage 'Norbec' un genre de stucco

  - Sélection de Profil
    - Aucun (seulement gage 22 et 24)
    - Ondulé (nouvelle appelation pour cannelé)
    - Ondulé-Plus (extérieur seulement, SRY seulement)
    - Silkline (intérieur seulement)
    - Silkline-Plus (extérieur seulement)
    - Micro-Nervuré (pas applicable sur acier extérieur 26 gauge)

  - Ordre de sélection non linéaire pour (type peinture, gauge, texture, couleur, fini, profil)

  - Sélection de butyle (oui/non)
    - Par défaut à oui
      - [ ] c'est pas vrai et pas souhaitable ???

```

Cannelure: c'est un offset pour créer un 'recess' entre deux panneaux (Norex-H et Norex-M)
  - ne pas confondre avec profil 'cannelé' qui est aujourd'hui remplacé par 'Ondulé'
  - 1/8 veux dire pas de recess entre deux panneaux
  - 3/4 veux dire un recess entre deux panneaux
  - Seulement sur panneaux Norex-H et Norex-M
  - Norex-H cannelure automatique 3/4
  - Norex-M optionnel

### Règles de configuration

- [x] Norex-S sont des panneaux intérieurs
  - Norex-IN équivalent faits à Strathroy
  - Pas de profil Silkline-Plus et Micro-Nervuré
  - Pas de cannelure

- [x] Norex-L
  - Pas de cannelure

- [x] Norex-H est principalement pour usage horizontal
  - Cannelure 3/4 obligatoire

- [x] Norex-M (vertical et horizontal) remplace Norex-H
  - Cannelure 1/8 par défaut
  - Cannelure 3/4 optionnelle
  - Fabriqué à SRY seulement

- [x] Noroc
  - Fabriqué seulement à STH
  - Pas de cannelure

- [x] NorSeam fabriqué uniquement à SRY
  - 22 et 24 ga
  - PVDF seulement
  - Pas d'embossage tôle extérieure
  - Profil extérieur seulement ondulé+

- [x] Butyl
  - Toujours du butyl pour les panneaux extérieurs
  - Sur demande seulement pour les panneaux intérieurs

- [ ] NorFlex sont des panneaux de toit en Norex-M ou Norex-L
  - Est-ce que NorFlex existe dans le configurateur? Est-ce qu'il devrait exister?
  - Est-ce qu'il y a des restrictions pour le NorFlex ???

### Specs non fonctionnelles
- [ ] Doit prévoir les éventuelles progressions vers un configurateur 3D (Revit).

Questions à clarifier:
- [x] Est-ce que la soumission de vente est liée à une usine? Non
- [x] Est-ce que les deux usines fabriquent tous les produits? Non
  - [x] Décrire les produits par usine (part-plant dans epicor)
    - peut-être pas utile pour le moment ???
- [ ] Est-ce qu'on pourrait clarifier les cas de non-conformité (avec quantification de conséquence et récurence)?
  - Comité piloté par Ludovik - Marc-Antoine stratégie pour retrouver les tickets (Jira) - Amine/Yassine pour execution
    - Longueur de panneau
    - Pas beaucoup liés au configurateur ou chargé de projet

## 2. Structure produit et règles de disponibilité

- En fonction du type de produit et du joint, différentes largeurs de panneaux sont disponibles.
  - Largeur de bobine optimale par config de panneau, sinon largeur supérieure (optimisation)
    - table [Configurateur].[dbo].[plan_nai_map_larg]
      - Type joint + largeur panneau -> largeur optimale + priorité
- En fonction de l'acier, différents profils sont disponibles.
- [x] Containte de longueur de panneau
  - [ ] Application MaxPanLen à présenter

Questions à clarifier:
- [x] Est-ce que la disponibilité des aciers est un facteur direct de la largeur requise pour produire le panneau?
- [ ] Expliquer les différents caractéristiques de l'acier (fini, profil, embossage, antidérapant, cannelure, ...)
  - [x] **Profil**: Aucun (22 et 24 GA seulement), Ondulé, Ondulé-Plus, Micro-Nervuré, Silkline, Silkline-Plus
    = Attention: éviter d'utiliser le terme 'lisse' pour désigner aucun profil (créé de la confusion avec fini lisse)
  - [x] **Fini**: Lisse, Embossé
  - [ ] **Embossage**: est-ce un autre terme pour désigner fini?
  - [ ] **stucco**: stucco et ... est-ce que c'est des alternatives à embossé ???
  - [ ] **Cannelure**: ???
  - [ ] **Antidérapant**: ???
  - **Est-ce qu'il y a d'autres caractéristiques**: ???
- [ ] Amélie et Annie : Discussion sur le sujet et ajouter les règles de fini vs ces autres propriétés
    - Doit identifier disponibilité intérieur/extérieur (non défini dans la doc)
      - [ ] Expliquer type de panneau intérieur vs extérieur
        - Est-ce que ça serait une pré-selection ie: ce type influence les caractéristiques possibles des panneaux
    - [ ] Tableau identifie calibre - couleur - profilé/fini X
    - Clarifier ce qui détermine les profils côté produit.
    - Clarifier ce qui détermine les profils côté acier.
    - Expliquer les profils disponibles selon le type de produit et le joint.
    - Expliquer les profils disponibles selon l'acier.
    - Expliquer les caractéristiques antidérapantes de **Norex-H** (à Clarifier)
- [ ] Expliquer le butyle et clarifier les règles

## 3. Sélection des aciers disponibles

- [ ] Expliquer: Une feuille d'acier disponible comme choix de produit fait passer directement à la sélection d'aciers.
- Les quatre filtres sont disponibles; l'utilisateur peut utiliser n'importe quelle combinaison de ceux-ci.
- Processus de sélection optionnelle à confirmer.
- Sélection optionnelle du gauge.
- Sélection optionnelle du type de peinture.
- Sélection optionnelle de la texture.
- Sélection optionnelle de la couleur.
- Résultat: liste d'aciers disponibles.
- Filtre sur les aciers disponibles dans Epicor: on ne veut pas qu'ils s'affichent tous dans NorConfig.
- Les couleurs devront être mises à jour pour masquer les couleurs non disponibles, tout en proposant la liste complète pour le côté extérieur et le côté intérieur.

Questions à clarifier:
- [ ] Est-ce qu'une pré-sélection est faite en fonction de la compatibilité avec le produit sélectionné?
  - Calibres contraint par mode
  - Ontario Gauge 24 mais pas au Québec - Catégorisé par client / région / secteur
  - Client Québec veut du 24 gauge est-ce qu'on devrait gérer ça?
- [ ] Est-ce que le filtre des aciers Epicor dépend d'une logique de priorité ou d'un autre critère?
  - [ ] Costing couleur sur mesure - Processus long et complexe - Calcul automatique prix acier (Annie)
    - Section couleur sur mesure
- [ ] Est-ce que c'est fonction de la priorité ou si c'est une autre option?
- [x] Est-ce qu'un mode `fréquent` et un mode `tout` amélioreraient l'efficacité de sélection?
  - [ ] Besoin d'une proposition concrète - Peut-être une POC

## 4. Processus et gouvernance à mettre en place (externe au configurateur)

- Processus de gestion de la gamme de couleurs offertes à mettre en place, impliquant Marketing et Appro.
- Processus à mettre en place pour s'assurer d'avoir un lisse et un embossé de chaque acier.

Questions à clarifier:
- [ ] Définir précisément le processus de gouvernance des couleurs.
- [ ] Expliquer le processus de gestion de la gamme de couleurs offertes.
- [ ] Expliquer si `lisse` et `embossé` sont des caractéristiques du SKU d'acier.
- [ ] Clarifier le processus garantissant la disponibilité de chaque fini.
- [ ] Clarifier le processus à mettre en place pour s'assurer d'avoir un lisse et un embossé de chaque acier.

## 6. Saisie des quantités et liste de coupe

- Saisie de la quantité en pi² ou par liste de coupe ou nombre de panneaux.

Questions à clarifier:
- [ ] Élaborer sur le besoin de chacun des cas

## 7. Prix et affichage

- On voudrait que le prix au pi² s'actualise au fil des sélections.
- L'actualisation du prix est possiblement disponible seulement une fois toutes les configurations sélectionnées.
- Permettre de spécifier qu'on veut que le prix du butyle soit inclus dans le prix du panneau, pas sur une ligne séparée.
- Prix final affiché seulement; pas besoin du détail.
- Possibilité de connaître la version de prix des révisions antérieures.
- À valider: débat sur le calcul du prix.

Questions à clarifier:
- [ ] Est-ce qu'on a un prix nominal en bas de la quantité minimale ou au seuil de celle-ci?
- [ ] Est-ce qu'on doit garder toutes les versions de prix pour consultation antérieure?

## 8. Avertissements et validations UX

- Les avertissements sur les limitations de quantité minimum à soumissionner devront être visibles.
- Valider la pertinence d'avoir un bouton au début du cycle pour **Panneau INT** ou **Panneau EXT**.

Questions à clarifier:
- [ ] Est-ce que la limitation selon la quantité minimale est informative ou stricte?
- [ ] Clarifier l'objectif du bouton 'Panneau INT' ou 'Panneau EXT'

## 9. Références

- 

## 10. Réunion non-conformités avec Ludovik
- Configuration de panneau qui ne se faisait pas
  - 4" et 22 ga extérieur sans profil intérieur
  - il y a eu des modification à la main directement dans Epicor
  - ce qui aurait pu aider ça aurait été un garde-fou dans Nplan par exemple

- Profil séville n'est pas dans le système de configuration
  - Il faut changer manuellement et c'est sujet à erreur
  - C'est un changement à faire dans le configurateur
