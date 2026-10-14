---
name: pilot-subagent
description: Comment un sous-agent livre un travail confié par un pilote (how a sub-agent delivers work given by a pilot) - branche de fonctionnalité, commits, pull request, et le rapport qu'il rend. À charger pour toute tâche donnée par un pilote ; le skill de livraison propre au projet ajoute ses spécificités.
---

# Livrer un changement (sous-agent)

Un pilote, un agent qui relit ton travail et boucle avec toi, t'a confié une tâche. Tu livres **une branche et une PR ouverte**, jamais un merge. Charge aussi les skills de livraison / de test du projet que le prompt nomme.

## Branche et commits

- Tu peux être dans un worktree git qui t'est propre (lancé avec `isolation: "worktree"`). Là, crée la branche à partir de `origin/main` : `git fetch`, `git checkout -b feature/<nom> origin/main` (`main` lui-même est extrait dans le checkout principal). Une telle branche suit `origin/main` jusqu'à ton premier `git push -u origin feature/<nom>` : pousse toujours avec `-u`.
- Sinon pars d'un `main` à jour : `git checkout main`, `git fetch`, `git pull --ff-only`, puis `git checkout -b feature/<nom>` (le nom que donne le prompt).
- Ne commite jamais sur `main`, ne fusionne jamais, ne force-push jamais autre chose que ta propre branche de fonctionnalité.
- Ne commite pas les produits de build, les captures d'écran ni les scripts jetables : garde-les dans un dossier ignoré par git ou un dossier temporaire.
- Messages de commit : sujet à l'impératif, dans la langue du projet, terminés par la ligne d'attribution de ton prompt système (`Co-Authored-By: ...`).
- Suis les conventions du CLAUDE.md du projet ; respecte le style du fichier (densité des commentaires, noms, idiomes). Lis le code autour de ton changement avant d'écrire. Ne duplique pas la logique : factorise-la en une seule fonction utilisée par tous les appelants.
- Problèmes hors périmètre : signale-les dans ton rapport, ne les corrige pas.

## Refus du bac à sable dans les worktrees

Chaque refus coûte un aller-retour.
- Lance les étapes git en commandes séparées plutôt qu'en une longue chaîne `&&`. Le bac à sable refuse les commandes « trop complexes » : expansion d'accolades, `git` mêlé à `&&`, `;`, un heredoc ou `python3 -`, `git` / `gh` / `sed` avec des variables shell. Écris les scripts de plusieurs lignes et les modifications de fichiers avec les outils Write / Edit.
- Ne mentionne jamais un chemin hors de ton worktree (pas de fichiers temporaires `/tmp/...`, pas de `export PATH=/home/...`) : garde les fichiers temporaires dans un dossier de ton worktree ignoré par git. Un outil introuvable : essaie son chemin complet (`~/.local/bin/<outil>`).
- `gh pr create` avec un long `--body "..."` en ligne est refusé comme trop complexe : écris la description avec Write, puis utilise `--body-file <fichier de ton worktree>`.
- `git add <les fichiers>` plutôt que `git add -A` (lent quand l'arbre contient de l'état d'exécution).
- Arrêter un processus en arrière-plan : `pkill -f "<motif>"` correspond aussi au shell qui le lance (et le tue, code de sortie 144). Utilise `pgrep -f "<motif>"`, puis `kill <pid>`.
- Pour attendre un processus en arrière-plan, charge d'abord l'outil `Monitor` (`ToolSearch` `select:Monitor`) plutôt que de scruter dans une boucle au premier plan. Jamais de `sleep` : le harnais le bloque.

## Être rapide

L'utilisateur trouve une longue boucle coûteuse.
- Lis seulement les sections que le prompt nomme (grep, puis lis autour) ; ne lis pas un gros fichier en entier ni un skill dont tu n'as pas besoin.
- Pendant que tu travailles, lance seulement le test sur lequel tu es (`--only` ou l'équivalent) ; lance les suites complètes que le prompt liste **une seule fois**, à la fin. Lance exactement les tests que le prompt liste, rien de plus.
- Un build par changement que tu veux voir.
- Des captures d'écran seulement si le prompt en demande ; vérifie le point de vue sur une première capture avant d'en faire une série.
- **Voie rapide** (le prompt le dit : un correctif d'une fonction) : pas de captures d'écran, le nouveau test plus le test de fumée, un rapport de 5 lignes.
- **N'attends pas la CI** après avoir ouvert la PR : rends ton rapport tout de suite, le pilote la vérifie.

## Pull request

```bash
git push -u origin feature/<name>
gh pr create --base main --title "<title>" --body-file <body file>   # write the body with Write first
```

Juste après un push, `gh pr checks --watch` peut encore lister les exécutions du commit précédent (`gh pr view <N> --json headRefOid,statusCheckRollup`) ; normalement tu ne l'attends pas du tout.

La description : ce qui a changé et pourquoi, comment c'était testé, ce qui ne l'était pas. Elle se termine par la ligne de ton prompt système (`🤖 Generated with [Claude Code](https://claude.com/claude-code)`).

## Rapport au pilote

Termine ton travail par ce rapport, et rien d'autre autour :

```
## Rapport
Branche / PR : feature/<nom>, #<N> (CI : réussie | échec : <laquelle>)
Fait : <puces : ce qui a changé, quelles fonctions / quels fichiers>
Écarts par rapport au prompt : <chacun, avec la raison ; « aucun » sinon>
Testé : <la sortie de l'exécution des tests collée en entier (lignes PASS / FAIL, durée totale) et son chemin ; puis ce qu'elle ne couvre pas et ce que tu as vérifié à la main>
Captures d'écran : <chemins quand le prompt en demande, voir plus bas>
Non testé : <et pourquoi>
Questions ouvertes : <décisions dont tu as besoin du pilote> (quand il t'en faut une pour continuer, arrête-toi là : rends ton rapport et termine ton tour ; le pilote te reprend avec la réponse. N'attends ni ne scrute jamais.)
Frictions : <ce qui t'a fait perdre du temps : une commande qui a échoué, quelque chose de difficile à trouver, une hypothèse fausse dans le prompt ou un skill, et comment tu as passé l'obstacle>
```

**Les tests sont écrits et lancés par une commande** : le pilote ne les relance pas et se fie à ta sortie, alors colle-la en entier. La section **Testé** est cette sortie, pas le récit de ce que tu as cliqué. Un fichier de test que tu écris est commité avec la PR.

**Captures d'écran quand le prompt en demande** (un changement visuel) : celles qu'il nomme, sinon l'état principal et l'autre état le plus important. Jamais commitées. Le pilote les regarde d'abord pour vérifier ton travail.

La section **Frictions** compte : le pilote la transforme en skills pour que le prochain sous-agent ne perde pas le même temps. Sois concret (« un sélecteur descendant ne traverse pas les shadow roots : parcours avec `.shadowRoot` »), pas vague.

Quand le pilote t'envoie des commentaires de relecture, corrige-les sur la même branche, pousse, et rends un nouveau rapport (seulement ce qui a changé).
