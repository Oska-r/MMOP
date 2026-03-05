# Klassenübersicht des MMOP-Projekts

## Übersicht der verwendeten Klassen

Dieses Dokument enthält eine Übersicht aller Klassen im Godot-Projekt, basierend auf GDScript-Dateien und Szenenstrukturen.

### GDScript-Klassen

#### Benannte Klassen (mit `class_name`)

- **DamageSystem**: Statische Klasse für Schadenssystem. Kein explizites `extends` (implizit Object).
- **Damageable**: Erbt von `Node`. Stellt schädigbare Objekte dar.
- **Item**: Erbt von `Resource`. Repräsentiert Items im Spiel.
- **ItemIDs**: Erbt von `Node`. Verwaltet Item-IDs.
- **CraftingRecipe**: Erbt von `Resource`. Definiert Crafting-Rezepte.
- **EnemyTypes**: Erbt von `Node`. Enum für Feindtypen.

#### Andere Skripte (ohne `class_name`)

- **grass.gd**: Erbt von `MultiMeshInstance3D`. Für Gras-Rendering (Addon).
- **plugin.gd**: Erbt von `EditorPlugin`. Plugin für Simple Grass Textured.
- **sgt_inspector.gd**: Erbt von `EditorInspectorPlugin`. Inspektor für das Addon.
- **singleton.gd**: Erbt von `Node3D`. Singleton für das Addon.
- **default_mesh_builder.gd**: Wahrscheinlich erbt von etwas, aber nicht in grep gefunden.
- **rotating_label.gd**: Erbt von `Label3D`. Rotierendes Label.
- **loot_table.gd**: Erbt von `Node`. Loot-Tabellen.
- **crafting.gd**: Erbt von `Node`. Crafting-Komponente.
- **crafting_table_inventory.gd**: Erbt von `ReferenceRect`. Inventar für Crafting-Tisch.
- **SoundManager.gd**: Erbt von `Node`. Sound-Verwaltung.
- **UIHelper.gd**: Erbt von `Node`. UI-Hilfsfunktionen.
- Verschiedene GUI-Skripte im Addon: Erben von Control, AcceptDialog, etc.

### Szenen und Node-Beziehungen

#### Hauptszene (main.tscn)
- Root: `Node3D` mit `main.gd` (nicht in Liste, wahrscheinlich extends Node3D oder Node).
- Instanziiert:
  - `world.tscn` (World)
  - `player.tscn` (Player)
  - `ui.tscn` (UI)
  - `world_environment.tscn` (WorldEnvironment)
- Andere Nodes: AudioStreamPlayer, RichTextLabel mit day_display.gd.

#### Player-Szene (player.tscn)
- Root: `CharacterBody3D` mit `player.gd`.
- Kinder:
  - MeshInstance3D (Mesh)
  - CollisionShape3D (Collider)
  - Node3D (Head) mit Camera3D, RayCast3D, Area3D (Attack_Area)
  - Node (SoundEffects) mit AudioStreamPlayer-Instanzen
  - Timer (AttackTimer)
  - Node (Components) mit:
    - Node (Movement) mit `player_movement.gd`
    - Node (Damageable) mit `damageable.gd`

#### Andere Szenen
- Ähnliche Strukturen für enemy.tscn, objects wie chest.tscn, etc.
- Viele Objekte haben Skripte wie `damageable.gd` attached.

### Vererbungen und Beziehungen
- Vererbung erfolgt hauptsächlich durch `extends` in Skripten.
- In Szenen werden Nodes instanziiert, die Skripte anhängen, wodurch die Klassen verwendet werden.
- Exportierte Nodes sind die Root-Nodes der Szenen, die in anderen Szenen instanziiert werden.

## PlantUML-Diagramm

Das folgende PlantUML-Diagramm zeigt die Vererbungshierarchie der Klassen und einige Beziehungen.

```
@startuml
class Resource
class Node
class Node3D extends Node
class Control extends Node
class AcceptDialog extends Control
class ConfirmationDialog extends Control
class MenuButton extends Control
class Label3D extends Node3D
class ReferenceRect extends Control
class MultiMeshInstance3D extends Node3D
class EditorPlugin
class EditorInspectorPlugin

class Item extends Resource
class CraftingRecipe extends Resource
class DamageSystem
class Damageable extends Node
class ItemIDs extends Node
class EnemyTypes extends Node
class grass extends MultiMeshInstance3D
class plugin extends EditorPlugin
class sgt_inspector extends EditorInspectorPlugin
class singleton extends Node3D
class rotating_label extends Label3D
class loot_table extends Node
class crafting extends Node
class crafting_table_inventory extends ReferenceRect
class SoundManager extends Node
class UIHelper extends Node

' GUI Addon classes
class about extends AcceptDialog
class clear_all_confirmation_dialog extends ConfirmationDialog
class toolbar extends Control
class toolbar_menu extends MenuButton
class global_parameters extends AcceptDialog
class toolbar_up extends Control
class domain_range extends Control

' Associations
DamageSystem --> Damageable : applies damage to
player --> Damageable : has component
world --> Item : uses
crafting --> CraftingRecipe : uses
@enduml
```

Kopiere diesen Code in PlantUML, um das Diagramm zu generieren.
