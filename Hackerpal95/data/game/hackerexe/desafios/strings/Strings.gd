extends Node2D
# Estados de Desafio
enum State {Infecting, Transmitted , Error}
var state_desafio

# Tiempo para cuent regresiva de Desafio
var time = 5
var start_time

# Variable para almacenar la palabra que se Tomará al azar de la lista
var word
var wordcount = 3
var initial_wordcount
# Nodo donde se va  desplegar el texto que se debe transcribir
onready var type_text = $Panel/VBoxContainer/Typetext
onready var msg_text = $Panel/VBoxContainer/Message
onready var pleft_text = $Panel/VBoxContainer/Left

onready var barra_carga = $Panel/VBoxContainer/Container/BarraCarga
# Solo para debug este array sirve para luego selecccionar al azar una dificultad
#var diffarray = ['easy','medium','hard','insane']

# Setter para establecer la dificultad del desafio
var diff = 'hard' setget set_difficulty
func set_difficulty(newvalue):
		diff=newvalue
		
var hackerexe #setget set_hackerexe

func set_hackerexe(object):
	hackerexe = object

# Funcion para obtener un array de palabras dependiendo de la dificultad
func get_words(string):
	var file = File.new()
	file.open("res://data/game/hackerexe/desafios/strings/"+string+".txt", File.READ)
	var lines = []
	while not file.eof_reached():
		lines.append(file.get_line())
	return lines
	
# Funcion para obtener un elemento al azar de un array
func rand_elem(array):
	var elem = array[randi() % array.size()]
	return elem

func semi_shuffle(string):
	var pos1 = randi() % string.length()
	var scancode = randi() % 25 + 66
	string.erase(randi() % string.length(),1)
	return string.insert(pos1,OS.get_scancode_string(scancode))
	
	
func victory():
		state_desafio = State.Transmitted # Cambiamos el estado del desafio
		msg_text.text = 'TRANSMITTED!!' # Ya fue resuelto el desafio
		yield(get_tree().create_timer(0.5), "timeout")
		hackerexe.last_hacked()
		queue_free()

func fail():
		state_desafio = State.Error # Cambiamos al estado error
		type_text.text = 'Error!!!'  # Cambiamos el label a ERROR
		yield(get_tree().create_timer(0.5), "timeout")
		
		if diff == 'insane' or diff == 'hard':
			wordcount = initial_wordcount
			
		reset()
		
func reset():
	randomize()
	# Al inicio establecemos el estado inicial en Infecting
	state_desafio = State.Infecting
	# Para debuggin establecemos una dificultad al azar
	# La idea de este set_diff es para cuando se instancie la escena desde ptra 
	# se establezca la dificultad
	
	# se deberia comentar esta linea  para propositos de juego final
	# set_difficulty(rand_elem(diffarray))
	
	# Asignamos una palabra al azar dependiendo de la dificultad
	word = rand_elem(get_words(diff)).to_upper()
	if word.length() == 0:
		word = rand_elem(get_words(diff)).to_upper()
	
	if diff != 'easy':
		word = semi_shuffle(word)
	# Dependiendo de la dificultad se coloca un time determinado
	match diff:
		'easy': 
			time = 5
		'medium':
			time = 4
		'hard':
			time = 3.5
		'insane':
			time = 3
		
	start_time = time
	
	# Asignamos Los nodos hijos a las variables correspondientes
	
	
	# Establecemos la palabra secleccionada en el texto del label a transcribir
	type_text.text = word
	pleft_text.text = 'Passwords Left: ' + str(wordcount)
	# Set la barra de carga
	barra_carga.set_level(1)
	
func _ready():
#	match diff:
#		'easy': 
#			wordcount = 3
#		'medium':
#			wordcount = 3
#		'hard':
#			wordcount = 3
#		'insane':
#			wordcount = 3
	initial_wordcount = wordcount
	pleft_text.text = 'Passwords Left: ' + str(wordcount)
	reset()

func _input(event):
	if (event is InputEventKey and !event.echo and event.pressed and state_desafio == State.Infecting):
		# Si el evento es una Entrada de Teclad y si acaba de presionar y si olo justo presiona y el estado del desafio es Infecting
		
		if(event.scancode >= 65 and event.scancode <= 90):
			# Aquí es si el codigo ASCII de las letras de la A-Z
			
			#var pressedChar = str(event.scancode)
			var pressedChar = OS.get_scancode_string(event.scancode)
			# Transformamos el codigo ASCII al caracter correspondiente
			
			if (word.begins_with(pressedChar)):
				# Si la primera letra de la palabra es la tecla que presionamos
				word.erase(0,1) # Borramos la primera letra
				type_text.text = word # y cambiamos el label
				match diff:
					'hard': time += 0.1
					'insane': time += 0.05
					
					
				
				# la idea principal es que cada vez que el hacker introduzca bien una letra
				# esta desaparezca del label, quedando las letras siguientes a la palabra
				
				if(word ==''):
					wordcount -= 1
					msg_text.text = 'Now this Password:'
					pleft_text.text = 'Passwords Left: ' + str(wordcount)
					if wordcount == 0:
						# ya para cuando introduzca todas las letras correctas y el string esté vacio
							victory()
					else:
						reset()

			else:
				# Si la primera letra de la palabra NO es la tecla que presionamos
				fail()
				#yield(get_tree().create_timer(1.0), "timeout") # Esperamos un segundo
				#queue_free() # Liberamos la instancia 
				
				# Aquí está el desafio fallido
			
func _process(delta):
	if state_desafio == State.Infecting:
			barra_carga.set_level(time/start_time)
			time -= delta
			
			# timer_text.text = str( "%10.1f" % time)
			
			if time <= 0.0:
				# Ahora si se acaba el tiempo estipulado para el desafio
				fail()
				#yield(get_tree().create_timer(1.0), "timeout")
				## Aqui se deberia emitir una señal para el "NODO, computador" que es hackeado
				## para que cambie su estado de virus transmitido
				##queue_free()
				
				# Aquí está el desafio fallido
	

		

