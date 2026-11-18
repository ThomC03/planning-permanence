// Test local du solveur (extraction des fonctions pures de index.html)
"use strict";
const fs = require("fs");
const html = fs.readFileSync(__dirname + "/../index.html", "utf8");
const script = html.match(/<script>\n"use strict";([\s\S]*?)<\/script>/)[1];

// Extraire uniquement les fonctions nécessaires au solveur
const needed = [
  /const ADMIN_ID[\s\S]*?;/,
  /function iso\(d\)[\s\S]*?\n}/,
  /function daysOfMonth\(ym\)[\s\S]*?\n}/,
  /function solve\(ym, maxAlt\)[\s\S]*?\n}\n\nfunction generate/,
];
let code = "";
for (const re of needed) {
  const m = script.match(re);
  if (!m) { console.error("Extraction échouée pour", re); process.exit(1); }
  code += m[0].replace(/\n\nfunction generate$/, "\n") + "\n";
}
code = code.replace(/^const ADMIN_ID.*$/m, "");

const cache = { users: [], dispos: [], besoins: {} };
const state = { mois: "2025-11" };
function daysOfMonth(ym) {
  const [y, m] = ym.split("-").map(Number);
  const days = [];
  let d = new Date(y, m - 1, 1);
  while (d.getFullYear() === y && d.getMonth() === m - 1) { days.push(new Date(d)); d = new Date(y, m - 1, d.getDate() + 1); }
  return days;
}

// Scénario : 3 permanents, novembre 2025 (30 jours, 1er = samedi)
// Besoins : tout à 1, sauf 4 et 12 à 2 personnes, 5 fermé.
const ym = "2025-11";
const nbDays = 30;
for (let d = 1; d <= nbDays; d++) {
  const key = ym + "-" + String(d).padStart(2, "0");
  const weekday = new Date(2025, 10, d).getDay();
  if (d === 5) cache.besoins[key] = 0;
  else if (d === 4 || d === 12) cache.besoins[key] = 2;
  else cache.besoins[key] = 1;
}
function mkUser(id, nom, c) { return { id, nom, ...c }; }
const u1 = mkUser("u1", "Alice", { no_we: true, only_we: false, min_we: false, paired: false, max_days: 0 });
const u2 = mkUser("u2", "Bob", { no_we: false, only_we: false, min_we: true, paired: false, max_days: 0 });
const u3 = mkUser("u3", "Chloe", { no_we: false, only_we: false, min_we: false, paired: true, max_days: 0 });
cache.users = [u1, u2, u3];
// Dispos : Alice tous les jours (week-ends filtrés par contrainte), Bob tous, Chloé 3-14
for (let d = 1; d <= nbDays; d++) {
  const key = ym + "-" + String(d).padStart(2, "0");
  cache.dispos.push({ permanent_id: "u1", date: key });
  cache.dispos.push({ permanent_id: "u2", date: key });
  if (d >= 3 && d <= 14) cache.dispos.push({ permanent_id: "u3", date: key });
}

const solve = new Function("cache", "state", "iso", "daysOfMonth", "ADMIN_ID", code + "\nreturn solve;")(
  cache, state,
  d => d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0"),
  daysOfMonth, "__admin__"
);

const res = solve(ym, 3);
if (res.err) { console.error("ERREUR solve:", res.err); process.exit(1); }
console.log("Solutions:", res.solutions.length);

const sol = res.solutions[0];
let fails = [];
// Vérifications
const jours = {};
for (const [date, noms] of Object.entries(sol.assign)) for (const n of noms) jours[n] = (jours[n] || 0) + 1;
if (Object.keys(jours).length !== 3) fails.push("tous les permanents doivent avoir au moins 1 jour");
for (const [date, noms] of Object.entries(sol.assign)) {
  const b = cache.besoins[date];
  if (noms.length !== b) fails.push(`besoin non respecté le ${date} (${noms.length}/${b})`);
  if (new Set(noms).size !== noms.length) fails.push(`doublon le ${date}`);
}
// Alice : jamais de week-end
for (const [date, noms] of Object.entries(sol.assign)) {
  const d = new Date(date + "T00:00:00");
  if (noms.includes("Alice") && d.getDay() >= 6) fails.push("Alice un week-end");
}
// Bob : au moins 1 week-end
let bobWE = 0;
for (const [date, noms] of Object.entries(sol.assign)) {
  const d = new Date(date + "T00:00:00");
  if (noms.includes("Bob") && d.getDay() >= 6) bobWE++;
}
if (bobWE < 1) fails.push("Bob sans week-end (min_we)");
// Chloé : jours consécutifs uniquement
{
  const dates = Object.entries(sol.assign).filter(([, n]) => n.includes("Chloe")).map(([d]) => d).sort();
  for (const d of dates) {
    const prev = new Date(d + "T00:00:00"); prev.setDate(prev.getDate() - 1);
    const next = new Date(d + "T00:00:00"); next.setDate(next.getDate() + 1);
    const p = prev.toISOString().slice(0, 10), nx = next.toISOString().slice(0, 10);
    if (!dates.includes(p) && !dates.includes(nx)) fails.push("Chloé jour isolé (paired)");
  }
}
// Équité : écart max <= 1 entre charges (idéalement)
const loads = res.solutions[0].load;
if (Math.max(...loads) - Math.min(...loads) > 2) fails.push("répartition peu équitable: " + loads);

if (fails.length) { console.error("ÉCHECS:", fails); process.exit(1); }
console.log("✔ Solveur OK — charges:", loads.map((l, i) => res.personnes[i].nom + "=" + l).join(", "), "week-ends:", res.solutions[0].weLoad.join(","));

// Test impossible : une seule personne, besoin 2 un jour
cache.users = [u1];
cache.dispos = cache.dispos.filter(d => d.permanent_id === "u1");
const res2 = solve(ym, 3);
if (!res2.err) { console.error("Devrait échouer (1 personne, jour à 2)"); process.exit(1); }
console.log("✔ Détection d'impossibilité OK :", res2.err);

// Test : tous les jours marqués fermés → erreur explicite, aucune affectation
for (let d = 1; d <= nbDays; d++) cache.besoins[ym + "-" + String(d).padStart(2, "0")] = 0;
const res3 = solve(ym, 3);
if (!res3.err || !/ferm/i.test(res3.err)) { console.error("Devrait échouer avec un message 'fermés' :", res3.err || res3.solutions.length); process.exit(1); }
console.log("✔ Tous les jours fermés → message clair OK :", res3.err);
