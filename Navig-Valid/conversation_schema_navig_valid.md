# Séparation entre structure produit et logique de configuration

## But du document

Ce document capture l’état actuel de la réflexion afin de pouvoir poursuivre la conversation dans un autre contexte sans perdre les nuances déjà acquises.

L’objectif principal est de **séparer clairement** :

1. la **structure du produit**,
2. la **structure des options acier**,
3. la **logique de configuration**,
4. la **logique de sélection des aciers**.

Ce document conserve aussi une nuance devenue centrale : **la logique de configuration inclut la structure du produit, mais ne doit pas être confondue avec elle**.

---

## Compréhension acquise à partir du diagramme

Le diagramme observé ne décrit pas seulement une arborescence de produit. Il décrit aussi un **schéma logique de configuration**.

### Ce que le diagramme contient

- une **structure d’offre de produit** allant de familles comme **Norex / Noroc** jusqu’à des attributs tels que la **largeur** et l’**épaisseur** du panneau ;
- une **structure de sélection de l’acier**, applicable pour la **face intérieure** puis pour la **face extérieure** ;
- une série de **règles métier**, exprimées surtout dans les **encadrés jaunes** ;
- un **flux de configuration** qui guide les choix ;
- des **dépendances entre attributs** et des restrictions selon les familles de produit ;
- une fin de parcours menant à un choix complet puis à un enregistrement.

### Distinction importante retenue

Le point clé de la discussion est le suivant :

- la **structure du produit** décrit **ce que le produit est** ;
- la **logique de configuration** décrit **comment on guide, filtre, contraint et enchaîne les choix**.

La logique de configuration est **dictée par** la structure du produit, mais ce sont **deux choses différentes**.

Formulation retenue :

- **structure produit** = référentiel / modèle des produits possibles ;
- **logique de configuration** = comportement du configurateur.

---

## Position conceptuelle actuelle

### 1. Structure produit

La structure produit doit être représentée **indépendamment** de la logique de configuration.

Elle doit être suffisamment riche pour informer sur les **produits réellement possibles**, et non seulement sur une liste plate d’attributs.

Elle devrait donc contenir :

- familles, types, sous-types, variantes ;
- attributs pertinents ;
- valeurs possibles pour ces attributs ;
- compatibilités intrinsèques entre attributs ;
- contraintes qui définissent l’espace réel des produits fabricables.

### 2. Structure acier

La structure des aciers disponibles doit elle aussi être représentée indépendamment.

Elle peut être portée par une structure dédiée décrivant :

- les options acier ;
- leurs propriétés ;
- les côtés applicables (intérieur / extérieur) ;
- les classifications utiles (fini, couleur, texture, revêtement, etc.).

### 3. Logique de configuration produit

Cette logique doit être exprimée **de façon générale**, idéalement sans être collée aux valeurs concrètes contenues dans la structure produit.

Elle doit plutôt exprimer :

- l’ordre des étapes ;
- les dépendances entre étapes ;
- les règles de filtrage génériques ;
- les validations de parcours ;
- les références vers les données structurées.

### 4. Logique de configuration acier

Même principe que pour la logique produit, mais appliqué à la sélection des aciers.

Elle doit pouvoir exprimer, de façon générique :

- le parcours de sélection intérieur / extérieur ;
- les filtrages applicables ;
- les dépendances éventuelles avec le produit ou avec l’acier déjà choisi sur l’autre face ;
- la validation de compatibilité finale.

---

## Nuance importante acquise pendant la discussion

Une clarification importante a été obtenue :

### Le schéma 1 ne doit pas être trop superficiel

Le schéma 1, celui de la **structure produit**, ne doit pas se limiter à une description légère des attributs.

Il doit être **plus profond** et, par son contenu, **bien informer sur les produits possibles**.

Cela signifie que la structure produit devrait inclure, par ses données :

- les compatibilités entre attributs ;
- les combinaisons valides ;
- les contraintes intrinsèques au produit.

Autrement dit, la structure produit doit décrire **l’espace des possibilités produit**.

### Répartition conceptuelle retenue

- **Compatibilités métier natives** → dans la **structure produit** ;
- **Ordre des choix, comportement, affichage, guidage** → dans la **logique de configuration**.

Question à laquelle répond le schéma 1 :

> **Quels produits peuvent réellement exister ?**

Question à laquelle répond la logique de configuration :

> **Comment guide-t-on l’utilisateur vers un produit valide ?**

---

## Vision cible des schémas JSON

L’idée actuelle est de pouvoir représenter séparément plusieurs structures JSON.

## Schéma 1 — Structure produit

