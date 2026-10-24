# Simulacion de estrategias de apuestas en la ruleta europea (37 numeros)
# Probabilidad y Estadistica, 2do semestre 2026

# La ruleta tiene 37 resultados: los numeros del 1 al 36 y el cero.
# 18 son rojos, 18 son negros; el cero no es ni rojo ni negro.

tirada_ruleta <- function() {
  sample(c("rojo", "negro", "cero"), size = 1, prob = c(18/37, 18/37, 1/37))
}

# ─── Estrategia 1: apuesta fija ──────────────────────────────────────────────
# El jugador siempre apuesta 1 ficha al rojo.

sim_apuesta_fija <- function(n, capital_inicial, apuesta_maxima) {
  capital  <- capital_inicial
  apuestas <- numeric(0)

  for (i in seq_len(n)) {
    if (capital < 1) break

    resultado <- tirada_ruleta()
    apuestas  <- c(apuestas, 1)

    if (resultado == "rojo") {
      capital <- capital + 1
    } else {
      capital <- capital - 1
    }
  }

  list(
    capital_final = capital,
    ganancia_neta = capital - capital_inicial,
    apuestas      = apuestas
  )
}

# ─── Estrategia 2a: duplicacion con limite, opcion 1 ─────────────────────────
# Si la proxima apuesta superaria el limite m, el dia termina.

sim_duplicacion_op1 <- function(n, capital_inicial, apuesta_maxima) {
  capital  <- capital_inicial
  apuestas <- numeric(0)
  apuesta  <- 1

  for (i in seq_len(n)) {
    if (capital < apuesta) break

    resultado <- tirada_ruleta()
    apuestas  <- c(apuestas, apuesta)

    if (resultado == "rojo") {
      capital <- capital + apuesta
      apuesta <- 1
    } else {
      capital   <- capital - apuesta
      siguiente <- apuesta * 2
      if (siguiente > apuesta_maxima) break  # opcion 1: se termina el dia
      apuesta <- siguiente
    }
  }

  list(
    capital_final = capital,
    ganancia_neta = capital - capital_inicial,
    apuestas      = apuestas
  )
}

# ─── Estrategia 2b: duplicacion con limite, opcion 2 ─────────────────────────
# Si la proxima apuesta superaria el limite m, vuelve a apostar 1 ficha.

sim_duplicacion_op2 <- function(n, capital_inicial, apuesta_maxima) {
  capital  <- capital_inicial
  apuestas <- numeric(0)
  apuesta  <- 1

  for (i in seq_len(n)) {
    if (capital < apuesta) break

    resultado <- tirada_ruleta()
    apuestas  <- c(apuestas, apuesta)

    if (resultado == "rojo") {
      capital <- capital + apuesta
      apuesta <- 1
    } else {
      capital   <- capital - apuesta
      siguiente <- apuesta * 2
      apuesta   <- if (siguiente > apuesta_maxima) 1 else siguiente  # opcion 2
    }
  }

  list(
    capital_final = capital,
    ganancia_neta = capital - capital_inicial,
    apuestas      = apuestas
  )
}

# ─── Estrategia 3: ciclo dinamico ────────────────────────────────────────────
# Lista inicial con suma = 10 fichas.

LISTA_CICLO <- c(1, 2, 1, 2, 1, 2, 1)

# Calcula la apuesta: suma de extremos (o el unico elemento si queda uno).
apuesta_ciclo <- function(lista) {
  if (length(lista) == 1) lista[1] else lista[1] + lista[length(lista)]
}

# Actualiza la lista segun el resultado:
#   Gano -> tacha los dos extremos (o el unico elemento).
#   Perdio -> agrega el monto apostado al final.
actualizar_lista <- function(lista, apuesta, gano) {
  if (gano) {
    if (length(lista) <= 2) numeric(0) else lista[-c(1, length(lista))]
  } else {
    c(lista, apuesta)
  }
}

# ─── Estrategia 3a: ciclo dinamico, opcion 1 ─────────────────────────────────
# El dia termina si: lista vacia, apuesta > capital o apuesta > m.

sim_ciclo_op1 <- function(n, capital_inicial, apuesta_maxima) {
  capital  <- capital_inicial
  apuestas <- numeric(0)
  lista    <- LISTA_CICLO

  for (i in seq_len(n)) {
    if (length(lista) == 0) break

    apuesta <- apuesta_ciclo(lista)
    if (apuesta > capital || apuesta > apuesta_maxima) break

    resultado <- tirada_ruleta()
    apuestas  <- c(apuestas, apuesta)
    gano      <- (resultado == "rojo")
    capital   <- capital + ifelse(gano, apuesta, -apuesta)
    lista     <- actualizar_lista(lista, apuesta, gano)
  }

  list(
    capital_final = capital,
    ganancia_neta = capital - capital_inicial,
    apuestas      = apuestas
  )
}

# ─── Estrategia 3b: ciclo dinamico, opcion 2 ─────────────────────────────────
# Cuando la lista queda vacia, reinicia con la lista inicial.
# El dia termina al llegar a n tiradas o si apuesta > capital o apuesta > m.

sim_ciclo_op2 <- function(n, capital_inicial, apuesta_maxima) {
  capital  <- capital_inicial
  apuestas <- numeric(0)
  lista    <- LISTA_CICLO

  for (i in seq_len(n)) {
    if (length(lista) == 0) lista <- LISTA_CICLO

    apuesta <- apuesta_ciclo(lista)
    if (apuesta > capital || apuesta > apuesta_maxima) break

    resultado <- tirada_ruleta()
    apuestas  <- c(apuestas, apuesta)
    gano      <- (resultado == "rojo")
    capital   <- capital + ifelse(gano, apuesta, -apuesta)
    lista     <- actualizar_lista(lista, apuesta, gano)
  }

  list(
    capital_final = capital,
    ganancia_neta = capital - capital_inicial,
    apuestas      = apuestas
  )
}
