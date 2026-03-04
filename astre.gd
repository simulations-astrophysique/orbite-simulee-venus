extends RigidBody3D

@export var centre_rotation : RigidBody3D
@export var periode_relative : float

@export_group("Paramètre de conversion simulation")
@export var min_distance_simulee : float
@export var max_distance_simulee : float
@export var min_distance_reelle : float
@export var max_distance_reelle : float

@export_group("Simulation gravitationnelle")
@export var masse : float
@export var masse_corps_rotation : float
@export var rayon_initial : float

@export_group("Paramètres de la méthode d'Euler")
@export var etapes_calcul_par_ecran : int

# Groupe de variable masquées pour les calculs
var G : float = 6.673e-11
var r_i : Vector3
var v_i : Vector3
var periode : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	r_i = rayon_initial * Vector3(1, 0, 0)
	position = conv_position_reelle_a_simulee(r_i)
	
	var vitesse_initiale  = sqrt(G * masse_corps_rotation / rayon_initial) # De la loi de Kepler
	v_i = vitesse_initiale * Vector3(0, 0, 1)
	
	periode = 2 * PI * rayon_initial / vitesse_initiale
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Calcule la position réelle
	appliquer_euler(delta)
	# Converti la position
	position = conv_position_reelle_a_simulee(r_i)

	if centre_rotation != null:
		position += centre_rotation.position

func conv_position_reelle_a_simulee(position_reelle : Vector3) -> Vector3:
	"""Effectue la conversion d'une position réelle à une position de l'espace 
	de la simulation
	
	Paramètres:
	position_reelle -- la position réelle à convertir
	
	Retour :
	la position dans le monde de la simulation à utiliser
	"""
	
	var distance_relle = position_reelle.length()
	var ratio_distance = inverse_lerp(min_distance_reelle, max_distance_reelle, 
		distance_relle)
	var facteur_distance_simulee = lerp (min_distance_simulee, max_distance_simulee,
		 ratio_distance)
	
	return position_reelle.normalized() * facteur_distance_simulee

func calculer_acceleration_gravitationnelle(position_rellee: Vector3) -> Vector3:
	"""Calcule l'accélération gravitationnelle exercée sur le corps selon sa position
	
	Paramètre:
	position_reelle : sa position dans l'espace en m
	
	Retour:
	L'accélération gravitationnelle exercée sur le corps en m/s^2
	"""
	var facteur = -G * masse * masse_corps_rotation / (position_rellee.length()**3)
	var force = (position_rellee - centre_rotation.position) * facteur
	return force / masse

func appliquer_euler(temps_dernier_ecran : float) -> void:
	"""
	Applique la méthode d'Euler pour déterminer la position et la vitesse selon le temps de rendu
	de la simulation.
		
	Paramètre :
	temps_dernier_ecran -- le temps écoulé depuis le dernier écran.
	"""
	#Nombre de période à simuler dans l'écran
	var nb_periode = temps_dernier_ecran  * periode / periode_relative
	#Pas de la simulation
	var h = nb_periode / etapes_calcul_par_ecran
		
	for i in range(etapes_calcul_par_ecran):
		var a_i = calculer_acceleration_gravitationnelle(r_i)
		
		var r_i_plus_1 = r_i + h * v_i
		var v_i_plus_1 = v_i + h * a_i
		
		r_i = r_i_plus_1
		v_i = v_i_plus_1