### Rôle
Décrire les **produits possibles** de façon suffisamment riche pour porter la vérité métier produit.

### Orientation retenue pour la suite

Pour la **structure produit seulement**, l'orientation retenue est maintenant une structure **plus simple et plus directe**, centrée sur le **produit commercial configurable**.

Autrement dit, au lieu de modéliser d'abord une hiérarchie générique `famille -> catégorie -> variante`, on représente directement chaque produit offert, avec ses contraintes intrinsèques.

### Il doit contenir

- les familles ;
- les produits configurables ;
- les attributs utiles à la définition réelle du produit ;
- les combinaisons valides ;
- les compatibilités intrinsèques entre attributs ;
- les contraintes propres au produit.

### Exemple de direction

```json
{
  "panelCatalog": {
    "generalInfo": {
      "id": "nai-panel-catalog-v1",
      "name": "Catalogue simplifie des panneaux NAI"
    },
    "products": [
      {
        "family": "norex",
        "id": "norex-l",
        "label": "Norex L",
        "widths": [
          {
            "width": 42.5,
            "thicknesses": [2, 3, 4, 5, 6, 8]
          },
          {
            "width": 36.0,
            "thicknesses": [3, 4]
          }
        ]
      },
      {
        "family": "norex",
        "id": "norex-h",
        "label": "Norex H",
        "characteristics": ["anti-slip"],
        "widths": [
          {
            "width": 41.5,
            "thicknesses": [3, 4]
          },
          {
            "width": 36.0,
            "thicknesses": [3, 4]
          }
        ]
      }
    ]
  }
}
```

### Intention retenue

Ce schéma doit, **par son contenu**, bien informer sur les produits possibles, sans imposer une hiérarchie plus abstraite que nécessaire.

### Conséquence de modélisation

Dans cette orientation simplifiée :

- la hiérarchie produit est **encodée directement dans les identités de produits offerts** ;
- les compatibilités natives restent **dans la structure produit** ;
- on évite d'introduire des niveaux `catégorie` / `variante` tant qu'ils n'apportent pas de valeur métier claire.

---

## Schéma 2 — Structure des aciers

### Rôle
Décrire le catalogue des options acier indépendamment du produit et indépendamment du parcours de configuration.

### Il doit contenir

- les options acier ;
- leurs propriétés ;
- leur côté applicable ;
- leurs classifications utiles.

### Exemple de direction

```json
{
  "steelCatalog": {
    "id": "steel-catalog-v1",
    "sides": ["interior", "exterior"],
    "steelOptions": [
      {
        "id": "steel-white-smooth",
        "label": "Blanc lisse",
        "properties": {
          "materialFamily": "steel",
          "finish": "smooth",
          "color": "white",
          "coating": "standard"
        },
        "applicableSides": ["interior", "exterior"],
        "tags": ["standard"]
      },
      {
        "id": "steel-embossed-gray",
        "label": "Gris embossé",
        "properties": {
          "materialFamily": "steel",
          "finish": "embossed",
          "color": "gray",
          "coating": "premium"
        },
        "applicableSides": ["exterior"]
      }
    ],
    "propertyDefinitions": {
      "finish": ["smooth", "embossed"],
      "color": ["white", "gray", "black"],
      "coating": ["standard", "premium"]
    }
  }
}
```

---

## Schéma 3 — Logique de configuration produit

### Rôle
Décrire le comportement général du configurateur produit, sans faire porter à cette logique la définition intrinsèque des produits possibles.

### Il doit contenir

- les étapes ;
- les dépendances entre étapes ;
- les règles génériques de filtrage ;
- les références vers la structure produit.

### Exemple de direction

```json
{
  "productConfigurationLogic": {
    "id": "product-config-logic-v1",
    "contextType": "product",
    "steps": [
      {
        "id": "select-family",
        "label": "Choisir la famille",
        "bindsTo": "family"
      },
      {
        "id": "select-category",
        "label": "Choisir la catégorie",
        "bindsTo": "category",
        "dependsOn": ["family"]
      },
      {
        "id": "select-variant",
        "label": "Choisir la variante",
        "bindsTo": "variant",
        "dependsOn": ["family", "category"]
      },
      {
        "id": "select-width",
        "label": "Choisir la largeur",
        "bindsTo": "width",
        "dependsOn": ["variant"]
      },
      {
        "id": "select-thickness",
        "label": "Choisir l'épaisseur",
        "bindsTo": "thickness",
        "dependsOn": ["variant", "width"]
      }
    ],
    "rules": [
      {
        "id": "rule-width-from-variant",
        "type": "derive-allowed-values",
        "target": "width",
        "source": "productModel.variant.attributes.width"
      },
      {
        "id": "rule-thickness-from-variant",
        "type": "derive-allowed-values",
        "target": "thickness",
        "source": "productModel.variant.attributes.thickness"
      },
      {
        "id": "rule-thickness-after-width",
        "type": "filter",
        "target": "thickness",
        "when": {
          "all": [
            { "field": "variant", "operator": "isSelected" },
            { "field": "width", "operator": "isSelected" }
          ]
        },
        "action": {
          "strategy": "applyCompatibilityRules",
          "source": "productModel.compatibilityRules"
        }
      }
    ]
  }
}
```

