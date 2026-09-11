/-
 EG203DirectPrimeWitness1500.lean — 2026-06-01

 KERNEL-CHECKED DIRECT PRIME WITNESSES for Erdős-Graham #203 over (1000, 1500].

 166 ordinary m, each with explicit (k, l) such that:
 Nat.Prime (m * 2^k * 3^l + 1)

 Combined with EG203DirectPrimeWitness1000 (333 witnesses for m ≤ 1000),
 total coverage: 499 ordinary m kernel-verified.

 NO SORRY. NO ADMIT. NO NOVEL AXIOM.
-/

import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Tactic

namespace EG203DirectPrimeWitness1500

def V (m k l : Nat) : Nat := m * 2 ^ k * 3 ^ l + 1

theorem prime_m1003 : Nat.Prime (V 1003 2 0) := by unfold V; native_decide
theorem prime_m1007 : Nat.Prime (V 1007 1 1) := by unfold V; native_decide
theorem prime_m1009 : Nat.Prime (V 1009 2 1) := by unfold V; native_decide
theorem prime_m1013 : Nat.Prime (V 1013 1 0) := by unfold V; native_decide
theorem prime_m1015 : Nat.Prime (V 1015 1 1) := by unfold V; native_decide
theorem prime_m1019 : Nat.Prime (V 1019 1 0) := by unfold V; native_decide
theorem prime_m1021 : Nat.Prime (V 1021 1 2) := by unfold V; native_decide
theorem prime_m1025 : Nat.Prime (V 1025 1 1) := by unfold V; native_decide
theorem prime_m1027 : Nat.Prime (V 1027 1 1) := by unfold V; native_decide
theorem prime_m1031 : Nat.Prime (V 1031 1 0) := by unfold V; native_decide
theorem prime_m1033 : Nat.Prime (V 1033 1 1) := by unfold V; native_decide
theorem prime_m1037 : Nat.Prime (V 1037 3 0) := by unfold V; native_decide
theorem prime_m1039 : Nat.Prime (V 1039 2 0) := by unfold V; native_decide
theorem prime_m1043 : Nat.Prime (V 1043 1 0) := by unfold V; native_decide
theorem prime_m1045 : Nat.Prime (V 1045 1 1) := by unfold V; native_decide
theorem prime_m1049 : Nat.Prime (V 1049 1 0) := by unfold V; native_decide
theorem prime_m1051 : Nat.Prime (V 1051 1 2) := by unfold V; native_decide
theorem prime_m1055 : Nat.Prime (V 1055 1 0) := by unfold V; native_decide
theorem prime_m1057 : Nat.Prime (V 1057 1 1) := by unfold V; native_decide
theorem prime_m1061 : Nat.Prime (V 1061 1 1) := by unfold V; native_decide
theorem prime_m1063 : Nat.Prime (V 1063 1 1) := by unfold V; native_decide
theorem prime_m1067 : Nat.Prime (V 1067 1 2) := by unfold V; native_decide
theorem prime_m1069 : Nat.Prime (V 1069 2 1) := by unfold V; native_decide
theorem prime_m1073 : Nat.Prime (V 1073 1 3) := by unfold V; native_decide
theorem prime_m1075 : Nat.Prime (V 1075 1 1) := by unfold V; native_decide
theorem prime_m1079 : Nat.Prime (V 1079 1 2) := by unfold V; native_decide
theorem prime_m1081 : Nat.Prime (V 1081 2 1) := by unfold V; native_decide
theorem prime_m1085 : Nat.Prime (V 1085 1 2) := by unfold V; native_decide
theorem prime_m1087 : Nat.Prime (V 1087 2 0) := by unfold V; native_decide
theorem prime_m1091 : Nat.Prime (V 1091 1 1) := by unfold V; native_decide
theorem prime_m1093 : Nat.Prime (V 1093 2 0) := by unfold V; native_decide
theorem prime_m1097 : Nat.Prime (V 1097 1 3) := by unfold V; native_decide
theorem prime_m1099 : Nat.Prime (V 1099 2 0) := by unfold V; native_decide
theorem prime_m1103 : Nat.Prime (V 1103 1 0) := by unfold V; native_decide
theorem prime_m1105 : Nat.Prime (V 1105 2 0) := by unfold V; native_decide
theorem prime_m1109 : Nat.Prime (V 1109 1 2) := by unfold V; native_decide
theorem prime_m1111 : Nat.Prime (V 1111 1 5) := by unfold V; native_decide
theorem prime_m1115 : Nat.Prime (V 1115 1 1) := by unfold V; native_decide
theorem prime_m1117 : Nat.Prime (V 1117 1 1) := by unfold V; native_decide
theorem prime_m1121 : Nat.Prime (V 1121 1 0) := by unfold V; native_decide
theorem prime_m1123 : Nat.Prime (V 1123 2 0) := by unfold V; native_decide
theorem prime_m1127 : Nat.Prime (V 1127 1 1) := by unfold V; native_decide
theorem prime_m1129 : Nat.Prime (V 1129 2 0) := by unfold V; native_decide
theorem prime_m1133 : Nat.Prime (V 1133 1 0) := by unfold V; native_decide
theorem prime_m1135 : Nat.Prime (V 1135 1 2) := by unfold V; native_decide
theorem prime_m1139 : Nat.Prime (V 1139 2 1) := by unfold V; native_decide
theorem prime_m1141 : Nat.Prime (V 1141 2 1) := by unfold V; native_decide
theorem prime_m1145 : Nat.Prime (V 1145 1 1) := by unfold V; native_decide
theorem prime_m1147 : Nat.Prime (V 1147 1 1) := by unfold V; native_decide
theorem prime_m1151 : Nat.Prime (V 1151 1 1) := by unfold V; native_decide
theorem prime_m1153 : Nat.Prime (V 1153 3 1) := by unfold V; native_decide
theorem prime_m1157 : Nat.Prime (V 1157 3 0) := by unfold V; native_decide
theorem prime_m1159 : Nat.Prime (V 1159 2 0) := by unfold V; native_decide
theorem prime_m1163 : Nat.Prime (V 1163 1 4) := by unfold V; native_decide
theorem prime_m1165 : Nat.Prime (V 1165 1 1) := by unfold V; native_decide
theorem prime_m1169 : Nat.Prime (V 1169 1 0) := by unfold V; native_decide
theorem prime_m1171 : Nat.Prime (V 1171 1 1) := by unfold V; native_decide
theorem prime_m1175 : Nat.Prime (V 1175 1 0) := by unfold V; native_decide
theorem prime_m1177 : Nat.Prime (V 1177 1 2) := by unfold V; native_decide
theorem prime_m1181 : Nat.Prime (V 1181 2 1) := by unfold V; native_decide
theorem prime_m1183 : Nat.Prime (V 1183 2 0) := by unfold V; native_decide
theorem prime_m1187 : Nat.Prime (V 1187 3 0) := by unfold V; native_decide
theorem prime_m1189 : Nat.Prime (V 1189 3 1) := by unfold V; native_decide
theorem prime_m1193 : Nat.Prime (V 1193 1 1) := by unfold V; native_decide
theorem prime_m1195 : Nat.Prime (V 1195 2 1) := by unfold V; native_decide
theorem prime_m1199 : Nat.Prime (V 1199 1 0) := by unfold V; native_decide
theorem prime_m1201 : Nat.Prime (V 1201 1 1) := by unfold V; native_decide
theorem prime_m1205 : Nat.Prime (V 1205 1 0) := by unfold V; native_decide
theorem prime_m1207 : Nat.Prime (V 1207 1 1) := by unfold V; native_decide
theorem prime_m1211 : Nat.Prime (V 1211 1 0) := by unfold V; native_decide
theorem prime_m1213 : Nat.Prime (V 1213 2 1) := by unfold V; native_decide
theorem prime_m1217 : Nat.Prime (V 1217 1 3) := by unfold V; native_decide
theorem prime_m1219 : Nat.Prime (V 1219 2 0) := by unfold V; native_decide
theorem prime_m1223 : Nat.Prime (V 1223 1 0) := by unfold V; native_decide
theorem prime_m1225 : Nat.Prime (V 1225 1 1) := by unfold V; native_decide
theorem prime_m1229 : Nat.Prime (V 1229 1 0) := by unfold V; native_decide
theorem prime_m1231 : Nat.Prime (V 1231 1 2) := by unfold V; native_decide
theorem prime_m1235 : Nat.Prime (V 1235 1 1) := by unfold V; native_decide
theorem prime_m1237 : Nat.Prime (V 1237 2 2) := by unfold V; native_decide
theorem prime_m1241 : Nat.Prime (V 1241 3 0) := by unfold V; native_decide
theorem prime_m1243 : Nat.Prime (V 1243 1 1) := by unfold V; native_decide
theorem prime_m1247 : Nat.Prime (V 1247 1 2) := by unfold V; native_decide
theorem prime_m1249 : Nat.Prime (V 1249 1 2) := by unfold V; native_decide
theorem prime_m1253 : Nat.Prime (V 1253 1 4) := by unfold V; native_decide
theorem prime_m1255 : Nat.Prime (V 1255 2 0) := by unfold V; native_decide
theorem prime_m1259 : Nat.Prime (V 1259 1 3) := by unfold V; native_decide
theorem prime_m1261 : Nat.Prime (V 1261 1 2) := by unfold V; native_decide
theorem prime_m1265 : Nat.Prime (V 1265 1 0) := by unfold V; native_decide
theorem prime_m1267 : Nat.Prime (V 1267 1 1) := by unfold V; native_decide
theorem prime_m1271 : Nat.Prime (V 1271 1 0) := by unfold V; native_decide
theorem prime_m1273 : Nat.Prime (V 1273 1 1) := by unfold V; native_decide
theorem prime_m1277 : Nat.Prime (V 1277 3 1) := by unfold V; native_decide
theorem prime_m1279 : Nat.Prime (V 1279 2 1) := by unfold V; native_decide
theorem prime_m1283 : Nat.Prime (V 1283 1 1) := by unfold V; native_decide
theorem prime_m1285 : Nat.Prime (V 1285 1 2) := by unfold V; native_decide
theorem prime_m1289 : Nat.Prime (V 1289 1 0) := by unfold V; native_decide
theorem prime_m1291 : Nat.Prime (V 1291 2 1) := by unfold V; native_decide
theorem prime_m1295 : Nat.Prime (V 1295 1 0) := by unfold V; native_decide
theorem prime_m1297 : Nat.Prime (V 1297 2 0) := by unfold V; native_decide
theorem prime_m1301 : Nat.Prime (V 1301 5 1) := by unfold V; native_decide
theorem prime_m1303 : Nat.Prime (V 1303 4 0) := by unfold V; native_decide
theorem prime_m1307 : Nat.Prime (V 1307 3 0) := by unfold V; native_decide
theorem prime_m1309 : Nat.Prime (V 1309 2 0) := by unfold V; native_decide
theorem prime_m1313 : Nat.Prime (V 1313 1 1) := by unfold V; native_decide
theorem prime_m1315 : Nat.Prime (V 1315 2 0) := by unfold V; native_decide
theorem prime_m1319 : Nat.Prime (V 1319 1 2) := by unfold V; native_decide
theorem prime_m1321 : Nat.Prime (V 1321 1 1) := by unfold V; native_decide
theorem prime_m1325 : Nat.Prime (V 1325 1 1) := by unfold V; native_decide
theorem prime_m1327 : Nat.Prime (V 1327 1 1) := by unfold V; native_decide
theorem prime_m1331 : Nat.Prime (V 1331 1 0) := by unfold V; native_decide
theorem prime_m1333 : Nat.Prime (V 1333 2 0) := by unfold V; native_decide
theorem prime_m1337 : Nat.Prime (V 1337 3 1) := by unfold V; native_decide
theorem prime_m1339 : Nat.Prime (V 1339 1 2) := by unfold V; native_decide
theorem prime_m1343 : Nat.Prime (V 1343 1 0) := by unfold V; native_decide
theorem prime_m1345 : Nat.Prime (V 1345 2 0) := by unfold V; native_decide
theorem prime_m1349 : Nat.Prime (V 1349 1 0) := by unfold V; native_decide
theorem prime_m1351 : Nat.Prime (V 1351 4 0) := by unfold V; native_decide
theorem prime_m1355 : Nat.Prime (V 1355 1 0) := by unfold V; native_decide
theorem prime_m1357 : Nat.Prime (V 1357 3 1) := by unfold V; native_decide
theorem prime_m1361 : Nat.Prime (V 1361 1 1) := by unfold V; native_decide
theorem prime_m1363 : Nat.Prime (V 1363 1 1) := by unfold V; native_decide
theorem prime_m1367 : Nat.Prime (V 1367 3 0) := by unfold V; native_decide
theorem prime_m1369 : Nat.Prime (V 1369 2 0) := by unfold V; native_decide
theorem prime_m1373 : Nat.Prime (V 1373 2 1) := by unfold V; native_decide
theorem prime_m1375 : Nat.Prime (V 1375 2 0) := by unfold V; native_decide
theorem prime_m1379 : Nat.Prime (V 1379 2 3) := by unfold V; native_decide
theorem prime_m1381 : Nat.Prime (V 1381 1 1) := by unfold V; native_decide
theorem prime_m1385 : Nat.Prime (V 1385 1 1) := by unfold V; native_decide
theorem prime_m1387 : Nat.Prime (V 1387 1 2) := by unfold V; native_decide
theorem prime_m1391 : Nat.Prime (V 1391 2 1) := by unfold V; native_decide
theorem prime_m1393 : Nat.Prime (V 1393 2 0) := by unfold V; native_decide
theorem prime_m1397 : Nat.Prime (V 1397 1 2) := by unfold V; native_decide
theorem prime_m1399 : Nat.Prime (V 1399 1 2) := by unfold V; native_decide
theorem prime_m1403 : Nat.Prime (V 1403 1 1) := by unfold V; native_decide
theorem prime_m1405 : Nat.Prime (V 1405 1 1) := by unfold V; native_decide
theorem prime_m1409 : Nat.Prime (V 1409 1 0) := by unfold V; native_decide
theorem prime_m1411 : Nat.Prime (V 1411 1 1) := by unfold V; native_decide
theorem prime_m1415 : Nat.Prime (V 1415 1 2) := by unfold V; native_decide
theorem prime_m1417 : Nat.Prime (V 1417 2 0) := by unfold V; native_decide
theorem prime_m1421 : Nat.Prime (V 1421 1 0) := by unfold V; native_decide
theorem prime_m1423 : Nat.Prime (V 1423 1 1) := by unfold V; native_decide
theorem prime_m1427 : Nat.Prime (V 1427 1 1) := by unfold V; native_decide
theorem prime_m1429 : Nat.Prime (V 1429 2 0) := by unfold V; native_decide
theorem prime_m1433 : Nat.Prime (V 1433 1 1) := by unfold V; native_decide
theorem prime_m1435 : Nat.Prime (V 1435 2 0) := by unfold V; native_decide
theorem prime_m1439 : Nat.Prime (V 1439 1 0) := by unfold V; native_decide
theorem prime_m1441 : Nat.Prime (V 1441 1 1) := by unfold V; native_decide
theorem prime_m1445 : Nat.Prime (V 1445 2 1) := by unfold V; native_decide
theorem prime_m1447 : Nat.Prime (V 1447 1 3) := by unfold V; native_decide
theorem prime_m1451 : Nat.Prime (V 1451 1 0) := by unfold V; native_decide
theorem prime_m1453 : Nat.Prime (V 1453 1 1) := by unfold V; native_decide
theorem prime_m1457 : Nat.Prime (V 1457 1 2) := by unfold V; native_decide
theorem prime_m1459 : Nat.Prime (V 1459 1 2) := by unfold V; native_decide
theorem prime_m1463 : Nat.Prime (V 1463 1 0) := by unfold V; native_decide
theorem prime_m1465 : Nat.Prime (V 1465 2 0) := by unfold V; native_decide
theorem prime_m1469 : Nat.Prime (V 1469 1 0) := by unfold V; native_decide
theorem prime_m1471 : Nat.Prime (V 1471 1 2) := by unfold V; native_decide
theorem prime_m1475 : Nat.Prime (V 1475 3 0) := by unfold V; native_decide
theorem prime_m1477 : Nat.Prime (V 1477 1 1) := by unfold V; native_decide
theorem prime_m1481 : Nat.Prime (V 1481 1 0) := by unfold V; native_decide
theorem prime_m1483 : Nat.Prime (V 1483 3 1) := by unfold V; native_decide
theorem prime_m1487 : Nat.Prime (V 1487 1 1) := by unfold V; native_decide
theorem prime_m1489 : Nat.Prime (V 1489 1 3) := by unfold V; native_decide
theorem prime_m1493 : Nat.Prime (V 1493 1 4) := by unfold V; native_decide
theorem prime_m1495 : Nat.Prime (V 1495 1 1) := by unfold V; native_decide
theorem prime_m1499 : Nat.Prime (V 1499 1 0) := by unfold V; native_decide

end EG203DirectPrimeWitness1500
