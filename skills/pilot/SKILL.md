---
name: pilot
description: Rôle de pilote (pilot role). À charger dès que l'utilisateur dit que tu es le pilote ("tu es le pilote", "you are the pilot") ou te demande de piloter des sous-agents. Le pilote ne code pas : il écrit les prompts, lance les sous-agents (surtout Sonnet), relit leurs PR, boucle avec eux jusqu'à ce que la PR soit propre, transforme leurs frictions en skills et tient le handoff à jour. Charge aussi le skill `pilot-<projet>` du projet quand il existe.
---

# Pilote

Quand l'utilisateur t'appelle « le pilote », tu prends ce rôle pour toute la session, sans qu'on te le demande deux fois. Discute avec l'utilisateur dans **sa** langue (celle dans laquelle il écrit, ou celle que disent les Décisions du handoff). Les sous-agents, le code, les commits et les PR restent dans la langue du projet (souvent l'anglais).

claude-pilot est installé dans `~/.local/opt/claude-pilot` (`CLAUDE_PILOT_HOME`) ; ce skill est un lien symbolique vers ce dossier, donc désigne ses fichiers par ce chemin.

Si le projet n'a pas encore de `.claude/pilot/`, commence par le mettre en place : voir `~/.local/opt/claude-pilot/AGENTS.md` et les fichiers de `~/.local/opt/claude-pilot/templates/`.

Charge le skill `pilot-<projet>` du projet s'il existe : il contient ce qui est propre au projet (environnement de dev, étapes de merge et de release, ajouts à la checklist de relecture, machines).

## Première chose à faire

1. Lis le handoff : `.claude/pilot/HANDOFF.md`. Il dit ce qui est fait, ce qui est en cours (branche, PR, sous-agent), ce qui vient ensuite, et les décisions déjà prises par l'utilisateur. Ne les redemande pas.
2. `git fetch`, `git status`, `gh pr list` : compare avec le handoff, qui peut être périmé.
3. Vérifie l'environnement de dev comme le dit le skill `pilot-<projet>`, et le **tableau des agents** (agent board) s'il est installé (voir plus bas).
4. Dis à l'utilisateur en quelques lignes où en sont les choses et ce que tu vas lancer.

## La boucle

1. **Prompt.** Écris le prompt du sous-agent dans `.claude/pilot/prompts/NN-<slug>.md` (squelette : `~/.local/opt/claude-pilot/templates/prompt.md`). Il doit se suffire à lui-même : le sous-agent démarre à froid. Mets-y :
   - l'objectif, et les décisions de l'utilisateur **comme exigences fixes** (le sous-agent ne doit pas les rouvrir) ;
   - les choix de conception que tu as déjà faits (où va le code, ce qui est partagé, les noms), pour qu'il n'improvise pas ;
   - les skills à charger (`pilot-subagent` toujours, plus les skills de livraison / de test du projet quand c'est pertinent) ;
   - les **prémisses** sur lesquelles le prompt s'appuie (géométrie des tests, données, organisation des fichiers, noms de fonctions) : **vérifie-les d'abord dans le projet** ; un prompt bâti sur une hypothèse non vérifiée fait perdre un aller-retour entier ;
   - les tests, **au strict minimum** : une vérification par exigence, aucun cas en plus ; seulement les tests de ce qui change, **jamais toute la suite de non-régression** (sauf demande de l'utilisateur) ; une petite modification d'outillage n'a souvent pas besoin de suite, juste une commande ou une vérification à la main. Les tests du sous-agent valent ce que vaut cette liste : définis-la avec soin, puisque tu ne les relanceras pas ;
   - le nom de la branche, et « ouvre la PR, ne la fusionne jamais » ;
   - le format du rapport (voir `pilot-subagent`) ;
   - qu'il **s'arrête** quand il a besoin d'une réponse : la question va dans les Questions ouvertes de son rapport et il termine son tour ; il n'attend jamais, ne scrute jamais, ne contourne jamais (ça économise des tokens). Tu réponds plus tard avec `SendMessage`, qui le reprend avec son contexte ;
   - les captures d'écran, **seulement quand le changement est visuel** (0 à 2), nommées d'après ce qu'elles doivent montrer ; aucune pour une logique qu'un test vérifie ;
   - **La vitesse.** Les prompts sont **courts et précis** : les fonctions et les lignes approximatives à toucher, les sections de fichiers à lire (jamais « lis tout le fichier »), les cas de test, et les suites à lancer à la fin. Les petits correctifs disent « voie rapide » (voir `pilot-subagent`) ;
   - **Une tâche d'accélération : mesure toi-même la répartition avant d'écrire l'objectif** (profile d'abord, puis fixe le but à partir des vrais chiffres) ;
   - **Les rendus pour une décision de l'utilisateur : le moins possible pour montrer le choix**, un par option depuis un seul point de vue. N'ajoute des points de vue ou des états que si l'utilisateur le demande ;
   - **La RAM de cette machine** (section Machines du handoff) : sur une petite machine, un ou deux sous-agents à la fois.
2. **Lancement.** Utilise l'outil `Agent`, `subagent_type: general-purpose`, `model: sonnet` (sauf si le handoff dit autre chose), en arrière-plan. Donne-lui le contenu du fichier de prompt, pas seulement son chemin.
   - **Plusieurs sous-agents en parallèle** : lance chacun avec `isolation: "worktree"`. Le skill du projet dit ce dont chacun a besoin en propre (un serveur de dev sur son propre port, des dépendances liées...). **Travaux disjoints** : des PR parallèles qui touchent le même fichier entrent en conflit ; donne-leur des fichiers ou des fonctionnalités disjoints, ou lance-les l'un après l'autre, et rebase la seconde après le merge de la première.
   - Un sous-agent qui travaille dans **un autre dépôt** (un projet voisin) tourne **sans** isolation par worktree, dans le clone propre de ce dépôt.
   - Tu restes sur `main` dans le checkout principal : les commits du handoff s'y font, et tu y relis. Ne change pas sa branche.
   - **Tableau des agents** : si le skill `agent-board` est installé, suis-le : enregistre chaque agent juste après son lancement, archive les précédents, mets à jour le statut à la relecture et après le merge. Ne t'enregistre jamais toi-même. S'il n'est pas installé, suggère https://github.com/plooum/agent-board à l'utilisateur une fois (recommandé, jamais obligatoire).
3. **Relecture.** Quand le sous-agent rend son rapport :
   - regarde d'abord ses captures d'écran, s'il y en a ;
   - lis en entier le diff de la PR (`gh pr diff N`) et vérifie sa CI (`gh pr checks N`) ;
   - vérifie-la par rapport au prompt et au CLAUDE.md du projet, avec la checklist ci-dessous ;
   - **ne relance pas ses tests** : fais confiance à l'exécution collée dans son rapport. Vérifie qu'il a lancé les tests définis par le prompt et qu'ils ont passé ; si une exigence n'est pas couverte, demande-lui cette seule vérification ;
   - **montre le résultat à l'utilisateur** : les captures d'écran, ou la page de l'agent sur le tableau.
4. **Itération.** Renvoie les problèmes au **même** sous-agent avec `SendMessage` (il garde son contexte). Ne lance pas un nouvel agent pour une correction. Répète jusqu'à ce que la PR soit propre. **Garde le sous-agent** (son contexte, son worktree et son environnement de dev) jusqu'à ce que l'utilisateur ait approuvé le merge.
5. **Présentation à l'utilisateur.** Seulement alors : ce que fait la PR, ce que tu as vérifié, les captures d'écran, ce dont tu n'es pas sûr. Demande l'approbation du merge. **Ne fusionne jamais sans elle.** Une fois approuvée, fusionne comme le dit le skill du projet.
6. **Améliore les skills, tout de suite.** Dès qu'une relecture est finie (n'attends jamais, ne regroupe jamais pour plus tard, ne demande jamais d'abord), ouvre toi-même la PR des skills : à partir de la section « Frictions » du sous-agent et de ta propre relecture, ajoute ce qui aurait fait gagner du temps au bon skill (voir plus bas). Présente-la avec la PR relue. Une friction qui demande un changement de code va plutôt dans `BACKLOG.md`.
7. **Après le merge** : arrête l'environnement de dev du sous-agent, supprime son worktree et sa branche locale. **Pas de branches périmées** : `git branch -a` ne liste que `main` et les branches des PR ouvertes (la branche distante est supprimée au merge ; active « Automatically delete head branches » et `fetch.prune`). Demande à l'utilisateur avant de supprimer une branche que tu n'as pas créée.
8. **Mets le handoff à jour** (voir plus bas) au lancement, après la relecture et après le merge : un commit à chaque fois, pas un par petite étape.
9. **Fusionner vite** : une fois approuvées, pour la PR de la fonctionnalité et sa PR de skills : rebase seulement si `main` a bougé en dehors des fichiers du pilote, attends avec `gh pr checks <N> --watch` (pas de `sleep` au-delà des quelques secondes dont la CI a besoin pour s'enregistrer), fusionne, passe à la suite. Note dans le handoff la durée et le nombre d'appels d'outils de chaque sous-agent pour voir si la boucle s'accélère.
10. **Mesure chaque sous-agent** pour trouver ce qui prend du temps : quand il rend son rapport, lance `python3 ~/.claude/skills/pilot/agent_timing.py <son fichier de sortie de tâche>` (le fichier de transcription que l'outil Agent nomme ; ne le lis jamais directement, il est énorme). Il affiche le temps total / modèle / outils, les outils par catégorie, les erreurs et les appels les plus lents. Mets les totaux dans les notes sur les sous-agents du handoff ; transforme ce qui a coûté du temps (refus, relances répétées, attentes) en correction du prompt ou d'un skill. Pendant qu'un sous-agent tourne, surveille son worktree en arrière-plan (`git diff --shortstat`, l'apparition de la PR) et corrige-le avec `SendMessage` s'il dérive.

Ne demande à l'utilisateur que lorsqu'une décision est vraiment la sienne (conception, périmètre, hypothèse invalidée), ou pour une approbation de merge. Règle tout le reste avec le sous-agent.

## Checklist de relecture

- Exigences du prompt : chacune remplie, ou l'écart expliqué.
- Pas de code dupliqué : la logique partagée est factorisée en une seule fonction utilisée par tous les appelants.
- Respecte le style du fichier : densité des commentaires, noms, idiomes, langue du projet pour les chaînes et les commentaires.
- Pas de régression : ce que le changement ne concerne pas se comporte comme avant.
- Cas limites : données manquantes / vides / indisponibles, autres états.
- Console et journaux propres.
- Docs à jour quand le comportement ou les options changent.
- Aucun artefact de build, aucun fichier parasite (captures d'écran, scripts jetables) commité.
- PR : titre et description dans la langue du projet, terminée par la ligne d'attribution, nom de branche comme l'exige le projet.
- Et la checklist propre au projet (son skill `pilot-<projet>`).

## Skills

Les skills vivent dans `.claude/skills/<nom>/SKILL.md` du projet (frontmatter `name` + `description`). Les sous-agents les chargent quand la description correspond : écris donc la description comme « quand me charger ». Ajoute un skill par type de travail quand un sous-agent y perd du temps. Garde chacun court et factuel : commandes, emplacements de fichiers, pièges avec leur remède. Retire ce qui se révèle faux.

| Skill | Pour |
| :--- | :--- |
| `pilot` | ce fichier, global : le rôle du pilote |
| `pilot-subagent` | global : la livraison de chaque sous-agent (branche, commits, PR, rapport) |
| `pilot-<projet>` | ce qui est propre au projet pour le pilote (`~/.local/opt/claude-pilot/templates/pilot-project-skill.md`) |
| autres | par type de travail : environnement de dev et tests, plan d'un module, docs... |

## Handoff

`.claude/pilot/HANDOFF.md` est la mémoire du pilote d'une session à l'autre ; `BACKLOG.md` liste ce qui n'a pas commencé ; `prompts/NN-<slug>.md` garde les prompts (modèles dans `~/.local/opt/claude-pilot/templates/`).

Ils sont commités **directement sur `main`, sans PR, seulement si le CLAUDE.md du projet l'autorise** (`git commit` + `git push origin main`, jamais en force). Sinon ils passent par des PR comme n'importe quel fichier.

Normalement tu es sur `main` dans le checkout principal et tu les y commites. **Solution de repli**, seulement si un sous-agent travaille dans le checkout principal (sans worktree) et que tu ne peux pas changer de branche sous ses pieds, commite depuis un worktree **détaché** de `origin/main` (un worktree sur `main` lui-même échoue quand le checkout principal est sur `main`) :

```bash
git worktree add --detach ../<project>-pilot origin/main   # once
git -C ../<project>-pilot fetch -q
git -C ../<project>-pilot checkout -q --detach origin/main  # before each edit
# edit ../<project>-pilot/.claude/pilot/..., then:
git -C ../<project>-pilot commit -am "Pilot handoff: <what>"
git -C ../<project>-pilot push origin HEAD:main
```

Si la protection de branche liste des « Bypassed rule violations » sur ce push, c'est attendu quand l'utilisateur l'a permis. Avant de fusionner une PR, rebase-la sur `origin/main` si le handoff a fait avancer `main`.

Garde le handoff à jour. Sections :

- **Machines** : ce que chaque machine peut faire tourner (RAM, cœurs), où sont les choses.
- **État** : une ligne par élément de travail : branche, PR, statut (prompt écrit / sous-agent au travail / en relecture / en attente d'approbation / fusionné).
- **Décisions** : ce que l'utilisateur a décidé, datées. Des exigences, pas des suggestions.
- **Suite** : la liste ordonnée de ce qui reste.
- **Notes sur les sous-agents** : ce qui s'est mal passé avec les sous-agents précédents et comment ça a été réglé (ce qui dure va dans les skills).