### Intention retenue

Cette logique doit exprimer **le parcours** et **l’utilisation générale des données**, mais ne pas devenir le dépôt principal de la vérité métier produit.

---

## Schéma 4 — Logique de configuration acier

### Rôle
Décrire le comportement général de sélection des aciers pour les faces intérieure et extérieure.

### Il doit contenir

- l’ordre des choix ;
- les dépendances ;
- les filtrages génériques ;
- les références au catalogue acier ;
- les validations de compatibilité avec le contexte produit et/ou l’autre face.

### Exemple de direction

```json
{
  "steelConfigurationLogic": {
    "id": "steel-config-logic-v1",
    "contextType": "steelSelection",
    "steps": [
      {
        "id": "select-interior-steel",
        "label": "Choisir l'acier intérieur",
        "bindsTo": "interiorSteel"
      },
      {
        "id": "select-exterior-steel",
        "label": "Choisir l'acier extérieur",
        "bindsTo": "exteriorSteel",
        "dependsOn": ["interiorSteel"]
      }
    ],
    "rules": [
      {
        "id": "rule-interior-side-filter",
        "type": "filter",
        "target": "interiorSteel",
        "action": {
          "strategy": "filterCatalog",
          "catalogRef": "steelCatalog",
          "criteria": [
            { "field": "applicableSides", "operator": "contains", "value": "interior" }
          ]
        }
      },
      {
        "id": "rule-exterior-side-filter",
        "type": "filter",
        "target": "exteriorSteel",
        "action": {
          "strategy": "filterCatalog",
          "catalogRef": "steelCatalog",
          "criteria": [
            { "field": "applicableSides", "operator": "contains", "value": "exterior" }
          ]
        }
      },
      {
        "id": "rule-product-steel-compatibility",
        "type": "filter",
        "target": "exteriorSteel",
        "when": {
          "all": [
            { "field": "product.variant", "operator": "isSelected" },
            { "field": "interiorSteel", "operator": "isSelected" }
          ]
        },
        "action": {
          "strategy": "applyCompatibilityRules",
          "source": "productSteelCompatibility"
        }
      }
    ]
  }
}
```

---

## Synthèse architecturale actuelle

La séparation visée à ce stade de la discussion est la suivante.

### Référentiels métier

- `panelCatalog.json`
- `steelCatalog.json`

### Logiques de comportement

- `productConfigurationLogic.json`
- `steelConfigurationLogic.json`

### Principe directeur

- les **valeurs métier** et **possibilités réelles** vivent dans les référentiels ;
- les **compatibilités natives produit** vivent dans le schéma produit ;
- les **règles de parcours** vivent dans les logiques de configuration ;
- le **moteur de configuration** lit ces structures de façon générique.

---

## Position la plus importante à conserver pour la suite

La formulation la plus importante à retenir est probablement celle-ci :

> La **structure du produit** et la **logique de configuration** sont liées, mais doivent rester **indépendantes**.
>
> La structure produit doit informer sur les **produits possibles**.
>
> La logique de configuration doit informer sur le **parcours de décision** permettant d’aboutir à un produit valide.

Ou encore :

- **Schéma 1** = modèle des possibilités produit ;
- **Schéma 2** = modèle des possibilités acier ;
- **Schéma 3** = modèle générique du parcours de configuration produit ;
- **Schéma 4** = modèle générique du parcours de configuration acier.

Pour la partie produit, le **Schéma 1** n'a donc pas besoin d'être un mini méta-modèle hiérarchique. Il peut être un catalogue simple des produits configurables tant qu'il conserve correctement les contraintes intrinsèques.

---

## Prochaine étape naturelle

La prochaine étape logique serait de formaliser ces schémas sous forme d’un **mini méta-modèle cohérent**, avec une structure uniforme pour :

- les entités,
- les attributs,
- les références,
- les règles,
- les compatibilités,
- les dépendances,
- les sources de données.

Cela permettrait ensuite de passer à une version plus stable et exploitable techniquement.
