source("ruleta.R")

# Parametros del trabajo practico
N_TIRADAS   <- 100
CAPITAL     <- 50
APUESTA_MAX <- 64
N_REP       <- 10000

# Lista de estrategias con nombres descriptivos
estrategias <- list(
  "E1: Apuesta fija"         = sim_apuesta_fija,
  "E2a: Duplicacion op.1"    = sim_duplicacion_op1,
  "E2b: Duplicacion op.2"    = sim_duplicacion_op2,
  "E3a: Ciclo dinamico op.1" = sim_ciclo_op1,
  "E3b: Ciclo dinamico op.2" = sim_ciclo_op2
)

# ─── Actividad 3: sesion unica ────────────────────────────────────────────────

cat("=== Actividad 3: sesion unica (n=100, C=50, m=64) ===\n\n")
set.seed(42)

for (nombre in names(estrategias)) {
  r <- estrategias[[nombre]](N_TIRADAS, CAPITAL, APUESTA_MAX)
  cat(sprintf("%-28s | capital final: %3d | ganancia: %+3d | tiradas: %d\n",
              nombre, r$capital_final, r$ganancia_neta, length(r$apuestas)))
}

# ─── Actividad 4: 10000 dias ──────────────────────────────────────────────────

cat("\n=== Actividad 4: 10000 dias (n=100, C=50, m=64) ===\n\n")
set.seed(42)

# Simula nRep dias con la estrategia dada y devuelve un data frame de resultados
simular_dias <- function(fn, n, capital_inicial, apuesta_maxima, nRep) {
  filas <- replicate(nRep, {
    r <- fn(n, capital_inicial, apuesta_maxima)
    c(
      ganancia    = r$ganancia_neta,
      capital_fin = r$capital_final,
      max_apuesta = if (length(r$apuestas) > 0) max(r$apuestas) else 0,
      total_apost = sum(r$apuestas)
    )
  })
  as.data.frame(t(filas))
}

resultados <- lapply(estrategias, simular_dias,
                     n               = N_TIRADAS,
                     capital_inicial = CAPITAL,
                     apuesta_maxima  = APUESTA_MAX,
                     nRep            = N_REP)

# Calcula las 7 metricas solicitadas para cada estrategia
resumir <- function(df) {
  data.frame(
    gan_prom      = round(mean(df$ganancia),            4),
    prop_gana     = round(mean(df$ganancia > 0),        4),
    prop_pierde   = round(mean(df$ganancia < 0),        4),
    prop_ruina    = round(mean(df$capital_fin == 0),    4),
    media_max_ap  = round(mean(df$max_apuesta),         4),
    media_tot_ap  = round(mean(df$total_apost),         4),
    var_ganancia  = round(var(df$ganancia),             4)
  )
}

tabla <- do.call(rbind, lapply(resultados, resumir))
rownames(tabla) <- names(estrategias)

cat("Metricas por estrategia:\n")
print(tabla)

# Histogramas de ganancia neta (un panel por estrategia)
png("histogramas_ganancia.png", width = 1400, height = 900)
par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))
for (nombre in names(resultados)) {
  hist(resultados[[nombre]]$ganancia,
       main   = nombre,
       xlab   = "Ganancia neta",
       ylab   = "Frecuencia",
       col    = "steelblue",
       border = "white",
       breaks = 40)
  abline(v = 0, col = "red", lty = 2, lwd = 1.5)
}
dev.off()

# Histogramas de total apostado por dia
png("histogramas_apostado.png", width = 1400, height = 900)
par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))
for (nombre in names(resultados)) {
  hist(resultados[[nombre]]$total_apost,
       main   = nombre,
       xlab   = "Total apostado",
       ylab   = "Frecuencia",
       col    = "darkorange",
       border = "white",
       breaks = 40)
}
dev.off()

cat("\nHistogramas guardados en histogramas_ganancia.png y histogramas_apostado.png\n")

# ─── Actividad 5: efecto del limite de apuesta en E2a ────────────────────────

cat("\n=== Actividad 5: efecto de la apuesta maxima en E2a ===\n\n")
set.seed(42)

m_valores <- c(8, 16, 32, 64)

tabla_m <- do.call(rbind, lapply(m_valores, function(m) {
  df <- simular_dias(sim_duplicacion_op1, N_TIRADAS, CAPITAL, m, N_REP)
  data.frame(
    m           = m,
    gan_prom    = round(mean(df$ganancia),         4),
    prop_gana   = round(mean(df$ganancia > 0),     4),
    prop_ruina  = round(mean(df$capital_fin == 0), 4)
  )
}))
rownames(tabla_m) <- NULL

cat("Efecto de m (E2a, n=100, C=50):\n")
print(tabla_m)

# Grafico de lineas: los 3 indicadores en funcion de m
png("efecto_apuesta_maxima.png", width = 1000, height = 400)
par(mfrow = c(1, 3), mar = c(4, 4, 3, 1))

plot(tabla_m$m, tabla_m$gan_prom, type = "b", pch = 16,
     xlab = "Apuesta maxima (m)", ylab = "Fichas",
     main = "Ganancia promedio",
     col  = "steelblue")

plot(tabla_m$m, tabla_m$prop_gana, type = "b", pch = 16,
     xlab = "Apuesta maxima (m)", ylab = "Proporcion",
     main = "Proporcion de dias ganadores",
     col  = "darkgreen", ylim = c(0, 1))

plot(tabla_m$m, tabla_m$prop_ruina, type = "b", pch = 16,
     xlab = "Apuesta maxima (m)", ylab = "Proporcion",
     main = "Proporcion que pierde todo",
     col  = "firebrick", ylim = c(0, 1))

dev.off()

cat("Grafico guardado en efecto_apuesta_maxima.png\n")
