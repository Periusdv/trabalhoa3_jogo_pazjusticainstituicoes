extends Node

var extintores_pegos: Array = []
var fogos_apagados: Array = []

func resetar_estado():
	extintores_pegos.clear()
	fogos_apagados.clear()
	print("GameManager resetado: tudo restaurado.")

func registrar_extintor_pego(nome: String):
	if nome not in extintores_pegos:
		extintores_pegos.append(nome)

func registrar_fogo_apagado(nome: String):
	if nome not in fogos_apagados:
		fogos_apagados.append(nome)
