class_name NoteData
extends Resource

@export var title: String
@export_multiline var text: String
@export var important: bool = false
@export var on_read_events: Array[Event]

@export_storage var was_read: bool = false
