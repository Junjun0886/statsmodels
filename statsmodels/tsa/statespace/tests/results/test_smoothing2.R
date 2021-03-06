library(KFAS)
options(digits=10)

# should run this from the statsmodels/statsmodels directory
dta <- read.csv('datasets/macrodata/macrodata.csv')

obs <- diff(log(data.matrix(dta[c('realgdp','realcons','realinv')])))

#T <- t(matrix(
#  c(-0.1119908792, 0.8441841604,  0.0238725303,
#     0.2629347724, 0.4996718412, -0.0173023305,
#    -3.2192369082, 4.1536028244,  0.4514379215), nrow=3, ncol=3))
#Q <- t(matrix(
#  c(0.0000640649, 0.0000388496, 0.0002148769,
#    0.0000388496, 0.0000572802, 0.000001555,
#    0.0002148769, 0.000001555,  0.0017088585), nrow=3, ncol=3))
#H <- matrix(0, 3, 3)
T <- t(matrix(
  c(-0.1119908792, 0.8441841604,  0.0238725303,
     0.2629347724, 0.4996718412, -0.0173023305,
    -3.2192369082, 4.1536028244,  0.4514379215), nrow=3, ncol=3))
Q <- t(matrix(
  c(0.0000640649, 0.0000388496, 0.0002148769,
    0.0000388496, 0.0000572802, 0.000001555,
    0.0002148769, 0.000001555,  0.0017088585), nrow=3, ncol=3))
H <- t(matrix(
  c(0.0000640649, 0.,           0.,
    0.,           0.0000572802, 0.,
    0.,           0.,           0.0017088585), nrow=3, ncol=3))

mod <- SSModel(obs ~ -1 + SSMcustom(Z=diag(3), T=T, R=diag(3), Q=Q, P1=diag(3)*1e6),  H=H)
kf <- KFS(mod, c("state", "signal", "mean"), c("state", "signal", "mean", "disturbance"), simplify=FALSE)

# kf$logLik # 1695.34872

# r = scaled_smoothed_estimator
# N = scaled_smoothed_estimator_cov
# m = forecasts
# v = forecasts_error
# F = forecasts_error_cov
# a = predicted_state
# P = predicted_state_cov
# mu = filtered_forecasts
# alphahat = smoothed_state
# V = smoothed_state_cov
# muhat = smoothed_forecasts
# etahat = smoothed_state_disturbance
# V_eta = smoothed_state_disturbance_cov
# epshat = smoothed_measurement_disturbance
# V_eps = smoothed_measurement_disturbance_cov

out <- as.data.frame(with(kf, cbind(
  t(r)[2:203,], apply(N, 3, det)[2:203],
  m, apply(P_mu, 3, det), v, t(F),
  a[2:203,], apply(P, 3, det)[2:203],
  alphahat, apply(V, 3, det),
  muhat, apply(V_mu, 3, det),
  etahat, apply(V_eta, 3, det), epshat, t(V_eps)
)))
names(out) <- c(
  "r1", "r2", "r3", "detN",
  "m1", "m2", "m3", "detPmu",
  "v1", "v2", "v3", "F1", "F2", "F3",
  "a1", "a2", "a3", "detP",
  "alphahat1", "alphahat2", "alphahat3", "detV",
  "muhat1", "muhat2", "muhat3", "detVmu",
  "etahat1", "etahat2", "etahat3", "detVeta",
  "epshat1", "epshat2", "epshat3", "Veps1", "Veps2", "Veps3"
)
write.csv(out, 'tsa/statespace/tests/results/results_smoothing2_R.csv', row.names=FALSE)
