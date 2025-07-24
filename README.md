Prototipo Digimon Arena


Descripción General

Prototipo de combate 1 vs 1 por rondas acumulativas.
El jugador controla un personaje y enfrenta a un enemigo con inteligencia artificial básica.
Cada vez que el jugador gana, avanza de ronda. Si pierde, se reinicia desde la ronda 1.


Controles

Mouse izquierdo: moverse
Barra espaciadora: detener al personaje
Teclas 1 a 4: usar habilidades


Entorno y objetos

Hay cajas y árboles en el escenario:
Las cajas tienen 100 de vida y pueden romperse
Los árboles y decoraciones tienen 10.000 de vida a modo de ejemplo, para que no se rompan fácilmente
Todos los objetos del entorno tienen colisiones reales según su forma
Desde Godot podés activar las colisiones visuales en el menú Depurar → Ver formas de colisión


Sonido

Cada proyectil genera sonido de impacto al chocar con:
  El entorno
  El enemigo
  El jugador
Al lanzar un ataque, tanto el enemigo como el jugador emiten un sonido de casteo
El ataque tiene un ligero retraso para simular el tiempo de casteo


IA del enemigo

El enemigo merodea si no ve al jugador
Tiene un rango de visión de 200 y un rango de ataque de 150
Si el jugador está dentro de rango de ataque (150):
Intenta usar skills ofensivas (1 o 2) si no están en cooldown
Si el jugador está fuera de los 150 pero dentro del rango de visión:
Puede usar buffs como curarse o acelerarse (skills 3 o 4)
Mientras merodea, hay un 20% de probabilidad de que use estos buffs si están disponibles
Todos los skills tienen cooldown individual

Ejecutables


En la carpeta exports/ vas a encontrar los ejecutables:
  Linux/ → versión para Linux
  Windows/ → versión para Windows

